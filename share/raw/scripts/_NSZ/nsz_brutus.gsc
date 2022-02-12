#using scripts\codescripts\struct;
#using scripts\shared\flag_shared;
#using scripts\shared\array_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\util_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;
#using scripts\shared\laststand_shared;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_magicbox;
#using scripts\zm\_zm_powerups;

#insert scripts\shared\aat_zm.gsh;

#using_animtree("generic");

#namespace brutus;

#precache("model", "brutus_helmet");
#precache("model", "bo2_brutus_fb_death");
#precache("model", "perk_clip");

#define SPAWN_FX "_NSZ/Brutus/spawn_fx"
#precache("fx", SPAWN_FX);

#define CHEST_FX "_NSZ/Brutus/chest_fx"
#precache("fx", CHEST_FX);

#define HELMET_SMOKE "_NSZ/Brutus/helmet_smoke"
#precache("fx", HELMET_SMOKE);

#define LOCK_FX "fire/fx_fire_ground_rubble_50x50"
#precache("fx", LOCK_FX);

function nsz_iprintlnbold(string)
{
	if (level.nsz_debug)
	{
		iprintlnbold("^6NSZ Debug:^7 " + string);
	}
}

function init()
{
	//
	// WARNING: all of the variables related to Brutus below will eventually go
	// away, be renamed, and/or be repurposed
	//

	// Used for testing, if it is true brutus Spawns on round 1
	level.brutus_debug = true;

	// Used to set players invicible for testing
	level.player_debug = false;

	// The maximum brutuss you want
	level.max_brutus = 2;

	// The minimum rounds to wait until brutus spawns next
	level.min_brutus_round = 5;

	// The max rounds to wait until brutus spawns next
	level.max_brutus_round = 7;

	// If you want multiple brutus, they will spawn in multiples after this
	// round
	level.multiple_brutus_round = 20;

	// How much base health you want brutus to have
	// This health is multiplied by the round number
	// It caps at 85000 health, in spawn_brutus()
	level.brutus_base_health = 3500;

	// Set to true if you have placed and want Brutus to lock Perk Machines/PaP
	level.brutus_lock_machines = false;

	// The duration, in seconds, of each sound that the ghost can have while
	// idly moving about
	level.ghost_idle_sound_durations = [];
	level.ghost_idle_sound_durations[0] = 1.9;
	level.ghost_idle_sound_durations[1] = 2.0;
	level.ghost_idle_sound_durations[2] = 2.0;
	level.ghost_idle_sound_durations[3] = 1.25;
	level.ghost_idle_sound_durations[4] = 4.6;
	level.ghost_idle_sound_durations[5] = 3.75;
	level.ghost_idle_sound_durations[6] = 3.75;

	// The current number of Brutus spawned
	level.current_brutuses = 0; 

	// What's an octobomb?! Nonetheless, it probably nukes Brutuses by calling
	// this function, an event-listener-esque callback
	level.octobomb_targets = &remove_brutus; 

	// Whether or not to enable Brutus-specific debugging
	level.nsz_debug = true;

	// Finally, spin the main function in a new thread
	thread main(); 
}

function main()
{
	// Wait until all players are connected
	level flag::wait_till("all_players_connected"); 

	level activate_brutus_spawns(); 

	// Spin a thread to handle spawning Brutuses throughout this game
	level thread brutus_spawn_logic(); 
}

function activate_brutus_spawns()
{
	// Init an empty array, populated below in wait_for_activation()
	level.brutus_spawn_points = [];

	// Get all Brutus spawner entities
	structs = struct::get_array("brutus_spawner_spot", "targetname");

	// Ensure we found at least one spawner, skip spawning if not
	if (!isDefined(structs) || structs.size < 1)
	{
		iPrintLnBold( "^1CANNOT FIND BRUTUS STRUCTS" );
		return;
	}

	// For each spawner found, spin a thread to handle enabling it
	foreach (point in structs)
	{
		point thread wait_for_activation();
	}
}

function wait_for_activation()
{
	//
	// The syntax 'my_array[my_array.size] = my_new_value;' essentially appends
	// the value 'my_new_value' to 'my_array'.
	//

	if (self.script_string == "start_zone")
	{
		// The spawner with script_string 'start_zone' is the spawner that's in
		// the spawn room of the map. Therefore, we don't have to wait for that
		// room to be made available, and it can confidently be added to our
		// list of Brutus spawners immediately.
		level.brutus_spawn_points[level.brutus_spawn_points.size] = self;
	}
	else
	{
		// Otherwise, this spawner is only available once this zone becomes
		// available, so wait for the notification.
		level flag::wait_till(self.script_string);
		level.brutus_spawn_points[level.brutus_spawn_points.size] = self;
	}
}

