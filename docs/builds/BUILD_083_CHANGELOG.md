# Build 08.3 — NPC vocalisations and enemy SFX

- Added 14 original procedural WAV fallback sounds (4 civilian grunts + five mechanical + five organic enemy sound events).
- Added `scripts/actor_voice_083.gd` reusable positional audio, three-to-four-syllable sequential civilian grunt variation and non-looping enemy event playback.
- Wired all generic `add_actor` civilians, Brin, Ossa and spawned enemies.
- On NPC interaction, only the physically present matching actor vocalises; never the interaction console.
- Enemy alert, windup, shot/rush commit, injury, and death trigger distinct event audio. Existing warning and impact sounds retained.
- Sound only; does not change damage, hearing rules, quests or save state.
- Runway generated three candidate original asset collections, but their MP3 bytes are NOT bundled (remote exports unavailable). Exact task IDs in `art/RUNWAY_AUDIO_MANIFEST_083.json`.
