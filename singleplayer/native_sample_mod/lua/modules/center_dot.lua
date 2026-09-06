--Show a white dot in the screen center. That's it.
--It gives my eyes something to lock onto. It can also be useful when playing archer.

local show_dot = settings.center_dot:get("show", false)

local prsnt = game.addPrsnt({
    id = "Dot",
    flags = {game.const.prsntf_read_only, game.const.prsntf_manual_end_only},
    triggers = {
        [game.const.ti_on_presentation_load] = function()
            game.presentation_set_duration(99999999)

            local screenPos = game.pos.new()
            local sizePos = game.pos.new()

            midDotOverlay = game.create_mesh_overlay(game.const.meshes.mesh_white_dot)
            screenPos.o.x = 0.5 - 0.0002
            screenPos.o.y = 0.75/2 - 0.0001
            sizePos.o.x = 0.1
            sizePos.o.y = 0.1
            game.overlay_set_position(midDotOverlay, screenPos)
            game.overlay_set_size(midDotOverlay, sizePos)
        end,
    }
})

--watchdog timer, presentation might close due to various reasons
event_mgr.subscribe("timer_1", function()
    if show_dot and not game.is_presentation_active(prsnt) then
        game.start_presentation(prsnt)
    elseif not show_dot and game.is_presentation_active(prsnt) then
        game.presentation_set_duration(0, prsnt)
    end
end)

event_mgr.subscribe("before_hot_reload", function()
    game.presentation_set_duration(0, prsnt)
end)

root_menu.add("Clock", {
    items = {
        {
            type = "checkbox",
            text = "Show Center Dot",
            checked = show_dot,
            OnChange = function(menu_data, self, val)
                show_dot = self.checked
                settings.center_dot.show = show_dot
            end
        }
    }
})