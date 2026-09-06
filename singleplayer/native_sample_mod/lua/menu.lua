--Creates and shows a menu that dynamically creates the presentation

menu = {}

local menu_data_proto = {
    backgroundMesh = 
    {
        mesh = game.const.mesh_mp_ingame_menu,
        pos = {
            x = 0.25,
            y = 0.08,
        },
        scale = {
            x = 1,
            y = 1,
        },
    },

    containerscale =
    {
        x = 0.41,
        y = 0.47,
    },

    startPos = {x = 0.28, y = 0.61},

    caption = {
      text = "caption",
      scale = 1.2,
      color = 0xFFFFFF,  
    },


    --During prsnt_build this is a simple list as shown below, with data coming from the user.
    --At the end of prsnt_build it will be replaced with a dict where key=id and val=item
    items = {
        --[[ Possible Types:
        {
            type = "text",
            id = "text1",
            text = "Sample text",
        },
        {
            type = "line",
            scale_x = 0.5,
        },
        {
            type = "button",
            id = "button1",
            text = "Btn 1 text",
        },
        {
            type = "checkbox",
            id = "checkbox1",
            text = "cb 1 caption",
        },
        {
            type = "combo",
            id = "combo_button_1",
            text = "combo1 caption",
            val = initial_val or 0,
            values = {
                "Option 1",
                "Option 2",
                "Option 3",
            }
        },
        {
            type = "slider",
            id = "slider_1",
            text = "slider_1 caption",
            val = initial_val or 0,
            min = 0,
            max = 100
        },
        {
            type = "section",
            id = "section1",
            text = "Section 1 Caption",
            line = true,
        },
            {
                type = "text",
                id = "text2",
                text = "Sample text",
            },
        {
            type = "section_end",
            id = "section1",
            text = "Section 1 Caption",
        },

        Each item can have optional OnChange function (OnEventStateChange callback)
        ]]
    },

    callbacks = {
        --These are optional
        -- OnLoad = function(menu_data, pos) ... end,
        -- OnRun = function(menu_data) ... end,
        -- OnEventStateChange = function(menu_data, item.id, val) ... end,
    },

    timeout = 999999,
    quit = false,

    escapeKey = game.const.triggers.key_escape,

    --This gets populated by prsnt_build
    overlay_items = {},    --this has overlay_no as key and item as value
}

local menu_data = {}

