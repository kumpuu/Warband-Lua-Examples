local cfg = require("stats_cfg")

-------------------------------------------------------------------------------------------- Worker Stuff
local linda = lanes.linda()
lanes.gen("*", require "stats_worker")(linda)


--Helper to communicate with worker thread
local worker
worker = {
  send = function(cmd, ...)
    linda:send("worker_cmd", cmd, select("#", ...))
    linda:send("worker_arg", ...)
  end,

  call = setmetatable({}, {
    __index = function(t, func)
      return function(...)
        worker.send("call", func, ...)
      end
    end
  }),

  --this returns a promise
  callbacks = {},
  rcall = setmetatable({}, {
    __index = function(t, func)
      return function(...)
        local args = {...}
        return {
          next = function(callback)
            local i = 1
            while worker.callbacks[i] ~= nil do i = i + 1 end
            worker.callbacks[i] = callback

            worker.send("retcall", i, func, unpack(args))
          end
        }
      end
    end
  }),

  handle_messages = function()
    local key, cmd, arg_count = linda:receive(0, linda.batched, "master_cmd", 2, 2)
    if not cmd then return end
    -- print(string.format("master received cmd '%s', %d args", cmd, arg_count))

    local args = {select(2, linda:receive(nil, linda.batched, "master_arg", arg_count, arg_count))} --select to get rid of key

    -- print("args:", unpack(args))

    if cmd == "call" then
      _G[args[1]](unpack(args, 2))

    elseif cmd == "ret" then
      worker.callbacks[args[1]](unpack(args, 2))
      worker.callbacks[args[1]] = nil

    elseif cmd == "print" then
      print(unpack(args))

    elseif cmd == "err" then
      print(unpack(args))
    end
  end
}
event_mgr.subscribe("timer_0", worker.handle_messages)

-------------------------------------------------------------------------------------------- API
--Add <amount> to some column
function statsUserIncValue(uid, column_name, amount)
  worker.call.user_inc_value(uid, column_name, amount)
end

-- /stats
-- Display stats of a user (s2) to player_no
function statsChatCmd(player_no, num_args)
  local stats_player = player_no
  
  if num_args >= 1 then 
    local stats_player_name = game.sreg[2]
    stats_player = search_player(stats_player_name)
    if not stats_player then
      send_info_msg(player_no, "Player " .. stats_player_name .. " not found")
      return
    end
  end

  if not game.player_is_active(stats_player) then return end
  local uid = game.op.player_get_unique_id(stats_player)

  worker.rcall.query_stats(uid).next(function(data)
    if not data then return end

    if player_no == stats_player then
      send_info_msg(player_no, "Your stats:")
    else
      game.str_store_player_username(40, stats_player)
      send_info_msg(player_no, "Stats of " .. game.sreg[40] .. ":")
    end

    for _, v in ipairs(data) do
      local col, val = v.column, v.val
      local msg

      if col == "seconds_online" then
        msg = "- Hours Online: " .. round(val / 60 / 60, 1)
      else
        msg = "- " .. cfg.full_column_names[col] .. ": " .. val
      end

      send_info_msg(player_no, msg)
    end
  end)
end

-- /duelstats
-- Display arena stats of a user (s2) to player_no
function statsChatCmdDuel(player_no, num_args)
  local stats_player = player_no

  if num_args >= 1 then 
    local stats_player_name = game.sreg[2]
    stats_player = search_player(stats_player_name)
    if not stats_player then
      send_info_msg(player_no, "Player " .. stats_player_name .. "not found")
      return
    end
  end

  if not game.player_is_active(stats_player) then return end
  local uid = game.op.player_get_unique_id(stats_player)

  worker.rcall.query_duelstats(uid).next(function(data)
    if not data then return end

    if player_no == stats_player then
      send_info_msg(player_no, "*** Your Wins/Losses ***")
    else
      game.str_store_player_username(40, stats_player)
      send_info_msg(player_no, "*** Wins/Losses of " .. game.sreg[40] .. " ***")
    end
    send_info_msg(player_no, string.format("- Duel %d/%d", data.ft1_wins, data.ft1_losses))
    send_info_msg(player_no, string.format("- FT3  %d/%d", data.ft3_wins, data.ft3_losses))
    send_info_msg(player_no, string.format("- FT5  %d/%d", data.ft5_wins, data.ft5_losses))
    send_info_msg(player_no, string.format("- FT7  %d/%d", data.ft7_wins, data.ft7_losses))
  end)
