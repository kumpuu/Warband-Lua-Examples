require "modules/height_map"

local fly_inst
local fly_mode_active = false
local fly_speed = 2

local fast_cam_active = false
local fast_cam_speed = 16
local fast_cam_drag_start_mouse_pos = nil
local fast_cam_drag_start_cam_rot = nil

local curPoint = 1
local tp_key_was_down = false

local function fast_cam_OnTick()
    local anyDown = false
    local function d(s)
        local kd = game.key_is_down(game.const.triggers["key_" .. s])
        if kd then anyDown = true end
        return kd
    end

    local true_speed = fast_cam_speed * 0.01

    game.mission_cam_get_position(0)
    local pos = game.pos0

    if d("w") then
        pos:moveY(true_speed)
    end
    if d("s") then
        pos:moveY(-true_speed)
    end
    if d("a") then
        pos:moveX(true_speed)
    end
    if d("d") then
        pos:moveX(-true_speed)
    end

    if d("e") then
        pos:moveZ(true_speed)
    end
    if d("c") then
        pos:moveZ(-true_speed)
    end

    if d("left_mouse_button") then
        game.mouse_get_position(0)
        local m_pos = game.pos0

        if m_pos.o.x > 0 and m_pos.o.x <= 1 and m_pos.o.y > 0 and m_pos.o.y <= 0.75 then

            if fast_cam_drag_start_mouse_pos then
                local m_delta = m_pos.o - fast_cam_drag_start_mouse_pos.o
                -- print(string.format("dx=%f dy=%f", round(m_delta.x, 2), round(m_delta.y, 2)))

                local new_rot = game.rotation.new(fast_cam_drag_start_cam_rot)
                new_rot:rotZ(-m_delta.x * 360, true)

                local rot_x = fast_cam_drag_start_cam_rot:getRot().x
                local add_rot = m_delta.y * 310

                if rot_x + add_rot > 72 then
                    add_rot = 72 - rot_x
                end
                if rot_x + add_rot < -80 then
                    add_rot = -80 - rot_x
                end

                new_rot:rotX(add_rot)

                --[[
                local s = tostring(m_delta.x) 
                s = s .. " " .. tostring(pos:getRot().z)
                s = s .. " " .. tostring(new_rot:getRot().z)

                s = s .. " " .. tostring(m_delta.y)
                s = s .. " " .. tostring(pos:getRot().x)
                s = s .. " " .. tostring(new_rot:getRot().x)
                s = s .. "\n"

                s = s:gsub("%.", ",")

                log(s)
                ]]
                pos.rot = new_rot
            else
                fast_cam_drag_start_mouse_pos = m_pos
                fast_cam_drag_start_cam_rot = pos.rot
            end
        end
    else
        fast_cam_drag_start_mouse_pos = nil
    end

    game.mission_cam_animate_to_position(pos, 1, 0)
end

local function fly_mode_OnTick()
    local anyDown = false
    local function d(s)
        local kd = game.key_is_down(game.const.triggers["key_" .. s])
        if kd then anyDown = true end
        return kd
    end

    local ag = getMyAgent()
    if not ag or not game.agent_is_alive(ag) then return end
    local horse = getHorse(ag)

    game.agent_get_position(0, horse or ag)
    local agPos = game.pos0

    game.agent_get_look_position(0, ag)
    local look_pos = game.pos0

    game.prop_instance_get_position(0, fly_inst)
    local prop_pos = game.pos0

    if game.get_sq_distance_between_positions(agPos, prop_pos) > 40 then --40cm
        game.agent_set_position(horse or ag, prop_pos)
    end

    local pos = game.pos.new({o = prop_pos.o, rot = look_pos.rot})

    if d("w") then
        pos:moveY(fly_speed)
    end
    if d("s") then
        pos:moveY(-fly_speed)
    end
    if d("d") then
        pos:moveX(fly_speed)
    end
    if d("a") then
        pos:moveX(-fly_speed)
    end
    if d("e") then
        pos.rot = agPos.rot
        pos:moveZ(fly_speed)
    end
    if d("c") then
        pos.rot = agPos.rot
        pos:moveZ(-fly_speed)
    end

    if anyDown then  
        pos.rot = agPos.rot

        pos:rotX(-90)
        game.prop_instance_stop_animating(fly_inst)
        game.prop_instance_animate_to_position(fly_inst, pos, 9)
    end
