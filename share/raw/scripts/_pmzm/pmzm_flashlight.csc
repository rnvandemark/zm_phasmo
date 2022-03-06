#using scripts\shared\system_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace pmzm_flashlight;
// dont replace anything in your .csc, only add stuff :)

#precache ("client_fx", "_pmzm/flashlight/flashlight_loop");
#precache ("client_fx", "_pmzm/flashlight/flashlight_loop_world");
#precache ("client_fx", "_pmzm/flashlight/flashlight_loop_view_moths");

REGISTER_SYSTEM( "pmzm_flashlight", &main, undefined )

function main()
{
    //// LEVEL EFFECTS //// ##############################################################################

    level._effect[ "flashlight_fx_loop_view" ]          = "_pmzm/flashlight/flashlight_loop";
    level._effect[ "flashlight_fx_loop_view_moths" ]    = "_pmzm/flashlight/flashlight_loop_view_moths";
    level._effect[ "flashlight_fx_loop_world" ]         = "_pmzm/flashlight/flashlight_loop_world";

    //// CLIENTFIELDS //// ##############################################################################

    clientfield::register( "toplayer",      "flashlight_fx_view",           VERSION_SHIP, 1, "int", &flashlight_fx_view,        !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
    clientfield::register( "allplayers",    "flashlight_fx_world",          VERSION_SHIP, 1, "int", &flashlight_fx_world,       !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
}

//// FLASHLIGHT //// ##############################################################################

function flashlight_fx_view( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump ) // self == player
{
    if ( newVal )
    {
        if ( isdefined( self.fx_flashlight_view ) )
            KillFx( localClientNum, self.fx_flashlight_view );

        if ( isdefined( self.fx_flashlight_moth ) )
            KillFx( localClientNum, self.fx_flashlight_moth );

        flash_fx_view = level._effect[ "flashlight_fx_loop_view" ];
            self.fx_flashlight_view = PlayViewmodelFx( localclientnum, flash_fx_view, "tag_flashlight" ); 

        flash_fx_moth = level._effect[ "flashlight_fx_loop_view_moths" ];
            self.fx_flashlight_moth = PlayFxOnTag( localClientNum, flash_fx_moth, self, "j_spine4" );

        playsound( localClientNum, "1_flashlight_click", self.origin ); 
    }

    else
    {
        if ( isdefined( self.fx_flashlight_view ) )
        {
            KillFx( localClientNum, self.fx_flashlight_view );
                self.fx_flashlight_view = undefined;

            playsound( localClientNum, "1_flashlight_click", self.origin ); 
        }

        if ( isdefined( self.fx_flashlight_moth ) )
        {
            KillFx( localClientNum, self.fx_flashlight_moth );
                self.fx_flashlight_moth = undefined;
        }
    }
}

function flashlight_fx_world( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump ) // self == player
{
    if ( newVal )
    {
        curr_player = GetLocalPlayer( localClientNum );

        if ( isdefined( self.fx_flashlight_world ) )
            KillFx( localClientNum, self.fx_flashlight_world );

        if( curr_player != self )
        {
            flash_fx_world = level._effect[ "flashlight_fx_loop_world" ];
                self.fx_flashlight_world = PlayFxOnTag( localClientNum, flash_fx_world, self, "tag_flashlight" );
        }
    }

    else
    {
        if ( isdefined( self.fx_flashlight_world ) )
        {
            KillFx( localClientNum, self.fx_flashlight_world );
                self.fx_flashlight_world = undefined;
        }
    }
}
