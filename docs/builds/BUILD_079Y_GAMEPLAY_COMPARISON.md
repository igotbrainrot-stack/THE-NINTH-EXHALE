# Player-visible difference: 07.9X → 07.9Y

| Situation | 07.9X | 07.9Y source behaviour |
| --- | --- | --- |
| Basilica pull behind structural cover | damage blocked but Breath could still be drained | Breath drains only when the same physical ray hits the player |
| Incoming ranged enemy shot | enemy animation, damage, pressure cue | also displays short role-tinted 3D firing line terminating at ray impact |
| Sootworks activated furnace | player avoids timed rectangular vent | nearby hostile standing in vent also gets a brief stagger once per cycle |
| Shootable pressure fixture near two enemies | canonical guard stagger and pressure feedback | nearby optional enemies are staggered/damaged too, without repeat rewards |
| Fast attack animation transitions | could enter an arbitrary animation frame because animation clock carried over | attack-state changes reset the animation phase; death starts its intended sequence |

These are source-level behaviours. Visual quality and engagement **have not** been established by a live Godot run.
