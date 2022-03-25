# zm_phasmo

## Installation instructions

1) Drag the folders into your root directory. Example: A:\SteamLibrary\steamapps\common\Call of Duty Black Ops III

-------------------------------------------------
2) Open useraliases.csv in share>raw>sound>aliases and add the following lines:

```
# ======= Phasmo Flashlight ========
flashlight_click,,,_pmzm\flashlight\flashlight_click.wav,,,UIN_MOD,,,,,,,,,0,0,100,100,0,100,300,,,,,,,,,,,,,,,,3d,,,NONLOOPING,,,0,0,0,0,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
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
# ====== Phasmo Flamethrower =======
thermometer_upgraded_raise,,,_pmzm\weapons\thermometer_upgraded\thermometer_upgraded_raise.wav,,,WPN_RELOAD_PLR,,,,,BUS_FX,,,,,,,,,,,,,,,,,,,,,,,,,,2d,wpn_fnt,,NONLOOPING,,,,,,,,,,,,,,,,,,,,,,,,,,,YES,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
thermometer_upgraded_start_1p,,,_pmzm\weapons\thermometer_upgraded\thermometer_upgraded_start.wav,,,WPN_SHOT_PLR,,,,,BUS_FX,,,wpn_cmn_shot_plr,,,,,,,,,,,,,,,,,,,,,,,2d,wpn_fnt,,NONLOOPING,,,,,,,,,,,,,,,,,,,,,,,,,,,YES,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
thermometer_upgraded_fireloop_1p,,,_pmzm\weapons\thermometer_upgraded\thermometer_upgraded_fireloop.wav,,,WPN_SHOT_PLR,,,,,BUS_FX,,,wpn_cmn_shot_plr,,,,,,,,,,,,,,,,,,,,,,,2d,wpn_fnt,,LOOPING,,,,,,,,,,,,,,,,,,,,,,,,,,,YES,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
thermometer_upgraded_cooldown_1p,,,_pmzm\weapons\thermometer_upgraded\thermometer_upgraded_cooldown.wav,,,WPN_RELOAD_PLR,,,,,BUS_FX,,,,,,,,,,,,,,,,,,,,,,,,,,2d,wpn_fnt,,NONLOOPING,,,,,,,,,,,,,,,,,,,,,,,,,,,YES,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
thermometer_upgraded_start_3p,,,_pmzm\weapons\thermometer_upgraded\thermometer_upgraded_start.wav,,,WPN_SHOT_NPC,,,,,BUS_FX,,,wpn_cmn_shot_3p,,,,,,,,,,,,,,,,,,,,,,,3d,wpn_fnt,,NONLOOPING,,,,,,,,,,,,,,,,,,,,,,,,,,,YES,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
thermometer_upgraded_fireloop_3p,,,_pmzm\weapons\thermometer_upgraded\thermometer_upgraded_fireloop.wav,,,WPN_SHOT_NPC,,,,,BUS_FX,,,wpn_cmn_shot_3p,,,,,,,,,,,,,,,,,,,,,,,3d,wpn_fnt,,LOOPING,,,,,,,,,,,,,,,,,,,,,,,,,,,YES,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
thermometer_upgraded_cooldown_3p,,,_pmzm\weapons\thermometer_upgraded\thermometer_upgraded_cooldown.wav,,,WPN_SHOT_NPC,,,,,BUS_FX,,,wpn_cmn_shot_3p,,,,,,,,,,,,,,,,,,,,,,,3d,wpn_fnt,,NONLOOPING,,,,,,,,,,,,,,,,,,,,,,,,,,,YES,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
thermometer_upgraded_rear,,,_pmzm\weapons\thermometer_upgraded\thermometer_upgraded_rear.wav,,,WPN_RELOAD_PLR,,,,,BUS_FX,,,,,,,,,,,,,,,,,,,,,,,,,,2d,wpn_fnt,,NONLOOPING,,,,,,,,,,,,,,,,,,,,,,,,,,,YES,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
thermometer_upgraded_off,,,_pmzm\weapons\thermometer_upgraded\thermometer_upgraded_start.wav,,,WPN_RELOAD_PLR,,,,,BUS_FX,,,,,,,,,,,,,,,,,,,,,,,,,,2d,wpn_fnt,,NONLOOPING,,,,,,,,,,,,,,,,,,,,,,,,,,,YES,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
thermometer_upgraded_pickup,,,_pmzm\weapons\thermometer_upgraded\thermometer_upgraded_pickup.wav,,,WPN_RELOAD_PLR,,,,,BUS_FX,,,,,,70,70,,,,,,,,,,,,,,,,,,,2d,wpn_fnt,,LOOPING,,,,,,,,,,,,,,,,,,,,,,,,,,,YES,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
thermometer_upgraded_alt_fire_1p,,,_pmzm\weapons\thermometer_upgraded\thermometer_upgraded_alt_fire.wav,,,WPN_SHOT_PLR,,,,,BUS_FX,,,wpn_cmn_shot_plr,,,,,,,,,,,,,,,,,,,,,,,2d,wpn_fnt,,NONLOOPING,,,,,,,,,,,,,,,,,,,,,,,,,,,YES,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
thermometer_upgraded_alt_fire_3p,,,_pmzm\weapons\thermometer_upgraded\thermometer_upgraded_alt_fire.wav,,,WPN_SHOT_NPC,,,,,BUS_FX,,,wpn_cmn_shot_3p,,,,,,,,,,,,,,,,,,,,,,,3d,wpn_fnt,,NONLOOPING,,,,,,,,,,,,,,,,,,,,,,,,,,,YES,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
# ======= Phasmo Misc ========
ice_shatter,,,_pmzm\misc\ice_shatter.wav,,,UIN_MOD,,,,,,,,,0,0,95,100,0,900,1000,,,,,,,,,,,,,,,,3d,,,NONLOOPING,,,0,0,0,0,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
```

--------------------------------------------------
3) Compile your map as usual and you are done!

## Credits

Some sound assets were created from free-to-use audio from:
- Lara Sluyter, ["LARA'S HORROR SOUNDS" on YouTube](https://www.youtube.com/channel/UCejRwWhTN76XWgNVNU_ZExA)

Some models made available online were used for the following:
- [Thermometer (Upgraded)](https://sketchfab.com/3d-models/pistol-d43323a1e2c54a17bc226708a7ada34d)

## Useful links for development

- [Collection of useful links and tips (Reddit)](https://www.reddit.com/r/CODZombies/comments/58nbvq/black_ops_3_mod_tools_super_guide/)
- [Collection of useful links and tips (Modme Wiki)](https://wiki.modme.co/wiki/Game-Support-_-Black-Ops-3.html)
- [Modme - Importing models from other CoD games](https://wiki.modme.co/wiki/black_ops_3/basics/Import-models-from-Call-of-Duty-games.html)
- [Zeroy - BO3 source code explorer](https://bo3explorer.zeroy.com/globals.html)
- [Zeroy - Scripting syntax and grammar](https://wiki.zeroy.com/index.php?title=Call_of_Duty_5:_Scripting_Syntax_And_Grammar)
- [Extensive BO3 code list](https://www.ugx-mods.com/forum/scripting/91/bo3-code-list/14199/)

Local files:
- /your/path/to/Steam/steamapps/common/Call of Duty Black Ops III/docs_modtools/bo3_scriptapifunctions.htm
