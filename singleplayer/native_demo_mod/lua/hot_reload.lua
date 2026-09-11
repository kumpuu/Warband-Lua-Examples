--setting this enables the hot reload key (Ctrl+Shift+O)
--Hot reloading is not magic! It might lead to bugs if you don't understand how lua works.
local dev_mode = true

if dev_mode and not _G.__reload_reg then
    --Register Reload Trigger before anything else
    _G.__reload_reg = true
    local reload_next_frame = false

    local function file_exists(name)
        local f = io.open(name,"r")
        if f then
            io.close(f)
            return true
        else
            return false
        end
    end

    local function do_actual_reload()
        if event_mgr then event_mgr.clear() end 

        --Require caches files and doesn't reload from disk.
        --That's no good when hot reloading. So wipe the cache for our files
        for k,_ in pairs(package.loaded) do
            if file_exists(k .. ".lua") then
                package.loaded[k] = nil
            end
        end

        dofile("main.lua")
    end

    function do_hot_reload(from_world_map)
        print("Reloading main.lua")

        if event_mgr then event_mgr.dispatch("before_hot_reload") end

        --We just dispatched the before_hot_reload event, it's better to wait a frame so e.g. presentations can close
        --However, that won't work on the world map since we use a mst trigger
        if not from_world_map then 
            reload_next_frame = true
        else 
            do_actual_reload() 
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

            elseif reload_next_frame then
                reload_next_frame = false
                do_actual_reload()
            end
        end)
    end
end