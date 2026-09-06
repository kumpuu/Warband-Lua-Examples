--This serves as manager that other modules can add their buttons to.
--Pressing J will open this root menu

require "menu"

root_menu = {}
local data_store = {}
local owner_data = {}

function root_menu.add(owner_name, menu_data)
    if menu_data.items then
    	--prefix overlay ids to avoid collision
        for _, itm in pairs(menu_data.items) do
            if itm.id then
                itm.id = owner_name .. "_" .. itm.id
            end
        end
    end

    table.insert(data_store, menu_data)
    owner_data[owner_name] = menu_data
end

function root_menu.add_btn(text, callback)
    local id = "##" .. getFunctionId(callback)

    root_menu.add(id, {
        items = {
            {
                id = "btn",
                type = "btn",
                text = text,
                OnChange = callback
            }
        },
    })
end

function root_menu.show()
    game.presentation_set_duration(0, game.const.prsnt_multiplayer_welcome_message)
    game.presentation_set_duration(0, game.const.prsnt_multiplayer_team_select)
    game.presentation_set_duration(0, game.const.prsnt_multiplayer_escape_menu)

    local my_menu = {
        caption = {
            text = "Lua Menu"
        },

        items = {},

        callbacks = {
            OnLoad = function(menu_data, pos)
                for _, data in pairs(owner_data) do
                    if data.callbacks and data.callbacks.OnLoad then
                        data.callbacks.OnLoad(menu_data, pos)
                    end
                end
            end,

            OnChange = function(menu_data, item, value)
                local owner, id = item.id:match("(.-)_(.+)")

                local data = owner_data[owner]
                if data and data.callbacks and data.callbacks.OnChange then
                    return data.callbacks.OnChange(menu_data, id, value, owner .. id)
                end
            end,
        },
    }

    for _, data in ipairs(data_store) do
        if data.items then
            for k, itm in pairs(data.items) do
                table.insert(my_menu.items, itm)
            end
        end
    end

    menu.show(my_menu)
end

event_mgr.subscribe("key_j", function()
    if game.is_presentation_active(menu.prsnt) then
        menu.close()
    else
        root_menu.show()
    end
end)