function brutus_spawn_logic()
{
	// What's 'intermission'? Perhaps an event similar to 'death', but less
	// specific / generalized to any game ending?
	level endon("intermission");

	// If Brutus debug is enabled, spin a thread to spawn a Brutus. This gets
	// called basically on init(), so this essentially spawns one immediately.
	if (level.brutus_debug)
	{
		level thread spawn_brutus();
	}

	// Determine the next round number to spawn a Brutus on
	level.next_brutus_round = RandomIntRange(level.min_brutus_round, level.max_brutus_round + 1);
	nsz_iprintlnbold("The Next brutus Round: " + level.next_brutus_round);
	while (1) // Infinite loop, break on 'intermission'
	{
		// Brutus can only spawn at the beginning of rounds, so may as well
		// wait until this round is over
		level waittill("between_round_over");
		if (level.round_number == level.next_brutus_round)
		{
			// We've reached the round to spawn Brutus at, we can calculate the
			// next round for it
			level.next_brutus_round = level.round_number + RandomIntRange(level.min_brutus_round, level.max_brutus_round + 1);

			// Hopefully dogs are disabled, but if not, make sure Brutus does
			// not spawn in the same round
			if (isDefined(level.next_dog_round) && level.next_brutus_round == level.next_dog_round)
			{
				level.next_brutus_round++;
			}

			// Spawn Brutuses until we've reached the max amount
			while (level.current_brutuses < level.max_brutus)
			{
				// Make it feel a little random by waiting XXX seconds
				wait(RandomIntRange(1, 20));

				// Spawn Brutus in this thread, break this while loop if necessary
				if ((level.current_brutuses < level.max_brutus) && (level.round_number >= level.multiple_brutus_round))
				{
					level spawn_brutus();
				}
				else if (level.current_brutuses < level.max_brutus)
				{
					level spawn_brutus();
					break;
				}
			}
		}
	}
}

function spawn_brutus()
{
	// Spawn a Brutus at a chosen spawner after XXX seconds of waiting
	level.current_brutuses++;
	spawner = GetEnt("zombie_brutus", "script_noteworthy");
	wait(RandomIntRange(5, 20));
	spot = choose_a_spawn();
	if (!isDefined(spot))
	{
		nsz_iprintlnbold("^1 No Available Spots For brutus");
		level.current_brutuses--;
		return;
	}

	// Dogs should be disabled, but in case, wait to spawn Brutus until the
	// next round
	if (level flag::exists("dog_round") && level flag::get("dog_round"))
	{
		nsz_iprintlnbold("^1 It is a dog Round Spawn him next round");
		level.current_brutuses--;
		level.next_brutus_round = level.round_number + 1;
		return;
	}

	nsz_iprintlnbold("Spawning Brutus #" + level.current_brutuses);

	// Play a randomly selected ghost pre-spawn sound
	prespawn_sound_suffix = randomint(3);
	nsz_iprintlnbold("ghost prespawn index = " + prespawn_sound_suffix);
	playsound_to_players("ghost_boss_prespawn_" + prespawn_sound_suffix);
	wait(10);

	// Play additional Brutus sounds as he's spawning in
	playsound_to_players("brutus_vox_spawn");
	playsound_to_players("brutus_spawn_short");

	// Spawn Brutus with the Brutus spawner entity
	// Build him, and run threads to help maintain him
	brutus = zombie_utility::spawn_zombie(spawner);
	brutus attach_helmet();
	brutus attach_light();
	brutus thread zombie_spawn_init();
	brutus thread idle_sounds();
	brutus thread melee_track();
	brutus thread note_tracker();
	brutus thread new_death();
	brutus thread aat_override();
	brutus thread zombie_utility::round_spawn_failsafe();

	// Set his health
	test_health = level.brutus_base_health*level.round_number*getplayers().size;
	if (test_health < 85000)
	{
		brutus.health = test_health;
	}
	else
	{
		brutus.health = 85000;
	}

	// Continue to initialize his traits
	brutus.deathanim = %brutus_death;
	brutus BloodImpact("normal");
	brutus.no_damage_points = true;
	brutus.allowpain = false;
	brutus.ignoreall = true;
	brutus.ignoreme = true;
	brutus.allowmelee = false;
	brutus.needs_run_update = true;
	brutus.no_powerups = true;
	brutus.canattack = false;
	brutus detachAll();
	brutus.goalRadius = 32;
	brutus.is_on_fire = true;
	brutus.gibbed = true;
	brutus.variant_type = 0;
	brutus.zombie_move_speed = "sprint";
	brutus.zombie_arms_position = "down";
	brutus.ignore_nuke = true;
	brutus.instakill_func = &anti_instakill;
	brutus.ignore_enemy_count = true;
	brutus PushActors(true);
	brutus.lightning_chain_immune = true;
	brutus.tesla_damage_func = &new_tesla_damage_func;
	brutus.thundergun_fling_func = &new_thundergun_fling_func;
	brutus.thundergun_knockdown_func = &new_knockdown_damage;
	brutus.is_boss = true;

	brutus thread track_helmet();
	
	brutus ForceTeleport(spot.origin, spot.angles, 1);
	brutus AnimScripted("note_notify", brutus.origin, brutus.angles, %brutus_spawn);
	PlayFx(SPAWN_FX, brutus.origin);
	Earthquake(0.4, 4, brutus.origin, 5000);
	wait(GetAnimLength(%brutus_spawn)); // Wait until the end of the animation

	// brutus thread debug_health();
	brutus thread custom_find_flesh();
	if (level.brutus_lock_machines)
	{
		brutus thread watch_for_machines();
	}
}

