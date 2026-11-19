# 07.9X QA / source-only verification

Test command: `python3 -m unittest discover -s tests -p test_*.py`; exit 0; result tail: `OK`. Project validations: `python3 tests/validate_project.py`, exit 0. Exact outputs in adjacent logs.

Godot 4.4+: NOT PRESENT. No live import/F5, no gameplay, animation, audio, frame-rate, save/load or physics testing. `unzip -t` checked after packaging. Runway authenticated; matching older exported task metadata located, actual media bytes unavailable; no integrated new Runway assets.

Godot runtime verification still required: check explicit animation `alert → windup → attack → recovery` and stagger override; check E interaction talk while modal opens; test muzzle strip alpha frames; verify `MeshInstance3D.look_at` and tracer fade with 4 weapons including nail rate; play three districts and inspect LOS/collision; compare movement against hazard fair windows; load 07.9B/07.9C older save and completed campaigns.

GitHub: new branch `feature/079x-kinetic-combat-20261118` used for incremental asset stage. The remote default branch was only an art/docs skeleton, and full 07.9X engine project has NOT been uploaded there. Full source deliverable is this ZIP.

GitHub connector verified branch ahead of main by 1 commit, with new muzzle PNG, tracer source and staging metadata only. Commit: `7eca6acbdc7e206aa23aa6ac1df32ccfdcebf23d`. Complete runnable project not yet on GitHub; do not represent remote as playable.