end

local function toggle_fly_mode()
    if game.edit_mode_window_open() then
        fast_cam_active = not fast_cam_active

        if fast_cam_active then
            print("Fast Cam enabled (speed=" .. tostring(fast_cam_speed) .. ")")
            print("Use mouse wheel to control speed")
        else
            print("Fast Cam disabled")
        end
    else
        local ag = getMyAgentOrHorse()
        if not ag then return end

        fly_mode_active = not fly_mode_active

        if fly_mode_active then
            print("Fly Mode enabled")
            print("Use mouse wheel to control speed")

            fly_inst = find_or_create_scene_prop(game.const.spr_barrier_2m, pos)

            game.agent_set_speed_modifier(ag, 0)
            game.agent_get_position(0, ag)
            local pos = game.pos0
            pos:rotX(-90)
            game.prop_instance_stop_animating(fly_inst)
            game.prop_instance_set_position(fly_inst, pos)

            game.prop_instance_get_position(0, fly_inst)
            pos = game.pos0

            game.agent_set_no_death_knock_down_only(ag, 1)
        else
            print("Fly Mode disabled")
            
            game.prop_instance_get_position(0, fly_inst)
            local prop_pos = game.pos0

            local hp = game.store_agent_hit_points(ag)
            local function free_agent()
                game.agent_set_hit_points(ag, hp)
                game.agent_set_speed_modifier(ag, 100)
                game.agent_set_no_death_knock_down_only(ag, 0)
            end

            prop_pos:moveY(0.5)

            local hit, prop_inst_no = game.cast_ray(0, prop_pos)
            local hit_pos = game.pos0
            hit_pos.rot = prop_pos.rot

            if hit then
                local T = 1000 --ms
                game.prop_instance_animate_to_position(fly_inst, hit_pos, T/10)
                --the platform might move down faster than agent fall speed, so add some teleports
                for i=1,100 do
                    timeout.add(i * T/100, function()
                        game.prop_instance_get_position(0, fly_inst)
                        game.agent_set_position(ag, 0)
                    end)
                end               

                timeout.add(1100, function()        
                    game.agent_set_position(ag, hit_pos)
                    free_agent()
                    hit_pos.o.z = -100
                    game.prop_instance_animate_to_position(fly_inst, hit_pos, 100) --1s
                    timeout.add(1000, clean_up_scene_prop, fly_inst)
                end)
            else
                prop_pos.o.z = -100
                game.prop_instance_animate_to_position(fly_inst, prop_pos, 1000) --10s
                timeout.add(10000, clean_up_scene_prop, fly_inst)
                free_agent()
            end
        end
    end
end

local psys_teleport = game.addPsys({
    id = "teleport_peasant", 
    flags = {game.const.psf_always_emit, game.const.psf_billboard_2d, game.const.psf_global_emit_dir},
    mesh = "peasant_a",
    num_particles = 100,
    life = 0.05,
    damping = 0.0,
    gravity_strength = 0.0,
    turbulance_size = 100.0,
    turbulance_strength = 0.0,
    alpha_keys = {{0.0, 0.7}, {1.0, 0.7}},
    red_keys =   {{0.0, 255}, {1.0, 255}},
    green_keys = {{0.0, 255}, {1.0, 255}},
    blue_keys =  {{0.0, 0.0}, {1.0, 0.0}},
    scale_keys = {{0.0, 1.0}, {1.0, 1.0}},
    emit_box_size = {0.0, 0.0, 0.0},
    emit_velocity = {0.0, 0.0, 0.0},
    emit_dir_randomness = 0.0,
    rotation_speed = 0,
    rotation_damping = 0
})

