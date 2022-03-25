#using scripts\shared\callbacks_shared;
#using scripts\shared\util_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;

#insert scripts\_pmzm\pmzm_thermometer.gsh;

#using_animtree("generic");

#precache("fx", "_pmzm/weapons/thermometer_upgraded/icegun_icewind");
#precache("fx", "_pmzm/weapons/thermometer_upgraded/icegun_ice_grow");
#precache("fx", "_pmzm/weapons/thermometer_upgraded/icegun_ice_shatter");

#namespace pmzm_thermometer;

function print_debug(msg)
{
	if (isDefined(level.debug_pmzm_thermometer) && level.debug_pmzm_thermometer)
	{
		iprintlnbold("^6PMZM:^7 " + msg);
	}
}

function init()
{
	// Enable/Disable debugging
	level.debug_pmzm_thermometer = true;

	// Capture the thermometer weapons
	level.wpn_pmzm_thermometer_upgraded_flame = getWeapon(PMZM_WPNNAME_THERMOMETER_UPGRADED_FLAME);
	level.wpn_pmzm_thermometer_upgraded_ice = getWeapon(PMZM_WPNNAME_THERMOMETER_UPGRADED_ICE);

	zombie_utility::set_zombie_var(PMZM_ZVAR_THERMOMETER_UPGRADED_ICE_CYLINDER_RADIUS, 180);
	zombie_utility::set_zombie_var(PMZM_ZVAR_THERMOMETER_UPGRADED_ICE_RANGE, 400);
	zombie_utility::set_zombie_var(PMZM_ZVAR_THERMOMETER_UPGRADED_ICE_DAMAGE, 2500);

	level._effect[PMZM_EFF_THERMOMETER_UPGRADED_ICE_SMOKE_CLOUD] = "_pmzm/weapons/thermometer_upgraded/icegun_icewind";
	level._effect[PMZM_EFF_THERMOMETER_UPGRADED_ICE_GROW] = "_pmzm/weapons/thermometer_upgraded/icegun_ice_grow";
	level._effect[PMZM_EFF_THERMOMETER_UPGRADED_ICE_SHATTER] = "_pmzm/weapons/thermometer_upgraded/icegun_ice_shatter";

	zm_utility::register_slowdown(
		PMZM_WPNNAME_THERMOMETER_UPGRADED_ICE,
		PMZM_THERMOMETER_UPGRADED_ICE_SLOWDOWN_RATE,
		PMZM_THERMOMETER_UPGRADED_ICE_SLOWDOWN_DURATION
	);

	callback::on_connect(&on_player_connect);
}

// self is player
function on_player_connect()
{
	self thread wait_for_icegun_fired();
}

function wait_for_icegun_fired()
{
	self endon("disconnect");

	while (1)
	{
		self waittill("weapon_fired");
		currWpn = self GetCurrentWeapon();
		if (isDefined(currWpn) && (level.wpn_pmzm_thermometer_upgraded_ice == currWpn))
		{
			// Spin a thread to handle all game mechanics (damage, freeze, etc)
			self thread icegun_fired();

			// Play an effect, a smoke cloud from the weapon
			view_angles = self getTagAngles("tag_flash");
			playFx(
				level._effect[PMZM_EFF_THERMOMETER_UPGRADED_ICE_SMOKE_CLOUD],
				self getTagOrigin("tag_flash"),
				anglesToForward(view_angles),
				anglesToUp(view_angles)
			);
		}
	}
}

function icegun_fired()
{
	cr = level.zombie_vars[PMZM_ZVAR_THERMOMETER_UPGRADED_ICE_CYLINDER_RADIUS];
	cylinder_radius_squared = cr * cr;
	projectile_range = level.zombie_vars[PMZM_ZVAR_THERMOMETER_UPGRADED_ICE_RANGE];
	forward_view_angles = anglesToForward(self getPlayerAngles());

	// Get the position of the weapon's muzzle (the start of the ice cone)
	pos_icecone_start = self getTagOrigin("tag_flash");
	pos_icecone_end = pos_icecone_start + (projectile_range * forward_view_angles);

	zombies = util::get_array_of_closest(
		pos_icecone_start,
		getAiSpeciesArray("axis", "all"),
		undefined,
		undefined,
		projectile_range
	);

	if (isDefined(zombies))
	{
		foreach (zomb in zombies)
		{
			if (zombieIsDead(zomb))
			{
				// zombie died, despawned, etc
				continue;
			}

			pos_zombie = zomb getCentroid();
			if (distanceSquared(pos_icecone_start, pos_zombie) > projectile_range * projectile_range)
			{
				// since the array is sorted by closest enemies, everything else in
				// the list will be out of range
				return;
			}

			if (0 > vectorDot(forward_view_angles, vectorNormalize(pos_zombie - pos_icecone_start)))
			{
				// zombie's behind us
				continue;
			}
			
			radial_origin = pointOnSegmentNearestToPoint(pos_icecone_start, pos_icecone_end, pos_zombie);
			if (distanceSquared(pos_zombie, radial_origin) > cylinder_radius_squared)
			{
				// zombie's outside the range of the cylinder of effect
				continue;
			}

			if (0 == zomb damageConeTrace(pos_icecone_start, self))
			{
				// zombie can't actually be hit from where we are (behind an
				// obstacle or something)
				continue;
			}

			// The zombie was within the range, inflict the damage on it
			zomb thread icegun_do_damage(self);
		}
	}
}

