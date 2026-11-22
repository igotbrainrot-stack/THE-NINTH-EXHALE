extends Node
## Build 09.5 DOOM-like RPG techniques runtime test:
## sound along walking routes (Doom's sector flood), the muzzle flash lighting
## the shooter, deterministic pain thresholds (Doom's pain chance without
## dice), and the district record (Doom/Dusk tally).
## Counts declared vs completed checks and exits 1 on any failure.
const P = preload("res://scripts/perception_092.gd")
const WalkGrid = preload("res://scripts/walk_grid_093.gd")
const Enemy = preload("res://scripts/enemy.gd")
const Record = preload("res://scripts/district_record_095.gd")
const DECLARED := 14
var scene: Node
var passes: int = 0
var failures: Array[String] = []

func _ready() -> void:
    call_deferred("_run")

func check(ok: bool, label: String) -> void:
    if ok: passes += 1; print("DOOM095_PASS: ", label)
    else: failures.append(label); print("DOOM095_FAIL: ", label)

func physics(seconds: float) -> void:
    var frames: int = int(ceil(seconds * Engine.physics_ticks_per_second))
    for i in range(frames): await get_tree().physics_frame

func _box(parent: Node3D, at: Vector3, size: Vector3) -> void:
    var body := StaticBody3D.new()
    body.collision_layer = 1
    var shape := CollisionShape3D.new()
    var box := BoxShape3D.new()
    box.size = size
    shape.shape = box
    body.add_child(shape)
    parent.add_child(body)
    body.global_position = at

## A 40 x 40 m floor with a wall along z = 0 and a doorway centred at gap_x.
func _walled_room(gap_x: float, sealed: bool) -> Node3D:
    var w := Node3D.new()
    add_child(w)
    _box(w, Vector3(0, -0.5, 0), Vector3(40, 1, 40))
    if sealed:
        _box(w, Vector3(0, 1.5, 0), Vector3(40, 3, 0.6))
    else:
        var left_len: float = (gap_x - 1.0) + 20.0
        var right_len: float = 20.0 - (gap_x + 1.0)
        _box(w, Vector3(-20.0 + left_len * 0.5, 1.5, 0), Vector3(left_len, 3, 0.6))
        _box(w, Vector3(20.0 - right_len * 0.5, 1.5, 0), Vector3(right_len, 3, 0.6))
    return w

func _run() -> void:
    await _sound_checks()
    _flash_checks()
    scene = load("res://scenes/hearth_nine.tscn").instantiate()
    add_child(scene)
    await get_tree().process_frame
    scene.begin_attempt("Witness")
    for i in range(3): await get_tree().process_frame
    scene.hud.close_modal(true)
    Game.state["zone"] = "sootworks"
    scene.reload_district_world()
    for i in range(4): await get_tree().process_frame
    scene.player.set_control_active(true)
    await _pain_checks()
    await _record_checks()
    var total: int = passes + failures.size()
    print("DOOM095_SUMMARY: %d passed, %d failed, %d of %d declared checks ran" % [passes, failures.size(), total, DECLARED])
    Music.request_quit(1 if failures.size() > 0 or total != DECLARED else 0)

# ------------------------------------------------------------- sound (4)
func _sound_checks() -> void:
    var src := Vector3(0, 0, -3)
    var ear := Vector3(0, 0, 3)
    var far := _walled_room(15.0, false)
    await physics(0.1)
    var space: PhysicsDirectSpaceState3D = far.get_world_3d().direct_space_state
    var old_rule: float = P.heard_distance(space, src, ear, [])
    var routed: float = P.heard_distance(space, src, ear, [], far, 26.0)
    check(absf(old_rule - 6.0 * P.OCCLUDED_DISTANCE_FACTOR) < 0.2 and routed > 28.0, "behind a wall, sound travels the route round it (%.1f m, not the old guess of %.1f m)" % [routed, old_rule])
    check(routed > P.WEAPON_NOISE["covenant"], "so a pistol shot 6 m away through a wall, with the doorway 15 m off, is not heard")
    WalkGrid.forget(far)
    far.queue_free()
    await physics(0.1)
    var near := _walled_room(1.5, false)
    await physics(0.1)
    var near_route: float = P.heard_distance(near.get_world_3d().direct_space_state, src, ear, [], near, 26.0)
    check(near_route < 9.0, "with the doorway beside it, the same shot carries (%.1f m)" % near_route)
    WalkGrid.forget(near)
    near.queue_free()
    await physics(0.1)
    var sealed := _walled_room(0.0, true)
    await physics(0.1)
    var shut: float = P.heard_distance(sealed.get_world_3d().direct_space_state, src, ear, [], sealed, 26.0)
    check(shut == INF, "a sealed room hears nothing, however loud (Doom's closed door)")
    WalkGrid.forget(sealed)
    sealed.queue_free()
    await physics(0.1)

