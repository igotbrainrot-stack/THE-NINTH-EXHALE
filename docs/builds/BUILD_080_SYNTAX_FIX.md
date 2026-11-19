# Build 08.0 — GDScript syntax hotfix

Fixed a GDScript parse error in `scripts/main.gd` line 1397: `var signal` used a reserved keyword. Renamed to `rail_signal` for its declaration and uses. Corrected the same reserved-name issue in `scripts/assembly_builder_078.gd` (line 66). Preserved runtime node names and gameplay data.

QA: 245 Python unittest tests passed; 14 project validations passed; ZIP integrity passed. Godot was not available, so runtime import/F5 checks are **not engine-tested**. The Linux launch script retains executable permissions in the ZIP; `unzip` is preferable to Python `zipfile.extractall` for preserving POSIX permissions.
