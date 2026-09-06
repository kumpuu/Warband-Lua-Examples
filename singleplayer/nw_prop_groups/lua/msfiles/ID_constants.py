from compiler import *
##############################################################
# These constants are used in various files.
# If you need to define a value that will be used in those files,
# just define it here rather than copying it across each file, so
# that it will be easy to change it if you need to.
##############################################################

########################################################
##  ITEM SLOTS             #############################
########################################################

slot_item_multiplayer_item_class   = 1 
slot_item_multiplayer_item_class2  = 2 
slot_item_royale_item_class        = 3 #unique for royale are the item classes (sadly)
slot_item_multiplayer_gf           = 4 #patch1115 60/13
slot_item_multiplayer_availability_linked_list_begin = 5 #temporary, can be moved to higher values


########################################################
##  AGENT SLOTS            #############################
########################################################

slot_agent_last_voice_at          = 1
slot_agent_last_sound_at          = 2
slot_agent_underwater_time        = 3
slot_agent_underwater_now         = 4
slot_agent_frizzle_times          = 5
slot_agent_current_command        = 6
slot_agent_current_control_prop   = 7
slot_agent_used_prop_instance     = 8
slot_agent_alone                  = 9
slot_agent_cur_damage_modifier    = 10
slot_agent_cur_accuracy_modifier  = 11
slot_agent_cur_reload_speed_modifier = 12
slot_agent_cur_use_speed_modifier = 13
slot_agent_cur_speed_modifier     = 14
slot_agent_music_play_together    = 15
slot_agent_base_speed_mod         = 16
slot_agent_started_playing_music_at = 17
# slot_agent_teleport_pos_x         = 17
# slot_agent_teleport_pos_y         = 18
# slot_agent_teleport_pos_z         = 19
# slot_agent_teleport_pos_z_rot     = 20
slot_agent_flag_target            = 18
slot_agent_behaviour              = 19
slot_agent_in_duel_with           = 20
slot_agent_duel_start_time        = 21
slot_agent_map_overlay_id         = 22
slot_agent_is_running_away        = 23
slot_agent_courage_score          = 24
slot_agent_state                  = 25

slot_agent_last_build_at          = 27  #patch1115 fix 6/2
slot_agent_healed_perc            = 28 # patch1115 surgeon
slot_agent_royale_horse           = 29

slot_agent_attached_prop_offset_x = 30
slot_agent_attached_prop_offset_y = 31
slot_agent_attached_prop_offset_z = 32

slot_agent_track_ends_at          = 33

slot_agent_has_fallen_off_horse   = 34
slot_agent_god_mode               = 35 #patch1115 54/14

slot_agent_last_rotz              = 36
slot_agent_last_speed_same_count  = 37

slot_agent_is_perk                  = 38
slot_agent_owner                    = 39
slot_agent_last_kill_at             = 40
slot_agent_kill_count               = 41
slot_agent_cosmetic_prop            = 42
slot_agent_last_surrender_stop_time = 43
########################################################
##  FACTION SLOTS          #############################
########################################################

slot_faction_banner                     = 1


########################################################
##  TROOP SLOTS            #############################
########################################################

slot_troop_occupation          = 2  # 0 = free, 1 = merchant
#slot_troop_banner_scene_prop    = 3 # important for kingdom heroes and player only


# MM added
slot_troop_initial_morale              = 5
slot_troop_officer_troop               = 6
slot_troop_scale_factor                = 7
slot_troop_base_type                   = 8

slot_troop_class                       = 10
slot_troop_class_type                  = 11
slot_troop_rank                        = 12
slot_troop_rank_type                  = 13

# slot_troop_custom_banner_bg_color_1      = 10
# slot_troop_custom_banner_bg_color_2      = 11
# slot_troop_custom_banner_charge_color_1  = 12
# slot_troop_custom_banner_charge_color_2  = 13
# slot_troop_custom_banner_charge_color_3  = 14
# slot_troop_custom_banner_charge_color_4  = 15
# slot_troop_custom_banner_bg_type         = 16
# slot_troop_custom_banner_charge_type_1   = 17
# slot_troop_custom_banner_charge_type_2   = 18
# slot_troop_custom_banner_charge_type_3   = 19
# slot_troop_custom_banner_charge_type_4   = 20
# slot_troop_custom_banner_flag_type       = 21
# slot_troop_custom_banner_num_charges     = 22
# slot_troop_custom_banner_positioning     = 23
# slot_troop_custom_banner_map_flag_type   = 24



slot_troop_button_id              = 20
slot_troop_button_2_id            = 21
slot_troop_active_this_mission    = 22


########################################################
##  PLAYER SLOTS           #############################
########################################################

slot_player_spawned_this_round                 = 0
slot_player_selected_item_indices_begin        = 2
slot_player_selected_item_indices_end          = 11
slot_player_cur_selected_item_indices_begin    = slot_player_selected_item_indices_end
slot_player_cur_selected_item_indices_end      = slot_player_selected_item_indices_end + 9
slot_player_join_time                          = 21
slot_player_button_index                       = 22 #used for presentations
slot_player_can_answer_poll                    = 23
slot_player_first_spawn                        = 24
slot_player_spawned_at_siege_round             = 25
slot_player_poll_disabled_until_time           = 26
slot_player_last_team_select_time              = 27
slot_player_death_pos_x                        = 28
slot_player_death_pos_y                        = 29
slot_player_death_pos_z                        = 30
slot_player_last_bot_count                     = 31
slot_player_bot_type_1_wanted                  = 32
slot_player_bot_type_2_wanted                  = 33
slot_player_bot_type_3_wanted                  = 34
slot_player_bot_type_4_wanted                  = 35
slot_player_spawn_count                        = 36