# -------------------------------------------------------------- flash (2)
func _flash_checks() -> void:
    var dark := Node3D.new()
    add_child(dark)
    var before: float = P.player_light(dark, Vector3.ZERO)
    P.register_shot("coil")
    var during: float = P.player_light(dark, Vector3.ZERO)
    check(before == P.LIGHT_FLOOR and absf(during - 0.9) < 0.001, "firing the Coil lights Ninth from %.2f to %.2f" % [before, during])
    check(P.sight_rate(8.0, 13.0, during, 1.0) > P.sight_rate(8.0, 13.0, before, 1.0) * 2.0, "so a guard 8 m away notices more than twice as fast")
    dark.queue_free()

# --------------------------------------------------------------- pain (4)
func _spawn(key: String, at: Vector3) -> Node:
    if Game.state["actors"].has(key):
        Game.state["actors"][key]["hostile"] = false
        Game.state["actors"][key].erase("hp")
    var foe := Enemy.new()
    foe.actor_key = key
    foe.player = scene.player
    scene.world.add_child(foe)
    foe.global_position = at
    return foe

func _pain_checks() -> void:
    var heavy: Node = _spawn("slag_sifter", Vector3(12, 0.15, 8))
    scene.player.global_position = Vector3(-22, 0.05, -18)   # out of the way
    await physics(0.1)
    var threshold: float = heavy.pain_threshold_095()
    check(threshold > 8.0 and threshold < 45.0, "a heavy enemy needs %.0f damage to flinch" % threshold)
    # Hold the Nail Storm on it for 3 s: 8 damage every 0.09 s (33 hits).
    var t: float = 0.0
    var since: float = 1.0
    var hits: int = 0
    heavy.hp = 9999
    while t < 3.0:
        if since >= 0.09:
            heavy.take_hit(8)
            hits += 1
            since = 0.0
        await get_tree().physics_frame
        var d: float = 1.0 / Engine.physics_ticks_per_second
        t += d
        since += d
    check(heavy.flinches_095 >= 2 and heavy.flinches_095 <= 5, "the Nail Storm flinches it %d times in 3 s, not on all %d hits (no stun-lock)" % [heavy.flinches_095, hits])
    await physics(1.0)
    var before: int = heavy.flinches_095
    heavy.take_hit(64)   # one Coil blast: 8 pellets x 8
    check(heavy.flinches_095 == before + 1, "one Coil blast flinches it at once")
    var crawler: Node = _spawn("intake_crawler", Vector3(10, 0.15, 6))
    await physics(0.1)
    check(crawler.pain_threshold_095() < threshold, "a small rusher flinches more easily (%.0f) than the heavy (%.0f)" % [crawler.pain_threshold_095(), threshold])
    heavy.queue_free()
    crawler.queue_free()
    await physics(0.1)

# ------------------------------------------------------------- record (4)
func _record_checks() -> void:
    Game.state.erase("district_record_095")
    var foe: Node = _spawn("chain_hauler", Vector3(6, 0.15, 11))
    await physics(0.1)
    foe.anger()
    await physics(0.2)
    foe.take_hit(9999)
    await physics(0.2)
    var e: Dictionary = Record.get_entry("sootworks")
    check(int(e.get("spotted", 0)) >= 1 and int(e.get("put_down", 0)) == 1, "the district record counts sightings (%d) and enemies put down (%d)" % [int(e.get("spotted", 0)), int(e.get("put_down", 0))])
    var before: int = int(e.get("records", 0))
    Game.record_event("test.095.record_counter", "test", {})
    check(int(Record.get_entry("sootworks").get("records", 0)) == before + 1, "records written here are counted here")
    var docket: String = scene._with_record_095("The municipal transfer remains open.")
    check(docket.contains("DISTRICT RECORD / SOOTWORKS") and docket.contains("1 put down") and docket.contains("Brin Harker alive"), "the return-rail docket shows it: " + docket.get_slice("\n\n", 1))
    Game.state.erase("district_record_095")
    var clean: String = Record.text("sootworks", get_tree())
    check(clean.contains("spotted never") and clean.contains("No one here saw you coming"), "an unseen, bloodless visit says so")
