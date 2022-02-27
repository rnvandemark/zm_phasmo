# zm_phasmo

## Installation instructions

1) Drag the folders into your root directory. Example: A:\SteamLibrary\steamapps\common\Call of Duty Black Ops III

-------------------------------------------------
2) Open useraliases.csv in share>raw>sound>aliases and add the following lines:

```
# ======= Phasmo Ghost Boss ========
ghost_boss_prespawn_0,,,_pmzm\ghost_boss\prespawn0.wav,,,UIN_MOD,,,,,,,,,0,0,95,100,0,3000,3000,,,,,,,,,,,,,,,,3d,,,NONLOOPING,,,0,0,0,0,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
ghost_boss_prespawn_1,,,_pmzm\ghost_boss\prespawn1.wav,,,UIN_MOD,,,,,,,,,0,0,95,100,0,3000,3000,,,,,,,,,,,,,,,,3d,,,NONLOOPING,,,0,0,0,0,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
ghost_boss_prespawn_2,,,_pmzm\ghost_boss\prespawn2.wav,,,UIN_MOD,,,,,,,,,0,0,95,100,0,3000,3000,,,,,,,,,,,,,,,,3d,,,NONLOOPING,,,0,0,0,0,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
ghost_boss_idle_0,,,_pmzm\ghost_boss\idle0_1900ms.wav,,,UIN_MOD,,,,,,,,,0,0,95,100,0,1750,2000,,,,,,,,,,,,,,,,3d,,,NONLOOPING,,,0,0,0,0,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
ghost_boss_idle_1,,,_pmzm\ghost_boss\idle1_2000ms.wav,,,UIN_MOD,,,,,,,,,0,0,95,100,0,1750,2000,,,,,,,,,,,,,,,,3d,,,NONLOOPING,,,0,0,0,0,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
ghost_boss_idle_2,,,_pmzm\ghost_boss\idle2_2000ms.wav,,,UIN_MOD,,,,,,,,,0,0,95,100,0,1750,2000,,,,,,,,,,,,,,,,3d,,,NONLOOPING,,,0,0,0,0,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
ghost_boss_idle_3,,,_pmzm\ghost_boss\idle3_1250ms.wav,,,UIN_MOD,,,,,,,,,0,0,95,100,0,1750,2000,,,,,,,,,,,,,,,,3d,,,NONLOOPING,,,0,0,0,0,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
ghost_boss_idle_4,,,_pmzm\ghost_boss\idle4_4600ms.wav,,,UIN_MOD,,,,,,,,,0,0,95,100,0,1750,2000,,,,,,,,,,,,,,,,3d,,,NONLOOPING,,,0,0,0,0,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
ghost_boss_idle_5,,,_pmzm\ghost_boss\idle5_3750ms.wav,,,UIN_MOD,,,,,,,,,0,0,95,100,0,1750,2000,,,,,,,,,,,,,,,,3d,,,NONLOOPING,,,0,0,0,0,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
ghost_boss_idle_6,,,_pmzm\ghost_boss\idle6_3750ms.wav,,,UIN_MOD,,,,,,,,,0,0,95,100,0,1750,2000,,,,,,,,,,,,,,,,3d,,,NONLOOPING,,,0,0,0,0,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
# ====== Zeroy's  Flamethrower =======,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
weap_flamethrower_start,,,weapons\flamethrower\wpn_flm_ignite.wav,,,WPN_SHOT_PLR,,,,,BUS_FX,,,wpn_cmn_shot_plr,,,,,,,,,,,,,,,,,,,,,,,2d,wpn_fnt,,NONLOOPING,,,,,,,,,,,,,,,,,,,,,,,,,,,YES,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
weap_flamethrower_fireloop,,,weapons\flamethrower\wpn_flmthwr_st_flame.wav,,,WPN_SHOT_PLR,,,,,BUS_FX,,,wpn_cmn_shot_plr,,,,,,,,,,,,,,,,,,,,,,,2d,wpn_fnt,,LOOPING,,,,,,,,,,,,,,,,,,,,,,,,,,,YES,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
weap_flamethrower_cooldown,,,weapons\flamethrower\wpn_flm_cooldown.wav,,,WPN_RELOAD_PLR,,,,,BUS_FX,,,,,,,,,,,,,,,,,,,,,,,,,,2d,wpn_fnt,,NONLOOPING,,,,,,,,,,,,,,,,,,,,,,,,,,,YES,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
weap_flamethrower_rear,,,weapons\flamethrower\wpn_flmthwr_st_r.wav,,,WPN_RELOAD_PLR,,,,,BUS_FX,,,,,,,,,,,,,,,,,,,,,,,,,,2d,wpn_fnt,,NONLOOPING,,,,,,,,,,,,,,,,,,,,,,,,,,,YES,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
weap_flamethrower_off,,,weapons\flamethrower\wpn_flm_ignite.wav,,,WPN_RELOAD_PLR,,,,,BUS_FX,,,,,,,,,,,,,,,,,,,,,,,,,,2d,wpn_fnt,,NONLOOPING,,,,,,,,,,,,,,,,,,,,,,,,,,,YES,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
weap_flamethrower_swtnr,,,weapons\flamethrower\wpn_flm_ignite.wav,,,WPN_RELOAD_PLR,,,,,BUS_FX,,,,,,,,,,,,,,,,,,,,,,,,,,2d,wpn_fnt,,NONLOOPING,,,,,,,,,,,,,,,,,,,,,,,,,,,YES,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
weap_flamethrower_start_3p,,,weapons\flamethrower\wpn_flm_ignite.wav,,,WPN_SHOT_NPC,,,,,BUS_FX,,,wpn_cmn_shot_3p,,,,,,,,,,,,,,,,,,,,,,,3d,wpn_fnt,,NONLOOPING,,,,,,,,,,,,,,,,,,,,,,,,,,,YES,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
weap_flamethrower_fireloop_3p,,,weapons\flamethrower\wpn_flm_cooldown.wav,,,WPN_SHOT_NPC,,,,,BUS_FX,,,wpn_cmn_shot_3p,,,,,,,,,,,,,,,,,,,,,,,3d,wpn_fnt,,LOOPING,,,,,,,,,,,,,,,,,,,,,,,,,,,YES,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
weap_flamethrower_cooldown_3p,,,weapons\flamethrower\wpn_flm_cooldown.wav,,,WPN_SHOT_NPC,,,,,BUS_FX,,,wpn_cmn_shot_3p,,,,,,,,,,,,,,,,,,,,,,,3d,wpn_fnt,,NONLOOPING,,,,,,,,,,,,,,,,,,,,,,,,,,,YES,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
weap_flamethrower_foley_F,,,weapons\flamethrower\foley\flame_front.wav,,,WPN_RELOAD_PLR,,,,,BUS_FX,,,,,,70,70,,,,,,,,,,,,,,,,,,,2d,wpn_fnt,,LOOPING,,,,,,,,,,,,,,,,,,,,,,,,,,,YES,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
weap_flamethrower_foley_R,,,weapons\flamethrower\foley\flame_rear.wav,,,WPN_RELOAD_PLR,,,,,BUS_FX,,,,,,70,70,,,,,,,,,,,,,,,,,,,2d,wpn_fnt,,NONLOOPING,,,,,,,,,,,,,,,,,,,,,,,,,,,YES,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
weap_flamethrower_raise,,,weapons\flamethrower\wpn_incindiary_core_start.wav,,,WPN_RELOAD_PLR,,,,,BUS_FX,,,,,,,,,,,,,,,,,,,,,,,,,,2d,wpn_fnt,,NONLOOPING,,,,,,,,,,,,,,,,,,,,,,,,,,,YES,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
# ======= SG4Y Flashlight ========
flashlight_click,,,sg4y\flashlight\flashlight_click.wav,,,UIN_MOD,,,,,,,,,0,0,100,100,0,100,300,,,,,,,,,,,,,,,,3d,,,NONLOOPING,,,0,0,0,0,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
```

