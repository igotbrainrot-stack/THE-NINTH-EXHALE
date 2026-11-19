# Build 06.9 QA Checklist

## Automated
Run:

```bash
python3 -m unittest discover -s tests -p 'test_*.py'
python3 tests/validate_project.py
```

Expected:
- Existing source/data regressions still pass.
- `tests/test_build069_ui.py` passes.

## Manual Godot checks

### Title screen
- Title panel appears styled, readable and coherent.
- Save chip correctly shows whether an active save exists.
- Buttons highlight/focus properly.
- Entering Hearth Nine still loads `scenes/hearth_nine.tscn`.

### HUD readability
- Objective card updates during intro progression.
- Advisory route updates while moving.
- Health and Breath bars respond during combat/sprinting.
- Weapon card updates when switching weapons.
- Nail Storm shows heat bar; other weapons hide it.

### Interaction prompt
- Looking at relay/valve/NPCs shows an `[E]` prompt.
- Looking away clears the prompt.
- Prompt disappears while modals are open.

### Dossier/modal
- Tab opens the civic pressure docket.
- Save action still works from the docket.
- Story modals are scrollable and buttons are focusable.
- ESC/Tab reopening behavior still feels sane during play.

### Regression sweep
- Intro relay -> crawler -> valve flow still works.
- Sootworks and Basilica travel still function.
- Weapon gallery and enemy gallery still load.
- Enemy ecology systems from 06.8 still load unchanged.