# MM
slot_player_selected_flag                      = 40
slot_player_bot_type_wanted                    = 41
slot_player_bot_type_spawned                   = 42
slot_player_teamkills                          = 43
slot_player_last_teamkill_at                   = 44

#slot_player_last_message_at          = 49  #patch1115
#slot_player_message_count          = 50  #patch1115

#patch1115 43/1 start
slot_player_musician_spawned					   = 45
slot_player_drummer_spawned					   = 46
slot_player_flag_spawned					   = 47
#patch1115 43/1 end
#slot_player_god_mode                 = 48 #patch1115 54/14
slot_player_revive_pos              = 48 #patch1115 46/16
slot_player_formation_change              = 49
slot_player_formation_change_2              = 50
slot_player_bot_order              = 51

slot_player_rank = 52
slot_player_tnt_count = 53
# slot_player_prefix = 54

slot_player_is_undercover = 55

slot_player_item1 = 56
slot_player_item2 = 57 # change
slot_player_item3 = 58
slot_player_item4 = 59

slot_server_url_player = 60

# slot_player_cosmetic_prop = 61
slot_player_cosmetic_effect = 62

slot_player_active_perk = 63
slot_player_perk_tick = 64
slot_player_item_perk = 65

slot_player_last_tnt_at = 66

slot_player_perk_bot1 = 67
slot_player_perk_bot2 = 68
slot_player_perk_bot3 = 69

slot_player_current_command = 70
#1=mute/unmute
#2=send duel
#3=accept duel
#4=stats
#5=prefix
slot_player_command_data = 71
slot_player_command_data2 = 72

slot_player_chat_cmd_player = 73
slot_player_chat_cmd_player_uid = 74

slot_player_last_chat_at = 75
# slot_player_current_spam = 76
# slot_player_last_send_at = 77
slot_player_event_joined = 78
slot_player_event_voted = 79
slot_player_event_score = 80
slot_player_event_warns = 81

slot_player_in_duel = 82
slot_player_duel_off = 83
slot_player_duel_weapon = 84
slot_player_duel_ft_goal = 85
slot_player_duel_arena = 86
slot_player_local_off = 87

slot_player_toggle = 88
slot_player_got_blessed = 89

slot_player_input_cooled_down_time = 90 #anti lag

#slot_player_naval_team = 84
########################################################
##  TEAM SLOTS             #############################
########################################################

slot_team_flag_situation                       = 0


### Troop occupations slot_troop_occupation
##slto_merchant           = 1
slto_inactive           = 0 #for companions at the beginning of the game

slto_player_companion   = 5 #This is specifically for companions in the employ of the player -- ie, in the party, or on a mission


########################################################
##  SCENE PROP SLOTS       #############################
########################################################

scene_prop_open_or_close_slot       = 1
scene_prop_smoke_effect_done        = 2
# MM
scene_prop_slot_is_spawned          = 3
scene_prop_slot_in_use              = 4 #spawned prop currently in use (prevents recycling)
scene_prop_slot_x_value             = 5
scene_prop_slot_y_value             = 6
scene_prop_slot_z_value             = 7
scene_prop_slot_x_rot               = 8
scene_prop_slot_y_rot               = 9
scene_prop_slot_z_rot               = 10
scene_prop_slot_z_rotation_limit    = 11
scene_prop_slot_x_scale             = 12
scene_prop_slot_y_scale             = 13
scene_prop_slot_z_scale             = 14
scene_prop_slot_is_scaled           = 15
scene_prop_slot_x_extra             = 16
scene_prop_slot_y_extra             = 17
scene_prop_slot_z_extra             = 18
scene_prop_slot_time                = 19
scene_prop_slot_bounces             = 20
scene_prop_slot_times_hit           = 21
scene_prop_slot_owner_team          = 22
scene_prop_slot_time_left           = 23
scene_prop_slot_has_ball            = 24
scene_prop_slot_is_loaded           = 25
scene_prop_slot_is_active           = 26
scene_prop_slot_just_fired          = 27
scene_prop_slot_health              = 28
scene_prop_slot_max_health          = 29
scene_prop_slot_displayed_particle  = 30
scene_prop_slot_ammo_type           = 31
scene_prop_slot_ignore_inherit_movement = 32
scene_prop_slot_float_ground        = 33
scene_prop_slot_ground_offset       = 34
scene_prop_slot_spawned_at          = 35
scene_prop_slot_is_not_pushed_back  = 36
scene_prop_slot_just_pushed_back    = 37


