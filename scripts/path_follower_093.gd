extends RefCounted
## Build 09.3: follows a walk_grid_093 path one waypoint at a time.
## Replans when the goal moves more than a metre or the body stops making
## progress. Pure position maths: works for CharacterBody3D (velocity) and for
## StaticBody3D witnesses (moved by position).

const WalkGrid = preload("res://scripts/walk_grid_093.gd")
const REACH := 0.45
const STUCK_SECONDS := 1.6

var waypoints: PackedVector3Array = PackedVector3Array()
var goal: Vector3 = Vector3.INF
var index: int = 0
var stuck_clock: float = 0.0
var last_pos: Vector3 = Vector3.INF
var failed: bool = false   # true when no route exists to the current goal

func set_goal(world: Node3D, from: Vector3, to: Vector3) -> void:
    if goal != Vector3.INF and goal.distance_to(to) < 1.0 and not waypoints.is_empty():
        return
    goal = to
    waypoints = WalkGrid.path(world, from, to)
    index = 0
    failed = waypoints.is_empty()
    stuck_clock = 0.0

func arrived(at: Vector3, within: float = 0.9) -> bool:
    return goal != Vector3.INF and Vector2(at.x - goal.x, at.z - goal.z).length() <= within

## Horizontal direction (unit vector, y = 0) to walk this frame, or ZERO.
func direction(world: Node3D, at: Vector3, delta: float) -> Vector3:
    if failed or goal == Vector3.INF:
        return Vector3.ZERO
    while index < waypoints.size() and Vector2(at.x - waypoints[index].x, at.z - waypoints[index].z).length() < REACH:
        index += 1
    var target: Vector3 = goal if index >= waypoints.size() else waypoints[index]
    var flat := Vector3(target.x - at.x, 0.0, target.z - at.z)
    if flat.length() < 0.05:
        return Vector3.ZERO
    stuck_clock += delta
    if stuck_clock >= STUCK_SECONDS:
        if last_pos != Vector3.INF and at.distance_to(last_pos) < 0.25:
            # Blocked by something that moved in (another body, a closed door):
            # plan again from here once; give up if there is still no way.
            var keep: Vector3 = goal
            goal = Vector3.INF
            set_goal(world, at, keep)
        last_pos = at
        stuck_clock = 0.0
    return flat.normalized()
