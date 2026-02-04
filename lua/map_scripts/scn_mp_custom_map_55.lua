--Football script made by Austerl1tz and modified by Kumpu
--Tropical Paradise 2025

--Use spr_stone_ball or spr_mm_cannonball_code_only_36pd

local ball_radius = 0.35 --m
local ball_prop_kind = "spr_stone_ball"
local ball_reset_time = 7 --seconds

local goal_width = 3.9 --In m. Total gate width will be 2x this!
local goal_depth = 2-ball_radius*0.7 --m
local goal_height = 4 --m

--0=disabled 1=knockdown 2=complete immunity
local damage_block = 0

local dt = 1/30 --physics update period in sec
local speed_mul = 0.22
local wall_bounce_mul = -2
local net_bounce_mul = -0.2
local friction_mul = 0.5^dt --Means speed gets multiplied by 0.5 each second
local bounce_mul = 0.6
local rotation_alpha_air = 0.5
local rotation_alpha_ground = 5 *dt
local gravity = 9.81
local sun_dir = vector3.new({x=2.27,y=0.1,z=-2.95}) --used to project shadow

------------------------------------------------------------

local borders = {}
local coord = 0
local fieldcenter = 0
local ballprop = 0
local shadow_prop
local ballbarrier = 0

local ux = vector3.new({x=1})
local uy = vector3.new({y=1})
local uz = vector3.new({z=1})
local velocity = vector3.new()
local rotation_axis = vector3.new()

local last_hit_agent_north --Towards Y+ / Team2's goal
local last_hit_agent_south --Towards Y- / Team1's goal

local goal_right = 0
local goal_left = 0
local goal_top = 0

local ball_enabled = false

local z_ground --The "virtual floor", grass level + ball radius

local debug_timer = 0

--Enum
local sides =
{
  none = 0,
  north = 1,
  south = 2
}

local goal_side = sides.none

local goals_1st = 0
local goals_2nd = 0
local goals_1st_scb = -11
local goals_2nd_scb = -11

local scoreboard_prop
-- local scoreboard_active = 0
local scoreboard_center
local test_timer = 0

local actual_numbers = {}
local old_numbers = {}

local numbers = {
  {12,13,14,21,25,31,34,35,41,43,45,51,52,55,61,65,72,73,74},
  {13,22,23,33,43,53,63,72,73,74},{12,13,14,21,25,35,44,53,62,71,72,73,74,75},
  {12,13,14,21,25,35,43,44,55,61,65,72,73,74},
  {14,23,24,32,34,41,44,51,52,53,54,55,64,74},
  {11,12,13,14,15,21,31,32,33,34,45,55,65,61,72,73,74},
  {12,13,14,21,25,31,41,42,43,44,51,55,61,65,72,73,74},
  {11,12,13,14,15,25,34,43,53,63,73},
  {12,13,14,21,25,31,35,42,43,44,51,55,61,65,72,73,74},
  {12,13,14,21,25,31,35,42,43,44,45,55,61,65,72,73,74}
}

local scoreboard_active_props = {{},{},{},{}}

local player_data = {}
local teams = {0, 0}

local slot_player_damage_info = game.const.slot_player_map_script_1
local slot_agent_warning = game.const.slot_agent_map_script_1

function Init()
  for prop in game.propInstIt() do
    local propkind = game.prop_instance_get_scene_prop_kind(0, prop)

    if propkind == game.const.spr_band_a then
      game.prop_instance_get_position(1, prop)
      local p = game.preg[1]
      local var1 = game.prop_instance_get_variation_id(0, prop)

      if var1 == 1 or var1 == 3 then
        coord = p.o.x
        if var1 == 3 then
          scoreboard_prop = prop
        end

      elseif var1 ==2 or var1 == 4 then
        coord = p.o.y

      elseif var1 == 5 then
        fieldcenter = prop
        goal_right = p.o.x + goal_width
        goal_left = p.o.x - goal_width
        goal_top = p.o.z + goal_height
      end

      borders[var1] = coord


    elseif propkind == game.const[ball_prop_kind] then
      local var1 = game.prop_instance_get_variation_id(0, prop)
      if var1 == 5 then
        ballprop = prop
        game.prop_instance_initialize_rotation_angles(ballprop)
      end
    end
  end

  local scale = 3600*ball_radius
  game.call_script(game.script.find_or_create_scene_prop_instance, game.const.spr_shadow_circle_1, 0, 0, 1, scale,scale,1000)
  shadow_prop = game.reg[0]

  PlaceBall()
  Init_ScoreBoard()
