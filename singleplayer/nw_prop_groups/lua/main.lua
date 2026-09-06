--Keys
--  shift+m = Select root
--  shift+k = Save group

require "util"
require "event_mgr"
-- local json = require "json"

--Reload Trigger
if not __reload_reg then
  __reload_reg = true
  for i = 0, game.getNumTemplates()-1 do
    game.addTrigger(i, 0, 0, 0, function()
      if game.key_clicked(game.const.triggers.key_o) then
        if game.key_is_down(game.const.triggers.key_left_shift) then
          if game.key_is_down(game.const.triggers.key_left_control) then
            event_mgr.clear()
            print("Reloading")
            dofile("main.lua")
          end
        end
      end
    end)
  end
end
local json = dofile("json.lua")

--how to transform from root pos to child pos
--returns: translate vector, rotation matrix
--add vector to child pos using its local coordinate system, then apply matrix
function get_transform(root_pos, child_pos)
  --child props
  local x = root_pos.rot.s
  local y = root_pos.rot.f
  local z = root_pos.rot.u

  --the inverse of the rotation matrix of root_pos
  local root_rot_inv = {
    {x[1], x[2], x[3]},
    {y[1], y[2], y[3]},
    {z[1], z[2], z[3]}
  }

  local d_vec = child_pos.o - root_pos.o

  local x_dist = root_pos.rot.s:dot(d_vec) / root_pos.rot.s:len()
  --modified formula of the orthogonal projection of d_vec onto rot.s to get the distance in rot.s direction (X direction)
  local y_dist = root_pos.rot.f:dot(d_vec) / root_pos.rot.f:len()
  local z_dist = root_pos.rot.u:dot(d_vec) / root_pos.rot.u:len()

  local moves = vector3.new({x = x_dist, y = y_dist, z = z_dist})

  x = child_pos.rot.s
  y = child_pos.rot.f
  z = child_pos.rot.u

  local rot = {
    {x[1], y[1], z[1]},
    {x[2], y[2], z[2]},
    {x[3], y[3], z[3]}
  }

  return moves, matr_mul(root_rot_inv, rot)
end

local prop_names = {}
for k,v in pairs(game.const.scene_props) do
  if starts_with(k, "spr_") then prop_names[v] = k end
end

local root_prop = nil

event_mgr.subscribe("ti_before_mission_start", function()
  root_prop = nil
end)

--Save group
event_mgr.subscribe("key_k down=key_shift", function()
  local count = game.op.edit_mode_get_num_selected_prop_instances()
  if count < 2 then
    print("Select more than 1 prop")
    return
  end

  if not root_prop then
    print("Select a root prop first (press M)")
    return
  end
  print(count .. " selected")

  game.prop_instance_get_position(0, root_prop)
  local root_pos = game.pos.new({o = game.preg[0].o})

  game.prop_instance_get_scale(0, root_prop)
  local scale = game.preg[0].rot

  local function sc(_scale) return round(_scale*1000) end


  local group = {
    childs = {}
  }

  for i = 0, count-1 do
    local inst = game.op.edit_mode_get_selected_prop_instance(i)
    game.prop_instance_get_position(0, inst)

    local tr, ro = get_transform(root_pos, game.preg[0])
    game.prop_instance_get_scale(0, inst)
    scale = game.preg[0].rot

    local child = {
      kind = prop_names[game.op.prop_instance_get_scene_prop_kind(inst)],
      translate = tr,
      rotate = ro,
      scale_x = sc(scale.s.x),
      scale_y = sc(scale.f.y),
      scale_z = sc(scale.u.z),
    }
    if game.op.prop_instance_get_variation_id(inst) ~= 0 then child.varno1 = game.op.prop_instance_get_variation_id(inst) end
    if game.op.prop_instance_get_variation_id_2(inst) ~= 0 then child.varno2 = game.op.prop_instance_get_variation_id_2(inst) end

    table.insert(group.childs, child)

    if inst == root_prop then group.root = i+1 end
  end

  local f, err = io.open("prop_group.json", "w+")

  if not f then 
    print("Error opening prop_group.json: " .. err, true)
    return false
  end

  f:write(json.encode(group, true))
  f:close()
  print("Saved lua\\prop_group.json")
end)

--Select root
event_mgr.subscribe("key_m down=key_shift", function()
  local count = game.op.edit_mode_get_num_selected_prop_instances()
  if count ~= 1 then
    print("Select one root prop")
    return
  end

  root_prop = game.op.edit_mode_get_selected_prop_instance(0)
  print("root prop selected, inst_no " .. root_prop)
end)

print("Lua Loaded")