scene_prop_slot_destruct_wall_height            = 38
scene_prop_slot_destruct_wall_width             = 39
scene_prop_slot_destruct_wall_length            = 40
scene_prop_slot_destruct_move_height_to_center  = 41
scene_prop_slot_destruct_move_width_to_center   = 42
scene_prop_slot_destruct_move_length_to_center  = 43
scene_prop_slot_destruct_rotate_z_90            = 44
scene_prop_slot_destruct_wall_height_offset     = 45
scene_prop_slot_destruct_wall_width_offset      = 46
scene_prop_slot_destruct_wall_length_offset     = 47
scene_prop_slot_destruct_inverse_width_movement = 48
scene_prop_slot_destruct_max_length             = 49

scene_prop_slot_destruct_smoke_strength         = 50

# under here slots that need -1 as default
scene_prop_slot_replaced_by         = 52
scene_prop_slot_replacing           = 53
scene_prop_slot_last_hit_by         = 54
scene_prop_slot_user_agent          = 55
scene_prop_slot_controller_agent    = 56
scene_prop_slot_carrier_agent       = 57
scene_prop_slot_linked_prop         = 58

scene_prop_slot_sound_effect        = 59
scene_prop_slot_particle_effect1    = 60
scene_prop_slot_particle_effect2    = 61
scene_prop_slot_particle_effect3    = 62
scene_prop_slot_particle_effect4    = 63

scene_prop_slot_destruct_smoke_type             = 64
scene_prop_slot_destruct_smoke_type2            = 65
scene_prop_slot_destruct_particles_type         = 66
scene_prop_slot_destruct_sound_id               = 67
scene_prop_slot_destruct_pile_prop_begin        = 68
scene_prop_slot_destruct_pile_prop_end          = 69

# precalc the next stages because that saves us a lot of running of codes.
scene_prop_slot_destruct_next_stage_1           = 70
scene_prop_slot_destruct_next_stage_2           = 71
scene_prop_slot_destruct_next_stage_3           = 72
scene_prop_slot_destruct_next_stage_4           = 73
scene_prop_slot_destruct_next_stage_5           = 74
scene_prop_slot_destruct_next_stage_6           = 75
scene_prop_slot_destruct_next_stage_7           = 76
scene_prop_slot_destruct_next_stage_8           = 77
scene_prop_slot_destruct_next_stage_9           = 78
scene_prop_slot_destruct_next_stage_10          = 79

scene_prop_slot_parent_prop         = 80
scene_prop_slot_child_prop1         = 81
scene_prop_slot_child_prop2         = 82
scene_prop_slot_child_prop3         = 83
scene_prop_slot_child_prop4         = 84
scene_prop_slot_child_prop5         = 85
scene_prop_slot_child_prop6         = 86
scene_prop_slot_child_prop7         = 88
scene_prop_slot_child_prop8         = 89
scene_prop_slot_child_prop9         = 90
scene_prop_slot_child_prop10        = 91
scene_prop_slot_child_prop11        = 92
scene_prop_slot_child_prop12        = 93
scene_prop_slot_child_prop13        = 94
scene_prop_slot_child_prop14        = 95
scene_prop_slot_child_prop15        = 96
scene_prop_slot_child_prop16        = 97

scene_prop_slots_begin              = scene_prop_open_or_close_slot
scene_prop_slots_end                = 98

scene_prop_slots_defmin_begin       = scene_prop_slot_replaced_by


scene_prop_molotov_ttl = 100
scene_prop_molotov_thower = 101
scene_prop_slot_owner = 102

scene_prop_elev_button_distance = 103
scene_prop_slot_elev_status = 104
scene_prop_is_loot_box = 105
scene_prop_smoke_loot_box = 106

scene_prop_is_cosmetic = 107
scene_prop_is_duel = 107
scene_prop_is_full = 108
scene_prop_slot_is_boat = 109

########################################################

factions_begin = "fac_britain"
factions_end = "fac_kingdoms_end"

# MM
faction_name_strings_begin = "str_britain_name"

companions_begin = "trp_companion_1"
companions_end = "trp_companions_end"

multiplayer_troops_begin = "trp_british_infantry"
multiplayer_troops_end = "trp_multiplayer_end"

# MM
multiplayer_ai_troops_begin = "trp_british_infantry_ai"
multiplayer_ai_troops_end = multiplayer_troops_begin

multiplayer_scenes_begin = "scn_mp_ambush"
multiplayer_scenes_end = "scn_multiplayer_maps_end"

multiplayer_scene_names_begin = "str_mp_ambush"
multiplayer_scene_names_end = "str_multi_scene_end"

multiplayer_flag_projections_begin = "mesh_flag_project_sw"
multiplayer_flag_projections_end = "mesh_flag_projects_end"

multiplayer_flag_taken_projections_begin = "mesh_flag_project_sw_miss"
multiplayer_flag_taken_projections_end = "mesh_flag_project_misses_end"

multiplayer_game_type_names_begin = "str_multi_game_type_1"
multiplayer_game_type_names_end = "str_multi_game_types_end"

#MM Begin
quick_battle_troops_begin = "trp_quick_battle_troop_britain_1"
quick_battle_troops_end = "trp_quick_battle_troops_end"
#MM End

quick_battle_scenes_begin = "scn_quick_battle_french_farm"
quick_battle_scenes_end = "scn_quick_battle_maps_end"

