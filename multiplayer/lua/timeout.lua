local timeouts = {}

function timeoutsTick()
  if #timeouts ~= 0 then
    local t_now = game.store_mission_timer_a_msec(0)

    for i = #timeouts, 1, -1 do
      if timeouts[i].t <= t_now then
        timeouts[i].cb(timeouts[i].cb, t_now)
        table.remove(timeouts, i)
      end
    end
  end
end

function timeoutAddScript(time, script_no, ...)
  local args = {...}
  local cb = function()
    game.call_script(script_no, unpack(args))
  end

  table.insert(timeouts, { t = game.store_mission_timer_a_msec(0) + time, cb = cb})
end

function timeoutAdd(time, callback)
  table.insert(timeouts, { t = game.store_mission_timer_a_msec(0) + time, cb = callback })
end

event_mgr.subscribe("ti_before_mission_start", function() timeouts = {} end)
event_mgr.subscribe("timer_0", timeoutsTick)