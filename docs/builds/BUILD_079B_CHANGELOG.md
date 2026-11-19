# Build 07.9B — Early safety preflight (partial implementation)

This is an incremental continuation of the complete 07.9 gameplay-first source. It is **not** the complete B1/B2/C/D/E milestone promised by the agent brief.

Implemented:
- Rush attackers must now have unobstructed line-of-sight to begin or commit a windup; rush contact damage requires an unobstructed ray at impact. Existing attack coordination and visual telegraphs remain.
- Shot impact material classification reads authored `surface_kind` collision-object metadata, with a stone fallback. The safety lever declares metal; glass/wood/cloth VFX categories are now supported. More world surfaces need authoring before this claim can cover every district.
- Quiet hazard service requires a second interaction within four seconds before any finite Energy/Labour expenditure. The first prompt distinguishes preventive maintenance from active threat and displays the cost. A shot is still an immediate, clearly signposted destructive rupture costing 2 Energy.
- Added regression tests and updated the outdated 07.9 line-of-sight expectation.

No quest, ending, Writ, passenger, save-schema, or canonical action IDs were removed or rewritten. Active saves remain schema-compatible.

Pending: complete Brin and Ossa four-beat quests, distinct tactical hazards and Rootkin tells, theatrical assembly, bounded layouts, fully validated art/audio imports, and in-engine manual testing.
