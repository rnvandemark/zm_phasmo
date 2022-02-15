#using scripts\shared\system_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace zm_flashlight;
// dont replace anything in your .csc, only add stuff :)

REGISTER_SYSTEM( "zm_flashlight", &main, undefined )

function main()
{
	//// CLIENTFIELDS //// ##############################################################################

    clientfield::register( "toplayer",		"flashlight_fx_view",			VERSION_SHIP, 1, "int" );
    clientfield::register( "allplayers",	"flashlight_fx_world",			VERSION_SHIP, 1, "int" );

    //-> Add callback after zm_usermap::main();

	callback::on_connect 	( &on_player_connect );
}


function on_player_connect()
{
	self thread flashlight_init();
}

function flashlight_init()
{
	self.flashlight_enabled = true;

	self clientfield::set_to_player( "flashlight_fx_view", 1 ); // Flashlight is enabled on spawn
	self clientfield::set( "flashlight_fx_world",	 1 );		// Flashlight is enabled on spawn

	self thread flashlight_watch_usebutton();
}

function flashlight_watch_usebutton()
{
	self endon( "kill_flashlight" );
	
	while( 1 )
	{
		if( self ActionSlotFourButtonPressed() )
		{
			catch_next = false;
			for( i = 0; i <= 0.5; i += 0.05 )
			{
				if( catch_next && self ActionSlotFourButtonPressed() )
				{
					if( !self.flashlight_enabled )
					{
						self flashlight_state( "ON" );
						wait 1;
						break;
					}

					else
					{
						self flashlight_state( "OFF" );
						wait 1;
						break;
					}
				}

				else if( !( self ActionSlotFourButtonPressed() ) )
					catch_next = true;

				wait 0.05;
			}
		}
		wait 0.05;
	}
}

function flashlight_state( state )
{
	if( !isdefined( state ) )
		break;

	if( state == "ON" )
	{
		self clientfield::set_to_player( "flashlight_fx_view", 1 );
		self clientfield::set( "flashlight_fx_world",	 1 );
		self.flashlight_enabled = true;
		break;
	}

	if( state == "OFF" )
	{
		self clientfield::set_to_player( "flashlight_fx_view", 0 );
		self clientfield::set( "flashlight_fx_world",	 0 );
		self.flashlight_enabled = false;
		break;
	}
}