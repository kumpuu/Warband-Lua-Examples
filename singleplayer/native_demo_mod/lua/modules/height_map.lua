require "bmp"

local prop_colors = require "modules/prop_colors"
local scene_min, scene_max --scene boundaries pos
local scene_width, scene_height
local img_width, img_height
local z_min, z_max, z_water
local step
local contour_map = {}

--translate world coordinate to image coordinate
local function world_2_img(vec)
    vec = vec - scene_min.o
    vec.x = img_width  * vec.x / scene_width
    vec.y = img_height * vec.y / scene_height
    return vec
end

--This function finds out the scenes min and max terrain heights
--It also figures out contour lines and writes it to contour_map
--contour_dz is the vertical distance between contour lines
local function scan_terrain(contour_dz)
    local p_cur = game.pos.new(scene_min)
    z_min, z_max = nil, nil

    local contour_map_tmp = {}
    --Find out min/max z of terrain first
    for x = 1, img_width do
        contour_map_tmp[x] = {}
        
        for y = 1, img_height do
            game.pos0 = p_cur
            game.position_set_z_to_ground_level(0)
            local z = game.pos0.o.z
            if not z_min or z < z_min then z_min = z end
            if not z_max or z > z_max then z_max = z end
            contour_map_tmp[x][y] = z

            p_cur.o.y = p_cur.o.y + step
        end

        p_cur.o.y = scene_min.o.y
        p_cur.o.x = p_cur.o.x + step
    end

    if contour_dz > 0 then
        --Figure out contour lines
        for x = 1, img_width do
            for y = 1, img_height do
                local z2 = contour_map_tmp[x][y] - z_min
                z2 = (z2 % (2*contour_dz))
                if z2 < 0 then z2 = z2 + 2*contour_dz end
                contour_map_tmp[x][y] = z2 < contour_dz
            end
        end

        -- Filter contour map - only keep pixels that have at least one neighboor which is not contour
        for x = 1, img_width do
            contour_map[x] = {}
            for y = 1, img_height do
                contour_map[x][y] = 0
                
                if contour_map_tmp[x][y] then
                    for dx = -1, 1 do
                        for dy = -1, 1 do
                            if not (contour_map_tmp[x+dx] or {})[y+dy] then 
                                contour_map[x][y] = 1
                                goto continue 
                            end
                        end
                    end
                    -- contour_map[x][y] = 1 --testing
                end
                ::continue::
            end
        end

        -- Gauss blur contour map a bit for antialiasing
        local kernel = {
            {1,2,1},
            {2,4,2},
            {1,2,1}
        }

        for x = 1, img_width do
            for y = 1, img_height do
                local sum = 0
                for dx = -1, 1 do
                    for dy = -1, 1 do
                        local px = ((contour_map[x+dx] or {})[y+dy] or 0)
                        sum = sum + px * kernel[dy+2][dx+2]
                    end
                end
                contour_map_tmp[x][y] = sum/16
                ::continue::
            end
        end

        contour_map = contour_map_tmp
    end
end

--Draw the height map using raycasts
--Also apply countour lines
local function draw(canvas_object, contour_dz)
    --Find min/max z
    scan_terrain(contour_dz)

    local p_cur = game.pos.new(scene_min)
    p_cur:rotX(-90)
    p_cur.o.z = z_max + 50

    local contour_buf = {}

    for x = 1, img_width do
        contour_buf[x] = {}

        for y = 1, img_height do
            local hit, prop_inst_no
            prop_inst_no = -1
            hit, prop_inst_no = game.cast_ray(0, p_cur) --will store into pos0
            local z = game.pos0.o.z

            local r,g,b
            if not game.prop_instance_is_valid(prop_inst_no) then
                if z <= z_water then
                    r,g,b = 0,0,1 --water color
                    z = (z_max-z_min) * ((z - z_min) / (z_water - z_min))
                else
                    r,g,b = 0,1,0 --grass color
                end
            else
                --get prop color
                local prop_kind = game.prop_instance_get_scene_prop_kind(prop_inst_no)
                r,g,b = unpack(prop_colors[prop_kind][2])
                r,g,b = r/255, g/255, b/255
            end

            local a = 0.3 + 0.7 * (z-z_min) / (z_max-z_min)
            if prop_inst_no==-1 and contour_dz>0 and contour_map[x][y]>0 then
                a = a * (1 - 0.15*contour_map[x][y])
            end

            r,g,b = r*a, g*a, b*a
            canvas_object:set_pixel(x, y, r, g, b)
                
            p_cur.o.y = p_cur.o.y + step
        end

        p_cur.o.y = scene_min.o.y
        p_cur.o.x = p_cur.o.x + step
    end
end

local function draw_spawns(canvas_object, draw_nums)
    for i = 1, 1000 do
        if not game.entry_point_is_auto_generated(i) then
            game.entry_point_get_position(0, i)
            local p = game.pos0
            local f = p.rot.f:unit()
            local s = p.rot.s:unit()

            local arrow_root  = world_2_img(p.o)
            local arrow_tip   = world_2_img(p.o + f*2)
            local arrow_right = world_2_img(p.o + f*1.5 + s*0.5)
            local arrow_left  = world_2_img(p.o + f*1.5 - s*0.5)

            local r,g,b = 0,0,0.6
            canvas_object:draw_line(arrow_root.x,  arrow_root.y,  arrow_tip.x, arrow_tip.y, r,g,b)
            canvas_object:draw_line(arrow_left.x,  arrow_left.y,  arrow_tip.x, arrow_tip.y, r,g,b)
            canvas_object:draw_line(arrow_right.x, arrow_right.y, arrow_tip.x, arrow_tip.y, r,g,b)

            if draw_nums then
                r,g,b = 0.1,0.1,0.5
                canvas_object:draw_number(i, round(arrow_root.x+5), round(arrow_root.y), r,g,b)
            end
        end
    end
end

function draw_height_map(res, _z_water, draw_spawn_points, number_spawn_points, contour_dz)
    --we want to get scene name from ID_scenes.py
    --but it got merged with header_scenes.py... so filter for actual scene names
    local scenes = table.filter(game.const.scenes, function(k,v,t) return string.starts_with(k, "scn_") end)

    local scene_no = game.store_current_scene()
    local scene_name = table.find(scenes, scene_no)
    if not scene_name then scene_name = "map" end

    print("Writing image to " .. scene_name .. ".bmp")
    print("This could take a while...")

    timeout.add(500, function() --Wrap in timeout so that the prints have time to display
        step = res or 0.5
        z_water = _z_water or -0.3

        game.get_scene_boundaries(0, 1)
        scene_min = game.pos0
        scene_max = game.pos1

        scene_width  = scene_max.o.x - scene_min.o.x
        scene_height = scene_max.o.y - scene_min.o.y

        img_width = round(scene_width / step)
        img_height = round(scene_height / step)

        --Now lets do actual drawing
        local canvas_object = canvas.new(img_width, img_height)
        draw(canvas_object, contour_dz)

        if draw_spawn_points then draw_spawns(canvas_object, number_spawn_points) end

        --Save to disk
        mkdir("height_maps")
        canvas_object:save(string.format("height_maps/%s.bmp", scene_name))
        print("Image saved.")
    end)
end