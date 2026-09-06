--Keys
--  shift+m = Select root
--  shift+k = Save group

local dev_mode = true

if dev_mode and not __reload_reg then
    --Register Reload Trigger before anything else
    __reload_reg = true
    game.op.make_default()

    for i = 0, game.getNumTemplates()-1 do
        game.addTrigger(i, 0, 0, 0, function()
            if game.key_clicked(game.const.triggers.key_o) and
               game.key_is_down(game.const.triggers.key_left_shift) and
               game.key_is_down(game.const.triggers.key_left_control) 
            then
                print("Reloading main.lua")

                local function rst()
                    event_mgr.clear()
                    dofile("main.lua")
                end

                if event_mgr then event_mgr.dispatch("before_hot_reload") end
                --We just dispatched the hot_reload event, it's better to wait a frame so e.g. presentations can close
                if timeout.add then timeout.add(1, rst) else rst() end
            end
        end)
    end

    local function file_exists(name)
        local f = io.open(name,"r")
        if f ~= nil then
            io.close(f)
            return true
        else
            return false
        end
    end

    --Require caches files and doesn't reload from disk.
    --That's no good when hot reloading. So replace it with dofile
    local old_require = require
    require = function(name)
        --Some libs aren't on disk though, so check for that
        if file_exists(name .. ".lua") then
            return dofile(name .. ".lua")
        else
            return old_require(name)
        end
    end
end

require "util"
require "event_mgr"
require "timeout"
require "settings"

require "root_menu"
require "modules/scene_tools"
require "modules/console"
require "modules/battle_toys"
require "modules/clock"
require "modules/center_dot"

print("~ Lua Loaded ~")


