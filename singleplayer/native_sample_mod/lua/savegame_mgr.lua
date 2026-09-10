--This manages storing/loading additional data from a savegame
--When the game saves to a slot, it will store an additional .json next to the .sav file.
--During savegame load, this .json gets loaded again.
--It sets OnGameLoad, OnSave, OnLoadSave functions, obviously don't set them in another file or things will break.
--If you need to hook these events, do it with event_mgr

local json = require "json"

savegame_mgr = {
	data = {},
}

--Best practice: start key with owner name
--E.g. event_mgr_world_timers instead of just world_timers
function savegame_mgr.set(key, val)
	savegame_mgr.data[key] = val
end

function savegame_mgr.get(key, default)
	return savegame_mgr.data[key] or (savegame_mgr.data[key]==nil and default)
end

game.OnGameLoad = function()
	log_rgl("Game loaded")
	event_mgr.dispatch("OnGameLoad", slot, md5)
end

function game.OnSave(slot)
	game.str_store_savegame_md5(0, slot)
	local md5 = game.s0
	log_rgl("savegame_mgr: game saved into slot " .. slot .. ", md5 is " .. md5)

	local path = string.format("%%savegames%%/sg%02d.json", slot)
	local f = io.open(path, "w+")

	if f then
		event_mgr.dispatch("savegame_mgr_before_save", slot, md5) --for last minute writes

		local txt = json.encode({md5 = md5, data = savegame_mgr.data}, true)
		f:write(txt)
		f:close()
		log_rgl("savegame_mgr: saved " .. #savegame_mgr.data .. " entries to slot " .. slot)
	else
		log_rgl("savegame_mgr: warning: could not save to slot " .. slot)
	end

	event_mgr.dispatch("OnSave", slot, md5)
end

function game.OnLoadSave(slot)
	game.str_store_savegame_md5(0, slot)
	local md5 = game.s0
	log_rgl("savegame_mgr: game loaded from slot " .. slot .. ", md5 is " .. md5)

	local path = string.format("%%savegames%%/sg%02d.json", slot)
	local f = io.open(path, "r")

	if f then
		local txt = f:read("*a")
		f:close()

		local data = json.decode(txt)
		if data.md5 == md5 then
			savegame_mgr.data = data.data
			log_rgl("savegame_mgr: loaded " .. #savegame_mgr.data .. " entries from slot " .. slot)
			event_mgr.dispatch("savegame_mgr_after_load", slot, md5)
		else
			log_rgl("savegame_mgr: found .json for slot " .. slot .. ", but md5 mismatch")
		end
	end

	event_mgr.dispatch("OnLoadSave", slot, md5)
end