end

function PlaceBall()
  ball_enabled = false
  
  game.prop_instance_get_position(4, ballprop)
  local ball_pos = game.preg[4]

  game.prop_instance_get_position(1, fieldcenter)
  local center_pos = game.preg[1]

  z_ground = center_pos.o.z + ball_radius

  --animate below ground first
  ball_pos.o.z = z_ground - 2.1*ball_radius
  ball_anim_to_pos(ball_pos, 25)

  timeoutAdd(25, function()
    --then move to center and animate upwards
    ball_pos.o.x = center_pos.o.x
    ball_pos.o.y = center_pos.o.y
    ball_set_pos(ball_pos)

    ball_pos.o.z = z_ground
    ball_anim_to_pos(ball_pos, 100)

    timeoutAdd(1000, function()
      --finally reset
      velocity = vector3.new()
      rotation_axis = vector3.new({x=0.00001})
      goal_side = sides.none

      ball_enabled = true
      game.sreg[4] = "Round Live!"
      game.call_script(game.script.multiplayer_broadcast_message)
    end)
  end)
end

function Set_ScoreBoard()
  local safety_1 = goals_1st
  local safety_2 = goals_2nd
  --prevents scoreboard breaking when >100 points
  if safety_1 > 99 then
    safety_1 = 99
  end
  if safety_2 > 99 then
    safety_2 = 99
  end
  actual_numbers = {math.floor(safety_1 / 10), safety_1 % 10, math.floor(safety_2 / 10), safety_2 % 10}
  old_numbers = {math.floor(goals_1st_scb / 10), goals_1st_scb % 10, math.floor(goals_2nd_scb / 10), goals_2nd_scb % 10}
  -- print("Ostatok - ", goals_1st % 10, goals_2nd % 10)
  local extra_y_shift = 0
  game.set_fixed_point_multiplier(100)

  for i = 1,4 do
    -- only change pixels if number has changed
    if old_numbers[i] ~= actual_numbers[i] then
      
      if #scoreboard_active_props[i] ~= 0 then
        --cleaning up existing pixels
        for k = 1, #scoreboard_active_props[i] do
          game.prop_instance_get_position(17, scoreboard_active_props[i][k])
          game.position_set_z(17, -450, 1)
          game.prop_instance_set_position(scoreboard_active_props[i][k], 17)
          game.scene_prop_set_slot(scoreboard_active_props[i][k], game.const.scene_prop_slot_in_use, 0)
        end
        scoreboard_active_props[i] = {}
      end

      if i > 2 then extra_y_shift = 75 end
      
      game.prop_instance_get_position(49, scoreboard_center)
      game.position_move_y(49, -272 + i * 80 + extra_y_shift, 1)
      game.position_move_z(49, 65, 1)
      game.copy_position(50, 49)

      for j = 1, #numbers[actual_numbers[i] + 1] do
        game.position_move_z(49, -(math.floor(numbers[actual_numbers[i]+1][j] / 10)) * 14, 1)
        game.position_move_y(49, (numbers[actual_numbers[i]+1][j] % 10) * 14, 1)

        game.call_script(game.script.find_or_create_scene_prop_instance, game.const.spr_ground_prop_snow, 0, 0, 1, 12, 8, 1000)
        game.set_fixed_point_multiplier(100)
        table.insert(scoreboard_active_props[i], game.reg[0])

        game.copy_position(49, 50)
      end
    end
  end

  goals_1st_scb = safety_1
  goals_2nd_scb = safety_2
end