function attach_light()
{
	//
	// I'm sure this will be removed...
	//

	fire_angles = self.angles;
	fire_angles_forward = anglesToForward(fire_angles);
	fire_init = self.origin + (0, 0, 57);
	impact = fire_init + vectorScale(fire_angles_forward, 9);
	light = spawn("script_model", impact);
	light SetModel("tag_origin");
	light.angles = self.angles;
	light EnableLinkTo();
	light LinkTo(self, "j_spineupper");
	PlayFxOnTag(CHEST_FX, light, "tag_origin");

	self.light = light;
}

function aat_override()
{
	// I believe this overrides how weapon effects behave against Brutus
	while (isDefined(self))
	{
		archetype = self.archetype;

		// always force the cooldown to be less than current time for each
		self.aat_cooldown_start[ZM_AAT_BLAST_FURNACE_NAME] = GetTime();
		self.aat_cooldown_start[ZM_AAT_DEAD_WIRE_NAME] = GetTime();
		self.aat_cooldown_start[ZM_AAT_FIRE_WORKS_NAME] = GetTime();
		self.aat_cooldown_start[ZM_AAT_THUNDER_WALL_NAME] = GetTime();
		self.aat_cooldown_start[ZM_AAT_TURNED_NAME] = GetTime();

		self.no_powerups = true; 
		self.b_octobomb_infected = true; 

		level.aat[ZM_AAT_FIRE_WORKS_NAME].immune_trigger[self.archetype] = true;
		level.aat[ZM_AAT_FIRE_WORKS_NAME].immune_result_direct[self.archetype] = true;
		level.aat[ZM_AAT_FIRE_WORKS_NAME].immune_result_indirect[self.archetype] = true;

		level.aat[ZM_AAT_BLAST_FURNACE_NAME].immune_trigger[self.archetype] = true;
		level.aat[ZM_AAT_BLAST_FURNACE_NAME].immune_result_direct[self.archetype] = true;
		level.aat[ZM_AAT_BLAST_FURNACE_NAME].immune_result_indirect[self.archetype] = true;

		level.aat[ZM_AAT_DEAD_WIRE_NAME].immune_trigger[self.archetype] = true;
		level.aat[ZM_AAT_DEAD_WIRE_NAME].immune_result_direct[self.archetype] = true;
		level.aat[ZM_AAT_DEAD_WIRE_NAME].immune_result_indirect[self.archetype] = true;

		level.aat[ZM_AAT_THUNDER_WALL_NAME].immune_trigger[self.archetype] = true;
		level.aat[ZM_AAT_THUNDER_WALL_NAME].immune_result_direct[self.archetype] = true;
		level.aat[ZM_AAT_THUNDER_WALL_NAME].immune_result_indirect[self.archetype] = true;

		level.aat[ZM_AAT_TURNED_NAME].immune_trigger[self.archetype] = true;
		level.aat[ZM_AAT_TURNED_NAME].immune_result_direct[self.archetype] = true;
		level.aat[ZM_AAT_TURNED_NAME].immune_result_indirect[self.archetype] = true;

		wait(0.05); 
	}

	level.aat[ZM_AAT_FIRE_WORKS_NAME].immune_trigger[archetype] = false;
	level.aat[ZM_AAT_FIRE_WORKS_NAME].immune_result_direct[archetype] = false;
	level.aat[ZM_AAT_FIRE_WORKS_NAME].immune_result_indirect[archetype] = false;

	level.aat[ZM_AAT_BLAST_FURNACE_NAME].immune_trigger[archetype] = false;
	level.aat[ZM_AAT_BLAST_FURNACE_NAME].immune_result_direct[archetype] = false;
	level.aat[ZM_AAT_BLAST_FURNACE_NAME].immune_result_indirect[archetype] = false;

	level.aat[ZM_AAT_DEAD_WIRE_NAME].immune_trigger[archetype] = false;
	level.aat[ZM_AAT_DEAD_WIRE_NAME].immune_result_direct[archetype] = false;
	level.aat[ZM_AAT_DEAD_WIRE_NAME].immune_result_indirect[archetype] = false;

	level.aat[ZM_AAT_THUNDER_WALL_NAME].immune_trigger[archetype] = false;
	level.aat[ZM_AAT_THUNDER_WALL_NAME].immune_result_direct[archetype] = false;
	level.aat[ZM_AAT_THUNDER_WALL_NAME].immune_result_indirect[archetype] = false;

	level.aat[ZM_AAT_TURNED_NAME].immune_trigger[archetype] = false;
	level.aat[ZM_AAT_TURNED_NAME].immune_result_direct[archetype] = false;
	level.aat[ZM_AAT_TURNED_NAME].immune_result_indirect[archetype] = false;
}

