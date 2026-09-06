local clock_state = settings.clock:get("state", 0)
local clock_overlay
local next_refresh_t

local prsnt_clock = game.addPrsnt({
    id = "Clock",
    flags = {game.const.prsntf_read_only, game.const.prsntf_manual_end_only},
    triggers = {
        [game.const.ti_on_presentation_load] = function()
            game.presentation_set_duration(99999999)

            clock_overlay = game.create_text_overlay("00:00:00", game.const.tf_left_align + game.const.tf_with_outline)

            local screenPos = game.pos.new()
            if     clock_state == 1 then
                screenPos.o.x = 0
                screenPos.o.y = 0
            elseif clock_state == 2 then
                screenPos.o.x = 0.92
                screenPos.o.y = 0
            elseif clock_state == 3 then
                screenPos.o.x = 0
                screenPos.o.y = 0.72
            elseif clock_state == 4 then
                screenPos.o.x = 0.92
                screenPos.o.y = 0.72
            end

            local sizePos = game.pos.new(game.preg[0])
            sizePos.o.x = 1
            sizePos.o.y = 1

            game.overlay_set_position(clock_overlay, screenPos)
            game.overlay_set_size(clock_overlay, sizePos)
            game.overlay_set_color(clock_overlay, 0xFFFFFA)

            next_refresh_t = 0

            -- midDotOverlay = game.create_mesh_overlay(0, game.const.meshes.mesh_white_dot)
            -- screenPos.o.x = 0.5 - 0.0002
            -- screenPos.o.y = 0.75/2 - 0.0001
            -- sizePos.o.x = 0.1
            -- sizePos.o.y = 0.1
            -- game.overlay_set_position(midDotOverlay, screenPos)
            -- game.overlay_set_size(midDotOverlay, sizePos)
        end,
        
        [game.const.ti_on_presentation_run] = function()
            local curTime = game.store_trigger_param_1()
            if curTime >= next_refresh_t then
                next_refresh_t = next_refresh_t + 1000

                game.overlay_set_text(clock_overlay, os.date("%X"))

                if not clock_state then
                    game.presentation_set_duration(0)
                end
            end
        end
    }
})

--watchdog timer, presentation might close due to various reasons
event_mgr.subscribe("timer_1", function()
    if clock_state > 0 then
        if not game.is_presentation_active(prsnt_clock) then
            game.start_presentation(prsnt_clock)
        end
    end
end)

event_mgr.subscribe("before_hot_reload", function()
    game.presentation_set_duration(0, prsnt_clock)
end)

root_menu.add("Clock", {
    items = {
        {
            type = "combo",
            text = "Clock",
            val = 0,
            values = {"Top Right", "Top Left", "Bottom Right", "Bottom Left", "Disabled"},
            --Annoyingly, the game shows this list in reverse order with left being the bottom.
            --Thats why we do 4-x

            OnLoad = function(menu_data, self)
                --gotta set the val here to get the freshest one
                self.val = 4 - clock_state
            end,

            OnChange = function(menu_data, self, val)
                game.presentation_set_duration(0, prsnt_clock)
                clock_state = 4 - val
                settings.clock.state = clock_state
            end,
        }
    }
})