function Init_ScoreBoard()
  game.set_fixed_point_multiplier(100)
  local space_between = 150
  local prop = 0

  -- print("Spawning", scoreboard_prop)
  -- game.init_position(2)
  game.set_fixed_point_multiplier(100)
  game.prop_instance_get_position(2, scoreboard_prop)
  game.position_move_x(2, -70, 1)
  game.position_move_y(2, space_between, 1)
  game.copy_position(49, 2)
  game.call_script(game.script.find_or_create_scene_prop_instance, game.const.spr_crude_fence_small_b, 0, 0, 1, 1000, 1000, 2350)
  game.set_fixed_point_multiplier(100)
  game.position_move_y(2, -2*space_between, 1)
  game.copy_position(49, 2)
  game.call_script(game.script.find_or_create_scene_prop_instance, game.const.spr_crude_fence_small_b, 0, 0, 1, 1000, 1000, 2350)
  game.set_fixed_point_multiplier(100)
  game.position_move_y(2, space_between, 1)
  game.position_move_x(2, 10, 1)
  game.position_move_z(2, 300, 1)
  game.copy_position(49, 2)
  game.position_rotate_y(49, 90)
  game.call_script(game.script.find_or_create_scene_prop_instance, game.const.spr_ramp_12m, 0, 0, 1, 1200, 1000, 350)
  game.set_fixed_point_multiplier(100)
  game.position_move_x(2, 15, 1)
  game.copy_position(49, 2)
  game.position_rotate_x(49, 90)
  game.position_rotate_y(49, 180)
  game.call_script(game.script.find_or_create_scene_prop_instance, game.const.spr_band_a, 0, 0, 1, 125, 900, 1000)
  scoreboard_center = game.reg[0]
  game.set_fixed_point_multiplier(100)
  Set_ScoreBoard()
end

function Player_Set_Team(agent)
  local player = game.agent_get_player_id(0, agent)
  if player_data[player] == nil then
    local hat
    local assigned_team
    if teams[1] > teams[2] then
      hat = game.const.itm_prussian_landwehr_hat_2
      assigned_team = 2
    else
      hat = game.const.itm_french_seaman_hat
      assigned_team = 1
    end

    -- game.agent_equip_item(agent, hat)
    -- game.multiplayer_send_3_int_to_player(player, game.const.multiplayer_event_return_agent_set_item, agent, hat, game.const.ek_head)
    game.call_script(game.script.give_item, player, hat, game.const.ek_head)
    game.player_set_slot(player, game.const.slot_player_hat_menu_block , 1)
    game.sreg[32] = "You are now in Team " .. tostring(assigned_team)
    game.multiplayer_send_string_to_player(player, game.const.multiplayer_event_show_server_message, 32)
    
    player_data[player] = {
      team = assigned_team,
      awol_counter = 0
    }

    teams[assigned_team] = teams[assigned_team] + 1
  end
end

function Player_Leave_Team(player)
  if player_data[player] ~= nil then
    teams[player_data[player].team] = teams[player_data[player].team] - 1
    player_data[player] = nil
  end
end

function Punish_Player(player_no)
  game.sreg[33] = "Don'play against your team!"
  game.multiplayer_send_string_to_player(player_no, game.const.multiplayer_event_show_server_message, 33)
  game.call_script(game.script.multiplayer_server_slay_player, player_no, 0)
end

function pos_is_on_field(p)
  return p.o.x < borders[1] and
         p.o.x > borders[3] and
         p.o.y > (borders[2] - goal_depth*1.2) and
         p.o.y < (borders[4] + goal_depth*1.2)
end

--absent without leave
function check_awol()
  for player in game.playersIt(true) do
    if not game.player_is_active(player) then goto continue end
    if not player_data[player] then goto continue end

    local a = game.op.player_get_agent_id(player)
    if not game.agent_is_active(a) then goto continue end
    if not game.agent_is_alive(a) then goto continue end

    game.agent_get_position(0, a)
    local p = game.preg[0]

    if not pos_is_on_field(p) then
      player_data[player].awol_counter = player_data[player].awol_counter + 1

      if player_data[player].awol_counter == 4 then
        send_warn_msg(player, "You will be removed from team " .. player_data[player].team .. " if you don't return.")
      elseif player_data[player].awol_counter > 4 then
        Player_Leave_Team(player)
        send_warn_msg(player, "You got kicked from your team.")
      end
    else
      player_data[player].awol_counter = 0
    end
    -- print("player",player,"awol=",player_data[player].awol_counter)

    ::continue::
  end