function debug_health()
{
	while (1)
	{
		self.health = 100000;
		wait(0.05);
	}
}

function custom_find_flesh()
{
	// Have Brutus recalculate its target player until either death or he goes
	// to lock a perk machine, the box, etc
	self endon("death");
	self endon("locking_target");

	while (1)
	{
		if (isDefined(self.brutus_enemy) && zm_utility::is_player_valid(self.brutus_enemy) && isDefined(self.brutus_enemy.brutus_track_countdown) && self.brutus_enemy.brutus_track_countdown > 0)
		{
			// Brutus is still happy to target the player it is curently after
			self.brutus_enemy.brutus_track_countdown -= 0.05;
			self.v_zombie_custom_goal_pos = self.brutus_enemy.origin;
		}
		else
		{
			// Brutus needs to reevaluate his current target player, set it as
			// the current closet
			nsz_iprintlnbold("^3Aquiring New Brutus Target");
			targets = array::get_all_closest(self.origin, getplayers());
			for (i = 0; i < targets.size; i++)
			{
				if (zm_utility::is_player_valid(targets[i]))
				{
					self.brutus_enemy = targets[i];
					self.v_zombie_custom_goal_pos = self.brutus_enemy.origin;

					nsz_iprintlnbold("^2Aquired New Brutus Target");
					if (!isDefined(targets[i].brutus_track_countdown))
					{
						targets[i].brutus_track_countdown = 2;
					}
					if (isDefined(targets[i].brutus_track_countdown) && targets[i].brutus_track_countdown <= 0)
					{
						targets[i].brutus_track_countdown = 2;
					}
					break;
				}
			}
		}
		wait(0.05);
	}
}

function watch_for_machines()
{
	// Watch for perk, PaP, or mystery box to lock until death
	self endon("death");

	while (1)
	{
		// Look for all structs which identify objects which can be locked
		locks = struct::get_array("brutus_lock", "targetname");
		targets = array::get_all_closest(self.origin, locks);

		// Loop through all locks in order of how they close they are to Brutus
		for (i = 0; i < locks.size; i++)
		{
			//
			// If a machine is visible and all other requirements are met, go
			// to lock it. Afterwards, have Brutus continue to find a player to
			// target, then continue this loop.
			//

			if (targets[i].script_noteworthy == "perk_machine" && !isDefined(targets[i].alread_locked) && Distance2d(self.origin, targets[i].origin) < 300 && BulletTracePassed(self.origin, targets[i].origin, false, self))
			{
				perk_trig = get_perk_trig(targets[i].script_string);
				if (perk_trig.power_on)
				{
					targets[i].alread_locked = true;
					nsz_iprintlnbold("^2Acquired New Brutus Lock Perk");
					self waittill_perk_lock_complete(targets[i]);
					self thread custom_find_flesh();
				}
			}

			if (targets[i].script_noteworthy == "magic_box" && !isDefined(targets[i].alread_locked) && Distance2d(self.origin, targets[i].origin) < 300 && BulletTracePassed(self.origin, targets[i].origin, false, self))
			{
				box = ArrayGetClosest(targets[i].origin, level.chests);
				// iprintlnbold(box.zbarrier zm_magicbox::get_magic_box_zbarrier_state());
				if (box.zbarrier.state == "initial" || box.zbarrier.state == "close")
				{
					targets[i].alread_locked = true;
					nsz_iprintlnbold("^2Acquired New Brutus Lock Magic Box");
					self waittill_box_lock_complete(targets[i], box);
					self thread custom_find_flesh();
				}
			}

			wait(0.05);
		}
	}
}

