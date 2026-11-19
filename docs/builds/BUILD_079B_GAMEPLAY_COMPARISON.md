# Build 07.9 vs 07.9B safety preflight

- Enemy behind opaque cover: in 07.9 a rush role may start a windup without visible contact; in this pass, it cannot, and contact damage also checks visibility. Verification: source-based tests only; live physics still needed.
- Service lever (E): 07.9 immediately charged for quiet intervention. This pass first explains the cost and whether the repair is preventive, then requires a second E within four seconds. Shooting still triggers irreversible rupture immediately. Verification: source-based tests only.
- Shot impact: 07.9 approximated collision surfaces from scene node names, defaulting to metal. This pass uses explicit collider metadata, defaulting to stone; the lever is metal. Other authored surfaces still need classification. Verification: source-based tests only.

No new four-beat NPC quests or cinematic assembly were implemented in this preflight. Do not describe this as the fully playable 07.9B redesign.