quick_battle_scene_images_begin = "mesh_cb_ui_maps_scene_french_farm"

quick_battle_battle_scenes_begin = quick_battle_scenes_begin
quick_battle_battle_scenes_end = "scn_quick_battle_scene_4"

quick_battle_siege_scenes_begin = quick_battle_battle_scenes_end
quick_battle_siege_scenes_end = quick_battle_scenes_end

quick_battle_scene_names_begin = "str_quick_battle_french_farm"

all_items_begin = 0
all_items_end = "itm_items_end"



walkers_begin =  "trp_walker_french_infantry"
walkers_end   = "trp_walkers_end"

armor_merchants_begin  = "trp_camp_armorer"
armor_merchants_end    = "trp_camp_weaponsmith"

weapon_merchants_begin = "trp_camp_weaponsmith"
weapon_merchants_end   = "trp_camp_horse_merchant"

horse_merchants_begin  = "trp_camp_horse_merchant"
horse_merchants_end    = "trp_merchants_end"


num_max_items = 10000 #used for multiplayer mode



# Banner constants

banner_meshes_begin = "mesh_banner_a01"
banner_meshes_end_minus_one = "mesh_banner_f21"

arms_meshes_begin = "mesh_banner_a01"
arms_meshes_end_minus_one = "mesh_banner_f21"

#banner_scene_props_begin = 99 #"spr_banner_a"
#banner_scene_props_end_minus_one = 100#"spr_banner_f21"


# Some constants for merchant invenotries
merchant_inventory_space = 30


# AI Tactics

#battle tactics
btactic_defense = 1
btactic_attack = 2
btactic_charge = 3
btactic_probe = 4

#unit tactics
utactic_hold = 1
utactic_advance = 2
utactic_charge = 3
utactic_retreat = 4

#(unit) combat status
cstatus_ready = 1
cstatus_engaged_balanced = 2
cstatus_engaged_losing = 3
cstatus_engaged_winning = 4
cstatus_dead = 5
cstatus_advancing = 6

#unit type
utype_inf_line = 1
utype_inf_skirmish = 2
utype_inf_flanker = 3
utype_inf_reserve = 4
utype_cav_line = 5
utype_cav_skirmish = 6
utype_cav_flanker = 7
utype_cav_reserve = 8

#unit use weapon type
unit_use_firearms = 1
unit_use_melee = 2

#base troop slots
basetroop_infantry = 1
basetroop_guard = 2
basetroop_skirmisher = 3
basetroop_hussar = 4
basetroop_dragoon = 5
basetroop_light_cav = 6
basetroop_lancer = 7
basetroop_heavy_cav = 8

slot_team1_base_troops_begin = 0
slot_team2_base_troops_begin = slot_team1_base_troops_begin + 9
slot_team1_utypes_begin = slot_team2_base_troops_begin + 9
slot_team2_utypes_begin = slot_team1_utypes_begin + 9
slot_team1_cstatus_begin = slot_team2_utypes_begin + 9
slot_team2_cstatus_begin = slot_team1_cstatus_begin + 9
slot_team1_utactic_begin = slot_team2_cstatus_begin + 9
slot_team2_utactic_begin = slot_team1_utactic_begin + 9
slot_team1_amount_of_troops = slot_team2_utactic_begin + 9
slot_team2_amount_of_troops = slot_team1_amount_of_troops + 9
slot_team1_unit_use_weapon = slot_team2_amount_of_troops + 9
slot_team2_unit_use_weapon = slot_team1_unit_use_weapon+ 9


#Viking Conquest patch 1.167 parameters for try_for_prop_instances
somt_object = 1
somt_entry = 2
somt_item = 3
somt_baggage = 4
somt_flora = 5
somt_passage = 6
somt_spawned_item = 7
somt_spawned_single_ammo_item = 8
somt_spawned_unsheathed_item = 9
somt_shield = 10
somt_temporary_object = 11


# MM
multiplayer_player_loops_end      = 250

multiplayer_game_max_minutes_min  = 5
multiplayer_game_max_minutes_max  = 241

multiplayer_game_max_points       = 10001


mm_destructible_props_begin  = "spr_mm_house_wall_1"
mm_destructible_props_end    = "spr_mm_house_wall_2dd"

mm_destroyed_props_begin     = "spr_mm_house_wall_2dd"
mm_destroyed_props_end       = "spr_mm_wallgate"

mm_cannon_types_begin        = "spr_mm_cannon_12pdr"
mm_cannon_types_end          = "spr_mm_cannonball_6pd"
 
mm_cannon_wood_types_begin   = "spr_mm_cannon_12pdr_wood"
mm_cannon_wood_types_end     = "spr_mm_cannon_12pdr_wheels"

mm_cannon_wheel_types_begin  = "spr_mm_cannon_12pdr_wheels"
mm_cannon_wheel_types_end    = "spr_mm_cannon_12pdr_barrel"

mm_cannon_barrel_types_begin = "spr_mm_cannon_12pdr_barrel"
mm_cannon_barrel_types_end   = "spr_mm_cannon_12pdr_limber_wheels"

mm_unlimber_button_types_begin = "spr_mm_cannon_12pdr_limber"
mm_unlimber_button_types_end   = "spr_mm_limber_button"

