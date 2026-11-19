# Build 08.1 Open Issues

1. **P0 — Live engine QA:** no Godot executable was available; import and playtest are required before classing this as a verified runnable build.
2. **P1 — Gate semantics:** decorative railway shutters look like doors, but original transfers still occur through an adjacent E interaction console. Physically cut openings/door animation with consistent spawn transitions only after reliable engine traversal tests.
3. **P1 — Asset art review:** low-poly architecture is authored, but placement, proportions, texture contrast and visual occlusion must be evaluated in Godot at 640x400.
4. **P1 — Weapons:** prior 08.0A transparent-edge fixes are preserved, but weapon art still needs author-supervised chroma-key review and stronger frame animations.
5. **P1 — Combat and character animation:** three major authored encounter set pieces, complete 8-way animation consistency and Runway binary integrations remain incomplete.
6. **P2 — Performance:** the new art layer adds non-colliding meshes and limited dynamic parts; measure FPS and reduce material switches or merge static meshes if needed.
7. **P2 — GitHub:** this latest full source ZIP has not been committed to the GitHub repository, whose default branch is still not the complete current game.
