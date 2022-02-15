#using scripts\codescripts\struct;
#using scripts\shared\flag_shared;
#using scripts\shared\flagsys_shared;
#using scripts\shared\array_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\clientfield_shared;
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
#insert scripts\shared\version.gsh;
#insert scripts\_pmzm\pmzm_ghost.gsh;

#using_animtree("generic");

#namespace pmzm_ghost;

#precache("model", "bo2_brutus_fb_death");

#define SPAWN_FX "_NSZ/Brutus/spawn_fx"
#precache("fx", SPAWN_FX);

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

	clientfield::register("world", "hunt_active", VERSION_SHIP, 1, "int");
	clientfield::register("actor", "hunt_possessed", VERSION_SHIP, 1, "int");

	// Used for testing, if it is true brutus Spawns on round 1
	level.brutus_debug = false;

	// Used to set players invicible for testing
	level.player_debug = false;

	// The minimum rounds to wait until brutus spawns next
	level.min_brutus_round = 2;

	// The max rounds to wait until brutus spawns next
	level.max_brutus_round = 3;

	// How much base health you want brutus to have
	// This health is multiplied by the round number
	// It caps at 85000 health, in spawn_brutus()
	level.brutus_base_health = 3500;

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
	level.brutus_active = false;

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

	// Spin thread to handle the start/end of ghost hunts
	level thread watch_ghost_boss_hunt_start();
	level thread watch_ghost_boss_hunt_finish();
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

function watch_ghost_boss_hunt_start()
{
	level endon("end_game");
	while (1)
	{
		// Wait until a hunt starts
		level waittill(NOTIFY_HUNT_STARTED);
		nsz_iprintlnbold("Hunt started");

		// Set the hunt status client field to 'true'
		level clientfield::set("hunt_active", 1);

		// Pause zombie spawning
		level flag::set_val("spawn_zombies", 0);

		// 'Possess' all of the zombies
		all_zombies = zombie_utility::get_zombie_array();
		foreach (zomb in all_zombies)
		{
			if (!zomb.is_boss)
			{
				zomb clientfield::set("hunt_possessed", 1);
				zomb thread possess_zombie();
			}
		}
	}
}

function watch_ghost_boss_hunt_finish()
{
	level endon("end_game");
	while (1)
	{
		// Wait until a hunt finishes
		level waittill(NOTIFY_HUNT_FINISHED);
		nsz_iprintlnbold("Hunt finished");

		// Set the hunt status client field to 'false'
		level clientfield::set("hunt_active", 0);

		// Resume zombie spawning
		level flag::set_val("spawn_zombies", 1);

		all_zombies = zombie_utility::get_zombie_array();
		foreach (zomb in all_zombies)
		{
			if (isDefined(zomb) && !zomb.is_boss)
			{
				zomb clientfield::set("hunt_possessed", 0);
				level.zombie_total++;
				zomb doDamage(2*zomb.health, zomb.origin);
			}
		}
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

			// Spawn the Brutus
			level spawn_brutus();
		}
	}
}

function spawn_brutus()
{
	// Spawn a Brutus at a chosen spawner after XXX seconds of waiting
	spawner = GetEnt("zombie_brutus", "script_noteworthy");
	wait(RandomIntRange(5, 20));
	spot = choose_a_spawn();
	if (!isDefined(spot))
	{
		nsz_iprintlnbold("^1 No Available Spots For brutus");
		return;
	}

	// Dogs should be disabled, but in case, wait to spawn Brutus until the
	// next round
	if (level flag::exists("dog_round") && level flag::get("dog_round"))
	{
		nsz_iprintlnbold("^1 It is a dog Round Spawn him next round");
		level.next_brutus_round = level.round_number + 1;
		return;
	}

	level.brutus_active = true;
	nsz_iprintlnbold("Spawning Brutus!");

	// Play a randomly selected ghost pre-spawn sound
	prespawn_sound_suffix = randomint(3);
	nsz_iprintlnbold("ghost prespawn index = " + prespawn_sound_suffix);
	playsound_to_players("ghost_boss_prespawn_" + prespawn_sound_suffix);
	wait(10);

	// Play additional Brutus sounds as he's spawning in
	playsound_to_players("brutus_vox_spawn");
	playsound_to_players("brutus_spawn_short");

	level notify(NOTIFY_HUNT_STARTED);

	// Spawn Brutus with the Brutus spawner entity
	// Build him, and run threads to help maintain him
	brutus = zombie_utility::spawn_zombie(spawner);
	brutus thread zombie_spawn_init();
	brutus thread idle_sounds();
	brutus thread check_for_ghost_reached_player();
	brutus thread note_tracker();
	brutus thread watch_hunt_end();
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
	
	brutus ForceTeleport(spot.origin, spot.angles, 1);
	brutus AnimScripted("note_notify", brutus.origin, brutus.angles, %brutus_spawn);
	PlayFx(SPAWN_FX, brutus.origin);
	wait(GetAnimLength(%brutus_spawn)); // Wait until the end of the animation

	brutus thread custom_find_flesh();
}