mm_cannon_button_types_begin   = "spr_mm_limber_button"
mm_cannon_button_types_end     = "spr_mm_round_button"

mm_button_types_begin       = "spr_mm_cannon_12pdr_limber"
mm_button_types_end         = "spr_mm_ship_rudder"

mm_explosive_props_begin       = "spr_crate_explosive_fra"
mm_explosive_props_end         = "spr_mm_bird"

mm_construct_props_begin       = "spr_mm_stakes_construct"
mm_construct_props_end         = "spr_mm_crator_small"

mm_construct_props_strings     = "str_mm_stakes_construct"

mm_construct_props_meshes     = "mesh_construct_mesh_stakes"

firearm_type_pistol         = 1
firearm_type_carabine       = 2
firearm_type_rifle          = 3
firearm_type_musket         = 4

firearm_types_begin        = 1
firearm_types_end          = firearm_type_musket + 1 # + 1 cause loops are -1


#royale
royale_item_class_musket      = 1
royale_item_class_pistol      = 2
royale_item_class_carabine    = 3 # rifles and musketoons too
royale_item_class_smallsword  = 4 # briquet and knives
royale_item_class_bigsword    = 5 # officer, light and heavy cav
royale_item_class_bottle      = 6
royale_item_class_axe         = 7 # big and small axes
royale_item_class_spear       = 8 # spears and pikes and lances
royale_item_class_club        = 9 # trunks clubs fighthammers
royale_item_class_tool        = 10 # spades, spyglass, construction hammer
royale_item_class_ramrod      = 11 # no box
royale_item_class_lighter     = 12 # no box
royale_item_class_ammo        = 13
royale_item_class_ammo_musket = 14
royale_item_class_ammo_pistol = 15
royale_item_class_end         = 16

royale_item_class_horse_light   = 1
royale_item_class_horse_medium  = 2
royale_item_class_horse_heavy   = 3
royale_item_class_horse_arty    = 4
royale_item_class_horse_end     = 5





mod_variable_use_class_limits  = 1
mod_variable_class_limit_player_count = 2
mod_variable_limit_grenadier   = 3
mod_variable_limit_skirmisher  = 4
mod_variable_limit_rifle       = 5
mod_variable_limit_cavalry     = 6
mod_variable_limit_lancer      = 7
mod_variable_limit_hussar      = 8
mod_variable_limit_dragoon     = 9
mod_variable_limit_cuirassier  = 10
mod_variable_limit_heavycav    = 11
mod_variable_limit_artillery   = 12
mod_variable_limit_rocket      = 13
mod_variable_limit_sapper      = 14
mod_variable_limit_musician    = 15
mod_variable_limit_sergeant    = 16
mod_variable_limit_officer     = 17
mod_variable_limit_general     = 18
mod_variable_squad_size        = 19
mod_variable_scale_squad       = 20
mod_variable_max_num_bots      = 21
mod_variable_build_points_1    = 22
mod_variable_build_points_2    = 23
mod_variable_allow_multiple_firearms = 24
mod_variable_enable_bonuses    = 25
mod_variable_bonus_strength    = 26
mod_variable_bonus_range       = 27
mod_variable_fall_off_horse    = 28
mod_variable_horse_dying       = 29
mod_variable_auto_kick         = 30
mod_variable_max_teamkills_before_kick = 31
mod_variable_auto_horse        = 32
mod_variable_auto_swap         = 33
mod_variable_no_rambo          = 34
mod_variable_no_rambo_range    = 35
mod_variable_limit_surgeon     = 36  #patch1115 59/11
mod_variable_groupfight_mode   = 37  #patch1115 60/8
mod_variable_is_admin          = 38  #patch1115
mod_variable_line_inf_spread   = 39  #patch1115 63/13
mod_variable_num_custom_maps   = 40  #patch1115 64/9
mod_variable_admin_white_list  = 41
mod_variable_competitive_score_mode = 42  #G:comp_score:
mod_variable_enable_custom_directional_keys = 43
mod_variable_custom_string_troop_id = 44 #modders_props:custom_strings: Will hold ID of troop which will be renamed on client in next message
mod_variable_number_of_custom_strings = 45 #modders_props:custom_strings: The number of custom string troops enabled. The more you have, higher the server load on player join
mod_variable_enable_custom_chat = 46 #custom_chat:
mod_variable_limit_arty_train   = 47
mod_variable_request_map_name   = 48
mod_variable_request_map_name_no_open = 49
mod_variable_enable_custom_action_v = 50 #custom_keys:
mod_variable_enable_custom_action_b = 51 #custom_keys:
mod_variable_auto_ff   = 52
mod_variable_beaconed_player   = 53

mod_variable_bw_setting_bird_anim			= 54 #bw_setting_... is taken over from brother wemans
mod_variable_bw_setting_hug_anim			= 55 #unused
mod_variable_bw_setting_build_spam			= 56 #unused
mod_variable_bw_setting_zoom				= 57
mod_variable_bw_setting_voice_spam			= 58 #unused
mod_variable_bw_setting_music_spam			= 59 #unused
mod_variable_bw_setting_nametag_distance	= 60
mod_variable_bw_setting_wallhack			= 61 #unused
mod_variable_bw_setting_freecam				= 62 #unused
mod_variable_tp_mod_enabled					= 63