local function prsnt_build()
    local pos = game.pos0
    local scalePos = game.pos0

    local itemHeight = 0.02
    local scrollContainer

    -------Create Backdrop-------
    if menu_data.backgroundMesh then
        local bg = game.create_mesh_overlay(menu_data.backgroundMesh.mesh)

        pos.o.x = menu_data.backgroundMesh.pos.x
        pos.o.y = menu_data.backgroundMesh.pos.y
        game.overlay_set_position(bg, pos)

        scalePos.o.x = menu_data.backgroundMesh.scale.x
        scalePos.o.y = menu_data.backgroundMesh.scale.y
        game.overlay_set_size(bg, scalePos)

        menu_data.background_overlay = bg
    end

    -------Create Menu Caption-------
    if menu_data.caption then
        --the game will draw the background mesh over the caption unless it's in a scroll container, which makes it look too dimm
        --so create this dummy scroll container
        scrollContainer = game.create_text_overlay("", game.const.tf_scrollable_style_2)
        pos.o.x = menu_data.startPos.x
        pos.o.y = menu_data.startPos.y
        game.overlay_set_position(scrollContainer, pos)

        scalePos.o.x = menu_data.containerscale.x*1.05
        scalePos.o.y = 0.02 * menu_data.caption.scale
        game.overlay_set_area_size(scrollContainer, scalePos)

        game.set_container_overlay(scrollContainer)

    
        local caption = game.create_text_overlay(menu_data.caption.text, game.const.tf_with_outline)
        pos.o.x = 0
        pos.o.y = 0
        scalePos.o.x = menu_data.caption.scale
        scalePos.o.y = menu_data.caption.scale

        game.overlay_set_size(caption, scalePos)
        game.overlay_set_position(caption, pos)
        game.overlay_set_color(caption, menu_data.caption.color)
        menu_data.caption_overlay = caption


        local line = game.create_mesh_overlay(game.const.mesh_white_plane)
        pos.o.x = 0.005
        pos.o.y = pos.o.y - 0.002
        scalePos.o.x = 22
        scalePos.o.y = 0.08
        game.overlay_set_size(line, scalePos)
        game.overlay_set_position(line, pos)
        game.overlay_set_alpha(line, 200)
        menu_data.caption_underline_overlay = line

        game.set_container_overlay(-1)

        pos.o.x = menu_data.startPos.x
        pos.o.y = menu_data.startPos.y --we were in relative (to scroller) coordinates before, now return to global
        pos.o.y = pos.o.y - itemHeight * menu_data.caption.scale * 0.5
    else
        pos.o.x = menu_data.startPos.x
        pos.o.y = menu_data.startPos.y
    end

    -------Create Scroll Box-------
    scrollContainer = game.create_text_overlay("", game.const.tf_scrollable_style_2)
    pos.o.y = pos.o.y - menu_data.containerscale.y
    game.overlay_set_position(scrollContainer, pos)

    scalePos.o.x = menu_data.containerscale.x
    scalePos.o.y = menu_data.containerscale.y
    game.overlay_set_area_size(scrollContainer, scalePos)

    game.set_container_overlay(scrollContainer)

    -------This is a helper "class" that converts user provided table into useful object-------
    local unnamed = {}
    local item
    item = {
        prototype = {
            --base vars contain type-specific information
            --if user has set his own value, it should add/multiply with the base value
            base_offset_left = 0,
            base_offset_y    = 0,
            base_height      = 0.02,
            base_margin_top  = 0.015,   --distance from item above
            base_scale_x     = 1,
            base_scale_y     = 1,
            base_alpha       = nil,     --transparency

            --these may be additionally specified by user
            offset_left  = 0,
            offset_y     = 0,
            margin_top   = 0,
            color        = 0xFFFFFF,
            scale        = 1,
        },

        --Automate get/set for these (will be forwarded to game.set_overlay_xyz when user sets item.xyz)
        --value gets buffered in __xyz
        forwards = {
            text = "",
            color = 0xFFFFFF,
            alpha = 1,
            display = true,
        },

        mt = {
            __index = function(self, k)
                if self.type == "checkbox" and k == "val" then --overlay_get_val doesnt work for checkbox
                    return self.__val

                elseif self.type == "checkbox" and k == "checked" then
                    return self.__val==1

                elseif k == "val" then
                    return game.overlay_get_val(self.overlay)

                elseif item.forwards[k] then
                    return self["__"..k] or item.forwards[k]

                else
                    return item.prototype[k]
                end
            end,

            __newindex = function(self, k, v)
                if k == "val" then
                    game.overlay_set_val(self.overlay, v)
                elseif k == "checked" then
                    self.__val = (v and 1) or 0
                    game.overlay_set_val(self.overlay, self.__val)
                elseif item.forwards[k] then
                    self["__"..k] = v
                    game.execOperation("overlay_set_"..k, self.overlay, v)
                else
                    rawset(self, k, v)
                end
            end
        },

        new = function(t)
            setmetatable(t, item.mt)

            if not t.id then
                unnamed[t.type] = (unnamed[t.type] or 0) + 1
                t.id = string.format("unnamed_%s_%d", t.type, unnamed[t.type])
            end

            local function make_caption(offset_left, offset_y)
                if t.text then
                    return item.new({
                        id = t.id .. "_caption",
                        type = "text",
                        text = t.text,
                        scale = t.scale * 0.8,
                        base_offset_left = t.offset_left + offset_left,
                        base_margin_top = 0,
                        base_height = 0,
                        offset_y = offset_y
                    })
                end
            end

            if t.type == "text" then
                t.overlay = game.create_text_overlay(t.text, t.style or 0)

            elseif t.type == "btn" then
                t.overlay = game.create_button_overlay(t.text)

            elseif t.type == "checkbox" then
                t.overlay = game.create_check_box_overlay(game.const.mesh_checkbox_off, game.const.mesh_checkbox_on)
                t.base_offset_left = 0.01
                t.caption_item = make_caption(0.03)
                t.__val = t.val or 0

            elseif t.type == "combo" then
                t.overlay = game.create_combo_button_overlay()
                t.base_offset_left = 0.128
                t.base_height = 0.03
                t.base_scale_x = 0.8
                t.caption_item = make_caption(0.21,0.005)

                for i = 1, #t.values do
                    game.overlay_add_item(t.overlay, t.values[i])
                end
                game.overlay_set_val(t.overlay, t.val or 0)

            elseif t.type == "slider" then
                t.overlay = game.create_slider_overlay(t.min or 0, t.max or 100)
                t.base_height = 0.03
                t.base_scale_x = 0.78
                t.base_offset_left = 0.135
                t.caption_item = make_caption(0.21,0.005)

            elseif t.type == "section" then
                t.overlay = game.create_text_overlay(t.text, t.style or 0)

            elseif t.type == "section_end" then
                t.base_height = 0
                t.base_margin_top = 0

            elseif t.type == "line" then
                t.overlay = game.create_mesh_overlay(game.const.mesh_white_plane)
                t.base_scale_x = 19
                t.base_scale_y = 0.05
                t.base_height = 0.005
                t.base_margin_top = 0.005
                t.base_offset_y = -0.005
                t.base_alpha = 0.3

            else
                print("menu.lua: invalid overlay type " .. tostring(t.type), t.id)
                return
            end

            if t.overlay then
                menu_data.overlay_items[t.overlay] = t

                if t.type == "checkbox" and t.checked~=nil then
                    game.overlay_set_val(t.overlay, (t.checked and 1) or 0)
                elseif t.val then
                    game.overlay_set_val(t.overlay, t.val)
                end
            end

            --we must now delete forwarded fields, otherwise the metatable wont be triggered
            for k,v in pairs(t) do
                if item.forwards[k] then
                    t["__"..k] = v
                    rawset(t, k, nil)
                end
            end
            rawset(t, "val", nil)
            rawset(t, "checked", nil)

            return t, t.caption_item
        end,
    }

    -------Apply above "class" to menu_data.items, also some section handling-------
    local is_in_section = false
    local generated_items = {}

    for i, itm in ipairs(menu_data.items) do
        --Handle sections
        local prev_itm  = menu_data.items[i-1] or {}
        if itm.type == "section" then
            is_in_section = true
            -- itm.color = itm.color or 0xD0D0D0

            if itm.line and not prev_itm.line then
                local line = item.new({type = "line", scale_x = 1})
                table.insert(generated_items, line)
            end
        
        elseif itm.type == "section_end" then
            is_in_section = false

            if itm.line then
                local line = item.new({type = "line", scale_x = 1})
                table.insert(generated_items, line)
            end

        elseif is_in_section then
            itm.is_in_section = true
        end

        --Convert to use item "class"
        local caption 
        itm, caption = item.new(itm)
        table.insert(generated_items, itm)
        table.insert(generated_items, caption) --might be nil which wont change the table--Handle Sections

        if is_in_section and caption then caption.is_in_section = true end
    end

    menu_data.items = {}

    -------Finally, set position, size, etc to overlays                       -------
    -------Backwards, because we start at y=0 which is the bottom of the menu.-------
    pos.o.y = 0 --bottom of scroll container
    for i = #generated_items, 1, -1 do
        local itm = generated_items[i]
        itm.index = i --might be useful for user
        menu_data.items[itm.id] = itm

        -- if itm.type =="slider" then
        --     print("****")
        --     printTable(itm, "  ")
        -- end
        pos.o.x = ((itm.is_in_section and 0.05) or 0.02) +
                    itm.base_offset_left + itm.offset_left

        local off_y = itm.base_offset_y + itm.offset_y  
        pos.o.y = pos.o.y + off_y

        local scale_x = (itm.scale_x or itm.scale)
        local scale_y = (itm.scale_y or itm.scale)
        scalePos.o.x = itm.base_scale_x * scale_x
        scalePos.o.y = itm.base_scale_y * scale_y

        if itm.overlay then
            game.overlay_set_position(itm.overlay, pos)
            game.overlay_set_size(itm.overlay, scalePos)
            game.overlay_set_color(itm.overlay, itm.color)

            if itm.alpha or base_alpha then
                game.overlay_set_alpha(itm.overlay, (base_alpha or 1) * (itm.alpha or 1) * 255)
            end
        end

        pos.o.y = pos.o.y - off_y
        pos.o.y = pos.o.y + itm.base_height * scale_y + itm.base_margin_top + itm.margin_top 
    end

    game.presentation_set_duration(menu_data.timeout)

    for _, v in pairs(menu_data.items) do
        if v.OnLoad then v.OnLoad(menu_data, v) end
        if v.init_change then v.OnChange(menu_data, v, v.val) end
    end

    if menu_data.callbacks.OnLoad then
        menu_data.callbacks.OnLoad(menu_data, pos)
    end