function get_perk_trig(perk)
{
	perk_trigs = GetEntArray("zombie_vending", "targetname");
	foreach (trig in perk_trigs)
	{
		if (trig.script_noteworthy == perk)
		{
			return trig;
		}
	}
}

function waittill_perk_lock_complete(lock_struct)
{
	// Wait until the given lock struct has finished being locked
	self notify("locking_target");

	while (Distance2d(lock_struct.origin, self.origin) > 55)
	{
		self.v_zombie_custom_goal_pos = lock_struct.origin;
		wait(0.05);
	}

	fx = struct::get_array(lock_struct.target, "targetname");
	fx = array::get_all_closest(lock_struct.origin, fx);
	self OrientMode("face point", undefined, undefined, fx[0].origin);
	self util::waittill_any_timeout(0.5, "orientdone");
	
	self AnimScripted("note_notify", self.origin, self.angles, %brutus_lock_perk);
	wait(GetAnimLength(%brutus_lock_perk)/2);
	// lock_struct.alread_locked = true;
	foreach (spot in fx)
	{
		nsz_iprintlnbold("^2Light Fire");
		spot.model = spawn("script_model", spot.origin);
		spot.model SetModel("tag_origin");
		PlayFxOnTag(LOCK_FX, spot.model, "tag_origin");
	}

	nsz_iprintlnbold("^2Locked: " + lock_struct.script_string);
	trig = get_perk_trig(lock_struct.script_string);
	if (!isDefined(trig))
	{
		iprintlnbold("^1No Perk Trig");
	}
	trig SetTeamForTrigger("axis");
	// iprintlnbold(trig.origin);
	trig.machine PlayLoopSound("brutus_lock_loop");
	trig SetInvisibleToAll();
	t_use = Spawn("trigger_radius_use", trig.origin, 0, 60, 80);
	t_use TriggerIgnoreTeam();
	t_use SetVisibleToAll();
	t_use SetTeamForTrigger("none");
	t_use UseTriggerRequireLookAt();
	t_use SetCursorHint("HINT_NOICON");
	t_use SetHintString("Press and Hold ^3&&1^7 to Unlock [Cost: 2000]");

	t_use.perk_trigger = trig;
	t_use.fx = fx;
	t_use.cost = 2000;
	t_use.lock_struct = lock_struct;
	
	t_use thread locked_think();
}

function waittill_box_lock_complete(lock_struct, box_trig)
{
	// Wait until the given lock struct has finished being locked
	self notify("locking_target");

	while (Distance2d(lock_struct.origin, self.origin) > 35)
	{
		self.v_zombie_custom_goal_pos = lock_struct.origin;
		wait(0.05);
	}

	self AnimScripted("note_notify", self.origin, self.angles, %brutus_lock_box);
	wait(GetAnimLength(%brutus_lock_box)/2);
	// lock_struct.alread_locked = true;
	fx = struct::get_array(lock_struct.target, "targetname");
	foreach (spot in fx)
	{
		nsz_iprintlnbold("^2Light Fire");
		spot.model = spawn("script_model", spot.origin);
		spot.model SetModel("tag_origin");
		PlayFxOnTag(LOCK_FX, spot.model, "tag_origin");
	}

	trig = box_trig;
	// machine = getentarray(level._custom_perks[perk].radiant_machine_name, "targetname");

	// trig SetInvisibleToAll();
	trig notify("kill_chest_think");
	thread zm_unitrigger::unregister_unitrigger(trig.unitrigger_stub);
	if (trig.zbarrier.state == "open")
	{
		trig.zbarrier thread zm_magicbox::set_magic_box_zbarrier_state("close");
	}
	t_use = Spawn("trigger_radius_use", trig.origin, 0, 40, 80);
	t_use TriggerIgnoreTeam();
	t_use SetVisibleToAll();
	t_use SetTeamForTrigger("none");
	t_use UseTriggerRequireLookAt();
	t_use SetCursorHint("HINT_NOICON");
	t_use SetHintString("Press and Hold ^3&&1^7 to Unlock [Cost: 2000]");

	t_use.fx = fx;
	t_use.cost = 2000;
	t_use.lock_struct = lock_struct;
	t_use.sound_ent = t_use.fx[0].model;
	t_use.sound_ent PlayLoopSound("brutus_lock_loop");

	t_use thread locked_think(trig);
}

