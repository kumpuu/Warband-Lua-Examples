if not game_op_is_default then
    game_op_is_default = true
    
    --see manual
    game.op.make_default()
end

require "hot_reload"

require "util"
require "event_mgr"
require "timeout"
require "settings"
require "savegame_mgr"
require "root_menu"


--I think normally each module should require its requirements individually.
--require is built for that and it's more portable.
--However, this mod chose a different pattern where most libraries create a global var that others can use,
--and we only require them once in main.lua
require "modules/scene_tools"
require "modules/console"
require "modules/battle_toys"
require "modules/clock"
require "modules/center_dot"
require "modules/world_map"

print("~ Lua Loaded ~")