mod_variables_begin        = mod_variable_use_class_limits
mod_variables_end          = mod_variable_beaconed_player + 1



construct_item_bomb_brit   = 1
construct_item_bomb_fren   = 2
construct_item_bomb_prus   = 3

construct_items_begin      = 1
construct_items_end        = 4


mm_rank_ranker            = 1
mm_rank_musician          = 2
mm_rank_sergeant          = 3
mm_rank_officer           = 4
mm_rank_general           = 5

mm_ranks_begin            = mm_rank_ranker
mm_ranks_end              = mm_rank_general + 1

player_list_player         = 0
player_list_all            = 1

player_list_targets_begin  = 0
player_list_targets_end    = 2


player_list_admin_ban_player_temp    = 0
player_list_admin_slay_player        = 1
player_list_admin_freeze_player      = 2
player_list_admin_swap_player        = 3
player_list_admin_spec_player        = 4
player_list_admin_cheat_heal_player  = 5
player_list_admin_cheat_ammo_player  = 6
player_list_admin_autobalance_player = 7
player_list_admin_beacon_player      = 8
player_list_admin_revive_player      = 9 ##patch1115 46/9
player_list_admin_god_mode      = 10 ##patch1115 54/7
player_list_admin_spawn_player      = 11 ##patch1115 46/29
player_list_commands_begin  = player_list_admin_ban_player_temp
player_list_commands_end    = 12


cheat_item_hammer          = 1
cheat_item_shotgun         = 2
cheat_item_rocketlauncher  = 3
cheat_item_grenade         = 4
cheat_item_horse           = 5
cheat_item_balllauncher    = 6

cheat_items_begin          = cheat_item_hammer
cheat_items_end            = 7


cheat_tele_to              = 0
cheat_tele_bring           = 1
cheat_tele_wall            = 2

cheat_teles_begin          = cheat_tele_to
cheat_teles_end            = 3

#cheat_god_mode             = 1  #patch1115 54/3
# Vincenzo end

#Beaver
instrument_max_tracks = 20 #if adding more than 20 tracks in any list you need to increase this number

drum_sounds_britain_begin = "snd_drum_britain_1"
drum_sounds_britain_end   = "snd_drum_france_1"
drum_sounds_france_begin = drum_sounds_britain_end
drum_sounds_france_end   = "snd_drum_prussia_1"
drum_sounds_prussia_begin = drum_sounds_france_end
drum_sounds_prussia_end   = "snd_drum_russia_1"
drum_sounds_russia_begin = drum_sounds_prussia_end
drum_sounds_russia_end   = "snd_drum_austria_1"
drum_sounds_austria_begin = drum_sounds_russia_end
drum_sounds_austria_end   = "snd_drum_highland_1"
drum_sounds_highland_begin = drum_sounds_austria_end
drum_sounds_highland_end   = "snd_drum_signal_1"
drum_sounds_calls_begin = drum_sounds_highland_end
drum_sounds_calls_end   = "snd_fife_britain_1"

fife_sounds_britain_begin = drum_sounds_calls_end
fife_sounds_britain_end   = "snd_fife_france_1"
fife_sounds_france_begin = fife_sounds_britain_end
fife_sounds_france_end   = "snd_fife_prussia_1"
fife_sounds_prussia_begin = fife_sounds_france_end
fife_sounds_prussia_end   = "snd_fife_russia_1"
fife_sounds_russia_begin = fife_sounds_prussia_end
fife_sounds_russia_end   = "snd_fife_austria_1"
fife_sounds_austria_begin = fife_sounds_russia_end
fife_sounds_austria_end   = "snd_bugle_britain_1"

bugle_sounds_britain_begin = fife_sounds_austria_end
bugle_sounds_britain_end   = "snd_bugle_france_1"
bugle_sounds_france_begin = bugle_sounds_britain_end
bugle_sounds_france_end   = "snd_bugle_prussia_1"
bugle_sounds_prussia_begin = bugle_sounds_france_end
bugle_sounds_prussia_end   = "snd_bugle_russia_1"
bugle_sounds_russia_begin = bugle_sounds_prussia_end
bugle_sounds_russia_end   = "snd_bugle_austria_1"
bugle_sounds_austria_begin = bugle_sounds_russia_end
bugle_sounds_austria_end   = "snd_bugle_signal_1"
bugle_sounds_calls_begin = bugle_sounds_austria_end
bugle_sounds_calls_end   = "snd_bagpipes_britain_1"

bagpipes_sounds_britain_begin = bugle_sounds_calls_end
bagpipes_sounds_britain_end   = "snd_bagpipes_extra_1"
bagpipes_sounds_extra_begin = bagpipes_sounds_britain_end
bagpipes_sounds_extra_end   = "snd_piano_loop_1"

piano_sounds_begin = bagpipes_sounds_extra_end
piano_sounds_end   = "snd_organ_loop_1"

organ_sounds_begin = piano_sounds_end
organ_sounds_end   = "snd_instruments_end"

instrument_sounds_begin   = drum_sounds_britain_begin
instruments_sounds_end    = organ_sounds_end