// self is a damaged entity
function icegun_do_damage(player)
{
	// Run override if specified
	if (isDefined(level.func_pmzm_icegun_do_damage))
	{
		return [[level.func_pmzm_icegun_do_damage]](player);
	}
	// Otherwise, handle it here
	else
	{
		// First things first, disable ragdoll in case
		self.nodeathragdoll = true;
		self.noragdoll = true;

		// Calculate how much damage it should do, accounting for double-tap
		damage = level.zombie_vars[PMZM_ZVAR_THERMOMETER_UPGRADED_ICE_DAMAGE];
		if (player hasPerk("specialty_rof"))
		{
			damage = Int(2 * damage);
		}

		// Spawn the ice chunk model, then spin a thread to handle the
		// remaining visuals for freezing the zombie
		ice_chunk_model = spawn("script_model", self getTagOrigin(PMZM_THERMOMETER_UPGRADED_ICE_TAG));
		self thread manage_zombie_freeze(ice_chunk_model);

		// Spawn a struct to track notifications from two separate objects,
		// wait for either to trigger and capture the result
		ent = SpawnStruct();
		self thread util::waittill_string("death", ent);
		ice_chunk_model thread util::waittill_string(PMZM_THERMOMETER_UPGRADED_NOTIFY_ICE_THAWED, ent);
		ent waittill("returned", result);
		ent notify("die");

		// If the zombie died, we already disabled ragdoll so just wait until
		// the ice shatters and then re-enable ragdoll
		if ("death" == result)
		{
			self setEntityPaused(true);
			ice_chunk_model waittill(PMZM_THERMOMETER_UPGRADED_NOTIFY_ICE_THAWED);
			self setEntityPaused(false);
		}
		// Otherwise, just re-enable ragdoll
		else
		{
			// Now the zombie can ragdoll again
			self.nodeathragdoll = false;
			self.noragdoll = false;
		}

		// Delete the ice block model and play a shatter effect
		ice_chunk_model hide();
		ice_chunk_model delete();
		playFx(
			level._effect[PMZM_EFF_THERMOMETER_UPGRADED_ICE_SHATTER],
			self getTagOrigin(PMZM_THERMOMETER_UPGRADED_ICE_TAG)
		);
		self playSound("ice_shatter");

		// Finally, deal the damage if it's alive
		if (!zombieIsDead(self))
		{
			self doDamage(damage, player.origin, player, undefined, "projectile");
		}
	}
}

// self is a damaged entity
function manage_zombie_freeze(ice_chunk_model)
{
	// Spin threads to track the ice model to the zombie and thaw the ice after
	// a specific amount of time
	self thread manage_ice_grow_effect(ice_chunk_model);
	ice_chunk_model thread manage_ice_thaw();

	// Slow the zombie down, do not spin a separate thread, so this blocks
	self zm_utility::slowdown_ai(PMZM_WPNNAME_THERMOMETER_UPGRADED_ICE);
}

// self is the ice model
function manage_ice_thaw()
{
	// The ice "thaws" after the slowdown duration, this notification ends the
	// manage_ice_grow_effect thread if the zombie hasn't died already
	wait(PMZM_THERMOMETER_UPGRADED_ICE_SLOWDOWN_DURATION);
	self notify(PMZM_THERMOMETER_UPGRADED_NOTIFY_ICE_THAWED);
}

// self is a damaged entity
function manage_ice_grow_effect(ice_chunk_model)
{
	self endon("death");
	ice_chunk_model endon(PMZM_THERMOMETER_UPGRADED_NOTIFY_ICE_THAWED);

	ice_chunk_model.angles = self getTagAngles(PMZM_THERMOMETER_UPGRADED_ICE_TAG);
	ice_chunk_model setModel("tag_origin");
	ice_chunk_model linkTo(self, PMZM_THERMOMETER_UPGRADED_ICE_TAG);

	playFxOnTag(
		level._effect[PMZM_EFF_THERMOMETER_UPGRADED_ICE_GROW],
		ice_chunk_model,
		"tag_origin"
	);

	while (1)
	{
		if (!(isDefined(ice_chunk_model) && isDefined(self)))
		{
			break;
		}

		ice_chunk_model.origin = self getTagOrigin(PMZM_THERMOMETER_UPGRADED_ICE_TAG);
		ice_chunk_model.angles = self getTagAngles(PMZM_THERMOMETER_UPGRADED_ICE_TAG);

		wait(0.01);
	}
}

function zombieIsDead(zomb)
{
	return !isDefined(zomb) || !isAlive(zomb) || (isDefined(zomb.marked_for_death) && zomb.marked_for_death);
}
