#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\math_shared;

#insert scripts\shared\version.gsh;
#insert scripts\_pmzm\pmzm_temperature_monitor.gsh;

#namespace pmzm_temperature_monitor;

function print_debug(msg)
{
	if (isDefined(level.debug_pmzm_temperature) && level.debug_pmzm_temperature)
	{
		iprintlnbold("^6PMZM:^7 " + msg);
	}
}

function init()
{
	// Enable/Disable debugging
	level.debug_pmzm_temperature = true;

	clientfield::register(
		"toplayer",
		PMZM_TEMPERATURE_CLIENTFIELD_ISFREEZING,
		VERSION_SHIP,
		1,
		"int"
	);
	clientfield::register(
		"clientuimodel",
		PMZM_TEMPERATURE_CLIENTFIELD_UIMODEL_CELSIUS,
		VERSION_SHIP,
		PMZM_TEMPERATURE_FIELD_BITS,
		"int"
	);

	callback::on_connect(&on_player_connect);
}

// self is player
function on_player_connect()
{
	self thread update_temperature();
}

// self is player
// TODO: implement real logic for the selected temperature
function update_temperature()
{
	self endon("disconnect");

	// The temperature can be anywhere in the range [0, max_value), which is
	// mapped to celsius
	max_value = math::pow(2, PMZM_TEMPERATURE_FIELD_BITS);

	while (1)
	{
		new_temp_bits = randomInt(max_value);
		self clientfield::set_player_uimodel(
			PMZM_TEMPERATURE_CLIENTFIELD_UIMODEL_CELSIUS,
			new_temp_bits
		);
		self clientfield::set_to_player(
			PMZM_TEMPERATURE_CLIENTFIELD_ISFREEZING,
			int(temperature_is_freezing(new_temp_bits))
		);
		wait(PMZM_TEMPERATURE_UPDATE_PERIOD);
	}
}

function temperature_is_freezing(temp_bits)
{
	return 0 > (PMZM_TEMPERATURE_MIN + (temp_bits * PMZM_TEMPERATURE_STEP));
}