end

function ball_hit(agent, dmg, hit_pos)
  if not ball_enabled then return end

  last_agent = agent
  Player_Set_Team(agent)

  game.prop_instance_get_position(1, ballprop)
  local ball_pos = game.preg[1]

  dmg = dmg * 40 / 100
  local v = (ball_pos.o - hit_pos.o):unit()
  v.z = v.z*3

  if v.y > 0 then
    last_hit_agent_north = agent
  elseif v.y < 0 then
    last_hit_agent_south = agent
  end

  -- print("damage",dmg)
  -- printTable(v)
  velocity = velocity + v*speed_mul*dmg
end

function get_shadow_pos(ball_pos)
  local p = game.pos.new()
  p.o = vector3.new(ball_pos.o)

  --Solve p.o.z + a*sun_dir.z == z_ground for a
  local a = (z_ground - ball_radius - p.o.z) / sun_dir.z

  p.o = p.o + a*sun_dir
  return p
end

function ball_set_pos(ball_pos)
  game.prop_instance_stop_animating(ballprop)
  game.prop_instance_set_position(ballprop, ball_pos)
  game.prop_instance_stop_animating(shadow_prop)
  game.prop_instance_set_position(shadow_prop, get_shadow_pos(ball_pos))
end

function ball_anim_to_pos(ball_pos, time) --time in centiseconds
  game.prop_instance_stop_animating(ballprop)
  game.prop_instance_animate_to_position(ballprop, ball_pos, time)
  game.prop_instance_animate_to_position(shadow_prop, get_shadow_pos(ball_pos), time)
end

function on_goal()
  local player

  if goal_side == sides.north then
    goals_1st = goals_1st + 1
    player = game.agent_get_player_id(0, last_hit_agent_north)
  else
    goals_2nd = goals_2nd + 1
    player = game.agent_get_player_id(0, last_hit_agent_south)
  end

  game.prop_instance_get_position(56, ballprop)
  game.call_script(game.script.multiplayer_server_play_sound_at_position, game.const.snd_team_scored_a_point)

  Set_ScoreBoard()

  game.sreg[5] = ""
  game.sreg[6] = ""

  if player_data[player].team ~= goal_side then
    game.sreg[5] = " the opposite"
    game.sreg[6] = "DUMB "
    Punish_Player(player)
  end

  game.str_store_player_username(3, player)
  game.sreg[4] = game.sreg[6] .. game.sreg[3] .. " scored a goal for" .. game.sreg[5] ..  " team " .. tostring(goal_side) .. "!! Score: " .. tostring(goals_1st) .. " - " .. tostring(goals_2nd)
  game.call_script(game.script.multiplayer_broadcast_message)

  timeoutAdd(1000, function()
    game.sreg[4] = "Starting new round in " .. ball_reset_time .. " seconds"
    game.call_script(game.script.multiplayer_broadcast_message)

    timeoutAdd(ball_reset_time*1000, PlaceBall)
  end)
end

