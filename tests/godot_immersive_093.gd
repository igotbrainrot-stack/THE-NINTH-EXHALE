extends Node
## Build 09.3 immersive-sim Phase 1b runtime test.
## SEARCH and HIGH ALERT, deterministic barks, the walking grid, a threatened
## witness running to report (delivered, killed on the way, calmed, reloaded),
## the dialogue gate, and the HUD stealth cue. Real game scene, Sootworks.
## Counts declared vs completed checks and exits 1 on any failure.
const P = preload("res://scripts/perception_092.gd")
const Enemy = preload("res://scripts/enemy.gd")
const WalkGrid = preload("res://scripts/walk_grid_093.gd")
const NamedWitness = preload("res://scripts/named_witness_093.gd")
const DECLARED := 36
var scene: Node
var passes: int = 0
var failures: Array[String] = []

func _ready() -> void:
    call_deferred("_run")

func check(ok: bool, label: String) -> void:
    if ok: passes += 1; print("IMM093_PASS: ", label)
    else: failures.append(label); print("IMM093_FAIL: ", label)

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
    _grid_checks()
    await _search_checks()
    await _runner_delivery_checks()
    await _calm_checks()
    await _reload_checks()
    await _runner_killed_checks()
    var total: int = passes + failures.size()
    print("IMM093_SUMMARY: %d passed, %d failed, %d of %d declared checks ran" % [passes, failures.size(), total, DECLARED])
    Music.request_quit(1 if failures.size() > 0 or total != DECLARED else 0)

# ---------------------------------------------------------------- pure (3)
func _pure_checks() -> void:
    check(P.bark_for("HOSTILE", "SIGHT") == "THERE!" and P.bark_for("HOSTILE", "SIGHT") == P.bark_for("HOSTILE", "SIGHT"), "barks are fixed lines chosen by cause, not dice")
    check(P.bark_for("SEARCH", "LOST") != "" and P.bark_for("NOPE", "X") == "", "search has a line; unknown causes stay silent")
    var dark_still: float = P.player_visibility(0.4, 0.0)
    var lit_sprint: float = P.player_visibility(1.0, 7.0)
    check(dark_still < lit_sprint and lit_sprint <= 1.0 and dark_still > 0.0, "visibility: dark and still < lit and sprinting (%.2f < %.2f)" % [dark_still, lit_sprint])

# ---------------------------------------------------------------- grid (2)
func _grid_checks() -> void:
    var before: int = WalkGrid.build_count
    var a := Vector3(-11, 0, 6)
    var b := Vector3(14, 0, -3)
    var length: float = WalkGrid.path_length(scene.world, a, b)
    check(length < INF and length >= a.distance_to(b) - 1.0, "a walking route crosses Sootworks (%.1f m for %.1f m straight)" % [length, a.distance_to(b)])
    WalkGrid.path_length(scene.world, b, a)
    check(WalkGrid.build_count == before + 1, "the district grid is sampled once and reused")

# ---------------------------------------------------------------- search (9)
func _spawn_patrol(at: Vector3, yaw: float) -> Node:
    if Game.state["actors"].has("slag_sifter"):
        Game.state["actors"]["slag_sifter"]["hostile"] = false
    var foe := Enemy.new()
    foe.actor_key = "slag_sifter"
    foe.player = scene.player
    scene.world.add_child(foe)
    foe.global_position = at
    foe.rotation.y = yaw
    foe.sense_092.base_yaw = yaw
    foe.sense_092.home = at
    return foe

func _put_player(at: Vector3) -> void:
    scene.player.global_position = at
    scene.player.velocity = Vector3.ZERO

