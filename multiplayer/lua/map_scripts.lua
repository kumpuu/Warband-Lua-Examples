--[[
  Before map start, searches for ./lua/map_scripts/<mapname>.lua and executes it in its own environment (using setfenv)
  The script can read from root _G via the metatable, event_mgr is wrapped though in order to auto-unsub at map change
]]

local subbed_events = {}

--wrap event_mgr so we can log all subscriptions and auto-unsub at map change
local fenv_mt = {
  __index = setmetatable({
    event_mgr = {
      subscribe = function(event_id, callback)
        local idx = _G.event_mgr.subscribe(event_id, callback)
        table.insert(subbed_events, {event_id = event_id, idx = idx})
        -- print("SUBBED", event_id, idx)
        return idx
      end,

      unsubscribe = function(event_id, index)
        -- print("UNSUBBED", event_id, index)
        for i,v in ipairs(subbed_events) do
          if v.idx == index then
            -- print("found for unsub " .. index)
            table.remove(subbed_events, i)
            return _G.event_mgr.unsubscribe(event_id, index)
          end
        end
      end,

      dispatch = _G.event_mgr.dispatch
    }   
  }, {__index = _G})
}

local scene_names = {}
for k,v in pairs(game.const.scenes) do scene_names[v] = k end

local function load_map_script(map_name)
  local fname = "map_scripts\\" .. map_name .. ".lua"
  local f = io.open(fname, r)
  if not f then
    -- print("no script for map " .. map_name)
    return
  end
  f:close()

  local func, error = loadfile(fname)
  if not func then print("Error loading " .. fname .. ": " .. error); return end

  local fenv = {}
  setmetatable(fenv, fenv_mt)

  setfenv(func, fenv)
  func()
end

event_mgr.subscribe("ti_before_mission_start", function()
  --clean events from last map
  for _,v in pairs(subbed_events) do
    -- print("unsub", v.event_id, v.idx)
    event_mgr.unsubscribe(v.event_id, v.idx)
  end
  subbed_events = {}

  local scene = game.store_current_scene(0)
  load_map_script(scene_names[scene])
end)