drum_strings_britain_begin = "str_drum_britain_1"
drum_strings_france_begin = "str_drum_france_1"
drum_strings_prussia_begin = "str_drum_prussia_1"
drum_strings_russia_begin = "str_drum_russia_1"
drum_strings_austria_begin = "str_drum_austria_1"
drum_strings_highland_begin = "str_drum_highland_1"
drum_strings_calls_begin = "str_drum_signal_1"

fife_strings_britain_begin = "str_fife_britain_1"
fife_strings_france_begin = "str_fife_france_1"
fife_strings_prussia_begin = "str_fife_prussia_1"
fife_strings_russia_begin = "str_fife_russia_1"
fife_strings_austria_begin = "str_fife_austria_1"

bugle_strings_britain_begin = "str_bugle_britain_1"
bugle_strings_france_begin = "str_bugle_france_1"
bugle_strings_prussia_begin = "str_bugle_prussia_1"
bugle_strings_russia_begin = "str_bugle_russia_1"
bugle_strings_austria_begin = "str_bugle_austria_1"
bugle_strings_calls_begin = "str_bugle_signal_1"

bagpipes_strings_britain_begin = "str_bagpipes_britain_1"
bagpipes_strings_extra_begin = "str_bagpipes_extra_1"

piano_strings_begin   = "str_piano_tune_1"
organ_strings_begin   = "str_organ_tune_1"

construct_costs_offset    = 50
construct_button_offset   = construct_costs_offset + 20
construct_display_offset  = construct_button_offset + 20
construct_offset_end      = construct_display_offset + 20

troop_select_type_infantry  = 1
troop_select_type_cavalry   = 2
troop_select_type_artillery = 3

command_type_cannon         = 1
command_type_ship           = 2

command_types_begin         = command_type_cannon
command_types_end           = 3

ship_command_forward        = 1
ship_command_back           = 2
ship_command_left           = 3
ship_command_right          = 4
ship_command_forward_left   = 5
ship_command_forward_right  = 6
ship_command_back_left      = 7
ship_command_back_right     = 8

ship_commands_begin         = ship_command_forward
ship_commands_end           = 9


cannon_command_up           = 1
cannon_command_down         = 2
cannon_command_right        = 3
cannon_command_left         = 4
cannon_command_fire         = 5
cannon_command_stop_aim     = 6

cannon_commands_begin         = cannon_command_up
cannon_commands_end           = 7 


kill_type_self          = 1
kill_type_team          = 2
kill_type_enemy         = 3

kill_types_begin        = kill_type_self
kill_types_end          = 4


players_list_action_poll_kick   = 1
players_list_action_poll_ban    = 2
players_list_action_kick        = 3
players_list_action_slay        = 4
players_list_action_freeze      = 5
players_list_action_ban         = 6
players_list_action_ban_temp    = 7
players_list_action_swap        = 8
players_list_action_spec        = 9
players_list_action_mute        = 10
players_list_action_unmute      = 11
players_list_action_heal        = 12
players_list_action_ammo        = 13
players_list_action_beacon      = 14
players_list_action_tele_to     = 15
players_list_action_tele_bring  = 16
players_list_action_revive      = 17 #patch1115 46/10
players_list_action_god      = 18 #patch1115 54/9
players_list_action_spawn     = 19 #patch1115 46/30
players_list_actions_begin      = players_list_action_poll_kick
players_list_actions_end        = 20


cannon_ammo_type_round      = 1
cannon_ammo_type_shell      = 2
cannon_ammo_type_canister   = 3
cannon_ammo_type_bomb       = 4
cannon_ammo_type_rocket     = 5

cannon_ammo_types_begin     = cannon_ammo_type_round
cannon_ammo_types_end       = 6

server_action_force_music_selection = 1

server_actions_begin                = server_action_force_music_selection
server_actions_end                  = 2

player_action_voice         = 1
player_action_music         = 2
player_action_spyglass      = 3
player_action_place_rocket  = 4
player_action_toggle_walk   = 5
player_action_has_cheat     = 6
player_action_surrender = 7
player_action_suicide = 8 #patch1115 58/6
#custom_keys: start
player_action_key_up_held = 9
player_action_key_down_held = 10
player_action_key_left_held = 11
player_action_key_right_held = 12
player_action_key_up_right_held = 13
player_action_key_up_left_held = 14
player_action_key_down_right_held = 15
player_action_key_down_left_held = 16
player_action_key_v = 17
player_action_key_b = 18
#custom_keys: end
player_action_misc_item_drinking = 19
player_action_custom_order_menu_interact = 20
player_action_tropical = 21

player_actions_begin        = player_action_voice
player_actions_end          = 22

#Note: keys have to be value 1 to 0. They are used in a try_for_range
custom_order_menu_key_1 = 1
custom_order_menu_key_2 = 2
custom_order_menu_key_3 = 3
custom_order_menu_key_4 = 4
custom_order_menu_key_5 = 5
custom_order_menu_key_6 = 6
custom_order_menu_key_7 = 7
custom_order_menu_key_8 = 8
custom_order_menu_key_9 = 9
custom_order_menu_key_0 = 10
custom_order_menu_key_end = 11
custom_order_menu_other_menu_active = 98
custom_order_menu_close = 99


