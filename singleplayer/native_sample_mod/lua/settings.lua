local json = require "json"

--[[
Usage:
	settings.<name>.xyz = 1
	local val = settings.<name>.xyz

To set default values:
	settings.<name>:init({
		xyz = 1,
		uvw = 0
	})
or  
	settings.<name>:get("xyz", default_value)

<name> can not be "save", "init", "get"
It will automatically load and save from disk
]]

local section = {}

section.prototype = {
	save = function(self)
		mkdir("settings")
		local f = io.open(self.__path, "w+")
		if f then
			local txt = json.encode(self.__data, true)
			f:write(txt)
			f:close()
		end
	end,

	init = function(self, defaults)
		assert(not defaults.save, "Settings: 'save' is a reserved identifier")
		assert(not defaults.init, "Settings: 'init' is a reserved identifier")
		assert(not defaults.get, "Settings: 'get' is a reserved identifier")
		table.merge(self.__data, defaults)
	end,

	get = function(self, name, default)
		assert(not section.prototype[name], "Settings: '" .. name .. "' is a reserved identifier")
		if not self.__data[name] then self.__data[name] = default end
		return self.__data[name]
	end,
}

section.mt = {
	--read
	__index = function(self, k)
		return section.prototype[k] or self.__data[k]
	end,

	--write
	__newindex = function(self, k, v)
		if self.__data[k] == v then return end
		assert(not section.prototype[k], "Settings: '" .. k .. "' is a reserved identifier")

		self.__data[k] = v
		
		--We always want to save changes to disk, but 5s after the last write (prevents excessive saving during batch write)
		if self.__save_timeout > 0 then timeout.cancel(self.__save_timeout) end
		self.__save_timeout = timeout.add(5000, function()
			self.__save_timeout = 0
			self:save()
			-- print("saved")
		end)
	end
}

function section.new(name)
	local sect = setmetatable({
			__data = {},
			__path = "settings/" .. name .. ".json",
			__save_timeout = 0
		}, section.mt)

	if file_exists(sect.__path) then
		local f = io.open(sect.__path, "r")
		if f then
			local txt = f:read("*a")
			f:close()

			if txt ~= "" then
				local ok, result = pcall(json.decode, txt)
				if ok then
					table.merge(sect.__data, result)
				else
					print(string.format("Settings-json error in '%s': %s", sect.__path, result))
				end
			end
		end
	end

	return sect
end 




--All this does is dynamically create new sections. It resolves the <name> part.
settings = {}

settings.mt = {
	__index = function(self, k)
		self[k] = section.new(k)
		return self[k]
	end
}

setmetatable(settings, settings.mt)