extends Node
## Build 09.3: a threatened named witness (Brin, Ossa) who was not seen or heard
## by any office-holder runs to tell one (immersive-sim Phase 1b).
##
## Bible L1398: knowledge travels only through surviving radios or runners.
## So the report is delivered by a living body walking a real route:
##   - reaching the keeper (within REPORT_REACH, clear line) delivers a TOLD
##     report: the keeper starts watching for the attacker, and the delivery is
##     recorded with the witness as the source;
##   - if the witness dies on the way, nothing is delivered or recorded (dead
##     NPCs are silent); the player can intercept, or simply be gone;
##   - with no living, working keeper in the district, the witness hides where
##     they are and nobody learns of it.
## Progress is kept in Game.state["witness_093"][victim] and survives reloads.

signal delivered(victim: String, keeper: String)
signal stranded(victim: String)

const P = preload("res://scripts/perception_092.gd")
const PathFollower = preload("res://scripts/path_follower_093.gd")
const KEEPER_FOR := {"brin": "millwright", "ossa": "cantor"}
const KEEPER_LABEL := {"millwright": "MILLWRIGHT", "cantor": "CANTOR"}

var victim: String = ""          # "brin" or "ossa"
var keeper_key: String = ""
var attacker_pos: Vector3 = Vector3.ZERO
var walker = PathFollower.new()
var status: String = "running"   # running | delivered | no_listener | keeper_engaged | calmed
var save_clock: float = 0.0

func start(victim_key: String, attacker: Vector3) -> void:
    victim = victim_key
    keeper_key = str(KEEPER_FOR.get(victim, ""))
    attacker_pos = attacker
    name = "WitnessRunner093"
    _store()

static func entry(victim_key: String) -> Dictionary:
    if not Game.has_attempt(): return {}
    return Game.state.get("witness_093", {}).get(victim_key, {})

func _body() -> Node3D:
    return get_parent() as Node3D

func _alive() -> bool:
    var body: Node3D = _body()
    return is_instance_valid(body) and int(body.get("hp")) > 0 and bool(Game.state.get(victim, {}).get("alive", true))

func find_keeper() -> Node3D:
    for n in get_tree().get_nodes_in_group("hostile"):
        if str(n.get("actor_key")) != keeper_key: continue
        if int(n.get("hp")) <= 0: continue
        var sense = n.get_node_or_null("Sense092")
        if sense == null: continue
        # An isolated regulator or governor cannot take a report.
        if keeper_key == "millwright" and bool(Game.state.get("labour", {}).get("regulator_isolated", false)): return null
        if keeper_key == "cantor" and bool(Game.state.get("faith", {}).get("governor_isolated", false)): return null
        return n
    return null

func _store() -> void:
    if not Game.has_attempt(): return
    if not Game.state.has("witness_093"): Game.state["witness_093"] = {}
    var body: Node3D = _body()
    var at: Vector3 = body.global_position if is_instance_valid(body) and body.is_inside_tree() else Vector3.ZERO
    Game.state["witness_093"][victim] = {
        "status": status, "to": keeper_key,
        "pos": [snappedf(at.x, 0.01), snappedf(at.y, 0.01), snappedf(at.z, 0.01)],
        "attacker": [snappedf(attacker_pos.x, 0.01), snappedf(attacker_pos.y, 0.01), snappedf(attacker_pos.z, 0.01)],
    }

func _physics_process(delta: float) -> void:
    if status != "running" or not Game.has_attempt(): return
    if not _alive():
        # Dead witnesses deliver nothing. Drop the pending report.
        Game.state.get("witness_093", {}).erase(victim)
        set_physics_process(false)
        return
    var body: Node3D = _body()
    var keeper: Node3D = find_keeper()
    if keeper == null or bool(keeper.get("hostile")):
        # Nobody to tell (or the office is already fighting): hide here.
        status = "no_listener" if keeper == null else "keeper_engaged"
        _store()
        stranded.emit(victim)
        set_physics_process(false)
        return
    var to_keeper: Vector3 = keeper.global_position - body.global_position
    to_keeper.y = 0.0
    if to_keeper.length() <= P.REPORT_REACH and _clear(body, keeper):
        _deliver(keeper)
        return
    var world: Node3D = body.get_parent() as Node3D
    walker.set_goal(world, body.global_position, keeper.global_position)
    if walker.failed:
        status = "no_listener"
        _store()
        stranded.emit(victim)
        set_physics_process(false)
        return
    var dir: Vector3 = walker.direction(world, body.global_position, delta)
    if dir != Vector3.ZERO:
        body.global_position += dir * P.RUNNER_SPEED * delta
        body.rotation.y = atan2(-dir.x, -dir.z)
    save_clock += delta
    if save_clock >= 0.5:
        save_clock = 0.0
        _store()

func _clear(body: Node3D, keeper: Node3D) -> bool:
    var exclude: Array = []
    if body is CollisionObject3D: exclude.append((body as CollisionObject3D).get_rid())
    if keeper is CollisionObject3D: exclude.append((keeper as CollisionObject3D).get_rid())
    return P.clear_line(body.get_world_3d().direct_space_state, body.global_position + Vector3(0, 1.2, 0), keeper.global_position + Vector3(0, 1.2, 0), exclude)

func _deliver(keeper: Node3D) -> void:
    var sense = keeper.get_node("Sense092")
    var display: String = "Brin Harker" if victim == "brin" else "Sister Ossa"
    if not bool(sense.call("receive_report_093", display, attacker_pos)):
        status = "no_listener"
        _store()
        stranded.emit(victim)
        set_physics_process(false)
        return
    status = "delivered"
    _store()
    # Recorded only now, by a living witness who reached the office (TOLD).
    Game.record_event("witness.093.%s.reported_to_%s" % [victim, keeper_key], "witness_report", {
        "witness_id": victim, "told": keeper_key, "channel": "TOLD",
        "witness_alive_at_record": _alive(), "zone": str(Game.state.get("zone", ""))})
    delivered.emit(victim, keeper_key)
    set_physics_process(false)
