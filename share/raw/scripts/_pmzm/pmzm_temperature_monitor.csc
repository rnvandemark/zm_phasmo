#using scripts\shared\clientfield_shared;

#insert scripts\shared\version.gsh;
#insert scripts\_pmzm\pmzm_temperature_monitor.gsh;

#namespace pmzm_temperature_monitor;

#precache("client_fx", "_pmzm/misc/fx_cold_breath_1p");

function init()
{
	// Advertise client fields
	clientfield::register(
		"toplayer",
		PMZM_TEMPERATURE_CLIENTFIELD_ISFREEZING,
		VERSION_SHIP,
		1,
		"int",
		&cold_breath_active_changed,
		!CF_HOST_ONLY,
		!CF_CALLBACK_ZERO_ON_NEW_ENT
	);
	clientfield::register(
		"clientuimodel",
		PMZM_TEMPERATURE_CLIENTFIELD_UIMODEL_CELSIUS,
		VERSION_SHIP,
		PMZM_TEMPERATURE_FIELD_BITS,
		"int",
		undefined,
		0,
		0
	);

	level._effect[PMZM_EFF_TEMPERATURE_COLD_BREATH_1P] = "_pmzm/misc/fx_cold_breath_1p";

	level.pmzm_player_breath_freezing = [];
}

// self is player
function cold_breath_active_changed(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	// Only enter this block if the value is new
	if ((!isDefined(level.pmzm_player_breath_freezing[localClientNum])) || (newVal != level.pmzm_player_breath_freezing[localClientNum]))
	{
		// Just to be sure, notify to end the breath for any new value
		self notify(PMZM_TEMPERATURE_NOTIFY_STOP_BREATH + localClientNum);

		if (1 == newVal)
		{
			self thread play_cold_breath(localClientNum);
		}
		level.pmzm_player_breath_freezing[localClientNum] = newVal;
	}
}

// self is player
function play_cold_breath(localClientNum)
{
	self endon("disconnect");
	self endon("entityshutdown");
	self endon("death");
	self endon(PMZM_TEMPERATURE_NOTIFY_STOP_BREATH + localClientNum);

	while (1)
	{
		playFxOnCamera(
			localClientNum,
			level._effect[PMZM_EFF_TEMPERATURE_COLD_BREATH_1P],
			(0, 0, 0),
			(1, 0, 0),
			(0, 0, 1)
		);
		wait(randomIntRange(3,7));
	}
}