--Ball movement
function ball_tick()
  if not ball_enabled then return end

  game.prop_instance_get_position(4, ballprop)
  local ball_pos = game.preg[4]

  local in_air = (ball_pos.o.z - z_ground) > 0.01

  --Handle gravity
  if in_air then
    velocity.z = velocity.z - gravity*dt
  
  --Not in air but negative z vel?
  elseif velocity.z < 0 then
    if velocity.z < -0.3 then --bounce
      velocity.z = velocity.z * -1 * bounce_mul
      if velocity.z > 5 then
        game.particle_system_burst(game.const.psys_gourd_smoke, ball_pos, 5)
      end
    else
      velocity.z = 0
    end
  end

  if math.abs(velocity.x)+math.abs(velocity.y)+math.abs(velocity.z) < 0.01 then return end

  ball_pos.o = ball_pos.o + velocity * dt

  velocity.x = velocity.x * friction_mul
  velocity.y = velocity.y * friction_mul

  --Update rotation axis if we have ground contact
  if (not in_air) and (math.abs(velocity.x)+math.abs(velocity.y) > 0.01) then
    --This is how we would rotate if perfectly in contact with ground and rotation matches velocity
    local fixed_rot_axis = (uz:cross(velocity) / ball_radius) * dt

    --But we only change axis by a certain factor each frame
    rotation_axis = rotation_axis:lerp(fixed_rot_axis, rotation_alpha_ground)

    --This is supposed to curve our path if we have sideways spin but don't think the math is right
    -- local d = 1 - math.max(0, fixed_rot_axis:unit():dot(rotation_axis:unit()))
    -- local dv = d * rotation_axis:cross(uz) * ball_radius * dt * 100
    -- velocity = velocity + dv
  end

  --Out of bounds on top?
  if ball_pos.o.y > borders[4] then
    local in_goal_xz = (ball_pos.o.x > goal_left) and (ball_pos.o.x < goal_right) and (ball_pos.o.z < goal_top)

    --Goal for Team 1?
    if goal_side == sides.none and in_goal_xz then
      goal_side = sides.north
      on_goal()

    --Already scored?
    elseif goal_side == sides.north then
      --Hit the net?
      if ball_pos.o.x < goal_left then
        --Since |net_bounce_mul|<1, it is important that we teleport the ball back to the border.
        --Otherwise the next frame couldn't move us far enough in reverse directon to be back over the border
        --and the x vel would get multiplied again.
        ball_pos.o.x = goal_left
        velocity.x = velocity.x * net_bounce_mul
      elseif ball_pos.o.x > goal_right then
        ball_pos.o.x = goal_right
        velocity.x = velocity.x * net_bounce_mul
      elseif ball_pos.o.y > (borders[4] + goal_depth) then
        ball_pos.o.y = (borders[4] + goal_depth)
        velocity.y = velocity.y * net_bounce_mul
      elseif ball_pos.o.z > goal_top then
        ball_pos.o.z = goal_top
        velocity.z = velocity.z * net_bounce_mul
      end
      
    --Hit outside goal so reverse
    else
      -- print("rev top 1")
      debug_timer = debug_timer + 1
      local tmp = velocity.y
      if in_air then
        velocity.y = 0
        rotation_axis = rotation_axis:lerp( (uy:cross(velocity) / ball_radius) * dt, rotation_alpha_air)
      end
      velocity.y = tmp * wall_bounce_mul
    end

  --Out of bounds on bottom?
  elseif ball_pos.o.y < borders[2] then
    local in_goal_xz = (ball_pos.o.x > goal_left) and (ball_pos.o.x < goal_right) and (ball_pos.o.z < goal_top)

    --Goal for team 2?
    if goal_side == sides.none and in_goal_xz then
      goal_side = sides.south
      on_goal()

    --Already scored?
    elseif goal_side == sides.south then
      --Hit the net?
      if ball_pos.o.x < goal_left then
        ball_pos.o.x = goal_left
        velocity.x = velocity.x * net_bounce_mul
      elseif ball_pos.o.x > goal_right then
        ball_pos.o.x = goal_right
        velocity.x = velocity.x * net_bounce_mul
      elseif ball_pos.o.y < (borders[2] - goal_depth) then
        ball_pos.o.y = (borders[2] - goal_depth)
        velocity.y = velocity.y * net_bounce_mul
      elseif ball_pos.o.z > goal_top then
        ball_pos.o.z = goal_top
        velocity.z = velocity.z * net_bounce_mul
      end
      
    --Hit outside goal so reverse
    else
      -- print("rev top 2")
      debug_timer = debug_timer + 1
      local tmp = velocity.y
      if in_air then
        velocity.y = 0
        rotation_axis = rotation_axis:lerp( (uy:cross(velocity) / ball_radius) * dt, rotation_alpha_air)
      end
      velocity.y = tmp * wall_bounce_mul
    end

  --Out of bounds horizontally?
  elseif ball_pos.o.x > borders[1] or ball_pos.o.x < borders[3] then
    -- print("rev side")
    debug_timer = debug_timer + 1
    local tmp = velocity.x
    if in_air then
      velocity.x = 0
      rotation_axis = rotation_axis:lerp( (ux:cross(velocity) / ball_radius) * dt, rotation_alpha_air)
    end
    velocity.x = tmp * wall_bounce_mul

  else
    debug_timer = 0
  end

  --Ball Rotation
  --sfu / sideways forwards up
  local ds = rotation_axis:cross(ball_pos.rot.s)
  local df = rotation_axis:cross(ball_pos.rot.f)
  local du = rotation_axis:cross(ball_pos.rot.u)

  ball_pos.rot.s = (ball_pos.rot.s + ds):unit()
  ball_pos.rot.f = (ball_pos.rot.f + df):unit()
  ball_pos.rot.u = (ball_pos.rot.u + du):unit()

  if debug_timer > 150 then
    game.sreg[4] = "Ball got bugged. Starting a new round"
    game.call_script(game.script.multiplayer_broadcast_message)
    PlaceBall()
  else
    ball_anim_to_pos(ball_pos, dt*99)
  end
