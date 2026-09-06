--[[
This can:
  - Spawn a group of props defined in a .json and collect them in an instance group. You can create these .json files with the included singleplayer mod.
  - Collect existing instances to an instance group
  - Animate instance groups
]]



local json = require "json"

--[[
  prop_group format example (json)

  {
    "root": 6,
    "childs":
    [
      {
        "scale_x": 4800,
        "scale_y": 2000,
        "scale_z": 1000,
        "kind": "spr_arabian_passage_house_a",
        "physics": 0|1, [optional]
        "slots": [optional]
        [
          "scene_prop_slot_health":  1000,
          ...
        ],
        "rotate":
        [
          [0.59816694259644, -0.80137157440186, 0],
          [0.80137157440186, 0.59816694259644, 0],
          [0, 0, 1.0000001192093]
        ],
        "translate":
        {
          "x": -3.1675033569336,
          "y": 2.1121673583984,
          "z": 2.0230001127347
        }
      },
      {
        ...
      }
    ],
  }

  group_instance format example (lua table)
  {
    {inst = 123, translate = ..., rotate = ..., [physics = 0]},        --rotate/translate like above
    {...},
    ...
  }
]]


prop_group_mgr = {
  prop_group_cache = {},
  group_instances = {}
}
local mgr = prop_group_mgr

function prop_group_mgr.apply_transform(pos, root_rot_matrix, translate, rotate)
  pos:move(translate)

  local r = matr_mul(root_rot_matrix, rotate)

  pos.rot = game.rotation.new({
    s = {x = r[1][1], y = r[2][1], z = r[3][1]},
    f = {x = r[1][2], y = r[2][2], z = r[3][2]},
    u = {x = r[1][3], y = r[2][3], z = r[3][3]}
  })
  return pos
end

--how to transform from root pos to child pos
--returns: translate vector, rotation matrix
--add vector to child pos using its local coordinate system, then apply matrix
function prop_group_mgr.get_transform(root_pos, child_pos)
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

--instances: simple list of instance numbers
--returns: index of group_instance
function prop_group_mgr.capture_group_instance(instances, root_pos)
  local group_instance = {}

  for i, inst in ipairs(instances) do
    game.prop_instance_get_position(51, inst)
    local child_pos = game.preg[51]
    local t, r = prop_group_mgr.get_transform(root_pos, child_pos)

    table.insert(group_instance, {inst = inst, translate = t, rotate = r, physics = 1})
  end

  local i = 1
  while mgr.group_instances[i] ~= nil do i = i + 1 end
  mgr.group_instances[i] = group_instance
  return i
end

function prop_group_mgr.animate(group_instance_index, target_pos, time, modsys_childs)
  local root_r = {
    {target_pos.rot.s[1], target_pos.rot.f[1], target_pos.rot.u[1]},
    {target_pos.rot.s[2], target_pos.rot.f[2], target_pos.rot.u[2]},
    {target_pos.rot.s[3], target_pos.rot.f[3], target_pos.rot.u[3]}
  }

  local group_instance = mgr.group_instances[group_instance_index]

  for i = 1, #group_instance do
    local child = group_instance[i]
    local child_pos = mgr.apply_transform(game.pos.new(target_pos), root_r, child.translate, child.rotate)

    if modsys_childs then
      game.preg[56] = child_pos
      game.call_script(game.script.prop_super_animate_to_position_with_childs_zxy, child.inst, time, 0, 0, 1)
    else
      if game.op.prop_instance_is_animating(child.inst) then game.prop_instance_stop_animating(child.inst) end
      game.prop_instance_animate_to_position(child.inst, child_pos, time)
    end
  end
end

--group_name e.g. "arena"
--Returns prop_group
function prop_group_mgr.require(group_name, skip_cache)
  if (not skip_cache) and mgr.prop_group_cache[group_name] then
    return mgr.prop_group_cache[group_name]
  end

  local path = string.format("prop_groups\\%s.json", group_name)

  local f, err = io.open(path, "r")
  if not f then 
    log(string.format("Error loading %s: %s", path, err), true)
    return false
  end

  local txt = f:read("*a")
  f:close()
  
  local prop_group = json.decode(txt)
  mgr.prop_group_cache[group_name] = prop_group

  return prop_group
end

--Returns (constant) index of group_instance
function prop_group_mgr.spawn(prop_group, spawn_pos)
  local group_instance = {}
  local regs = {}

  local root_r = {
    {spawn_pos.rot.s[1], spawn_pos.rot.f[1], spawn_pos.rot.u[1]},
    {spawn_pos.rot.s[2], spawn_pos.rot.f[2], spawn_pos.rot.u[2]},
    {spawn_pos.rot.s[3], spawn_pos.rot.f[3], spawn_pos.rot.u[3]}
  }

  for i, c in ipairs(prop_group.childs) do
    game.preg[49] = mgr.apply_transform(game.pos.new(spawn_pos), root_r, c.translate, c.rotate)
    game.call_script(game.script.find_or_create_scene_prop_instance, game.const.scene_props[c.kind], 0, 0, 1, c.scale_x, c.scale_y, c.scale_z)
    local inst = game.reg[0]

    if c.physics then
      game.prop_instance_enable_physics(inst, c.physics)
    end

    if c.slots then
      for k, v in pairs(c.slots) do
        game.scene_prop_set_slot(inst, game.const[k], v)
      end
    end

    if c.save_inst_to_reg then
      regs[c.save_inst_to_reg] = inst
    end

    table.insert(group_instance, {inst = inst, translate = c.translate, rotate = c.rotate, physics = (c.physics or 1)})
  end

  for k,v in pairs(regs) do
    game.reg[k] = v
  end

  local i = 1
  while mgr.group_instances[i] ~= nil do i = i + 1 end
  mgr.group_instances[i] = group_instance
  return i
end

--group_name e.g. "arena"
--Returns (constant) index of group_instance
function prop_group_mgr.spawn_from_file(group_name, spawn_pos, skip_cache)
  if type(spawn_pos) == "number" then spawn_pos = game.preg[spawn_pos] end

  local prop_group = mgr.require(group_name)
  local idx = mgr.spawn(prop_group, spawn_pos)

  return idx
end

function prop_group_mgr.forget_group_instance(group_instance_index)
  mgr.group_instances[group_instance_index] = nil
end
