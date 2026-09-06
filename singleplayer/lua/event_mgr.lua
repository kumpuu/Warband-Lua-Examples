--[[
Usage:
  event_mgr.subscribe(event_id, callback)
    event_id:
      "ti_constant", e.g. "ti_before_mission_start"
      "timer_x.y", e.g. "timer_1.5" or "timer_0"
      "itm_a:ti_constant", e.g. "itm_french_cav_pistol:ti_on_weapon_attack"
      "spr_b:ti_constant", same thing
      "script_", e.g. "script_game_quick_start" (versus hookScript - you can not control execution of modsys script here)
      "key_", e.g.:
        "key_o"                              O clicked
        "key_o down=key_shift"               O clicked while Shift down
        "key_k down=key_shift key_control"   key_shift, key_control means both left/right
      "your_own_event_id", can be used with dispatch()

    returns: an ID which you can use with unsubscribe

  event_mgr.unsubscribe(event_id, index)
    will not shift other IDs

  event_mgr.clear()
    Clear all callbacks. This does not remove triggers added to the game, but unsubscribes all.
    Useful for hot-reloading

    Example reload:
    event_mgr.subscribe("key_r down=key_shift", function()
      event_mgr.clear()
      print("Reloading")
      dofile("main.lua")
    end)

  event_mgr.dispatch(event_id, ...)
]]

local regex = require "regex"

if not event_mgr then
  event_mgr = {
    events = {}
  }
end

function event_mgr.subscribe(event_id, callback)
  event_mgr.init_event(event_id)

  local i = 1
  while event_mgr.events[event_id][i] ~= nil do i = i + 1 end
  event_mgr.events[event_id][i] = callback
  return i
end

function event_mgr.unsubscribe(event_id, index)
  event_mgr.events[event_id][index] = nil
end

function event_mgr.dispatch(event_id, ...)
  if event_mgr.events[event_id] then
    for _, event_callback in pairs(event_mgr.events[event_id]) do
      event_callback(...)
    end
  end
end

function event_mgr.clear()
  for event_id, _ in pairs(event_mgr.events) do
    event_mgr.events[event_id] = {}
  end
end

function event_mgr.init_event(event_id)
  if event_mgr.events[event_id] then return end
  make(event_mgr.events, event_id)

  local function add_mst_trig(const, callback)
    for i = 0, game.getNumTemplates()-1 do
      game.addTrigger(i, const, 0, 0, callback)
    end
  end
  
  --generic dispatcher
  local function cb()
    event_mgr.dispatch(event_id)
    return false
  end

  if starts_with(event_id, "ti_") then
    local const = game.const.triggers[event_id]
    add_mst_trig(const, cb)
  
  elseif starts_with(event_id, "timer_") then
    local const = tonumber(string.match(event_id, "%d+%.?%d*"))
    add_mst_trig(const, cb)

  elseif starts_with(event_id, "itm_") then
    local itm, const = string.match(event_id, "([%w_]+):([%w_]+)")
    itm = game.const[itm]
    const = game.const[const]
    game.addItemTrigger(itm, const, cb)

  elseif starts_with(event_id, "spr_") then
    local spr, const = string.match(event_id, "([%w_]+):([%w_]+)")
    spr = game.const[spr]
    const = game.const[const]
    game.addScenePropTrigger(spr, const, cb)

  elseif starts_with(event_id, "script_") then
    local s = string.match(event_id, "script_([%w_]+)")
    game.hookScript(game.script[s], function(...) event_mgr.dispatch(event_id, ...) end)

  elseif starts_with(event_id, "key_") then
    local keyname, modkeys = regex.match(event_id, [[(key_\w+)(?: down=(.+))?]])
    local down = {}

    local function key_test_func(keyname, op)
      if keyname == "key_control" then
        local k1 = game.const.triggers["key_left_control"]
        local k2 = game.const.triggers["key_right_control"]
        return function() return (op(k1) or op(k2)) end

      elseif keyname == "key_shift" then
        local k1 = game.const.triggers["key_left_shift"]
        local k2 = game.const.triggers["key_right_shift"]
        return function() return (op(k1) or op(k2)) end

      elseif keyname == "key_alt" then
        local k1 = game.const.triggers["key_left_alt"]
        local k2 = game.const.triggers["key_right_alt"]
        return function() return (op(k1) or op(k2)) end

      else
        local k = game.const.triggers[keyname]
        return function() return op(k) end
      end
    end

    local clicked = key_test_func(keyname, game.key_clicked)
    for modkey in regex.gmatch(modkeys, [[\w+]]) do
      table.insert(down, key_test_func(modkey, game.key_is_down))
    end

    add_mst_trig(0, function()
      if clicked() then
        for i = 1, #down do
          if not down[i]() then return false end
        end

        event_mgr.dispatch(event_id)
        return false
      end
    end)
  end
end

--For calling from modsys
function eventDispatch(event_id, ...)
  event_mgr.dispatch(event_id, ...)
end