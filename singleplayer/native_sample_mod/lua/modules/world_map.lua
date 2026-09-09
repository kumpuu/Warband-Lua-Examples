
event_mgr.world_timer("once", "welcome_timer", function(date)
	print("Welcome to the native lua sample mod. The current date is: " .. date)
end)



--this runs every hour while on the world map
--We are not guaranteed however that it will be the very start of the hour,
--So our servant might remind us a bit late.
local first = true
event_mgr.world_timer(1, "test_id", function(date)
	--this might return nil, false, true. Only true will pass
	if not savegame_mgr.get("world_map_tell_hour", true) then return end

	local hour = math.floor(date % 24)
	--date is in hours since game start
	--so hour mod 24 is hour of day.

	local am
	if hour > 12 then
		am = "pm"
		hour = hour - 12
	else
		am = "am"
	end

	game.display_message("{Sir/Madame}, it is now " .. hour .. " o'clock " .. am .. ".")
	if first then
		first = false
		game.display_message("Press 'R' to disable this message.")
	end
end)

event_mgr.subscribe("world_key_r", function()
	local tell = not savegame_mgr.get("world_map_tell_hour", true)

	if tell then
		print("Your servant will remind you of the hour.")
	else
		print("Your servant will be silent.")
	end
	savegame_mgr.set("world_map_tell_hour", tell)
end)

event_mgr.subscribe("game_event_party_encounter", function()
	print("Just encountered a party in lua.")
end)

event_mgr.subscribe("world_key_o down=key_shift key_control", function()
	do_hot_reload(true)
end)