end

local function prsnt_OnRun()
    local curTime = game.store_trigger_param_1()

    if menu_data.quit then
        if menu_data.callbacks.OnClose then
            menu_data.callbacks.OnClose(menu_data)
        end

        game.presentation_set_duration(0)
        return
    end

    if curTime > 200 then
        if menu_data.escapeKey and game.key_clicked(menu_data.escapeKey) then
            game.presentation_set_duration(0)
            --prevent dumb escape menu from showing
            timeout.next_frame(function() game.presentation_set_duration(0, game.const.prsnt_multiplayer_escape_menu) end)
        end
    end

    if menu_data.callbacks.OnRun then
        if menu_data.callbacks.OnRun(menu_data) then
            game.presentation_set_duration(0)
        end
    end
end

local function prsnt_OnChange()
    local overlay_no = game.store_trigger_param_1()
    local value = game.store_trigger_param_2()

    local item = menu_data.overlay_items[overlay_no]
    if not item then return end

    if item.type == "checkbox" then
        item.__val = value
    end

    --Call items OnChange first
    if item.OnChange and item.OnChange(menu_data, item, value) then
        game.presentation_set_duration(0)
    end

    --Now call general callback
    if menu_data.callbacks.OnChange and menu_data.callbacks.OnChange(menu_data, item, value) then
        game.presentation_set_duration(0)
    end
end

menu.prsnt = game.addPrsnt({
    id = "luaMenu",
    flags = {game.const.prsntf_manual_end_only},
    triggers = {
        [game.const.ti_on_presentation_load] = prsnt_build,
        [game.const.ti_on_presentation_run] = prsnt_OnRun,
        [game.const.ti_on_presentation_event_state_change] = prsnt_OnChange,
    }
})

function menu.show(_menu_data)
    menu_data = _menu_data or {}
    table.merge(menu_data, menu_data_proto, true)
    -- table.print(menu_data)

    game.start_presentation(menu.prsnt)
end

function menu.close()
    menu_data.quit = true
end

--auto close menu on hot reload
event_mgr.subscribe("before_hot_reload", function() menu.close() end)
