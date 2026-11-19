# Build 07.9C — QA evidence

- Baseline: Build 07.9B Safety Preflight; `The_Ninth_Exhale_Build_079B_SAFETY_PREFLIGHT.zip`.
- Godot engine: not installed; no F5, live old-save migration, FPS, audio or collision test.
- Source tests are not a substitute for runtime checks.

## Unittest

```
python3 -m unittest discover -s tests -p test_*.py
```
Exit code: 0

```
....................................................................................................................................................................................................................................
----------------------------------------------------------------------
Ran 228 tests in 10.338s

OK

```

## Project validations

```
python3 tests/validate_project.py
```
Exit code: 0

```
counts) ... ok
test_player_and_pistol_logic_source (__main__.ProjectSourceValidation.test_player_and_pistol_logic_source) ... ok
test_procedural_placeholder_art_is_original_generated_files (__main__.ProjectSourceValidation.test_procedural_placeholder_art_is_original_generated_files) ... ok
test_source_does_not_import_obsolete_creature_moves (__main__.ProjectSourceValidation.test_source_does_not_import_obsolete_creature_moves) ... ok
test_stable_quest_id_does_not_invent_second_cipher (__main__.ProjectSourceValidation.test_stable_quest_id_does_not_invent_second_cipher) ... ok
test_state_save_and_provenance_guards (__main__.ProjectSourceValidation.test_state_save_and_provenance_guards) ... ok
test_technical_ids_are_unique (__main__.ProjectSourceValidation.test_technical_ids_are_unique) ... ok

----------------------------------------------------------------------
Ran 14 tests in 0.107s

OK

```