function locked_think(trig)
{
	while (1)
	{
		self waittill("trigger", player);
		if (player.score >= self.cost)
		{
			player zm_score::minus_to_player_score(self.cost);
			PlaySoundAtPosition("zmb_cha_ching", self.origin);
			if (isDefined(self.perk_trigger))
			{
				self.perk_trigger.machine StopLoopSound(2);
			}
			if (isDefined(self.sound_ent))
			{
				self.sound_ent StopLoopSound(2);
			}
			wait(0.05);
			if (isDefined(self.perk_trigger))
			{
				self.perk_trigger SetTeamForTrigger("allies");
			}
			foreach (fx in self.fx)
			{
				fx.model delete();
			}
			self.lock_struct.alread_locked = undefined;
			self delete();
			if (isDefined(trig))
			{
				trig thread zm_magicbox::treasure_chest_think();
				trig.zbarrier thread zm_magicbox::set_magic_box_zbarrier_state("initial");
			}
		}
		else
		{
			PlaySoundAtPosition("nsz_deny", player.origin);
		}
	}
}

function choose_a_spawn()
{
	// Return a Brutus spawn point closest to a random player
	player = array::randomize(getplayers())[0];	
	if (!isDefined(level.brutus_spawn_points) || level.brutus_spawn_points.size < 1)
	{
		nsz_iprintlnbold("^1 No brutus Spots Are Init");
	}
	return ArrayGetClosest(player.origin, level.brutus_spawn_points);
}

function boss_think()
{
	self endon( "death" ); 
	assert( !self.isdog );
	
	self.ai_state = "zombie_think";
	self.find_flesh_struct_string = "find_flesh";

	self SetGoal( self.origin );
	self PathMode( "move allowed" );
	self.zombie_think_done = true;
}

function idle_sounds()
{
	self endon( "death" ); 
	
	while(1)
	{
		idle_sound_suffix = randomint(level.ghost_idle_sound_durations.size);
		self Playsound("ghost_boss_idle_" + idle_sound_suffix);
		wait(level.ghost_idle_sound_durations[idle_sound_suffix] + (randomintrange(500, 8000)/1000.0));
	}
}

function melee_track()
{
	self endon( "death" ); 
	
	while(1)
	{
		if( Distance2d( self.brutus_enemy.origin, self.origin ) < 75 && BulletTracePassed( self.brutus_enemy.origin, self.origin, 0, self, self.brutus_enemy )  )
		{
			self AnimScripted( "note_notify", self.origin, self.angles, %brutus_swing ); 
			wait( GetAnimLength( %brutus_swing ) ); 
		}
		wait(0.05); 
	}
}

function note_tracker()
{
	self endon( "death" ); 
	
	while(1)
	{
		self waittill( "note_notify", note ); 
		if( note == "swing" )
		{
			chance =  RandomIntRange(0,2); 
			self PlaySound( "brutus_swing_0"+chance ); 
			PlaySoundAtPosition( "brutus_vox_swing", self.origin ); 
			players = getplayers(); 
			foreach( player in players )
			{
				if( Distance2d(player.origin, self.origin) < 150 && self.brutus_enemy == player )
				{
					Earthquake( .25, 3, player.origin, 50 ); 
					player shellShock( "frag_grenade_mp", 1 ); 
					player DoDamage( 75, player.origin, self ); 
				}
			}
		}
		if( note == "spawn_complete" )
		{
			self playsound( "brutus_spawn" ); 
			Earthquake( 0.4, 4, self.origin, 1000 ); 
		}
		if( note == "summon" )
		{
			self playsound( "brutus_spawn" ); 
			PlaySoundAtPosition( "brutus_vox_yell", self.origin ); 
		}
		
		if( note == "lock" )
		{
			self playsound( "brutus_lock" ); 
			PlaySoundAtPosition( "brutus_vox_swing", self.origin ); 
			self playsound( "brutus_clang" ); 
		}
		
	}
}

