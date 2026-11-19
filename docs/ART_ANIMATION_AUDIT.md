# 07.9X — Art and animation audit

Roster count: 15. Full 8-angle 768×768 atlas present for 15/15 roster types. Missing/mismatched roster: []. Source checks cannot validate visual continuity, pivots, motion, or runtime display.

Existing 12-cell 8-angle enemies map 0–3 locomotion, 4–5 windup, 6–7 attack, 8 damage, 9–11 death. Added alert state invoking 4–5; sped up attack timing; hurt priority; longer death reveal. NPC four-cell idle strips now pulse frames 2–3 briefly on actual E interactions. These are state-trigger improvements using existing artwork, not newly generated full speaking/death/crouch/reload directional atlases.

New muzzle strip: `assets/fx/civic_muzzle_burst_079x.png`, four 128×128 frames with fixed centre, referenced by `scripts/game_ui.gd`. Reproducible from build tool. See `art/BUILD_079X_MUZZLE_BEFORE_AFTER.png` and `art/BUILD_079X_ACTOR_FRAME_AUDIT.png` (authoring previews, NOT engine captures).

Runway: service connected; 2 matching audio tasks found, but export bytes could not be obtained in this environment; nothing external-only is represented as integrated.