func _search_checks() -> void:
    Game.state["actors"].get("slag_sifter", {}).erase("high_alert_093")
    var foe: Node = _spawn_patrol(Vector3(12, 0.15, 8), 0.0)
    var seen_at := Vector3(12, 0.05, 4)
    _put_player(seen_at)
    await physics(0.1)
    foe.anger()
    await physics(0.3)
    check(foe.hostile, "patrol is hostile after being angered in view")
    # Vanish: far beyond the 24 m clear-shot distance.
    _put_player(Vector3(-22, 0.05, -18))
    var t: float = 0.0
    while foe.hostile and t < 10.0:
        await get_tree().physics_frame
        t += 1.0 / Engine.physics_ticks_per_second
    check(not foe.hostile and foe.sense_092.state == "SEARCH", "a patrol that loses its target drops to SEARCH (after %.1f s)" % t)
    check(t >= P.LOSE_TRACK_SECONDS - 0.2, "it does not give up before %.0f s" % P.LOSE_TRACK_SECONDS)
    check(foe.sense_092.bark_text == P.bark_for("SEARCH", "LOST"), "it says why: '%s'" % foe.sense_092.bark_text)
    var saved: Dictionary = Game.state["actors"]["slag_sifter"]
    check(not bool(saved.get("hostile", true)) and bool(saved.get("high_alert_093", false)), "the save says: not hostile, high alert")
    await physics(P.SEARCH_SECONDS + 0.5)
    check(foe.sense_092.state == "HIGH_ALERT" and foe.sense_092.high_alert, "after searching it stays on HIGH ALERT, not calm")
    check(foe.sense_092.bark_text == P.bark_for("HIGH_ALERT", "END"), "and says so: '%s'" % foe.sense_092.bark_text)
    # High alert sees further: 15 m is outside normal range (13 m), inside 16.9 m.
    foe.queue_free()
    await physics(0.1)
    var alert: Node = _spawn_patrol(Vector3(12, 0.15, 8), 0.0)
    check(alert.sense_092.high_alert, "high alert survives a reload of the actor")
    Game.state["actors"]["slag_sifter"]["high_alert_093"] = false
    var calm: Node = Enemy.new()
    calm.actor_key = "slag_sifter"
    calm.player = scene.player
    scene.world.add_child(calm)
    calm.global_position = Vector3(12, 0.15, 8)
    calm.rotation.y = 0.0
    _put_player(Vector3(12, 0.05, 8 - 15.0))
    await physics(0.1)
    check(alert.sense_092.sees_player() and not calm.sense_092.sees_player(), "high alert sees 15 m away; a calm patrol does not")
    alert.queue_free()
    calm.queue_free()
    Game.state["actors"]["slag_sifter"]["high_alert_093"] = false
    await physics(0.1)

# ------------------------------------------------------- witness runner (8)
func _reset_brin() -> Node:
    for id in Game.state["event_ids"].keys():
        if str(id).begins_with("witness.085.brin") or str(id).begins_with("witness.093.brin") or str(id).begins_with("witness.092.millwright"):
            _forget(str(id))
    Game.state.erase("witness_093")
    Game.state["brin"].erase("calmed_093")
    Game.state["actors"]["brin"]["hp"] = 45
    Game.state["actors"]["millwright"]["hostile"] = false
    Game.state["actors"]["millwright"].erase("position")   # back to the post
    scene.reload_district_world()
    for i in range(4): await get_tree().process_frame
    return scene.world.get_node_or_null("Brin Harker")

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

func _runner_delivery_checks() -> void:
    var brin: Node3D = await _reset_brin()
    var keeper: Node = scene.guard
    var start: Vector3 = brin.global_position
    # Threaten Brin where the Millwright can neither see nor hear it.
    _put_player(start + Vector3(1.5, 0.05, 1.5))
    brin.take_hit(19)
    await physics(0.2)
    check(NamedWitness.status("brin") == "running" and brin.get_node_or_null("WitnessRunner093") != null, "unheard, Brin runs to tell the Millwright")
    check(not scene._witness_gate_093("brin").is_empty(), "a threatened Brin will not continue his arc")
    # Step aside so the player is not seen when he arrives.
    _put_player(Vector3(-22, 0.05, 18))
    var d0: float = start.distance_to(keeper.global_position)
    await physics(2.0)
    check(brin.global_position.distance_to(keeper.global_position) < d0 - 3.0, "he covers ground toward the office")
    var t: float = 0.0
    while NamedWitness.status("brin") == "running" and t < 25.0:
        await physics(0.25)
        t += 0.25
    check(NamedWitness.status("brin") == "delivered", "he reaches the Millwright and tells him (%.1f s)" % t)
    var report: Dictionary = _find_event("witness.093.brin.reported_to_millwright")
    check(str(report.get("channel", "")) == "TOLD" and bool(report.get("witness_alive_at_record", false)), "the report is recorded by a living witness, channel TOLD")
    check(keeper.sense_092.assault_channel == "TOLD" and keeper.sense_092.assault_alert > 0.0 and not keeper.hostile, "the keeper now watches for the attacker, but has not seen them")
    # Walk into the keeper's view: now he turns, and records what he was told.
    # Stand to one side of Brin (he now stands between the keeper and where he
    # came from, and a body blocks sight), with the keeper facing the player.
    var away: Vector3 = keeper.global_position - brin.global_position
    away.y = 0.0
    var side: Vector3 = Vector3(-away.z, 0.0, away.x).normalized()
    var spot: Vector3 = keeper.global_position + side * 6.0
    var space: PhysicsDirectSpaceState3D = keeper.get_world_3d().direct_space_state
    if not P.clear_line(space, keeper.global_position + Vector3(0, 1.4, 0), spot + Vector3(0, 1.2, 0), [keeper.get_rid(), scene.player.get_rid()]):
        spot = keeper.global_position - side * 6.0
    var to_spot: Vector3 = spot - keeper.global_position
    keeper.rotation.y = atan2(-to_spot.x, -to_spot.z)
    keeper.sense_092.base_yaw = keeper.rotation.y
    _put_player(spot + Vector3(0, 0.05, 0))
    t = 0.0
    while not keeper.hostile and t < 6.0:
        await get_tree().physics_frame
        t += 1.0 / Engine.physics_ticks_per_second
    check(keeper.hostile, "seen after the report, the attacker is fought (%.2f s)" % t)
    var rec: Dictionary = _find_event("witness.092.millwright.assault_on_brin_harker")
    check(str(rec.get("channel", "")) == "TOLD" and str(rec.get("confirmed_by", "")) == "SIGHT", "the keeper's record says told, then confirmed by sight")