end

-- /top
-- top10 or more
function statsChatCmdTop(player_no, num_args)
  local function help()
    send_info_msg(player_no, "Usage:")
    send_info_msg(player_no, "/top                    Show top 10 kill/death ratio (with >100kills)")
    send_info_msg(player_no, "/top (stat)            Show top 10 for this stat")
    send_info_msg(player_no, "/top (stat) (10-50)  Show top 10-50 for this stat")

    local t = {}
    for _, v in ipairs(cfg.top_data) do
      table.insert(t, v.stat)
    end
    send_info_msg(player_no, "(stat) can be: " .. table.concat(t, ", "))
  end

  local stat = "kd"
  local limit = 10

  if num_args >= 1 then
    if game.sreg[2] == "help" then
      help()
      return
    end

    if num_args >= 2 then
      if not (game.str_is_integer(3) and tonumber(game.sreg[3]) >= 10 and tonumber(game.sreg[3]) <= 50) then
        help()
        return
      end
      limit = tonumber(game.sreg[3])
    end

    stat = string.lower(game.sreg[2])
  end

  local top_entry
  for _, v in ipairs(cfg.top_data) do
    if v.stat == stat then top_entry = v end
  end

  if not top_entry then
    help()
    return
  end

  local query
  if top_entry.query then
    query = string.format(top_entry.query, limit)
  else
    if not top_entry.col then
      log(string.format("/top error: %s has no query and no col!", stat), true)
      return
    end
    query = string.format("SELECT last_username, %s FROM users ORDER BY %s DESC LIMIT %d", top_entry.col, top_entry.col, limit)
  end


  --We have everything, lets go
  worker.rcall.rows(query).next(function(rows)
    send_info_msg(player_no, string.format("######Top%d - %s #####", limit, top_entry.caption or cfg.full_column_names[top_entry.col]))

    for i, row in ipairs(rows) do
      local txt

      if top_entry.formatter then
        txt = top_entry.formatter(row)
      else
        txt = tostring(row[2])
      end

      send_info_msg(player_no, string.format("%d %s: %s", i, row[1], txt))
    end

    if limit >= 20 then
      send_info_msg(player_no, "Press L to view in Chatlog")
    end
  end)
end

function statsSaveToFile()
  worker.call.flush_to_file()
end

-- /names
function statsChatCmdNames(player_no, num_args)
  local target_name, target_uid

  if num_args < 1 or num_args > 2 then
    send_info_msg(player_no, "Shows known usernames for player. Usage:^/names (playername)^/names uid (uid)")
    return
  end
  
  if num_args == 1 then 
    local name = game.sreg[2]
    local target_player = search_player(name)
    if not target_player then
      send_info_msg(player_no, "Player " .. name .. " not found")
      return
    end
    target_uid = game.op.player_get_unique_id(target_player)
    game.str_store_player_username(0, target_player)
    target_name = game.sreg[0]

  elseif num_args == 2 then
    if not game.str_is_integer(3) then
      send_info_msg(player_no, "Shows known usernames for player. Usage:^/names (playername)^/names uid (uid)")
      return
    end
    target_uid = round(tonumber(game.sreg[3]))
  end

  if not target_uid or type(target_uid) ~= "number" then return end
  worker.rcall.rows("SELECT known_username FROM known_user_names WHERE user_id = " .. target_uid).next(function(rows)
    if target_name then
      send_info_msg(player_no, "Known usernames for " .. target_name)
    else
      send_info_msg(player_no, "Known usernames for uid " .. target_uid)
    end

    for _, row in ipairs(rows) do
      send_info_msg(player_no, "- " .. row[1])
    end
  end)
