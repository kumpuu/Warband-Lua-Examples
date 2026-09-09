
--setting this 1) enables hot reload key (Ctrl+Shift+O)
--             2) replaces all require with dofile. require is not what we want for a reload
--Hot reloading is not magic! It might lead to bugs if you don't understand how lua works.
local dev_mode = true

if dev_mode and not __reload_reg then
    --Register Reload Trigger before anything else
    __reload_reg = true
    game.op.make_default() --see manual

    function do_hot_reload(from_world_map)
        print("Reloading main.lua")

        local function rst()
            event_mgr.clear()
            dofile("main.lua")
        end

        if event_mgr then event_mgr.dispatch("before_hot_reload") end

        --We just dispatched the before_hot_reload event, it's better to wait a frame so e.g. presentations can close
        --However, timeout won't work on the world map since it uses a mst trigger
        if timeout and timeout.next_frame and not from_world_map then 
            timeout.next_frame(rst) 
        else 
            rst() 
        end
    end

    --We ain't using event_mgr here, because if we change it and make a bug, it would break reloads.
    for i = 0, game.getNumTemplates()-1 do
        game.addTrigger(i, 0, 0, 0, function()
            if game.key_clicked(game.const.triggers.key_o) and
               game.key_is_down(game.const.triggers.key_left_shift) and
               game.key_is_down(game.const.triggers.key_left_control) 
            then
                do_hot_reload()
            end
        end)
    end

    local function file_exists(name)
        local f = io.open(name,"r")
        if f then
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
require "savegame_mgr"
require "root_menu"


--I think normally each module should require its requirements individually.
--require is built for that and it's more portable.
--However, this mod chose a different pattern where most libraries create a global that others can use,
--and we only require them once in main.lua
--This is also advantageous for hot reloading, since we replace require with dofile.
--Having multiple dofile of the same library can cause side effects.
require "modules/scene_tools"
require "modules/console"
require "modules/battle_toys"
require "modules/clock"
require "modules/center_dot"
require "modules/world_map"

print("~ Lua Loaded ~")
