extends RefCounted
## Build 09.3 walking grid for NPC movement (immersive-sim Phase 1b).
##
## A 0.5 m AStarGrid2D sampled from world collision (layer 1), lifted from the
## playbot's proven sampler. Used by searching guards and by witnesses running
## to report. It stands in for a navmesh until Phase 2 bakes one.
##
## Moving actors (enemies, Brin, Ossa, the player) are excluded from sampling
## so they do not block their own cells. Doors and furniture count as walls.
## One grid per district, built on first use and cached by world instance.

const CELL := 0.5
const HALF := 70          # 70 cells each way = 35 m from the origin
const BODY_RADIUS := 0.42

static var _grids: Dictionary = {}   # world instance id -> AStarGrid2D
static var build_count: int = 0      # for tests: proves the cache is reused

static func cell_of(p: Vector3) -> Vector2i:
    return Vector2i(clampi(roundi(p.x / CELL), -HALF, HALF - 1), clampi(roundi(p.z / CELL), -HALF, HALF - 1))

static func _moving_bodies(tree: SceneTree) -> Array:
    var rids: Array = []
    for group in ["hostile", "player_controller", "named_witness_093"]:
        for n in tree.get_nodes_in_group(group):
            if n is CollisionObject3D:
                rids.append((n as CollisionObject3D).get_rid())
    return rids

static func grid_for(world: Node3D) -> AStarGrid2D:
    var key: int = world.get_instance_id()
    if _grids.has(key) and is_instance_valid(world):
        return _grids[key]
    var astar := AStarGrid2D.new()
    astar.region = Rect2i(-HALF, -HALF, HALF * 2, HALF * 2)
    astar.cell_size = Vector2(CELL, CELL)
    astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
    astar.update()
    var space: PhysicsDirectSpaceState3D = world.get_world_3d().direct_space_state
    var shape := SphereShape3D.new()
    shape.radius = BODY_RADIUS
    var q := PhysicsShapeQueryParameters3D.new()
    q.shape = shape
    q.collision_mask = 1
    q.exclude = _moving_bodies(world.get_tree())
    var floor_q := PhysicsRayQueryParameters3D.new()
    floor_q.collision_mask = 1
    floor_q.exclude = q.exclude
    for x in range(-HALF, HALF):
        for z in range(-HALF, HALF):
            var w := Vector3(x * CELL, 0.95, z * CELL)
            q.transform = Transform3D(Basis(), w)
            var blocked: bool = not space.intersect_shape(q, 1).is_empty()
            if not blocked:
                q.transform = Transform3D(Basis(), Vector3(w.x, 0.55, w.z))
                blocked = not space.intersect_shape(q, 1).is_empty()
            if not blocked:
                floor_q.from = w
                floor_q.to = w - Vector3(0, 3, 0)
                blocked = space.intersect_ray(floor_q).is_empty()
            if blocked:
                astar.set_point_solid(Vector2i(x, z))
    _grids[key] = astar
    build_count += 1
    return astar

static func forget(world: Node3D) -> void:
    _grids.erase(world.get_instance_id())

static func _open_near(astar: AStarGrid2D, c: Vector2i) -> Vector2i:
    if not astar.is_point_solid(c):
        return c
    var best: Vector2i = c
    var best_d: int = 1 << 30
    for dx in range(-6, 7):
        for dz in range(-6, 7):
            var n: Vector2i = c + Vector2i(dx, dz)
            if astar.region.has_point(n) and not astar.is_point_solid(n):
                var d: int = dx * dx + dz * dz
                if d < best_d:
                    best_d = d
                    best = n
    return best

## World-space waypoints from `from` to `to` (y = from.y). Empty if unreachable.
static func path(world: Node3D, from: Vector3, to: Vector3) -> PackedVector3Array:
    var astar: AStarGrid2D = grid_for(world)
    var a: Vector2i = _open_near(astar, cell_of(from))
    var b: Vector2i = _open_near(astar, cell_of(to))
    var out := PackedVector3Array()
    if astar.is_point_solid(a) or astar.is_point_solid(b):
        return out
    for p in astar.get_point_path(a, b):
        out.append(Vector3(p.x, from.y, p.y))
    return out

## Path length in metres, or INF if no route exists.
static func path_length(world: Node3D, from: Vector3, to: Vector3) -> float:
    var pts: PackedVector3Array = path(world, from, to)
    if pts.is_empty():
        return INF
    var total: float = from.distance_to(pts[0])
    for i in range(1, pts.size()):
        total += pts[i - 1].distance_to(pts[i])
    return total
