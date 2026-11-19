# Build 06.9 Change Log — UI + HUD Polish

## Summary
Build 06.9 improves the visual fidelity and usability of the prototype interface without replacing the existing diegetic “Pressure Docket” identity.

## Added
- New HUD layout with separate objective, route, vitals and equipment cards.
- Health and breath progress bars.
- Central interaction prompt driven by the player’s aim ray.
- Updated reticle art and vignette overlay under `assets/ui/`.
- Improved modal styling for story cards, choices and the dossier.
- New automated regression file: `tests/test_build069_ui.py`.

## Changed
- Restyled the title screen and improved onboarding copy.
- Reworked dossier formatting into clearer sections.
- Converted weapon and resource readouts from one dense line into grouped information.
- Added clearer notification banner treatment.

## Preserved intentionally
- Existing districts, enemy roster, trial slice and dialogue/content flow.
- Diegetic UI framing rather than replacing it with futuristic floating widgets.
- Fixed 640×400 retro presentation.

## Known limits
- Godot runtime testing has not yet been performed in this environment.
- Prompt wording currently relies on a curated interaction-id map and may need per-object tuning.
- No dedicated settings/options screen has been added yet.
