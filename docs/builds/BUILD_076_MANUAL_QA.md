# Build 07.6 — Live Godot QA (not yet executed)

Follow the full `README.md` route and record exact Godot warnings/errors. Suggested seed QA: `-- --ninth-seed=100`, `101`, `102` for differing selected Custodians; inspect `Tab` to confirm the selection.

## Engine launch / save

- [ ] Import `project.godot` using Godot 4.4+ and press F5. No parser/resource-loading errors.
- [ ] Resume a Build 07.5 active save. Save schema still 1, prior Writs and NPC decisions unchanged.
- [ ] Check both the old two-Writ Edda test berth and the separate real three-Writ Quorum desk.
- [ ] Attempt full-core entry with only two Writs or an uncompleted hearing: **must be denied**.
- [ ] Authenticate all three Writs, interact with the desk a second time: **must reach central archives**.

## Spatial QA

- [ ] Player does not spawn embedded in scenery.
- [ ] Both archive signature stations, rail charter, key Custodian evidence, cipher, repair bay and return console can be reached and aimed at with E.
- [ ] The physically wide cross-aisle connects both archive wings; body and interactive colliders do not block it.
- [ ] The executive actuator begins passive. On engaging it, cover blocks attacks and the weapon telegraph is visible.
- [ ] Combat remains possible with a basic pistol plus physically limited ammo; emergency intervention works.

## State consistency

- [ ] Copy the two independent signatures. A second interaction cannot duplicate XP.
- [ ] Copy the railway charter: the HUD updates, it never claims infinite train space.
- [ ] Record the optional `cipher` exactly once. Confirm no public mandate/True Dawn or second Founders' Cipher is invented.
- [ ] Select three different WorldPlan Custodians on different attempts. Each offers the correct counterevidence, not a reused generic proof.
- [ ] Test nonviolent tribunal and save/reload: executive actuator must **remain inactive and unspawned**.
- [ ] Test containment with Tech 5 and no Energy or Labour: denied without consuming partial resources. Test enough resources: exact costs, once.
- [ ] Test combat disabling a machine; narrative must not claim killing Edda or Voss.
- [ ] Test one carriage repair: exactly -2 salvage, -3 Labour, -2 Energy, +12 *local seats*; repeats denied.
- [ ] Record priority plan and reload: only the chosen draft persists; there are zero actual passengers.
- [ ] Return to Hearth Nine; retain core evidence and earlier districts/quests.

## Visual/audio QA

- [ ] New wall and floor textures load, render without conspicuous texture seams and keep nearest-style roughness.
- [ ] Core executive actuator has eight distinct directions and recognisable windup/hit/death animation.
- [ ] Core exploration music plays, battle music fades in only on actual combat, F10 mute persists in session.
- [ ] Check menu UI at 1280×800 and at a smaller window; no archive text/button clipping.

### Release gate

Do not label this a verified runtime release until a successful live engine import, a full three-Writ playthrough, save/load test, and short human combat/navigation playtest have been recorded.
