require "event_mgr"
	
local physics_fps 			= 30
local dt          			= 1/physics_fps 	--s
local ball_speed  			= 50 				--m/s
local gravity				= -9.81				--m/s²
local ball_radius   		= 0.27				--m
local ball_max_life_time 	= 120				--s

--set default values for our settings
settings.battle_toys:init({
	ball_damage_mul = 1,
	lifesteal = 0,
})

--The ball has a collider, but warband is not good at handling high speed collision.
--So hack together our own collision
--https://www.geogebra.org/3d/vjkvwgmg
local function ball_knockback(ball_pos, speed)
	for ag in game.agentsIt(ball_pos, speed:len()*5, 1) do
		if not (game.agent_is_active(ag) and game.agent_is_alive(ag))
		   or   game.agent_is_active(game.agent_get_horse(ag))
		then 
			goto continue 
		end

		game.agent_get_position(0, ag)
		local ag_pos = game.pos0
		ag_pos:moveZ(1) --take belly height
		local ball2ag = ag_pos.o - ball_pos.o

		--if we used the small ball radius for this calculation it would be very hard to hit
		--mostly because we dont take the agent bounding box into account, we treat them like a point without size
		local collision_radius = 1

		--if we orthogonally project ball2ag onto speed,
		--this factor will tell use where on the speed vec it will land.
		--alpha=0 is at the start, 1 at the end. So outside 0-1 means we can't have collision.
		local alpha = speed:dot(ball2ag) / (speed:len()^2)
		if alpha < 0 or alpha > 1 then goto continue end

		--calculate the orthogonal distance from ball2ag to speed vec
		--the len of the cross product is equal to the area of the parallelogram that the 2 vectors open,
		--divided by one side gives the height
		local d = speed:cross(ball2ag):len() / speed:len()
		if d > collision_radius then goto continue end

		--since we are here, we have collision. now calculate the knockback vector.
		--this is the vector from the center of the ball at the moment of collision, to the agent
		local a = math.sqrt(collision_radius^2 - d^2) --absolute length of adjacent leg
		local center = speed * (alpha - a/speed:len())
		local kb = (ball2ag - center) / collision_radius --normalized direction vector

		--actually, it looks much better if we bias the acceleration into the direction of the ball
		kb = kb:lerp(speed:unit(), 0.5)

		--only thing left is to figure out how strong the knockback should be
		--since our speed is already multiplied with dt, and we accelerate over a single frame,
		--cancel dt out again
		kb = kb * kb:dot(speed) / dt

		--if there is negative z it will eat all the speed due to ground friction
		--also looks cool if they fly in the air
		kb.z = math.max(kb.z, 3) * 10

		game.agent_accelerate(ag, game.pos.new({o = kb}), 0)
		game.play_sound_at_position(game.const.snd_wooden_hit_high_armor_high_damage, ag_pos)

		if game.agent_is_human(ag) then --applying this anim to horse would crash the game
			game.agent_set_animation(ag, game.const.anim_strike_fall_back_rise, 0)
	        game.agent_set_animation(ag, game.const.anim_strike_fall_back_rise_upper, 1)
	    end

		game.agent_deliver_damage_to_agent(getMyAgent() or ag, ag, kb:len()*2*settings.battle_toys.ball_damage_mul, game.const.itm_stones)

		::continue::
	end
end