end

----------------------------------------------------------------------------------Events

event_mgr.subscribe("ti_on_player_exit", function()
  local player = game.store_trigger_param_1(0)
  Player_Leave_Team(player)
end)

event_mgr.subscribe("spr_custom_button_1_second:ti_on_scene_prop_use", function()
  -- ## Trigger Param 1: user agent id
  local agent = game.store_trigger_param_1(0)
  local player = game.agent_get_player_id(0, agent)
  if player_data[player] == nil then
    game.sreg[15] = "You can use this button to leave a team"
  else
    game.sreg[15] = "You have left the team " .. tostring(player_data[player].team)
    Player_Leave_Team(player)
    game.player_set_slot(player, game.const.slot_player_hat_menu_block , 0)
  end
  game.multiplayer_send_string_to_player(player, game.const.multiplayer_event_show_server_message, 15)
end)

--Spawn horses with low hp
event_mgr.subscribe("ti_on_agent_spawn", function()
  local agent = game.op.store_trigger_param_1()
  if not game.agent_is_human(agent) then
    game.agent_set_hit_points(agent, 25, 0)
  end
end)

event_mgr.subscribe("ti_after_mission_start", function() timeoutAdd(2500, Init) end)


event_mgr.subscribe(ball_prop_kind .. ":ti_on_scene_prop_hit", function()
  local ball = game.op.store_trigger_param_1()
  if ball == ballprop then
    local damage = game.op.store_trigger_param_2()
    local agent = game.op.store_trigger_param_3()
    if not game.agent_is_active(agent) then return end

    game.agent_get_position(3, agent)
    local p = game.preg[3]
    p.o.z = game.preg[1].o.z

    ball_hit(agent, damage, p)
  end
end)

--pos47 = position
event_mgr.subscribe("script_explosion_at_position", function(shooter_agent_no, max_damage, range)
  local pos = game.preg[47]
  pos.o.z = pos.o.z + 0.2 --Otherwise it kicks it too high
  game.prop_instance_get_position(1, ballprop)
  local ball_pos = game.preg[1]

  local d = pos:dist(ball_pos)*100
  if d > range then return end

  local dmg = max_damage * (1 - ((0.75*d)/range))  --for example:   40 * (1 - ((0.75*500)/800)) = 21.25  damage
  ball_hit(shooter_agent_no, dmg, pos)
end)

event_mgr.subscribe("timer_"..dt, ball_tick)

event_mgr.subscribe("timer_20", check_awol)

event_mgr.subscribe("spr_earthwork1_destructible:ti_on_scene_prop_hit", function()
  local safeguard = 250
  local earthwork = game.store_trigger_param_1(0)
  game.prop_instance_get_position(15, earthwork)
  local p = game.preg[15]
  local x_earth = p.o.x
  local y_earth = p.o.y

  if y_earth < (borders[4] + safeguard) and y_earth > (borders[2] - safeguard) then
    if x_earth < (borders[1] + safeguard) and x_earth > (borders[3] - safeguard) then
      game.position_move_z(15, -3000, 1)
      game.scene_prop_set_slot(earthwork, game.const.scene_prop_slot_in_use, 0)
      game.prop_instance_animate_to_position(earthwork, 15, 0.1)
      local agent = game.store_trigger_param_3(0)
      local player = game.agent_get_player_id(0, agent)
      game.sreg[7] = "No earthworks here"
      -- game.call_script(game.script.multiplayer_broadcast_message)
      game.multiplayer_send_string_to_player(player, game.const.multiplayer_event_show_server_message, 7)
    end
  end
end)

