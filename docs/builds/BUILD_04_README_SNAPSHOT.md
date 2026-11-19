# THE NINTH EXHALE — BUILD 04 / SOOTWORKS AND THE LABOUR WRIT

**Status:** Godot 4.x editable engineering prototype; **based on the working Build 03**, without restarting the project. The uploaded `MASTER_GAME_BIBLE_FINAL.md` is still the canonical source of story and mechanics. The full game is not built yet.

## Launch on Linux

1. Extract this ZIP to a normal directory. The project directory contains `project.godot`, `scenes/`, `scripts/`, `assets/`, `data/`, `docs/` and `tests/`.
2. Open **Godot 4.x, standard (not .NET)** → **Import** → point at **this Build 04** `project.godot`.
3. Click **Edit**, then press **F5** / **Run Project**; *opening the project in the editor does not launch the game*.
4. Select **ENTER HEARTH NINE** → **NEW NINTH / Witness**, or choose one of the other three builds. Resume is also available for active compatible Build 03 saves.
5. Enter the ward. Use **WASD** + mouse to move and look, **E** to examine consoles/people, **Tab** for Docket, **left click** to fire, **R** to reload, **Shift** to sprint, **Space** to dash, **1** to use an Ampoule, **F5/F9** to save/load.

Linux terminal option: `chmod +x launch_linux.sh && ./launch_linux.sh` from this project directory. If `godot` is not on your PATH, open the project in the graphical editor.

## New gameplay: Hearth Nine → Sootworks

**The route requires a completed Cinder Lung quest.** First obtain the existing spare in municipal requisitions by the old Build 03 routes (evidence-backed bargain, Tech reroute, theft, or defeat the enforcer). Return to **Dr Sela Vale** in Hearth Nine and **install** the single spare. The five finite city resources, allocation change, and 140 unique XP are still tracked.

After installation, walk east through the large passage in the pressure wall, then towards the **SOOTWORKS / SERVICE RAIL** console near the southern boundary (press **E**). Choose **TRAVEL TO SOOTWORKS**. The next area is a second 3D collidable district, with its own working furnaces, public registry, guards, NPC and consoles. You can return to Hearth Nine using the service-rail console near Sootworks' southwest wall.

### Brin Harker — four-step NPC quest

1. Find **Brin Harker** in the workers' section. **Talk to him** to record your first meeting.
2. Locate the **original payroll cylinder** along the northwest freight-office wall, inspect it and copy the evidence. It proves the debt was **paid 43 years ago**. Return to Brin, show him the original and record the **investigation**.
3. Approach the **Worker Council ledger** to make a choice (help with a controlled, staffed strike, negotiated compromise, exploit the workers, or abandon the matter). Choices record different concrete rewards and resource/trust costs. Brin's location changes with the outcome.
4. Find Brin again to witness the **aftermath** if he is alive. He can also be killed by the player's pistol; his death is recorded and later conversations are disabled. No dead character is allowed to speak in the future epilogue implementation.

Brin's *help* route grants **Brin's Torque** as a recorded relic reward, a controlled safe stoppage, +Labour trust, and documented energy/labour costs. His *compromise* route grants **Union Rivet Kit**. Exploitation grants an **exclusive Chain of Wages modification reward** and vouchers, but reduces Labour trust and strains resources. These rewards appear in the Docket as recorded items; **the full equipment screen/equipping is not yet implemented**.

### Labour Writ — three ways to obtain it

- **Worker council:** record Brin's payroll evidence, investigate, and support the controlled strike. Return to the Council ledger and accept the **Writ of Labour**.
- **Technical regulator:** with **Tech 5** (Mechanist build), interact with the **Heat isolation bus** and isolate the Millwright's control line, consuming source-backed Energy/Labour. Then use the **Millwright order board** to register the Writ.
- **Assault and registry fallback:** at the Millwright's order board, issue an open challenge; fight the powered office keeper (125 provisional HP) with your Covenant Pistol. Then retrieve the Writ from the **public Labour registry**. The keeper dying does **not** destroy the founding credential or force Brin to live.

A **one-time emergency supplies** console near the passage carries 24 physical Ledger Slugs and two Breath Ampoules. Re-entering the district or loading a save cannot legitimately collect the same issue again. All three routes produce **one unique `qobj_writ_of_labour`** and the same 165 unique Writ XP, with distinct provenance. Neither a high-stat noncombat check nor Brin's survival is required for the assault/registry fallback.

Use **Tab** to inspect Brin's stage, the Writ count, resource deltas and any recorded item rewards. The FULL game requires **three distinct Writs**. The later **two-Writ test lift** is a vertical-slice-only exception; it has not been added yet.

## What's new compared with Build 03

- A second authored, physically collidable Sootworks environment and travel console (with both directions implemented).
- Original, deliberately basic Brin work-sprite and an office keeper using separate 125-HP actor state.
- Brin's meet → payroll evidence → investigation → decision → aftermath, including death-aware dialogue and independent rewards/consequences.
- Labour Writ: worker-council, Tech sabotage or public-registry fallback after Millwright defeat.
- Safe-strike versus exploit resource and trust accounting; finite district supplies.
- District/actor/quest state stored in the existing versioned attempt save; Build 03 save migration for absent Sootworks fields.
- Nix's failed-attempt record now stays within the current failure chain rather than importing unrelated previous profile failures.
- New source tests covering all introduced interactions and the unique Writ rules.

## Engine test commands

These **source/data checks** are available without the Godot executable:

```bash
python3 tests/validate_project.py
python3 -m unittest discover -s tests -p 'test_*.py' -v
```

To actually compile/import in your installed Godot 4.x engine, run from the extracted project directory:

```bash
godot --headless --editor --path . --quit
godot --headless --path . --quit-after 120
```

**Important:** Source tests passing is not proof Godot accepts every new script or that combat and physics are polished. Godot was not available in the author's sandbox for this build. If any error appears, open Godot's **Debugger → Errors** panel and send the exact message and file/line. Build 03 itself was confirmed working by the user; Build 04 still requires a live test.

## Scope and limitations

Build 04 is an engineering milestone, not a finished 20–35-minute slice. The Millwright uses an **office-enforcer placeholder sprite/AI**, not final 8-angle animation, cover tactics or a unique fully authored boss. Brin's sprite is a new placeholder. Technical actions are initiated at physical consoles but do not yet have full moving machinery cinematics. Rewards are recorded but do not yet implement the full inventory/mod equip screens. District geometry is **authored**, not procedurally shuffled. Only Hearth Nine and Sootworks are currently available; there is no Flood Basilica, Sister Ossa quest, field hearing, Edda finale, completed endings, and no complete 16-weapon combat system. The other V6 story/configuration data remains in the project for future phases.

The next verified milestone is **Flood Basilica + Ossa's multi-stage arc + a genuine one-participant five-command public-loaner Echoform hearing**, followed by the two-Writ slice-only Edda test confrontation. Do not confuse either with full-game three-of-five or all four endings.
