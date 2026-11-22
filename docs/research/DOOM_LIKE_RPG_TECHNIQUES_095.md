# DOOM-like RPG techniques for THE NINTH EXHALE (Build 09.5)

Repo copy of the Claude doc of the same name (2026-11-22). The doc is the living version.

## Summary

Four DOOM-era techniques fit the canon and are in Build 09.5:
- **Sound follows the route** (Doom's sector flood).
- **Muzzle flash lights you.**
- **Deterministic pain thresholds** (Doom's pain chance without dice; this ends the Nail Storm stun-lock).
- **District record** on the return rail (Doom intermission, Dusk stats).

The strongest next steps are infighting and an automap with notes. Glory-kill refills and random loot were rejected because they break the bible's finite, deterministic rules.

## Games reviewed

| Game | Year | Relevant technique |
|---|---|---|
| [Doom](https://bookdown.org/robertness/doom_tour/9_9_monster_ai_logic.html) | 1993 | Sound flood through sectors; ambush monsters; [pain chance](https://doomwiki.org/wiki/Pain_state); [infighting](https://doomwiki.org/wiki/Monster_infighting); colour-keyed doors |
| [Hexen](https://doomwiki.org/wiki/Hexen:_Beyond_Heretic) | 1995 | Hub maps that keep their state |
| [Strife](https://www.doomwiki.org/wiki/Strife) | 1996 | Doom-engine RPG: town hub, dialogue choices that change the ending, quests, stealth weapons |
| [Ultima Underworld](https://gallery.ultimacodex.com/ultima-underworlds-auto-mapping-feature/) | 1992 | Automap with player notes |
| [Doom RPG](https://www.doomwiki.org/wiki/Doom_RPG) | 2005 | Turn-based grid RPG in the Doom universe |
| [Doom (2016)](https://gdcvault.com/play/1024940/Embracing-Push-Forward-Combat-in) | 2016 | Push-forward combat, glory kills that refill |
| [Dusk](https://dusk.gamepedia.com/How_to_play_guide_for_Dusk?oldid=2050) | 2018 | Kill/secret counters, end-of-level stats, par time |
| [Project Warlock](https://www.hardcoregaming101.net/project-warlock/) | 2018 | XP into stats; upgrade points hidden in secrets |
| [Nightmare Reaper](https://www.pcgamer.com/uk/nightmare-reaper-is-a-pretty-dang-cool-roguelite-looter-shooter-retro-fps/) | 2022 | Roguelite structure, randomised loot |
| [Cultic](https://www.moddb.com/games/cultic) | 2022 | Retro look with modern dynamic lighting |
| [F.E.A.R.](https://www.oreilly.com/library/view/game-ai-pro/9781482254792/K23980_C002.xhtml) | 2005 | Squad callouts make AI legible |

## Techniques and plan

| Technique | Seen in | Plan |
|---|---|---|
| Sound follows the walking route, stops at sealed rooms | Doom | **Built (09.5)** |
| Deterministic pain thresholds | Doom | **Built (09.5)** |
| Muzzle flash lights the shooter | Doom, Cultic | **Built (09.5)** |
| District record on leaving | Doom, Dusk | **Built (09.5)** |
| Infighting | Doom, Heretic, Hexen | Later (needs non-player targets in enemy AI) |
| Automap with notes, locked doors marked | Ultima Underworld, Heretic | Later (UI build) |
| Secrets that pay out | Dusk, Project Warlock | Later (authored caches, balance) |
| Posted guards that wait for sight | Doom ambush flag | Later |
| Combat callouts | F.E.A.R. | Later (extends 09.3 barks) |
| Persistent maps | Hexen | Already have |
| Danger-free town hub | Strife | Owner ruling (Hearth Nine) |
| Kill to refill health and ammo | Doom (2016) | Not a fit (finite resources) |
| Randomised loot | Nightmare Reaper | Not a fit (deterministic, authored) |
| Turn-based grid | Doom RPG | Not a fit |

## Built in 09.5, with measurements (`tests/godot_doom_095.tscn`, 14/14)

- **Sound:** a pistol shot 6 m away through a wall, with the doorway 15 m along, travels a 32.7 m route and is not heard (the old rule gave 11.4 m, heard). With the doorway beside it the route is 6.8 m, heard. A sealed room never hears.
- **Flash:** in the dark, a Coil shot raises Ninth's light from 0.40 to 0.90 for 0.22 s, so a guard 8 m away notices more than twice as fast.
- **Pain:** a held Nail Storm flinches a Slag Sifter 4 times in 3 s, not 31; one Coil blast flinches it at once; rushers flinch at 10 HP, the Slag Sifter at 22.
- **Record:** "DISTRICT RECORD / SOOTWORKS: 1 min here, 1 put down, 2 still standing (1 office-holder), spotted once, Brin Harker alive, 1 record written."
