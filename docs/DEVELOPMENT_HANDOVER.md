# THE NINTH EXHALE — DEVELOPMENT HANDOVER

> **Historical (pre-engine handover of 17 November 2026).** Kept for provenance; it no longer describes the game. Current state, open rulings and next steps: `docs/research/CONSOLIDATION_REVIEW_096.md`, `README.md` and `CHANGELOG.md`. The bible (`docs/MASTER_GAME_BIBLE_FINAL.md`) remains the canon.

**Handover date:** 17 November 2026  
**Single authoritative specification:** `MASTER_GAME_BIBLE_FINAL.md`  
**Status:** consolidated *production design candidate*. Python references exist and pass their reference tests; **no runnable Godot FPS was supplied or verified**.

## What to build

An offline Linux-first, old-school sprite-based first-person shooter with a five-act civic horror narrative, six-attribute RPG progression, finite inventory/economy, evidence-driven dialogue, multi-stage NPC stories and one-command-at-a-time Echoform civic hearings. Roguelite attempts reconstruct bounded physical modules after actual death; successful endings are terminal. User actions, not random seeds, choose morality and ending.

The engine implementation is Godot-oriented; the V5 Python narrative generator and V6 rules-reference module are **oracles for specific state transitions only**. Do not render Python prose in place of real characters, rooms and combat.

## Canonical invariants not to change

- White Quiet 91 years before present; two independent Lumen channels: mechanical power versus mnemonic correction; five finite city resources; no free biomass, energy or air.
- Five districts/offices, three-of-five **unique** founding Writs, Writ public-registry fallback when office holder dead, three Custodian variants, four original endings, explicitly recoverable optional True Dawn dossiers and real civic mandate.
- Ninth is the ninth surviving template, **not** proof of eight player deaths. Nix only references actual recorded previous failed attempts; no digital omniscience.
- Mandatory hearing has `Press`, `Attune`, `Brace`, `Observe`, `Withdraw`, one active participant, loaner Rootkin and unlimited retries; no type ring/ownership reward.
- All eight NPC arcs, 20 short local quests, 16 weapons, 20 mods, eight armour sets, 12 Echoforms, 23 basic consumables and original visuals/lore preserved. V5's corrected weapon silhouettes supersede V2.
- `WorldPlan` is immutable after seeded generation; `Campaign` logs actual actions. All mandatory paths and the first three endings available to any build. Completed endings never rewind.

## Reading order

1. Master §§1–4 (identity, story), 6 (quest predicates) and 9 (hearing).
2. Master §§7–8 and Appendix B (RPG/weapon/item data). Apply numeric targets only as *provisional balance*.
3. Master §§10,14 (procedural map and save/transaction interfaces).
4. Master §§11–13 (art, audio, UI/accessibility).
5. Master §15 and `IMPLEMENTATION_GAP_REGISTER.md` for gate order, and `VALIDATION_REPORT.md` for test limitations.

## First project tasks (do not refactor history first)

1. Create a Godot 4.x project with directories described in master §14; data-only import of `MASTER_AUTHORING_DATA.json` and `MASTER_IDS.json`, versioned schema and collision-free identifiers.
2. Implement `RunManager` with one authoritative event transaction queue, immutable `WorldPlan`, `QuestState`, `CharacterProgression`, `InventoryEquipment`, `CivicResourceLedger`, `SaveCodec` and read-only `NarrativeRenderer`. In-memory tests must reject duplicate `event_id` and item instances.
3. Build Hearth Nine FPS movement and Covenant Pistol targeting. Use real collision; add save/load at current position and two different dialogue outcomes for the Lung.
4. Add Sootworks and Flood Basilica with registry fallback; play through Brin's encounter/investigation/decision/aftermath, then Ossa. Ensure NPC death cannot trigger speech in credits.
5. Implement one civic hearing with an accorded or public loaner Rootkin, five commands, Withdraw/retry, an actual opposing creature and a transcript. The opponent is not loot.
6. Create a deliberately **slice-only** two-Writ lift, Edda confrontation and two conditional ending cards. Then implement actual death/reprint, Nix testimony and state-safe save/load.
7. Only expand to all five districts/three Writs/three Custodians/four endings after the 20–35 minute slice is genuinely playable.

## Acceptance evidence required

**G0:** deterministic test logs and data import, original catalogue counts, unique IDs.  
**G1:** player-controlled recording walking/colliding and firing; player cannot clip through doors.  
**G2:** actual Lung and Writ quest alternatives plus inventory/air consequences.  
**G3:** a live hearing with loaner and replay, an NPC death that alters aftermath correctly.  
**G4:** load/suspend/restart equality, actual death creates another seed, finished ending does not resume as playable.  
**G5:** 1,000 seeded physical layouts per district with avatar-sized collision/nav checks; complete real 3-of-5 campaign; all four choices where eligible.  
**G6:** controlled player testing of combat readability, level timing, hearing clarity, accessible sound/visual cues and source-verified original graphics.

## Do not claim

No “implemented” badge based on a written specification. No “all 4 endings playable” based on Python story states. No “navigation verified” based only on symbolic BFS. No “legal clearance” from this team's similarity review. No new canon enemy roster, region or fifth ending merely to justify coding convenience.

## Relevant official Godot references

- Deterministic RNG and saved state: https://docs.godotengine.org/en/stable/classes/class_randomnumbergenerator.html
- Save-game state: https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html
- Navigation meshes and their difference from collision: https://docs.godotengine.org/en/stable/tutorials/navigation/navigation_using_navigationmeshes.html

**Next human or AI developer's first tangible deliverable:** an executable offline Linux scene with movement, collisions, Covenant Pistol, a genuine Cinder Lung quest choice, schema-safe save/load and a concise reproduction log. Everything else follows that demonstration.