--spawn fly prop
event_mgr.subscribe("ti_before_mission_start", "net_sp, net_host", function()
    curPoint = 1
    fly_mode_active = false
    fly_inst = nil
end)

--Tick fly/fast cam
--Teleport Code
event_mgr.subscribe("timer_0", "net_sp, net_host", function()
    if fast_cam_active and game.edit_mode_window_open() then
        fast_cam_OnTick()
    elseif fly_mode_active and not game.edit_mode_window_open() then
        fly_mode_OnTick()
    end

    if game.is_presentation_active(prsnt_console) then return end

    --Teleport
    if game.key_is_down(game.const.key_v) then
        tp_key_was_down = true

        game.mission_cam_get_position(0)
        if game.cast_ray(1, 0) then
            -- game.particle_system_burst_no_sync(game.const.psys_village_fire_big, 1, 5)
            game.particle_system_burst_no_sync(psys_teleport, 1, 1)
        end

    elseif tp_key_was_down then
        tp_key_was_down = false

        game.mission_cam_get_position(0)
        if game.cast_ray(1, 0) then
            game.position_move_y(1, -50)
            game.mission_cam_animate_to_position(1, 1, 0)

            local ag = getMyAgentOrHorse()
            if ag then
                game.position_move_y(1, 50)
                if fly_mode_active then
                    game.prop_instance_stop_animating(fly_inst)
                    game.prop_instance_set_position(fly_inst, 1)
                else
                    game.agent_set_position(ag, 1)
                end
            end
        end
    end
end)

--fly faster
event_mgr.subscribe("key_mouse_scroll_up", "net_sp, net_host", function()
    if fast_cam_active and game.edit_mode_window_open() then
        fast_cam_speed = math.min(fast_cam_speed * 2, 256)
        print("Cam Speed: " .. fast_cam_speed)
    elseif fly_mode_active and not game.edit_mode_window_open() then
        fly_speed = math.min(fly_speed * 2, 256)
        print("Fly Speed: " .. fly_speed)
    end
end)

--fly slower
event_mgr.subscribe("key_mouse_scroll_down", "net_sp, net_host", function()
    if fast_cam_active and game.edit_mode_window_open() then
        fast_cam_speed = math.max(fast_cam_speed / 2, 0.125)
        print("Cam Speed: " .. fast_cam_speed)
    elseif fly_mode_active and not game.edit_mode_window_open() then
        fly_speed = math.max(fly_speed / 2, 0.125)
        print("Fly Speed: " .. fly_speed)
    end
end)

--Teleport to next entry point
event_mgr.subscribe("key_n down=key_left_control", "net_sp, net_host", function()
    local agent = getMyAgentOrHorse()
    if not agent then return end

    game.entry_point_get_position(0, curPoint)
    game.agent_set_position(agent, 0)

    local auto = ""
    if game.entry_point_is_auto_generated(curPoint) then
        auto = " (auto generated)"
    end

    print("entry point " .. curPoint .. auto)

    curPoint = curPoint + 1
    if curPoint > 64 then
        curPoint = 1
    end
end)

--Toggle fast cam mode
event_mgr.subscribe("key_b down=key_left_control", "net_sp, net_host", toggle_fly_mode)

event_mgr.subscribe("before_hot_reload", "net_sp, net_host", function()
    if fly_inst then clean_up_scene_prop(fly_inst) end
end)

