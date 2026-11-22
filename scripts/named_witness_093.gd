extends RefCounted
## Build 09.3 shared behaviour for the named civilian witnesses (Brin, Ossa).
##
## - Threatened (below 60% HP) civilians who were not perceived by an office
##   run to tell their keeper (witness_runner_093.gd).
## - While threatened they will not continue their arc with the person who
##   hurt them; a deterministic Speech or Insight 5 apology calms them.
##   Calming does not unsay a report already delivered.
## - Where they ran to, and whether they are calm, survives reloads.

const Runner = preload("res://scripts/witness_runner_093.gd")
const CALM_THRESHOLD := 5

static func setup(actor: Node3D, key: String) -> void:
    actor.add_to_group("named_witness_093")
    if not Game.has_attempt(): return
    var entry: Dictionary = Game.state.get("witness_093", {}).get(key, {})
    if entry.is_empty() or not bool(Game.state.get(key, {}).get("alive", true)): return
    # Once calmed, the story places them again (decisions move them).
    if calmed(key): return
    var pos: Array = entry.get("pos", [])
    if pos.size() == 3 and not (float(pos[0]) == 0.0 and float(pos[2]) == 0.0):
        actor.position = Vector3(float(pos[0]), float(pos[1]), float(pos[2]))
    if str(entry.get("status", "")) == "running":
        var attacker: Array = entry.get("attacker", [0, 0, 0])
        _add_runner(actor, key, Vector3(float(attacker[0]), float(attacker[1]), float(attacker[2])))

static func _add_runner(actor: Node3D, key: String, attacker: Vector3) -> Node:
    var runner = Runner.new()
    actor.add_child(runner)
    runner.start(key, attacker)
    return runner

## Called when nobody perceived the assault. Returns the runner, or null when
## there is no keeper to run to (the witness then simply hides).
static func start_run(actor: Node3D, key: String, attacker: Vector3) -> Node:
    if not is_instance_valid(actor) or actor.get_node_or_null("WitnessRunner093") != null: return null
    if calmed(key): return null
    var runner = _add_runner(actor, key, attacker)
    if runner.find_keeper() == null:
        runner.status = "no_listener"
        runner._store()
        runner.set_physics_process(false)
    _label(actor, "THREATENED WITNESS / RUNNING TO THE %s" % str(Runner.KEEPER_LABEL.get(runner.keeper_key, "OFFICE")) if runner.status == "running" else "THREATENED WITNESS / HIDING")
    return runner

static func _label(actor: Node3D, text: String) -> void:
    for child in actor.get_children():
        if child is Label3D:
            (child as Label3D).text = text
            return

static func calmed(key: String) -> bool:
    return Game.has_attempt() and bool(Game.state.get(key, {}).get("calmed_093", false))

## Threatened and not yet calmed: the arc is paused (main.gd docket gate).
static func is_threatened(actor: Node) -> bool:
    if not is_instance_valid(actor) or not actor.has_meta("threatened_085"): return false
    return bool(actor.get_meta("threatened_085")) and not calmed(str(actor.get_meta("interaction_id", "")))

static func status(key: String) -> String:
    if not Game.has_attempt(): return ""
    return str(Game.state.get("witness_093", {}).get(key, {}).get("status", ""))

static func calm_check() -> Dictionary:
    var speech: int = Game.stat("Speech")
    var insight: int = Game.stat("Insight")
    return {"ok": speech >= CALM_THRESHOLD or insight >= CALM_THRESHOLD,
        "text": "[Speech %d / %d or Insight %d / %d]" % [speech, CALM_THRESHOLD, insight, CALM_THRESHOLD]}

## Apologise and stand down. Stops a run in progress; a delivered report stays.
static func calm(actor: Node, key: String) -> bool:
    if not Game.has_attempt() or not bool(calm_check()["ok"]) or calmed(key): return false
    if not Game.record_event("witness.093.%s.calmed" % key, "witness_calmed", {"witness_id": key, "method": "apology", "report_status": status(key)}):
        return false
    Game.state[key]["calmed_093"] = true
    if is_instance_valid(actor):
        var runner = actor.get_node_or_null("WitnessRunner093")
        if runner != null and str(runner.status) == "running":
            runner.status = "calmed"
            runner._store()
            runner.set_physics_process(false)
        actor.set_meta("threatened_085", false)
        for child in actor.get_children():
            if child.has_method("set_threatened_085"):
                child.call("set_threatened_085", false)
        _label(actor, "BRIN HARKER / SHAKEN" if key == "brin" else "SISTER OSSA / SHAKEN")
    elif Game.state.get("witness_093", {}).has(key) and status(key) == "running":
        Game.state["witness_093"][key]["status"] = "calmed"
    Game.save_attempt()
    return true
