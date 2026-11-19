# Build 07.6 — First Signature: Implementation Record

## Phase 1. Three-Writ archive

- `scripts/core_builder_076.gd`: brand new physical central archive, consoles, material changes and conditional world-state signage.
- `scripts/main.gd`: added zone `core` and separate full-three-Writ public desk entry; existing zone `lift` still denotes explicitly **two-Writ development-only** trial.
- `scripts/run_state.gd`: additive `core` state; returns from the core through existing Hearth Nine transport. `core.freight_lift_opened_076` is registered once.
- Two archive proofs plus a physical rail map are independently recorded once; they cannot be substituted for each other.

## Phase 2. Custodian resolution

- Exactly one of Canon Edda, Marshal Voss or Archivist Latch is chosen from the unchanged WorldPlan per attempt.
- Target-specific evidence required for public tribunal or evidence-backed persuasion.
- Technical containment consumes already-existing Energy/Labour resources and requires a staffed safety fallback. Combat remains an option for low-stat builds using the executive actuator; its defeat does not imply killing a human.
- Preserves `custodian_method`, `custodian_fate`, `actuator_disabled` separately, and has no callable terminal ending route.
- A resolved noncombat outcome physically depowers the executive actuator and persists across reloads.

## Phase 3. Rail consequences and presentation

- One repair to a damaged carriage spends exactly 2 salvage, 3 Labour, 2 Energy and raises *local* viable seating from 24 to 36.
- One draft boarding priority per attempt, never actual boarding, and the public assembly can remain undecided.
- Optional unique single `cipher` item; explicit absence of True Dawn mandate and two additional technical prerequisites.
- Original procedural archive wall/floor texture, original synthesised 16-second looping core exploration atmosphere and interim eight-view actuator artwork.
- `scripts/game_ui.gd`: new location label, real objective routing, dossier evidence and rail-summary line.
- `scripts/player.gd`: authored aimed interaction prompts.
- `scripts/adaptive_music_072.gd`: central core exploration score and existing combat switching.
- `scripts/district_mood_074.gd`: central-core practical lamps.

## Verification

- 169 automated Python source/regression tests PASS, including 11 new Build 07.6-specific tests.
- 14 project/data validation tests PASS.
- New Ogg and PNG headers/properties validated.
- Planar approximate path checks detect walkable access to core's major sources and the executive station.

## Outstanding verification

No local Godot 4 executable; thus no engine parser, graphical, physics, controller or human engagement run was completed. The new sources are packaged for live F5 import and iterative correction, not certified as a stable release.
