# Build 02 — startup usability fix (17 November 2026)

## Reported problem
"It doesn't do anything when opening in Godot." The original project imported into the Godot editor, but its main `.tscn` contained only a player and camera. The entire ward appeared only at runtime, so the editor viewport looked nearly empty. Further, Godot Project Manager's **Edit** button does not automatically run the game; the user has to click **Run Project (F5)**.

## Actual changes
- A visible `scenes/main.tscn` title/menu is now the configured project startup scene. Its ENTER HEARTH NINE button changes to the live three-dimensional scene.
- The former `main.tscn` is preserved as `scenes/hearth_nine.tscn`, with its existing Godot scripts, collision and quest logic unchanged.
- The initial camera faces north toward the clinic rather than into the west wall.
- A startup diagnostic is printed into Godot Output when title screen loads and when the ward loads.
- Updated Linux launcher locates other Godot 4 executable filenames, reports a missing engine instead of exiting without explanation, and remains offline.
- Explicit instructions in README: extract ZIP, import project.godot, open in Godot editor, press F5, click ENTER HEARTH NINE, select build and start.
- Added static startup-graph tests; all existing original source/data tests still pass.

## Validation boundaries
The actual Godot engine executable is unavailable in this execution container (and external download DNS is blocked). Therefore **engine parsing, render, game input and collision are not runtime-verified here**. A live test on a Linux Godot 4 installation is needed. A blank/failed F5 after this update should be diagnosed using Godot's Output and Debugger/Errors panels; attach their text, not another speculative rewrite.

## Next acceptance gates
Run project with F5. Confirm title renders, ENTER button opens 3D ward and campaign-choice docket, Witness start enters mouse-captured 3D world, WASD moves, E interacts at a reachable NPC/console, attack/reload works, save+reload persists, and quit returns control to desktop.
