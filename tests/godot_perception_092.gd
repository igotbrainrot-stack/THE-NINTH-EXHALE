extends Node
## Build 09.2 perception and witness runtime test (immersive-sim Phase 1).
## Uses the real game scene and Sootworks geometry with controlled positions.
## Counts declared vs completed checks and exits 1 on any failure, so a parse
## error or early abort cannot pass silently.
const P = preload("res://scripts/perception_092.gd")
const Enemy = preload("res://scripts/enemy.gd")
const DECLARED := 25
var scene: Node
var passes: int = 0
var failures: Array[String] = []

func _ready() -> void:
    call_deferred("_run")

func check(ok: bool, label: String) -> void:
    if ok: passes += 1; print("PERC092_PASS: ", label)
    else: failures.append(label); print("PERC092_FAIL: ", label)

func physics(seconds: float) -> void:
    var frames: int = int(ceil(seconds * Engine.physics_ticks_per_second))
    for i in range(frames): await get_tree().physics_frame

func _run() -> void:
    _pure_checks()
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
    await _patrol_checks()
    await _civic_checks()
    var total: int = passes + failures.size()
    print("PERC092_SUMMARY: %d passed, %d failed, %d of %d declared checks ran" % [passes, failures.size(), total, DECLARED])
    Music.request_quit(1 if failures.size() > 0 or total != DECLARED else 0)

func _pure_checks() -> void:
    check(P.sight_rate(2.0, 13.0, 1.0, 1.0) > P.sight_rate(10.0, 13.0, 1.0, 1.0), "closer is noticed faster")
    check(P.sight_rate(6.0, 13.0, 0.4, 1.0) < P.sight_rate(6.0, 13.0, 1.0, 1.0), "darkness slows noticing")
    check(P.sight_rate(14.0, 13.0, 1.0, 1.0) == 0.0, "nothing beyond view range")
    var fwd := Vector3(0, 0, -1)
    check(P.in_cones(Vector3.ZERO, fwd, Vector3(0, 1, -8), 13.0) and not P.in_cones(Vector3.ZERO, fwd, Vector3(0, 1, 8), 13.0), "front seen, back not")
    check(P.in_cones(Vector3.ZERO, fwd, Vector3(2.5, 1, -0.5), 13.0) and not P.in_cones(Vector3.ZERO, fwd, Vector3(8, 1, -0.5), 13.0), "wide near cone only close by")
    var root := Node3D.new()
    add_child(root)
    var lamp := OmniLight3D.new()
    lamp.omni_range = 6.0
    lamp.light_energy = 1.5
    root.add_child(lamp)
    check(P.light_at(root, Vector3(0.5, 0, 0)) > P.light_at(root, Vector3(5.5, 0, 0)) and P.light_at(root, Vector3(9, 0, 0)) == P.LIGHT_FLOOR, "analytic light falls off and floors")
    root.queue_free()

func _spawn_patrol(at: Vector3, yaw: float) -> Node:
    # Each spawn reuses one actor key, so clear the hostility the last one saved.
    if Game.state["actors"].has("slag_sifter"):
        Game.state["actors"]["slag_sifter"]["hostile"] = false
    var foe := Enemy.new()
    foe.actor_key = "slag_sifter"   # an optional Sootworks enemy (wake > 0)
    foe.player = scene.player
    scene.world.add_child(foe)
    foe.global_position = at          # after _ready, which restores saved spots
    foe.rotation.y = yaw
    foe.sense_092.base_yaw = yaw
    foe.sense_092.home = at
    return foe

func _put_player(at: Vector3) -> void:
    scene.player.global_position = at
    scene.player.velocity = Vector3.ZERO

func _patrol_checks() -> void:
    var foe: Node = _spawn_patrol(Vector3(12, 0.15, 8), 0.0)   # faces -Z
    check(foe.sense_092.temperament == "patrol", "optional enemy perceives as a patrol")
    _put_player(Vector3(12, 0.2, 14.5))                          # 6.5 m behind, still
    await physics(2.5)
    check(not foe.hostile and foe.sense_092.awareness < P.SUSPICIOUS, "still player behind is not noticed")
    P.emit_noise(get_tree(), scene.player.global_position, P.NOISE_SPRINT, "footsteps", false, scene.player)
    await physics(0.6)
    check(foe.sense_092.state in ["SUSPICIOUS", "INVESTIGATE"] and not foe.hostile, "sprint footsteps behind make it suspicious, not hostile")
    check(absf(wrapf(foe.rotation.y - 0.0, -PI, PI)) > 0.6, "it turns toward the sound")
    var walk_quiet := P.emit_noise(get_tree(), Vector3(12, 0.2, 13.6), P.NOISE_WALK, "footsteps", false, scene.player)
    check(walk_quiet == 0, "walking 5.6 m away is not heard")
    foe.queue_free()
    await physics(0.1)
    # In front and in view: noticed, then hostile, deterministically.
    var times: Array = []
    for run in range(2):
        var f2: Node = _spawn_patrol(Vector3(12, 0.15, 8), 0.0)
        _put_player(Vector3(12, 0.2, 2.0))                       # 6 m in front
        var t: float = 0.0
        while not f2.hostile and t < 6.0:
            await get_tree().physics_frame
            t += 1.0 / Engine.physics_ticks_per_second
        times.append(snappedf(t, 0.001))
        if run == 0:
            check(f2.hostile and t > 0.4 and t < 5.0, "player in front is noticed then fought (%.2f s)" % t)
        f2.queue_free()
        await physics(0.1)
    check(times.size() == 2 and times[0] == times[1], "detection is deterministic %s" % [times])
    # A wall blocks sight: enemy east of the divider looking west at the player.
    var f3: Node = _spawn_patrol(Vector3(5, 0.15, -8), PI / 2.0)
    _put_player(Vector3(-3, 0.2, -8))
    await physics(3.0)
    check(not f3.hostile and f3.sense_092.awareness < P.SUSPICIOUS, "the office divider blocks sight")
    # Gunfire is heard through the doorway and investigated.
    var start: Vector3 = f3.global_position
    P.emit_noise(get_tree(), Vector3(-2, 0.2, 0), P.WEAPON_NOISE["covenant"], "gunfire", true, scene.player)
    await physics(0.1)
    check(f3.sense_092.state == "INVESTIGATE", "gunfire makes it investigate")
    _put_player(Vector3(-20, 0.2, -20))                         # gone from view
    await physics(1.5)
    check(f3.global_position.distance_to(start) > 0.5, "it walks toward the shot")
    f3.queue_free()
    await physics(0.1)

