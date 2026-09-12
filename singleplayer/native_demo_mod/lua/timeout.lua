timeout = {}
local callbacks = {}
local cur_id = 0

--Internal
function timeout.tick()
    if #callbacks == 0 then return end

    local t_now = game.store_mission_timer_a_msec()

    for i = #callbacks, 1, -1 do
        local data = callbacks[i]
        
        if data.t <= t_now then
            local cb = data.cb
            table.remove(callbacks, i)

            table.insert(data.args, cb) --give reference to self in case they want to set it as timeout again
            table.insert(data.args, t_now)
            cb(unpack(data.args))
        end
    end
end

--Add a callback that will execute in <time> ms. Optionally, you can pass additional parameters.
--Upon execution, callback will receive all the additional parameters and then a reference to itself and the mission time.
--Example:
--  timeout.add(1000, function(param1, param2, self, mission_time_ms) ... end, "param 1", "hello")
--Returns a unique id that can be used with cancel

function timeout.add(time, callback, ...)
    cur_id = cur_id + 1

    table.insert(callbacks, {
        t = game.store_mission_timer_a_msec() + time,
        cb = callback,
        args = {...},
        id = cur_id
    })

    return cur_id
end

function timeout.next_frame(callback, ...)
    return timeout.add(0.1, callback, ...)
    --game would need to run at more than 10000 fps before 0.1ms becomes too long
end

function timeout.add_script(time, script_no, ...)
    return timeout.add(time, game.call_script, script_no, ...)
end

function timeout.cancel(id)
    if not id then return end

    for i, v in ipairs(callbacks) do
        if v.id == id then
            table.remove(callbacks, i)
            break
        end
    end
end

event_mgr.subscribe("ti_before_mission_start", function() callbacks = {} end)
event_mgr.subscribe("timer_0", timeout.tick)