--------------------------------------------------
3) Compile your map as usual and you are done!

## Credits

Some sound assets were created from free-to-use audio from:
- Lara Sluyter, ["LARA'S HORROR SOUNDS" on YouTube](https://www.youtube.com/channel/UCejRwWhTN76XWgNVNU_ZExA)

## Useful links for development

- [Collection of useful links and tips (Reddit)](https://www.reddit.com/r/CODZombies/comments/58nbvq/black_ops_3_mod_tools_super_guide/)
- [Collection of useful links and tips (Modme Wiki)](https://wiki.modme.co/wiki/Game-Support-_-Black-Ops-3.html)
- [Modme - Importing models from other CoD games](https://wiki.modme.co/wiki/black_ops_3/basics/Import-models-from-Call-of-Duty-games.html)
- [Zeroy - BO3 source code explorer](https://bo3explorer.zeroy.com/globals.html)
- [Zeroy - Scripting syntax and grammar](https://wiki.zeroy.com/index.php?title=Call_of_Duty_5:_Scripting_Syntax_And_Grammar)
- [Extensive BO3 code list](https://www.ugx-mods.com/forum/scripting/91/bo3-code-list/14199/)

Local files:
- /your/path/to/Steam/steamapps/common/Call of Duty Black Ops III/docs_modtools/bo3_scriptapifunctions.htm