func _civic_checks() -> void:
    var keeper: Node = scene.guard
    check(is_instance_valid(keeper) and keeper.sense_092.temperament == "civic", "the Millwright perceives as an office-holder")
    # A citizen at the counter is not a threat.
    _put_player(keeper.global_position + Vector3(-5, 0.05, 0))
    await physics(3.0)
    check(not keeper.hostile, "standing in view of the office-holder is not an offence")
    # Brin threatened out of earshot (default spots ~26 m apart).
    var brin: Node = scene.world.get_node_or_null("Brin Harker")
    check(is_instance_valid(brin), "Brin is present")
    _put_player(brin.global_position + Vector3(2, 0.05, 2))
    var records_before: int = _witness_records()
    brin.take_hit(19)
    await physics(3.0)
    check(Game.state["event_ids"].has("witness.085.brin.threatened"), "Brin records his own threat (living victim)")
    check(not keeper.hostile and _witness_records() == records_before, "an office-holder out of earshot is not alerted by fiat")
    # Same act within sight: the office-holder sees it and records it.
    Game.state["actors"]["brin"]["hp"] = 45
    _forget("witness.085.brin.threatened")
    # 09.3: the first scenario sent Brin running to report; reset that too.
    Game.state.erase("witness_093")
    scene.reload_district_world()
    for i in range(4): await get_tree().process_frame
    keeper = scene.guard
    brin = scene.world.get_node_or_null("Brin Harker")
    keeper.global_position = brin.global_position + Vector3(9, 0, 0)
    keeper.rotation.y = PI / 2.0          # facing -X, toward Brin
    keeper.sense_092.base_yaw = PI / 2.0
    _put_player(brin.global_position + Vector3(-2, 0.05, 1.5))
    await physics(0.3)
    brin.take_hit(19)
    var t: float = 0.0
    while not keeper.hostile and t < 5.0:
        await get_tree().physics_frame
        t += 1.0 / Engine.physics_ticks_per_second
    check(keeper.hostile, "an office-holder who saw the assault turns on the attacker (%.2f s)" % t)
    var rec: Dictionary = _find_event("witness.092.millwright.assault_on_brin_harker")
    check(not rec.is_empty() and str(rec.get("witness_id", "")) == "millwright" and str(rec.get("channel", "")) == "SIGHT", "the living witness writes the record %s" % [rec])
    # A heard cry with the attacker never seen, then the witness dies: silence.
    Game.state["actors"]["brin"]["hp"] = 45
    Game.state["actors"]["millwright"]["hostile"] = false
    _forget("witness.085.brin.threatened")
    _forget("witness.092.millwright.assault_on_brin_harker")
    scene.reload_district_world()
    for i in range(4): await get_tree().process_frame
    keeper = scene.guard
    brin = scene.world.get_node_or_null("Brin Harker")
    keeper.global_position = brin.global_position + Vector3(0, 0, -12)
    keeper.rotation.y = 0.0               # facing away from Brin
    keeper.sense_092.base_yaw = 0.0
    _put_player(brin.global_position + Vector3(0, 0.05, 2))
    await physics(0.2)
    brin.take_hit(19)
    await physics(0.2)
    check(keeper.sense_092.assault_alert > 0.0 and not keeper.hostile, "a keeper who only heard the cry is alerted but not yet hostile")
    keeper.take_hit(9999)
    await physics(0.5)
    check(_find_event("witness.092.millwright.assault_on_brin_harker").is_empty(), "a witness who dies before seeing the attacker records nothing")

func _witness_records() -> int:
    var n: int = 0
    for id in Game.state["event_ids"].keys():
        if str(id).begins_with("witness.092."): n += 1
    return n

func _forget(id: String) -> void:
    Game.state["event_ids"].erase(id)
    var kept: Array = []
    for e in Game.state["events"]:
        if str(e.get("id", "")) != id: kept.append(e)
    Game.state["events"] = kept

func _find_event(id: String) -> Dictionary:
    for e in Game.state.get("events", []):
        if str(e.get("id", "")) == id:
            var payload = e.get("details", {})
            return payload if payload is Dictionary else {}
    return {}
