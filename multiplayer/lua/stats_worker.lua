--Worker thread for stats database

return function(linda)
  function master_send(cmd, ...)
    linda:send("master_cmd", cmd, select("#", ...))
    linda:send("master_arg", ...)
  end

  local f = function()
    local sqlite3 = require("lsqlite3")
    local cfg = require("stats_cfg")
    require("util")

    local file_db --the actual sqlite file
    local mem_db --in-memory database object

    local backup_last_date = os.date("%Y-%m-%d")

    --Helper to cache statements
    local stmt_cache = {
      statements = {},

      prepare = function(self, query)
        local stmt = self.statements[query]
        if stmt and stmt:isopen() then
          stmt:reset()
          return stmt
        end

        stmt = mem_db:prepare(query)
        if not stmt then
          mlog(string.format("Error compiling statement, Code '%d', Msg '%s', Query:\n%s", mem_db:errcode(), mem_db:errmsg(), query), true)
        end
        self.statements[query] = stmt
        return stmt
      end,

      prep_n_bind = function(self, query, ...)
        local stmt = self:prepare(query)
        if not stmt then return end

        -- print(query, ...)
        stmt:bind_values(...)
        return stmt
      end,
    }

    function mlog(msg, show_in_console)
      master_send("call", "log", msg, show_in_console)
    end

    function mprint(...)
      master_send("print", ...)
    end

    function add_column(columnName, columnType, defaultValue)
      --check if the column exists
      for row in mem_db:nrows("PRAGMA table_info(users);") do
        if row.name == columnName then
          return
        end
      end

      --If the column does not exist, add it
      local result = mem_db:exec(string.format("ALTER TABLE users ADD COLUMN %s %s DEFAULT %s;", columnName, columnType, defaultValue))
      if result ~= sqlite3.OK then
        mlog("mem_db add column error, Code: " .. mem_db:errcode() .. ", " .. mem_db:errmsg(), true)
      end
    end

    --Load stats.sqlite3 from disk and copy to in-memory mem_db
    function load_db ()
      mlog("Opening stats.sqlite3", true)

      file_db, errcode, errmsg = sqlite3.open(cfg.db_path)
      if not file_db then
        mlog("Error opening stats.sqlite3, Code " .. errcode .. ", " .. errmsg, true)
        return
      end

      mem_db = sqlite3.open_memory()

      --Copy the contents of the file database to the in-memory database
      local backup = sqlite3.backup_init(mem_db, "main", file_db, "main")
      if not backup then
        mlog("Error copying file_db to in-memory db, Code: " .. mem_db:errcode() .. ", " .. mem_db:errmsg(), true)
        return
      else
        local step_result = backup:step(-1)
        if step_result ~= sqlite3.DONE then
          mlog("Error during backup step: " .. mem_db:errmsg(), true)
          backup:finish() -- Ensure to finish the backup even on error
          return
        end

        backup:finish()
      end

      if mem_db:exec(cfg.init_query) ~= sqlite3.OK then
        mlog("mem_db init error, Code: " .. mem_db:errcode() .. ", " .. mem_db:errmsg(), true)
        return
      end

      for _, v in ipairs(cfg.new_columns) do
        add_column(v.column, v.type, v.default)
      end
    end

    --returns success
    function create_backup()
      if cfg.num_backups <= 0 then return true end
      if not file_exists(cfg.db_path) then return end

      local last_file = cfg.backup_folder .. "stats_backup_" .. cfg.num_backups .. ".sqlite3"
      if file_exists(last_file) then
        local ok, errmsg = os.remove(last_file)
        if not ok then
          mlog("Backup error, " .. errmsg)
          return false
        end
      end

      for i = (cfg.num_backups - 1), 1, -1 do
        local fl = cfg.backup_folder .. "stats_backup_" .. i     .. ".sqlite3"
        if file_exists(fl) then
          local fh = cfg.backup_folder .. "stats_backup_" .. i + 1 .. ".sqlite3"
          
          local ok, errmsg = os.rename(fl, fh)
          if not ok then
            mlog("Backup error, " .. errmsg)
            return false
          end
        end
      end

      local ok, errmsg = file_copy(cfg.db_path, cfg.backup_folder .. "stats_backup_1.sqlite3")
      if not ok then
        mlog("Backup error, " .. errmsg)
        return false
      end

      return true
    end

    function flush_to_file()
      --before doying anything, we want to make a daily backup of stats.sqlite3
      local date = os.date("%Y-%m-%d")
      if date ~= backup_last_date then
        if create_backup() then
          backup_last_date = date
        end
      end

      --now we flush the memory db to the file
      local backup = sqlite3.backup_init(file_db, "main", mem_db, "main")
      if not backup then
        mlog("Error copying in-memory db to file_db , " .. mem_db:errmsg(), true)
        return
      end

      local step_result = backup:step(-1)
      if step_result ~= sqlite3.DONE then
        mlog("Error during backup step: " .. file_db:errmsg(), true)
        backup:finish() -- Ensure to finish the backup even on error
        return
      end

      backup:finish()
    end

    --SELECT COUNT(*) AS count FROM ... where ...
    function test_row_exist(query, ...)
      local stmt = stmt_cache:prep_n_bind(query, ...)
      if not stmt then return false end

      if stmt:step() == sqlite3.ROW then
          local count = stmt:get_value(0)
          return count > 0
      end

      return false
    end

    --return true if uid in db
    function user_exists(uid)
      return test_row_exist("SELECT COUNT(*) AS count FROM users WHERE id = ?;", uid)
    end

    --if user not in db, create him
    function user_init(uid)
      if not user_exists(uid) then
        local query = "INSERT INTO users (id) VALUES (?);"
        local stmt = stmt_cache:prep_n_bind(query, uid)
        if not stmt then return end

        stmt:step()
      end
    end

    --increment uid.value
    function user_inc_value(uid, column_name, amount)
      amount = amount or 1

      local query = string.format("UPDATE users SET %s = %s + ? WHERE id = ?", column_name, column_name)
      local stmt = stmt_cache:prep_n_bind(query, amount, uid)
      if not stmt then return end

      stmt:step()
    end

    function query_stats(uid)
      local stmt = stmt_cache:prep_n_bind(cfg.stats_query, uid)
      if not stmt then return end

      local result = stmt:step()

      if result ~= sqlite3.ROW then return end

      local res = {}
      for i = 0, stmt:columns() - 1 do
        table.insert(res, {column = stmt:get_name(i), val = stmt:get_value(i)})
      end
      return res
    end

    function query_duelstats(uid)
      local stmt = stmt_cache:prep_n_bind(cfg.duelstats_query, uid)
      if not stmt then return end

      local result = stmt:step()

      if result ~= sqlite3.ROW then return end
      return stmt:get_named_values()
    end

    function rows(query)
      local results = {}
      for row in mem_db:rows(query) do
          table.insert(results, row)
      end
      return results
    end

    function on_user_joined(uid, username, ip, date)
      user_init(uid)

      local stmt = stmt_cache:prep_n_bind("UPDATE users SET last_username = ?, last_ip = ?, last_date_online = ? WHERE id = ?;", 
        username, ip, date, uid)

      if not stmt then return end
      stmt:step()

      --add known username
      if not test_row_exist("SELECT COUNT(*) AS count FROM known_user_names WHERE user_id = ? AND known_username = ?;", uid, username) then
        stmt = stmt_cache:prep_n_bind("INSERT INTO known_user_names (user_id, known_username) VALUES (?, ?)", uid, username)
        stmt:step()
      end
    end

    function on_user_leave(uid, date, seconds_online)
      local stmt = stmt_cache:prep_n_bind("UPDATE users SET last_date_online = ? WHERE id = ?;", date, uid)
      if not stmt then return end

      stmt:step()
      user_inc_value(uid, "seconds_online", seconds_online)
    end

    load_db()

    --Message Loop
    while true do
      local key, cmd, arg_count = linda:receive(nil, linda.batched, "worker_cmd", 2, 2)
      if not cmd then return end
      -- mprint(string.format("worker received cmd '%s', %d args", cmd, arg_count))

      local args = {select(2, linda:receive(nil, linda.batched, "worker_arg", arg_count, arg_count))} --select to get rid of key
      -- mprint("args:", unpack(args))

      if cmd == "call" then
        local f = getfenv()[args[1]]
        f(unpack(args, 2))

      elseif cmd == "retcall" then
        --arg1 is return id, arg2 funcname, arg3 and up are arguments
        local f = getfenv()[args[2]]
        master_send("ret", args[1], f(unpack(args, 3)))
      
      elseif cmd == "ping" then
        master_send("call", "print", "pong")
      end
    end
  end

  local ok, err = pcall(f)
  if not ok then master_send("err", err) end
end