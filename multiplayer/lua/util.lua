local bit = require("bit")
local regex = require("regex")

function starts_with(str, start)
    return str:sub(1, #start) == start
end
 
 function ends_with(str, ending)
    return ending == "" or str:sub(-#ending) == ending
 end

function getAllMatches(s, pattern)
    local res = {}
    for match in s:gmatch(pattern) do
        table.insert(res, match)
    end
    return res
end

 function getMissionTime()
    return game.store_mission_timer_a(0)
 end

 function getMissionTimeMs()
    return game.store_mission_timer_a_msec(0)
 end

function make(_table, ...)
    local curTable = _table

    for i = 1, select("#", ...) do
        local curKey = select(i, ...)
        if not curTable[curKey] then curTable[curKey] = {} end
        curTable = curTable[curKey]
    end

    return curTable
end

function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function round2(num, numDecimalPlaces)
    return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

function strToType(str)
    s = str:lower()

    if s == "true" then
        return true
    elseif s == "false" then
        return false
    elseif s == "nil" then
        return nil
    elseif s:match("^%d*%.?%d*$") or s:match("^0x%x*.?%x*$") then
        return tonumber(s)
    end

    return str
end

function sortedPairs (t, f)
    local a = {}
    for n in pairs(t) do
        table.insert(a, n)
    end
    table.sort(a, f)

    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
      i = i + 1
      if a[i] == nil then
        return nil
      else 
        return a[i], t[a[i]]
      end
    end
    return iter
end

function extractTable(s)
    local res = {}
    s = s .. ","
    for match in s:gmatch("(.-)[,|;%s]") do
      if match ~= "" then
        table.insert(res, match)
      end
    end

    return res
end

function getMyAgent()
    local myAgent = game.player_get_agent_id(0, game.multiplayer_get_my_player(0))

    if game.agent_is_active(myAgent) then return myAgent end
    return nil
end

function getAngleAndDistance(pos1, pos2) --pos2 angle to pos1 forward vector
    local forwards = pos1.rot.f
    local sideways = pos1.rot.s

    local x1 = pos2.o.x
    local y1 = pos2.o.y
    local a1 = sideways.x
    local b1 = sideways.y

    local x2 = pos1.o.x
    local y2 = pos1.o.y
    local a2 = forwards.x
    local b2 = forwards.y

    local t = (y1-y2 - (x1-x2)*b1/a1) / (b2-(a2*b1)/a1)

    local adjacent = math.abs(t)
    local hypothenuse = math.sqrt(math.pow(x1-x2, 2) + math.pow(y1-y2, 2))

    x2 = x2 + t * a2
    local s = (x1 - x2) / a1
    
    local angle = math.acos(adjacent/hypothenuse)

    if s >= 0 then
        return angle, hypothenuse
    else
        return -angle, hypothenuse
    end
end

function joinTables(target, source)
    for k,v in pairs(source) do
        if not target[k] then
            target[k] = v
        else
            if type(v) == "table" and type(target[k]) == "table" then
                joinTables(target[k], v)
            end
        end
    end
end

function getFunctionId(func)
    return tostring(func):match("0x.+")
end

function getNetworkLevel()
    if game.multiplayer_is_server() then
        if game.multiplayer_is_dedicated_server() then
            return "dedicated"
        else
            return "server"
        end    
    else
        return "client"
    end
end

function ellipsis(str, max)
    if str:len() > max + 2 then
        return str:sub(1, max) .. "..."
    end

    return str
end

function swap_k_v(table)
    local new = {}

    for k,v in pairs(table) do
        new[v] = k
    end

    return new
end

function custom_chat_open()
    return game.is_presentation_active(game.const.prsnt_multiplayer_admin_chat) or
        game.is_presentation_active(game.const.prsnt_multiplayer_custom_chat)
end

function repeat_key(key, length)
    if #key >= length then
        return key:sub(1, length)
    end

    local times = math.floor(length / #key)
    local remain = length % #key

    local result = ''

    for i = 1, times do
        result = result .. key
    end

    if remain > 0 then
        result = result .. key:sub(1, remain)
    end

    return result
end

function xor_str(message, key)
    local rkey = repeat_key(key, #message)

    local result = ''

    for i = 1, #message do
        local k_char = rkey:sub(i, i)
        local m_char = message:sub(i, i)

        local k_byte = k_char:byte()
        local m_byte = m_char:byte()

        local xor_byte = bit.bxor(m_byte, k_byte)

        local xor_char = string.char(xor_byte)

        result = result .. xor_char
    end

    return result
end

function file_exists(name)
    local f = io.open(name,"r")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

function file_copy(source, destination)
    local sourceFile, err = io.open(source, "rb")
    if not sourceFile then
        return nil, "Error opening source file: " .. err
    end

    local destinationFile, err = io.open(destination, "wb")
    if not destinationFile then
        sourceFile:close()
        return nil, "Error opening destination file: " .. err
    end

    local data = sourceFile:read("*all")  -- Read the entire file
    destinationFile:write(data)  -- Write the data to the destination file

    -- Close both files
    sourceFile:close()
    destinationFile:close()

    return true
end

function dbgp(...)
    if show_debug_msg then
        print(...)
    end
end

function dbge(...)
    if show_debug_msg or show_err_msg then
        print(...)
    end
end

lastStr = nil
function lprint(str)
    if str ~= lastStr then
        print(str)
        lastStr = str
    end
end

local function _format(v)
    if type(v) == "string" then return "'" .. v .. "'" else return tostring(v) end
end

function printTable(t, prefix, seen)
    prefix = prefix or ""
    seen = seen or {}
    seen[t] = true

    for k,v in pairs(t) do
        if type(v) == "table" then
            if seen[v] then
                print(string.format("%s[%s] %s = %s{", prefix, type(k), _format(k), tostring(v)))
                print(prefix .. "    #Reference to parent table#")
                print(prefix .. "}")   
            else
                print(string.format("%s[%s] %s = %s{", prefix, type(k), _format(k), tostring(v)))
                printTable(v, prefix .. "    ", seen)
                print(prefix .. "}")   
            end
        else
            print(string.format("%s[%s] %s = [%s] %s", prefix, type(k), _format(k), type(v), _format(v)))
        end
    end

    seen[t] = nil
end

function log(str, show_in_console)
    -- game.sreg[15] = str
    game.server_add_message_to_log(str)

    if(show_in_console) then
        print(str)
    end
end

function log2(...)
    local s = table.concat({...}, "    ")
    game.server_add_message_to_log(s)
    print(s)
end

function logTable(t, prefix, show_in_console)
    if not prefix then
        prefix = ""
    end

    for k,v in pairs(t) do
        local typ = "[" .. type(v) .. "] "
        local name = "'" .. k .. "' ="
        local val = " " .. tostring(v)

        if type(v) == "table" then
            log(prefix .. typ .. name, show_in_console)
            logTable(v, prefix .. "___", show_in_console)

        else
            log(prefix .. typ .. name .. val, show_in_console)
        end
    end
end

function matr_mul(A, B)
  local res = {{},{},{}}

  for row = 1, 3 do
    for col = 1, 3 do
      res[row][col] = A[row][1]*B[1][col] + A[row][2]*B[2][col] + A[row][3]*B[3][col]
    end
  end

  return res
end

function send_info_msg(player_no, msg)
    game.sreg[40] = msg
    game.call_script(game.script.send_colored_chat_s40, player_no, game.const.color_info)
end

function search_player(name)
    for player_no in game.playersIt(true) do
      game.str_store_player_username(40, player_no)
      if game.str_contains(40, name, 1) then return player_no end
    end
    return nil
end

function search_val(t, val)
    for k,v in pairs(t) do
        if v == val then return k, v end
    end
end

function count_pattern_occurences(str, pattern)
    local count = 0
    local startIndex = 1

    while true do
        local start, finish = regex.find(str, pattern, startIndex)
        if not start then break end
        count = count + 1
        startIndex = finish + 1
    end

    return count
end