function new_death()
{
	self waittill( "death" );
	self.light delete(); 
	level.current_brutuses--;
	PlayFx( SPAWN_FX, self.origin ); 
	
	if( level.current_brutuses < 1 )
		thread zm_powerups::specific_powerup_drop( undefined, self.origin);
	
	self PlaySound( "brutus_helmet" ); 
	self PlaySound( "brutus_defeated_0"+randomintrange(0,3) ); 
	self PlaySound( "brutus_death" ); 
	nsz_iprintlnbold( "^2Brutus Died" ); 
	clone = spawn( "script_model", self.origin ); 
	clone.angles = self.angles; 
	clone SetModel( "bo2_brutus_fb" ); 
	self hide(); 
	clone UseAnimTree( #animtree ); 
	clone AnimScripted( "placeholder", clone.origin, clone.angles, %brutus_death );	
	wait( GetAnimLength(%brutus_death) ); 
	self delete(); 
	wait(30); 
	clone delete(); 
}

function attach_helmet()
{
	self.helmet = spawn( "script_model", self GetTagOrigin("j_head") ); 
	self.helmet SetModel( "brutus_helmet" ); 
	self.helmet.angles = self GetTagAngles("j_head"); 
	self.helmet EnableLinkTo(); 
	self.helmet LinkTo( self, "j_head" ); 
}

function playsound_to_players(sound)
{
	players = getplayers(); 
	foreach( player in players )
		player PlayLocalSound( sound );
}

function track_helmet()
{
	pop_off = self.health/2; 
	while(self.health > pop_off )
		wait(0.05); 
	
	self PlaySound( "brutus_helmet" ); 
	self PlaySound( "brutus_vox_yell" ); 
	
	self.helmet Unlink(); 
	self.helmet Launch( (0,0,200), (0,200,200) ); 
	
	PlayFxOnTag( HELMET_SMOKE, self, "j_head" ); 
	
	self AnimScripted( "note_notify", self.origin, self.angles, %brutus_headpain, undefined, undefined, undefined, .1 ); 
	wait( GetAnimLength(%brutus_headpain) ); 
	self AnimScripted( "note_notify", self.origin, self.angles, %brutus_enrage, undefined, undefined, undefined, .2 ); 
	wait(5); 
	self.helmet delete(); 
}

function anti_instakill( player, mod, hit_location )
{
	return true; 
}

function new_thundergun_fling_func( player )
{
	self DoDamage( 5000, self.origin, player ); 
}

function new_tesla_damage_func( origin, player )
{
	self DoDamage( 4000, self.origin, player ); 
}

function new_knockdown_damage( player, gib )
{
	self DoDamage( 1000, self.origin, player ); 
}

function remove_brutus( ai )
{
	foreach( zom in ai )
	{
		if( isDefined(zom.is_boss) )
			ArrayRemoveValue( ai, zom, false ); 
	}
	return ai; 
}

// set up zombie walk cycles ================================================================================
function zombie_spawn_init()
{
	self.targetname = "zombie_boss";
	self.script_noteworthy = undefined;

	//A zombie was spawned - recalculate zombie array
	zm_utility::recalc_zombie_array();
	self.animname = "zombie_boss"; 		
	
	//pre-spawn gamemodule init
	// if(isdefined(zm_utility::get_gamemode_var("pre_init_zombie_spawn_func")))
	// {
		// self [[zm_utility::get_gamemode_var("pre_init_zombie_spawn_func")]]();
	// }
	 
	self.ignoreme = false;
	self.allowdeath = true; 			// allows death during animscripted calls
	self.force_gib = true; 		// needed to make sure this guy does gibs
	self.is_zombie = true; 			// needed for melee.gsc in the animscripts
	self allowedStances( "stand" );
	
	//needed to make sure zombies don't distribute themselves amongst players
	self.attackerCountThreatScale = 0;
	//reduce the amount zombies favor their current enemy
	self.currentEnemyThreatScale = 0;
	//reduce the amount zombies target recent attackers
	self.recentAttackerThreatScale = 0;
	//zombies dont care about whether players are in cover
	self.coverThreatScale = 0;
	//make sure zombies have 360 degree visibility
	self.fovcosine = 0;
	self.fovcosinebusy = 0;
	
	self.zombie_damaged_by_bar_knockdown = false; // This tracks when I can knock down a zombie with a bar

	self.gibbed = false; 
	self.head_gibbed = false;
	
	// might need this so co-op zombie players cant block zombie pathing
//	self PushPlayer( true ); 
//	self.meleeRange = 128; 
//	self.meleeRangeSq = anim.meleeRange * anim.meleeRange; 

	self setPhysParams( 15, 0, 72 );
	self.goalradius = 32;
	
	self.disableArrivals = true; 
	self.disableExits = true; 
	self.grenadeawareness = 0;
	self.badplaceawareness = 0;

	self.ignoreSuppression = true; 	
	self.suppressionThreshold = 1; 
	self.noDodgeMove = true; 
	self.dontShootWhileMoving = true;
	self.pathenemylookahead = 0;


	self.holdfire			= true;	//no firing - performance gain

	self.badplaceawareness = 0;
	self.chatInitialized = false;
	self.missingLegs = false;

	if ( !isdefined( self.zombie_arms_position ) )
	{
		if(randomint( 2 ) == 0)
			self.zombie_arms_position = "up";
		else
			self.zombie_arms_position = "down";
	}
	
	self.a.disablepain = true;
	self zm_utility::disable_react(); // SUMEET - zombies dont use react feature.

	// if ( isdefined( level.zombie_health ) )
	// {
		// self.maxhealth = level.zombie_health; 
		
		// if( IsDefined(level.a_zombie_respawn_health[ self.archetype ] ) && level.a_zombie_respawn_health[ self.archetype ].size > 0 )
		// {
			// self.health = level.a_zombie_respawn_health[ self.archetype ][0];
			// ArrayRemoveValue(level.a_zombie_respawn_health[ self.archetype ], level.a_zombie_respawn_health[ self.archetype ][0]);		
		// }
		// else
		// {
			// self.health = level.zombie_health;
		// }	 
	// }
	// else
	// {
		// self.maxhealth = level.zombie_vars["zombie_health_start"]; 
		// self.health = self.maxhealth; 
	// }

	self.freezegun_damage = 0;

	//setting avoidance parameters for zombies
	self setAvoidanceMask( "avoid none" );

	// wait for zombie to teleport into position before pathing
	self PathMode( "dont move" );

	// level thread zombie_death_event( self );

	// We need more script/code to get this to work properly
//	self add_to_spectate_list();
//	self random_tan(); 
	self zm_utility::init_zombie_run_cycle(); 
	self thread boss_think(); 
	// self thread zombie_utility::zombie_gib_on_damage(); 
	self thread zm_spawner::zombie_damage_failsafe();
	
	self thread zm_spawner::enemy_death_detection();

	if(IsDefined(level._zombie_custom_spawn_logic))
	{
		if(IsArray(level._zombie_custom_spawn_logic))
		{
			for(i = 0; i < level._zombie_custom_spawn_logic.size; i ++)
			{
			self thread [[level._zombie_custom_spawn_logic[i]]]();
			}
		}
		else
		{
			self thread [[level._zombie_custom_spawn_logic]]();
		}
	}
	
	// if ( !isdefined( self.no_eye_glow ) || !self.no_eye_glow )
	// {
		// if ( !IS_TRUE( self.is_inert ) )
		// {
			// self thread zombie_utility::delayed_zombie_eye_glow();	// delayed eye glow for ground crawlers (the eyes floated above the ground before the anim started)
		// }
	// }
	self.deathFunction = &zm_spawner::zombie_death_animscript;
	self.flame_damage_time = 0;

	self.meleeDamage = 60;	// 45
	self.no_powerups = true;
	
	// self zombie_history( "zombie_spawn_init -> Spawned = " + self.origin );

	self.thundergun_knockdown_func = level.basic_zombie_thundergun_knockdown;
	self.tesla_head_gib_func = &zm_spawner::zombie_tesla_head_gib;

	self.team = level.zombie_team;
	
	// No sight update
	self.updateSight = false;

	// self.heroweapon_kill_power = ZM_ZOMBIE_HERO_WEAPON_KILL_POWER;
	// self.sword_kill_power = ZM_ZOMBIE_HERO_WEAPON_KILL_POWER;

	if ( isDefined(level.achievement_monitor_func) )
	{
		self [[level.achievement_monitor_func]]();
	}

	// gamemodule post init
	// if(isdefined(zm_utility::get_gamemode_var("post_init_zombie_spawn_func")))
	// {
		// self [[zm_utility::get_gamemode_var("post_init_zombie_spawn_func")]]();
	// }

	if ( isDefined( level.zombie_init_done ) )
	{
		self [[ level.zombie_init_done ]]();
	}
	self.zombie_init_done = true;

	self notify( "zombie_init_done" );
}