# ---------------------------------------------------------------- calm (5)
func _calm_checks() -> void:
    var brin: Node3D = await _reset_brin()
    _put_player(brin.global_position + Vector3(1.5, 0.05, 1.5))
    brin.take_hit(19)
    await physics(0.5)
    Game.state["attributes"]["Speech"] = 3
    Game.state["attributes"]["Insight"] = 3
    check(not NamedWitness.calm(brin, "brin") and NamedWitness.status("brin") == "running", "an apology without Speech or Insight 5 does not stop him")
    Game.state["attributes"]["Speech"] = 6
    check(NamedWitness.calm(brin, "brin"), "with Speech 6 he stops and listens")
    var stopped_at: Vector3 = brin.global_position
    await physics(1.5)
    check(brin.global_position.distance_to(stopped_at) < 0.05 and NamedWitness.status("brin") == "calmed", "a calmed witness stays put; nothing is delivered")
    check(Game.state["event_ids"].has("witness.093.brin.calmed") and not Game.state["event_ids"].has("witness.093.brin.reported_to_millwright"), "calming is recorded; no report exists")
    check(scene._witness_gate_093("brin").is_empty(), "the arc can continue after calming")

# ------------------------------------------------------- reload resume (3)
func _reload_checks() -> void:
    var brin: Node3D = await _reset_brin()
    var start: Vector3 = brin.global_position
    _put_player(start + Vector3(1.5, 0.05, 1.5))
    brin.take_hit(19)
    _put_player(Vector3(-22, 0.05, 18))
    await physics(2.0)
    scene.reload_district_world()
    for i in range(4): await get_tree().process_frame
    brin = scene.world.get_node_or_null("Brin Harker")
    check(brin.global_position.distance_to(start) > 3.0, "after a reload Brin is where he had run to")
    check(brin.get_node_or_null("WitnessRunner093") != null and NamedWitness.status("brin") == "running", "and he is still running to report")
    check(NamedWitness.is_threatened(brin), "and still threatened")

# ------------------------------------------------------ killed runner (4)
func _runner_killed_checks() -> void:
    var brin: Node3D = await _reset_brin()
    var keeper: Node = scene.guard
    _put_player(brin.global_position + Vector3(1.5, 0.05, 1.5))
    brin.take_hit(19)
    await physics(1.0)
    check(NamedWitness.status("brin") == "running", "a second threat run starts")
    brin.take_hit(40)
    await physics(8.0)
    check(not Game.state["event_ids"].has("witness.093.brin.reported_to_millwright"), "a witness killed on the way delivers nothing")
    check(not Game.state.get("witness_093", {}).has("brin"), "the undelivered report dies with him")
    check(is_instance_valid(keeper) and keeper.sense_092.assault_alert == 0.0 and keeper.sense_092.assault_victim == "", "the Millwright never learns of it")
    # HUD cue (bonus wiring checks counted in DECLARED via _hud_checks below).
    await _hud_checks()

# ----------------------------------------------------------------- HUD (0+)
func _hud_checks() -> void:
    var cue = scene.hud.get("awareness_cue_093")
    if cue == null:
        check(false, "HUD stealth cue exists")
        return
    cue.refresh()
    check(cue.visible and cue.visibility > 0.0 and cue.visibility <= 1.0, "the HUD cue shows visibility (%.2f)" % cue.visibility)
    var foe: Node = _spawn_patrol(scene.player.global_position + Vector3(4, 0.1, 0), 0.0)
    await physics(0.1)
    foe.anger()
    cue.refresh()
    check(cue.alarm == "HOSTILE" and cue.word.text == "SPOTTED !", "a hostile guard nearby reads SPOTTED !")
    foe.queue_free()
