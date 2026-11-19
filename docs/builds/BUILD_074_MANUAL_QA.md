# BUILD 07.4 — GODOT MANUAL GRAPHICS QA

1. Import **this build** into Godot 4.4+ as a new project folder; press **F5**. Confirm title shows the expected game; start new or resume an existing attempt.
2. In Hearth Nine, look at Sela from front, sides, diagonal angles and rear. All eight must show the same original character with readable clothing and **no green chromakey fringe**.
3. Travel to Sootworks and rotate around Brin. Verify feet stay fixed on the floor and new art doesn't clip into nearby worktables.
4. Title -> Enemy Gallery: 17 figures must open. Press **T** to toggle 07.3/07.4. Change views 1-8. Check for duplicate fronts, wrong backs, over-dithered outlines and mismatched feet.
5. Move near/away from a crawler or Enforcer, checking alpha edges, depth sorting and the contact shadow beneath them. No camera-following furniture.
6. Walk the critical paths with new coloured lamps on: intake relay -> crawler -> valve -> Sela, Cinder Lung, rail; then test two district travel points and the trial.
7. Check district look and contrast under actual Godot compatibility renderer. Four lamp meshes per district must be visible but not blind the player; if the room is too dark, tune `scripts/main.gd` ambient or `district_mood_074.gd` lamp energy.
8. Confirm lights, contact shadows and floor-wear decals never block traversal or interactions.
9. Save/Load and full character change: check the existing save loads without lost event IDs or quest effects.
10. Verify on target hardware for performance: the new atlases and transparency cut mode must not cause flicker, artifacts, large load stalls or unexpectedly high VRAM use.

**Open blocker:** This environment has no Godot executable; manual import, scene compilation, visual playback and performance remain **unverified**, even though static tests pass.