root_menu.add_btn("Scene Tools", function()
    local propNum = 0

    for fly_inst in game.propInstI() do
        propNum = propNum + 1
    end

    local spawnPoints = 0
    for i = 1, 1000 do
        if not game.entry_point_is_auto_generated(i) then
            spawnPoints = spawnPoints + 1
        end
    end

    menu.show({
        caption = {text = "Scene Edit Tools"},

        items = {
            {
                type = "text",
                text = "Props: " .. propNum
            },
            },
            {
                type = "text",
                text = "Total Spawn Points " .. spawnPoints
            },
            {
                type = "section",
                text = "Height Map",
                line = true,
            },
                {
                    id = "slider_res",
                    type = "slider",
                    text = "Resolution: 0.50m",
                    val = 50,
                    min = 5,   --0.05m
                    max = 500, --5m
                    OnChange = function(menu_data, self, val)
                        game.get_scene_boundaries(0, 1)
                        local scene_min = game.pos0
                        local scene_max = game.pos1
                        local scene_width  = scene_max.o.x - scene_min.o.x
                        local scene_height = scene_max.o.y - scene_min.o.y
                        local res = menu_data.items.slider_res.val/100
                        local img_width = round(scene_width/res)
                        local img_height = round(scene_height/res)
                        local estimate = img_width*img_height * 4 * 10^-7

                        --caption item gets auto generated
                        self.caption_item.text = string.format("Resolution: %.2fm", res)
                        menu_data.items.imgsize.text = string.format(
                            "Image Size: %dx%d px (~%.1f minutes)", img_width, img_height, estimate)
                    end,
                    init_change = true, --this will trigger OnChange once after item loaded to set caption
                },
                {
                    id = "imgsize",
                    type = "text",
                    text = "",
                    scale = 0.5,
                    margin_top = -0.005
                },
                {
                    type = "text",
                    text = "Warning: big images sizes can take very long!",
                    scale = 0.5,
                    margin_top = -0.01
                },
                {
                    id = "slider_res_water",
                    type = "slider",
                    text = "Water level: -0.30m",
                    val = -3,
                    min = -100, -- -10m
                    max = 100,  --  10m
                    OnChange = function(menu_data, self, val)
                        self.caption_item.text = string.format("Water level: %.2fm", val/10)
                    end
                },
                {
                    type = "text",
                    text = "Terrain below this level will be drawn in blue",
                    scale = 0.5,
                    margin_top = -0.005
                },
                {
                    id = "cb_draw_spawns",
                    type = "checkbox",
                    text = "Draw Spawn Points",
                },
                {
                    id = "cb_number_spawns",
                    type = "checkbox",
                    val = 1,
                    text = "Number Spawn Points",
                },
                {
                    id = "slider_contour",
                    type = "slider",
                    val = 5,
                    min = 0,
                    max = 50,
                    text = "Contour Lines",
                    OnChange = function(menu_data, self, val)
                        menu_data.items.slider_contour_info.text = string.format("%dm increment. Set to 0 to disable", val)
                    end
                },
                {
                    id = "slider_contour_info",
                    type = "text",
                    text = "5m increment. Set to 0 to disable",
                    scale = 0.5,
                },
                {
                    type = "btn",
                    text = "Start Draw",
                    OnChange = function(menu_data)
                        draw_height_map(menu_data.items.slider_res.val/100, 
                                        menu_data.items.slider_res_water.val/10,
                                        menu_data.items.cb_draw_spawns.checked,
                                        menu_data.items.cb_number_spawns.checked,
                                        menu_data.items.slider_contour.val)
                    end
                },
            {
                type = "section_end",
                line = true,
            },
            {
                type = "section",
                text = "Hotkeys",
            },
                {
                    type = "text",
                    text = "Ctrl + B: Toggle Fly Mode / Fast Cam (edit mode)",
                    scale = 0.8
                },
                {
                    type = "text",
                    text = "E / C: Up/Down (Fly Mode)",
                    scale = 0.8
                },
                {
                    type = "text",
                    text = "Ctrl + N: Teleport to next Entry Point",
                    scale = 0.8
                },
                {
                    type = "text",
                    text = "V: Teleport",
                    scale = 0.8
                },
            {
                type = "section_end",
                text = "Draw Map",
            },
        },
    })
end)