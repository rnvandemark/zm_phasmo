#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;

#insert scripts\shared\version.gsh;

#namespace pmzm_flashlight;

function init()
{
	//// CLIENTFIELDS //// ##############################################################################
    clientfield::register("toplayer", "flashlight_fx_view", VERSION_SHIP, 1, "int");
    clientfield::register("allplayers", "flashlight_fx_world", VERSION_SHIP, 1, "int");

    //-> Add callback after zm_usermap::main();
	callback::on_connect(&on_player_connect);
}

function on_player_connect()
{
	self thread flashlight_init();
}

function flashlight_init()
{
	self set_flashlight_state(1); // Enable flashlight on spawn
	self thread watch_change_flashlight_state();
}

function watch_change_flashlight_state()
{
	self endon("kill_flashlight");
	
	pressed = self [[level.func_toggle_flashlight]]();
	while (true)
	{
		new_pressed = self [[level.func_toggle_flashlight]]();
		if (new_pressed && !pressed)
		{
			self set_flashlight_state(1-self.flashlight_on);
			self Playsound("flashlight_click");
		}
		pressed = new_pressed;
		wait 0.05;
	}
}

function set_flashlight_state(is_on)
{
	self.flashlight_on = is_on;
	self clientfield::set_to_player("flashlight_fx_view", self.flashlight_on);
	self clientfield::set("flashlight_fx_world", self.flashlight_on);
}