voice_type_cry                = 1
voice_type_surrender          = 2
voice_type_comm_ready         = 3
voice_type_comm_present       = 4
voice_type_comm_fire          = 5
voice_type_comm_charge        = 6
voice_type_comm_advance       = 7
voice_type_comm_hold          = 8
voice_type_comm_fire_at_will  = 9
voice_type_comm_on_me         = 10
voice_type_comm_fall_back     = 11
voice_type_cheer              = 12

voice_types_begin             = voice_type_cry
voice_types_end               = 13

music_type_start              = 1
music_type_stop               = 2
music_type_toggle_together    = 3

music_types_begin             = music_type_start
music_types_end               = music_type_toggle_together + 1

spyglass_type_start           = 1
spyglass_type_stop            = 2

drinking_type_start       = 1
drinking_type_stop        = 2

colour_white      = 0
colour_red        = 1
colour_green      = 2
colour_blue       = 3
colour_yellow     = 4
colour_purple     = 5
colour_pink       = 6
colour_magenta    = 7
colour_invisible  = 8

## ORDERS
#Order types
mm_order_type_move      = 0
mm_order_type_formation = 1
mm_order_type_fire      = 2

#Move orders
mm_order_hold       = 0
mm_order_follow     = 1
mm_order_charge     = 2
mm_order_advance    = 3
mm_order_halt       = 4
mm_order_fallback   = 5
mm_order_retreat    = 6
mm_order_slow       = 7
mm_order_quick      = 8
#Formation orders
mm_order_line       = 0
mm_order_column     = 1
mm_order_square     = 2
mm_order_skirmish   = 3
mm_order_wheelleft  = 4
mm_order_wheelright = 5
mm_order_adjust     = 6
#Fire orders
mm_order_holdfire   = 0
mm_order_fireatwill = 1
mm_order_volley     = 2
mm_order_targetpos  = 3
mm_order_targetfree = 4
#Common
mm_order_none       = 10

#Division slots
slot_troop_no_begin_team1 = 0
slot_troop_no_begin_team2 = 10
slot_troops_in_division_begin_team1 = 20
slot_troops_in_division_begin_team2 = 30
slot_formation_order_begin_team1 = 40
slot_formation_order_begin_team2 = 50
slot_fire_order_begin_team1 = 60
slot_fire_order_begin_team2 = 70
slot_volley_state_begin_team1 = 80
slot_volley_state_begin_team2 = 90
slot_move_order_begin_team1 = 100
slot_move_order_begin_team2 = 110

#Agent Behaviour Types
bot_type_attacker   = 0
bot_type_defender   = 1
bot_type_skirmish   = 2

prop_effect_type_sound     = 1
prop_effect_type_particle  = 2
prop_effect_type_stop_all  = 3

prop_effect_types_begin  = prop_effect_type_sound
prop_effect_types_end    = 4

prop_effect_handle_stop    = 0
prop_effect_handle_start   = 1

prop_effect_handles_begin  = prop_effect_handle_stop
prop_effect_handles_end    = 2

admin_chat_type_everyone   = 1
admin_chat_type_inter      = 2

admin_chat_types_begin  = admin_chat_type_everyone
admin_chat_types_end    = 3

admin_chat_type_custom_poll = 4

debug_mode = 1

cannon_hit_effect_event_type_explosion  = 1
cannon_hit_effect_event_type_ground     = 2
cannon_hit_effect_event_type_water_ball = 3
cannon_hit_effect_event_type_wall       = 4

cannon_hit_effect_event_types_begin = cannon_hit_effect_event_type_explosion
cannon_hit_effect_event_types_end = 5


# constants for random number generator.

randomer_const_m1      = 2147483647
randomer_const_m2      = 2147483399
randomer_const_a1      = 40015
randomer_const_a2      = 40692
randomer_const_q1      = 53667  # (store_div,":Q1",":M1",":A1"),
randomer_const_q2      = 52774  # (store_div,":Q2",":M2",":A2"),
randomer_const_r1      = 38657  # (store_mod,":R1",":M1",":A1"),
randomer_const_r2      = 3791   # (store_mod,":R2",":M2",":A2"),
randomer_const_m1_sub1 = 2147483646



admin_id_mask = 0xffffff
admin_id_flag_shift = 4*6
color_mask = 0xff
color_shift = 4*2

# admin_perms_none = -1
# admin_perms_normal = 0
# admin_perms_head = 1
# admin_perms_owner = 2
# pirate_hat_check = 3
# admin_or_vip = 4
# is_in_duel = 4


color_announcement = 0x6666FF
color_warning = 0xFF8000
color_info = 0x89C4F4
color_error = 0x89C4F4


tnt_warning_threshold = 5

players_duelwin = 1
players_duellose = 2
players_propsbuilt = 3
players_heals = 4

#naval_ship = 1
#naval_shirt = 2
#naval_sink = 3
#naval_count = 4
#
#naval_name = 1



## need?
#naval_team_red = 1
#naval_team_green = 2
#naval_team_blue = 3
#naval_team_white = 4
#naval_team_orange = 5
#naval_team_pink = 6
#naval_team_black = 7
#naval_team_yellow = 8
#

