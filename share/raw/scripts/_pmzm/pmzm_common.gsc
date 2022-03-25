#using scripts\_pmzm\pmzm_flashlight;
#using scripts\_pmzm\pmzm_ghost;
#using scripts\_pmzm\pmzm_thermometer;

#namespace pmzm_common;

function init()
{
	// Define function to use to check for the flashlight toggle
	level.func_toggle_flashlight = &ActionSlotFourButtonPressed;

	// Init all other scripts
	pmzm_flashlight::init();
	pmzm_ghost::init();
	pmzm_thermometer::init();
}
