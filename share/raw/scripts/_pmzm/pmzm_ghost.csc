#using scripts\shared\clientfield_shared;
#using scripts\zm\_zm;
#insert scripts\shared\version.gsh;

#define NORMAL_ZOMBIE_EYE_FX "frost_iceforge/red_zombie_eyes"
#precache("client_fx", NORMAL_ZOMBIE_EYE_FX);

#define GHOST_HUNT_ZOMBIE_EYE_FX "frost_iceforge/white_zombie_eyes"
#precache("client_fx", GHOST_HUNT_ZOMBIE_EYE_FX);

#namespace pmzm_ghost;

function init()
{
	clientfield::register("world", "hunt_active", VERSION_SHIP, 1, "int", &ghost_boss_hunt_active_changed, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
	clientfield::register("actor", "hunt_possessed", VERSION_SHIP, 1, "int", &hunt_possession_changed, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
	level._override_eye_fx = NORMAL_ZOMBIE_EYE_FX;
}

function ghost_boss_hunt_active_changed(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	if (1 == newVal)
	{
		level._override_eye_fx = GHOST_HUNT_ZOMBIE_EYE_FX;
	}
	else
	{
		level._override_eye_fx = NORMAL_ZOMBIE_EYE_FX;
	}
	iprintlnbold("Hunt active: " + level._override_eye_fx);
}

function hunt_possession_changed(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	// To change the zombie's eye color, delete the current eyes, assert that
	// the eye FX override is set as expected, then create the new eyes.
	// ('self' is the actor.)
	expected_eye_fx = undefined;
	if (1 == newVal)
	{
		expected_eye_fx = GHOST_HUNT_ZOMBIE_EYE_FX;
	}
	else
	{
		expected_eye_fx = NORMAL_ZOMBIE_EYE_FX;
	}
	while (expected_eye_fx != level._override_eye_fx)
	{
		wait(0.05);
	}
	self zm::deleteZombieEyes(localClientNum);
	self zm::createZombieEyes(localClientNum);
	self mapshaderconstant(localClientNum, 0, "scriptVector2", 0, zm::get_eyeball_on_luminance(), self zm::get_eyeball_color());
}
