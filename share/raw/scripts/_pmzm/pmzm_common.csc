#using scripts\_pmzm\pmzm_flashlight;
#using scripts\_pmzm\pmzm_ghost;
#using scripts\_pmzm\pmzm_thermometer;
#using scripts\_pmzm\pmzm_temperature_monitor;

#namespace pmzm_common;

function init()
{
	// Load custom Lua
	luiLoad("ui.uieditor.menus.hud.hud_zm_phasmo");

	// Init all other scripts
	pmzm_flashlight::init();
	pmzm_ghost::init();
	pmzm_thermometer::init();
	pmzm_temperature_monitor::init();
}
