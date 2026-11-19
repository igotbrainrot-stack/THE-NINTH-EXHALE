# Build 07.7 — exact manual F5 checks

1. **Import/parse:** Extract to a clean folder, open `project.godot` with Godot 4.4+, press F5 and check Debugger > Errors and Output. Do not overwrite the previous known-working extraction.
2. **Save compatibility:** Resume a 07.6 schema-1 attempt with Lung installed; verify new Orchard/Barracks transfer choices appear and the original three Writs, core records, Custodian, items and attempted decisions are unchanged. Back up save before cross-version tests.
3. **Orchard navigation:** Reach all evidence, Venn, Growth wicket, root seed and return stations from entrance. Verify no blocking of the central 10m crossover and no furniture billboarding.
4. **Growth routes (different fresh attempts):** (a) control sample -> researchers -> vote -> transfer. (b) Mechanist Tech 6 feed isolation -> transfer, verify Energy -2 and Labour -1. (c) combat -> registry, verify frame stays disabled after F9 and rail travel. Re-enter each station and confirm no repeated XP, supplies or Writ.
5. **Venn arc:** Meet -> original remote staple order -> investigate -> help/compromise/exploit/abandon -> aftermath, verify record and mutually exclusive choice, no automatic owned Echoform. Confirm each stage requires previous stage.
6. **Root Seed:** Before sample evidence, item unavailable. After sample, collect exactly one stable `qobj_orchard_root_seed`; not a completed True Dawn.
7. **Barracks navigation:** Reach roll, watch officer, signal station, Commandant, Writ, Heat Survey and return rail from entrance. Check no ghost barriers.
8. **Defence routes (fresh attempts):** (a) copy casualty roll + guard roster -> assembly -> transfer. (b) Tech 6 + guard roster -> isolate signal (Energy -2, Labour -2) -> transfer. (c) combat -> registry transfer; no wrongful central Marshal Voss death recorded.
9. **Kest:** Meet -> original forged warrant -> investigate -> exclusive choice -> aftermath; no assertion of prior user murder without a source. Reopening cannot grant XP again.
10. **Deep Heat Survey:** Collect once after casualty roll; real mapping record, no generated electricity or Correction.
11. **Three of five:** Test Labour + Faith + Growth, Labour + Faith + Defence, and Trade + Growth + Defence with Rootkin hearing and installed Lung. Each should pass Hearth public authentication; duplicate IDs should not. Two-Writ test lift remains explicitly separate.
12. **Sound/presentation:** Ensure new procedural Ogg loops play in their respective districts; combat layer crossfades only with actual hostiles; HUD objective, navigation pointer and names update; F10 mute still works.
13. **Negative tests:** Unknown zone, no Lung, no hearing, Tech under 5, insufficient finite Energy/Labour, non-existent route, attempted duplicate item, attempted repeat decision, killed regional frame with no reappearing holder.
14. **Performance:** Walk around the 3D planters and barriers while firing/reloading and opening dialogue. Inspect frame pacing and interaction raycasts.

## Automated test commands

```
python3 -m unittest discover -s tests -p 'test_*.py'
python3 tests/validate_project.py
```

Passing Python checks **does not** count as a native Godot parser, shader, visual or playability test. Report errors with file, line, and the exact Godot error text.
