local num_lines = 333
local quit, set_focus, run_btn, clear_btn, first_line_ov, active_line, last_focused_line

local function save_lines()
    local txt = ""
    for i = 1, num_lines do
        game.str_store_overlay_text(0, first_line_ov + i - 1)
        txt = txt .. game.sreg[0] .. "\n"
    end

    local f, err = io.open("console_script.lua", "w+")
    f:write(txt)
    f:close()
end

local function load_lines()
    if not file_exists("console_script.lua") then return end

    local i = 1
    for line in io.lines("console_script.lua") do
        game.overlay_set_text(first_line_ov + i - 1, line)
        i = i + 1
        if i > num_lines then break end
    end
end

local function execute()
    local txt = ""
    for i = 1, num_lines do
        game.str_store_overlay_text(0, first_line_ov + i - 1)
        txt = txt .. game.sreg[0] .. "\n"
    end

    local f, err = loadstring(txt)
    if not f then
        print(err)
    else
        local ok, err = pcall(f)
        if not ok then
            print(err)
        end
    end
end

--translate line no to corresponding overlay no
local function line2ov(line_no)
    if line_no >= 1 and line_no <= num_lines then
        return first_line_ov + line_no - 1
    end
end

prsnt_console = game.addPrsnt({
    id = "console",
    flags = {game.const.prsntf_manual_end_only},
    triggers = {
        [game.const.ti_on_presentation_load] = function()
            game.presentation_set_duration(99999999)

            --in console you can press any key which could open unwanted presentations... so use this workaround
            game.hookOperation("start_presentation", function() return false end)

            local p = game.pos.new()
            local s = game.pos.new()

            local bg = game.create_mesh_overlay(game.const.mesh_mp_ingame_menu)
            p.o.x = 0.15
            p.o.y = 0.1
            game.overlay_set_position(bg, p)

            s.o.x = 1.4
            s.o.y = 1
            game.overlay_set_size(bg, s)

            local scrollContainer = game.create_text_overlay("", game.const.tf_scrollable_style_2)
            p.o.x = 0.19
            p.o.y = 0.15
            game.overlay_set_position(scrollContainer, p)
            s.o.x = 0.8
            s.o.y = 0.5
            game.overlay_set_area_size(scrollContainer, s)
            game.set_container_overlay(scrollContainer)


            local line_height = 0.019

            p.o.x = 0.012
            p.o.y = (num_lines+3)*line_height

            local caption = game.create_text_overlay("Lua Console", game.const.tf_with_outline)
            game.overlay_set_color(caption, 0xffffff)
            game.overlay_set_position(caption, p)

            -- run_btn = game.create_button_overlay("            Run              ")
            -- p.o.x = 0.2
            -- s.o.x = 1
            -- s.o.y = 1
            -- game.overlay_set_position(run_btn, p)
            -- game.overlay_set_size(run_btn, s)
            -- game.overlay_set_color(run_btn, 0xffffff)

            caption = game.create_text_overlay("Press Shift+Enter to Run", game.const.tf_with_outline)
            p.o.x = 0.175
            s.o.x = 0.7
            s.o.y = 0.7
            game.overlay_set_color(caption, 0xffffff)
            game.overlay_set_position(caption, p)
            game.overlay_set_size(caption, s)

            clear_btn = game.create_button_overlay("Clear All")
            p.o.x = 0.52
            s.o.x = 0.7
            s.o.y = 0.7
            game.overlay_set_position(clear_btn, p)
            game.overlay_set_size(clear_btn, s)
            game.overlay_set_color(clear_btn, 0xffffff)

            p.o.y = p.o.y - 0.02

            --create line numbers
            local start_y = p.o.y
            p.o.y = p.o.y + 0.005
            for i = 1, num_lines do
                p.o.y = p.o.y - line_height
                p.o.x = 0.018
                s.o.x = 0.7
                s.o.y = 0.7
                local txt = game.create_text_overlay(tostring(i), game.const.tf_right_align)
                game.overlay_set_position(txt, p)
                game.overlay_set_size(txt, s)
                game.overlay_set_color(txt, 0x999999)
            end

            --create line text boxes
            first_line_ov = nil
            p.o.y = start_y
            for i = 1, num_lines do
                p.o.y = p.o.y - line_height
                p.o.x = 0.023
                s.o.x = 0.55
                s.o.y = 1
                local textBox = game.create_simple_text_box_overlay()
                game.overlay_set_position(textBox, p)
                game.overlay_set_size(textBox, s)

                if not first_line_ov then first_line_ov = textBox end
            end

            load_lines()

            exec = -1
            set_focus = false
            active_line = 1
            last_focused_line = 0
            game.overlay_obtain_focus(first_line_ov)
        end,

        [game.const.ti_on_presentation_event_state_change] = function()
            local ov = game.store_trigger_param_1()
            local line = ov - first_line_ov + 1

            if ov == clear_btn then
                for i = 1, num_lines do
                    game.overlay_set_text(line2ov(i), "")
                end
                print("Console cleared")
                game.overlay_obtain_focus(first_line_ov)

            elseif line >= 1 and line <= num_lines then
                --state_change gets triggered when a textbox loses focus
                last_focused_line = line
            end
        end,

        [game.const.ti_on_presentation_mouse_press] = function()
            local ov = game.store_trigger_param_1()
            local line = ov - first_line_ov + 1

            --weirdly, clicking a line can trigger mouse_press twice, once with the previously in focus line
            if line >= 1 and line <= num_lines and line ~= last_focused_line then
                active_line = line
            end
        end,
        
        [game.const.ti_on_presentation_run] = function()
            if set_focus then
                set_focus = false
                game.overlay_obtain_focus(line2ov(active_line))
            end


            ----Escape----
            if game.key_clicked(game.const.triggers.key_escape) then
                quit = true

            ----Enter----
            elseif game.key_clicked(game.const.triggers.key_enter) then

                if game.key_is_down(game.const.triggers.key_left_shift) or
                   game.key_is_down(game.const.triggers.key_right_shift)
                then
                    quit = true
                    --user might try to start a prsnt...
                    game.hookOperation("start_presentation", nil)
                    execute()
                else
                    if active_line < num_lines then
                        --shift lines...
                        for i = num_lines, active_line + 2, -1 do
                            game.str_store_overlay_text(0, line2ov(i-1))
                            game.overlay_set_text(line2ov(i), game.s0)
                        end

                        active_line = active_line + 1
                        set_focus = true
                        game.overlay_set_text(line2ov(active_line), "")
                    end
                end

            ----Backspace----
            elseif game.key_clicked(game.const.triggers.key_back_space) then
                game.str_store_overlay_text(0, line2ov(active_line))
                if game.s0 == "" and active_line > 1 then
                    --shift lines...
                    --awkwardly, the text box itself has not processed the backspace yet.
                    --if we'd shift this frame, it would delete the last char of the following line.
                    timeout.next_frame(function()
                        for i = active_line, num_lines - 1 do
                            game.str_store_overlay_text(0, line2ov(i+1))
                            game.overlay_set_text(line2ov(i), game.s0)
                        end
                        game.overlay_set_text(line2ov(num_lines), "")

                        active_line = active_line - 1
                        set_focus = true
                    end)
                end

            ----Up----
            elseif game.key_clicked(game.const.triggers.key_up) then
                active_line = math.max(active_line - 1, 1)
                set_focus = true

            ----Down----
            elseif game.key_clicked(game.const.triggers.key_down) then
                active_line = math.min(active_line + 1, num_lines)
                set_focus = true
            end


            if quit then
                save_lines()
                game.presentation_set_duration(0)
                game.hookOperation("start_presentation", nil)
            end
        end
    }
})

--auto close menu on hot reload
event_mgr.subscribe("before_hot_reload", function() 
    quit = true
    game.hookOperation("start_presentation", nil) --things can go wrong... this prevents softlocks
end)

root_menu.add_btn("Lua Console", function(menu_data)
    menu.close()
    if not game.is_presentation_active(prsnt_console) then
        quit = false
        game.start_presentation(prsnt_console)
    end
end)