end



-------------------------------------------------------------------------------------------- Triggers
local player_join_times = {}

event_mgr.subscribe("ti_on_multiplayer_mission_end", statsSaveToFile)

--Update or create user row
event_mgr.subscribe("ti_server_player_joined", function()
  local player_no = game.op.store_trigger_param_1()
  if not game.player_is_active(player_no) then return end
  local uid = game.op.player_get_unique_id(player_no)
  player_join_times[uid] = getTime()

  game.str_store_player_username(0, player_no)
  local username = game.sreg[0]
  game.str_store_player_ip(1, player_no)
  local ip = game.sreg[1]

  worker.call.on_user_joined(uid, username, ip, os.date("%Y.%m.%d, %X"))
end)

--Update last_date_online
event_mgr.subscribe("ti_on_player_exit", function()
  local player_no = game.op.store_trigger_param_1()
  if not game.player_is_active(player_no) then return end
  local uid = game.op.player_get_unique_id(player_no)

  local seconds_online = round((getTime() - player_join_times[uid]) / 1000)
  player_join_times[uid] = nil --might help garbage collection
  worker.call.on_user_leave(uid, os.date("%Y.%m.%d, %X"), seconds_online)
end)

--Update k/d
event_mgr.subscribe("ti_on_agent_killed_or_wounded", function()
  local dead_player = -1
  local killer_player = -1

  local dead_agent = game.op.store_trigger_param_1()
  if game.agent_is_active(dead_agent) and (not game.agent_is_non_player(dead_agent)) then
    
    dead_player = game.op.agent_get_player_id(dead_agent)
    if game.player_is_active(dead_player) then
      local uid = game.op.player_get_unique_id(dead_player)
      if player_join_times[uid] == nil then return end
      --the death might be player that disconnected. Don't count that. His join time should be set to nil already by exit trigger

      worker.call.user_inc_value(game.op.player_get_unique_id(dead_player), "deaths")
    end
  end

  if game.agent_is_human(dead_agent) then --Dont count horsekill
    local killer_agent = game.op.store_trigger_param_2()
    if game.agent_is_active(killer_agent) and (not game.agent_is_non_player(killer_agent)) then
      
      killer_player = game.op.agent_get_player_id(killer_agent)
      if killer_player ~= dead_player and game.player_is_active(killer_player) then
        worker.call.user_inc_value(game.op.player_get_unique_id(killer_player), "kills")
      end
    end
  end
end)

--Update seconds_online every 5 min so it doesnt take until round end to update
event_mgr.subscribe("timer_300", function()
  for player_no in game.playersIt(true) do
    if game.player_is_active(player_no) then
      local uid = game.op.player_get_unique_id(player_no)

      local seconds_online = round((getTime() - player_join_times[uid]) / 1000)
      player_join_times[uid] = getTime()
      
      worker.call.user_inc_value(uid, "seconds_online", seconds_online)
    end
  end
end)

--Update chat data
event_mgr.subscribe("script_wse_chat_message_received", function(player_no, chat_type) --0 = global, 1 = team, 2 = local chat |  s0 = message
  if not game.player_is_active(player_no) then return end
  
  local uid = game.op.player_get_unique_id(player_no)
  local msg = game.sreg[0]
  worker.call.user_inc_value(uid, "chat_chars_sent", string.len(msg))
  
  if starts_with(msg, "/") then return end

  local nwords = count_pattern_occurences(string.lower(msg), "\\bn+(i+|e+)g+(e+r+|a+)\\b")
  if nwords > 0 then
    worker.call.user_inc_value(uid, "n_words", nwords)
  end

  if chat_type == 2 then
    worker.call.user_inc_value(uid, "local_msgs_sent")
  else
    worker.call.user_inc_value(uid, "chat_msgs_sent")
  end
end)