if damage_block > 0 then
  event_mgr.subscribe("ti_on_agent_hit", function()
    local victim = game.op.store_trigger_param_1()
    if not game.agent_is_active(victim) then return end
    if not game.agent_is_human(victim) then return end
    if game.agent_is_non_player(victim) then return end

    local dealer = game.op.store_trigger_param_2()
    if victim==dealer then return end

    game.agent_get_position(0,victim)
    local victim_on_field = pos_is_on_field(game.preg[0])

    if victim_on_field then
      local victim_on_foot = game.op.agent_get_horse(victim) == -1
      local troop = game.op.agent_get_troop_id(victim)
      local victim_is_sapper = game.troop_slot_eq(troop, game.const.slot_troop_class, game.const.multi_troop_class_mm_sapper)

      local itm = game.op.agent_get_wielded_item(victim ,0)
      local has_flag = itm >= 0 and game.item_slot_eq(itm, game.const.slot_item_multiplayer_item_class, game.const.multi_item_class_type_flag)
      
      if victim_on_foot and (not victim_is_sapper) and (not has_flag) then
        --we block that dmg
        if damage_block == 1 then
          game.agent_set_no_death_knock_down_only(victim, 1)
        
          --check abuse
          if not game.agent_is_non_player(dealer) then
            local player = game.op.agent_get_player_id(dealer)
            if game.player_is_active(player) then

              if game.player_slot_eq(player, slot_player_damage_info, 0) then
                send_warn_msg(player, "Welcome to football! You are in a no-death zone. Please don't attack others or you will get punished.")
                game.player_set_slot(player, slot_player_damage_info, 1)
              end

              local dmg = game.op.store_trigger_param_3()
              if dmg > 3 then
                local warn = game.op.agent_get_slot(dealer, slot_agent_warning)
                warn = warn + 1
                game.op.agent_set_slot(dealer, slot_agent_warning, warn)

                if warn == 3 then
                  send_warn_msg(player, "Please don't attack others or you will get punished.")
                elseif warn >= 5 then
                  send_warn_msg(player, "You got slayed for abusing the no-death zone.")
                  game.call_script(game.script.multiplayer_server_slay_player, player, 0)
                end
              end
            end
          end

        elseif damage_block == 2 then
          game.set_trigger_result(0)
        end

      else
        if game.agent_slot_eq(victim, game.const.slot_agent_god_mode, 0) then
          game.agent_set_no_death_knock_down_only(victim, 0)
        end
      end

    else
      local player = game.op.agent_get_player_id(victim)
      
      if game.agent_slot_eq(victim, game.const.slot_agent_god_mode, 0) and 
          game.player_slot_eq(player, game.const.slot_player_in_duel, 0) and
          not (game.gvar.g_current_event == 4 and game.player_slot_eq(player, game.const.slot_player_event_joined, 1)) then
        --We have to turn this off again otherwise everyone is immortal
        game.agent_set_no_death_knock_down_only(victim, 0)
      end
      
      --To prevent camping on field with ranged
      game.agent_get_position(0,dealer)
      local dealer_on_field = pos_is_on_field(game.preg[0])
      if dealer_on_field then
        game.set_trigger_result(0)
      end
    end
  end)
end

-- script_give_item
-- Input: arg1 = player_id, arg2 = item_id, arg3 = slot
-- Output: none
-- ("give_item", [
-- (store_script_param, ":player_id", 1),
-- (store_script_param, ":item_id", 2),
-- (store_script_param, ":slot", 3),


-- # script_find_or_create_scene_prop_instance
-- # Input: arg1 = prop_kind_id
-- # Input: arg2 = always_spawn_new
-- # Input: arg3 = align_to_ground
-- # input: arg4 = non_default_scale
-- # input: arg5 = scale_x
-- # input: arg6 = scale_y
-- # input: arg7 = scale_z
-- # Input: pos49 = pos of prop.
-- # Output: reg0 = prop_instance_id
