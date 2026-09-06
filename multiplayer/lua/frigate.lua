--This can add cannons to mm_frigate. Modsys patches required though.

local frigates = {}

function frigateAddCannons()
  for inst in game.propInstIt(game.const.spr_mm_frigate) do
    if game.op.prop_instance_is_valid(inst) and game.op.prop_instance_get_variation_id(inst) > 0 then
      local var2 = game.op.prop_instance_get_variation_id_2(inst)
      game.prop_instance_get_position(51, inst)
      local root_pos = game.preg[51]

      local inst_group_idx
      if var2 == 1 then
        inst_group_idx = prop_group_mgr.spawn_from_file("frigate_cannons_frontal", root_pos)
      elseif var2 == 2 then
        inst_group_idx = prop_group_mgr.spawn_from_file("frigate_cannons", root_pos)
      elseif var2 == 3 then
        inst_group_idx = prop_group_mgr.spawn_from_file("frigate_cannons_half", root_pos)
      end

      if inst_group_idx then
        -- print("found frigate",inst)
        local props = {}

        for i, child in ipairs(prop_group_mgr.group_instances[inst_group_idx]) do
          if game.op.prop_instance_get_scene_prop_kind(child.inst) == game.const.spr_mm_cannon_naval then

            game.call_script(game.script.generate_bits_for_cannon_instance, child.inst, 0, 0, 1)
            local wood = game.reg[1]
            local ammo = game.reg[2]

            game.op.scene_prop_set_slot(wood, game.const.scene_prop_slot_parent_prop, inst)
            game.op.scene_prop_set_slot(wood, game.const.scene_prop_slot_is_boat, 1)

            for i = game.const.scene_prop_slot_child_prop1, game.const.scene_prop_slot_child_prop16 do
              if game.op.scene_prop_get_slot(wood, i) == ammo then
                game.op.scene_prop_set_slot(wood, i, -1)
              end
            end

            game.op.scene_prop_set_slot(ammo, game.const.scene_prop_slot_ignore_inherit_movement, 0)

            table.insert(props, wood)
            table.insert(props, ammo)
            -- printProp(wood)
            -- printProp(ammo)
          else
            table.insert(props, child.inst)
          end
        end

        prop_group_mgr.forget_group_instance(inst_group_idx)
        inst_group_idx = prop_group_mgr.capture_group_instance(props, root_pos)
        -- print("set slot ",inst, game.const.scene_prop_slot_attached_group, inst_group_idx)
        game.scene_prop_set_slot(inst, game.const.scene_prop_slot_attached_group, inst_group_idx)

        prop_group_mgr.animate(inst_group_idx, root_pos, 10, true) --to fix cannon position
      end
    end
  end
end

local prop_names = {}
for k,v in pairs(game.const.scene_props) do
  if starts_with(k, "spr_") then prop_names[v] = k end
end

function printProp(inst, indent)
  if not game.op.prop_instance_is_valid(inst) then return end
  indent = indent or ""

  local kind = game.op.prop_instance_get_scene_prop_kind(inst)
  
  local active = game.op.scene_prop_get_slot(inst, game.const.scene_prop_slot_is_active)

  print(indent .. prop_names[kind] .. " " .. inst .. ((active==0) and " INACTIVE" or ""))

  for i = game.const.scene_prop_slot_child_prop1, game.const.scene_prop_slot_child_prop16 do
    printProp(game.op.scene_prop_get_slot(inst, i), indent .. "    ")
  end
end

event_mgr.subscribe("script_prop_child_animate_to_position_with_childs_zxy", function(prop_instance_id, duration, ignored_prop_instance, ignored_prop_instance2)
  if game.op.prop_instance_get_scene_prop_kind(prop_instance_id) ~= game.const.scene_props.spr_mm_frigate then return end
  local p57 = game.preg[57]
  local target_pos = game.preg[58]

  local group_idx = game.op.scene_prop_get_slot(prop_instance_id, game.const.scene_prop_slot_attached_group)
  if group_idx < 1 then return end

  prop_group_mgr.animate(group_idx, target_pos, duration, true)

  game.preg[57] = p57
  game.preg[58] = target_pos --revert any changes
end)