--Ball shoot trigger
event_mgr.subscribe("timer_0.1", "net_sp, net_host", function()
	if not game.key_is_down(game.const.key_q) then return end
	if game.is_presentation_active(prsnt_console) then return end
	if game.edit_mode_window_open() then return end

	--Spawn ball at mission cam
	game.mission_cam_get_position(0)
	local ball_pos = game.pos0
	ball_pos:moveY(2)
	ball_pos:moveZ(-1)

	local ball = find_or_create_scene_prop(game.const.spr_stone_ball, ball_pos)
	game.prop_instance_enable_physics(ball, 1) --is this needed? idk

	--rot.f is the local y axis (f=forwards) of the position
	local speed = vector3.new(ball_pos.rot.f * ball_speed)

	game.play_sound_at_position(game.const.snd_throw_stone, ball_pos)


	--Now animate the ball
	local ray_start = game.pos.new()
	local hit, prop, hit_pos
	local life_time = 0

	timeout.next_frame(function(self)
		if hit then
			game.particle_system_burst(game.const.psys_dummy_smoke, hit_pos, 30)
			game.particle_system_burst(game.const.psys_gourd_piece_1, hit_pos, 5)
			game.particle_system_burst(game.const.psys_gourd_piece_2, hit_pos, 5)
			timeout.add(1000, clean_up_scene_prop, ball)
		else
			game.prop_instance_stop_animating(ball)
			
			--check if we will collide first...
			ray_start.o = ball_pos.o
			ray_start.rot.f = speed:unit()
			--i dont know if these is really needed for the ray cast, but technically the rotation would be broken if we dont do it
			ray_start.rot.u = ray_start.rot.s:cross(ray_start.rot.f) 

			local ray_len = speed:len()*dt

			--We have to temporarily move the ball out of the way, or the ray cast would hit the ball itself
			ball_pos:moveZ(-100)
			game.prop_instance_set_position(ball, ball_pos)

			--Now cast ray
			game.set_fixed_point_multiplier(1000)
			hit, prop = game.cast_ray(1, ray_start, ray_len*1000)
			if hit then
				if game.prop_instance_is_valid(prop) and game.prop_instance_get_scene_prop_kind(prop) == game.const.spr_stone_ball then
					hit = nil
				else
					hit_pos = game.pos1
				end
			end

			--Restore position
			ball_pos:moveZ(100)
			game.prop_instance_set_position(ball, ball_pos)

			ball_knockback(ball_pos, speed*dt)

			--Move forwards
			ball_pos.o = ball_pos.o + speed*dt
			speed.z = speed.z + gravity*dt

			game.prop_instance_animate_to_position(ball, ball_pos, dt*100)


			--Schedule next frame
			life_time = life_time + dt
			if life_time < ball_max_life_time then
				--A nice thing about using timeout to do the physics in this instance
				--is that it decouples the physics framerate from the trigger interval!
				timeout.add(dt*1000, self)
			end
		end
	end)
end)

--ball faster
event_mgr.subscribe("key_page_up", "net_sp, net_host", function()
    ball_speed = math.min(ball_speed + 10, 100)
    print("Ball Speed: " .. ball_speed)
end)

--ball slower
event_mgr.subscribe("key_page_down", "net_sp, net_host", function()
   ball_speed = math.max(ball_speed - 10, 10)
    print("Ball Speed: " .. ball_speed)
end)

--Life Steal
event_mgr.subscribe("ti_on_agent_hit", "net_sp, net_host", function()
	if settings.battle_toys.lifesteal == 0 then return end
	local victim = game.store_trigger_param_1()
	local dealer = game.store_trigger_param_2()
	local dmg    = game.store_trigger_param_3()
	local my_ag  = getMyAgent()
	if dealer ~= my_ag or victim == my_ag then return end

	--dmg can be very high, but victim hp low
	local vict_hp = game.store_agent_hit_points(victim, 1)
	dmg = math.min(dmg, vict_hp)

	local hp = game.store_agent_hit_points(my_ag, 1)
	local bonus = dmg*settings.battle_toys.lifesteal
	game.agent_set_hit_points(my_ag, hp + bonus, 1)
end)

root_menu.add_btn("Battle Toys", function()
    menu.show({
        caption = {text = "Battle Toys"},

        items = {
            {
                id = "slider_ball_dmg",
                type = "slider",
                -- text = "Ball Damage 100%",
                val = settings.battle_toys.ball_damage_mul*10,
                min = 0,
                max = 100,
                OnChange = function(menu_data, self, val)
                	settings.battle_toys.ball_damage_mul = val/10
                    self.caption_item.text = string.format("Ball Damage %d%%", val*10)
                end,
                init_change = true --this will trigger OnChange once after item loaded to set caption
            },
            {
                id = "slider_settings.battle_toys.lifesteal",
                type = "slider",
                -- text = "settings.battle_toys.lifesteal 0%",
                val = settings.battle_toys.lifesteal*100,
                min = 0,
                max = 100,
                OnChange = function(menu_data, self, val)
                	settings.battle_toys.lifesteal = val/100
                    self.caption_item.text = string.format("Life Steal %d%%", val)
                end,
                init_change = true
            },
            {
                type = "section",
                text = "Hotkeys",
            },
                {
                    type = "text",
                    text = "Q: Shoot Ball",
                    scale = 0.8
                },
                {
                    type = "text",
                    text = "Page Up: Increase Ball Velocity",
                    scale = 0.8
                },
                {
                    type = "text",
                    text = "Page Up: Decrease Ball Velocity",
                    scale = 0.8
                },
            {
                type = "section_end",
                text = "Draw Map",
            },
        },
    })
end)