function possess_zombie()
{
	self endon("death");
	possible_suffices = [];
	possible_suffices[0]= "a";
	possible_suffices[1]= "b";
	possible_suffices[2]= "c";
	possible_suffices[3]= "d";
	possible_suffices[4]= "e";
	anim_name = "ai_zombie_zod_";
	if (self.missingLegs)
	{
		anim_name = anim_name + "crawl_";
	}
	anim_name = anim_name + "stunned_electrobolt_" + possible_suffices[randomint(possible_suffices.size)];
	anim_length = GetAnimLength(anim_name);
	while (1)
	{
		self AnimScripted("placeholder", self.origin, self.angles, anim_name);
		wait(anim_length);
	}
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

function custom_find_flesh()
{
	// Have Brutus recalculate its target player until death
	self endon("death");

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
			targets = array::get_all_closest(self.origin, getplayers());
			for (i = 0; i < targets.size; i++)
			{
				if (zm_utility::is_player_valid(targets[i]))
				{
					self.brutus_enemy = targets[i];
					self.v_zombie_custom_goal_pos = self.brutus_enemy.origin;

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
	self endon("death"); 
	assert(!self.isdog);
	
	self.ai_state = "zombie_think";
	self.find_flesh_struct_string = "find_flesh";

	self SetGoal(self.origin);
	self PathMode("move allowed");
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

function check_for_ghost_reached_player()
{
	// Check for if the ghost reached the player for its lifetime
	self endon("death"); 
	
	while (1)
	{
		if (Distance2d(self.brutus_enemy.origin, self.origin ) < 75 && BulletTracePassed(self.brutus_enemy.origin, self.origin, 0, self, self.brutus_enemy))
		{
			self AnimScripted("note_notify", self.origin, self.angles, %brutus_swing);
			wait(GetAnimLength(%brutus_swing));
		}
		wait(0.05);
	}
}

function note_tracker()
{
	self endon("death");
	
	while (1)
	{
		self waittill("note_notify", note); 
		if (note == "swing")
		{
			self PlaySound("brutus_swing_0" + randomint(2)); 
			PlaySoundAtPosition("brutus_vox_swing", self.origin);
			foreach (player in getplayers())
			{
				if (Distance2d(player.origin, self.origin) < 150 && self.brutus_enemy == player)
				{
					player DoDamage(75, player.origin, self);
				}
			}
		}
		if (note == "spawn_complete")
		{
			self playsound("brutus_spawn");
		}
		if (note == "summon")
		{
			self playsound("brutus_spawn");
			PlaySoundAtPosition("brutus_vox_yell", self.origin);
		}
	}
}

function watch_hunt_end()
{
	// Wait until Brutus dies
	self waittill("death");

	// Notify of the ghost hunt ending
	level notify(NOTIFY_HUNT_FINISHED);

	// Mark Brutus as dead and inactive
	level.brutus_active = false;
	nsz_iprintlnbold("^2Brutus Died");

	// Reuse the spawn effect
	PlayFx(SPAWN_FX, self.origin);

	// Spawn a random powerup
	thread zm_powerups::specific_powerup_drop(undefined, self.origin);

	// Overlap a couple of death sounds
	self PlaySound("brutus_defeated_0" + randomintrange(0, 3));
	self PlaySound("brutus_death");

	// Clone the Brutus model and adjust the angles to the specified pose
	// Hide the delete the model of the Brutus that was originally killed
	clone = spawn("script_model", self.origin);
	clone.angles = self.angles;
	clone SetModel("bo2_brutus_fb");
	self hide();
	clone UseAnimTree(#animtree);
	clone AnimScripted("placeholder", clone.origin, clone.angles, %brutus_death);
	wait(GetAnimLength(%brutus_death));
	self delete();

	// Wait for a little then delete the cloned model
	wait(30);
	clone delete();
}

function playsound_to_players(sound)
{
	foreach (player in getplayers())
	{
		player PlayLocalSound(sound);
	}
}

function anti_instakill(player, mod, hit_location)
{
	return true;
}

function new_thundergun_fling_func(player)
{
	// Do nothing
}

function new_tesla_damage_func(origin, player)
{
	// Do nothing
}

function new_knockdown_damage(player, gib)
{
	// Do nothing
}

function remove_brutus(ai)
{
	foreach (zom in ai)
	{
		if (isDefined(zom.is_boss))
		{
			ArrayRemoveValue(ai, zom, false);
		}
	}
	return ai;
}

function zombie_spawn_init()
{
	self.targetname = "zombie_boss";
	self.script_noteworthy = undefined;

	//A zombie was spawned - recalculate zombie array
	zm_utility::recalc_zombie_array();
	self.animname = "zombie_boss"; 		
	 
	self.ignoreme = false;
	// allows death during animscripted calls
	self.allowdeath = true;
	// needed to make sure this guy does gibs
	self.force_gib = true;
	// needed for melee.gsc in the animscripts
	self.is_zombie = true;
	self allowedStances("stand");
	
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
	
	// This tracks when I can knock down a zombie with a bar
	self.zombie_damaged_by_bar_knockdown = false;

	self.gibbed = false; 
	self.head_gibbed = false;

	self setPhysParams(15, 0, 72);
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

	// no firing - performance gain
	self.holdfire = true;

	self.badplaceawareness = 0;
	self.chatInitialized = false;
	self.missingLegs = false;
	
	self.a.disablepain = true;
	self zm_utility::disable_react(); // SUMEET - zombies dont use react feature.

	self.freezegun_damage = 0;
	self.flame_damage_time = 0;

	// setting avoidance parameters for zombies
	self setAvoidanceMask("avoid none");

	// wait for zombie to teleport into position before pathing
	self PathMode("dont move");

	// We need more script/code to get this to work properly
	self zm_utility::init_zombie_run_cycle(); 
	self thread boss_think(); 
	self thread zm_spawner::zombie_damage_failsafe();
	
	self thread zm_spawner::enemy_death_detection();

	if (isDefined(level._zombie_custom_spawn_logic))
	{
		if (isArray(level._zombie_custom_spawn_logic))
		{
			for (i = 0; i < level._zombie_custom_spawn_logic.size; i++)
			{
				self thread [[level._zombie_custom_spawn_logic[i]]]();
			}
		}
		else
		{
			self thread [[level._zombie_custom_spawn_logic]]();
		}
	}

	self.deathFunction = &zm_spawner::zombie_death_animscript;

	self.meleeDamage = 60;
	self.no_powerups = true;

	self.thundergun_knockdown_func = level.basic_zombie_thundergun_knockdown;
	self.tesla_head_gib_func = &zm_spawner::zombie_tesla_head_gib;

	self.team = level.zombie_team;

	// No sight update
	self.updateSight = false;

	if (isDefined(level.achievement_monitor_func))
	{
		self [[level.achievement_monitor_func]]();
	}

	if (isDefined(level.zombie_init_done))
	{
		self [[level.zombie_init_done]]();
	}
	self.zombie_init_done = true;

	self notify( "zombie_init_done" );
}
