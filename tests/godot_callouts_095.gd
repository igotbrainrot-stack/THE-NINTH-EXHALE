extends Node
## Build 09.5 combat callouts (after F.E.A.R.): every line matches a real
## behaviour, lines rotate deterministically, one voice at a time, deaths are
## only called out by an ally that saw them, the dead never speak.
## Counts declared vs completed checks and exits 1 on any failure.
const Callouts = preload("res://scripts/callouts_095.gd")
const Enemy = preload("res://scripts/enemy.gd")
const DECLARED := 11
var scene: Node
var passes: int = 0
var failures: Array[String] = []

func _ready() -> void:
    call_deferred("_run")

func check(ok: bool, label: String) -> void:
    if ok: passes += 1; print("CALL095_PASS: ", label)
    else: failures.append(label); print("CALL095_FAIL: ", label)

func physics(seconds: float) -> void:
    var frames: int = int(ceil(seconds * Engine.physics_ticks_per_second))
    for i in range(frames): await get_tree().physics_frame

func _spawn(key: String, at: Vector3, yaw: float) -> Node:
    if Game.state["actors"].has(key):
        Game.state["actors"][key]["hostile"] = false
        Game.state["actors"][key].erase("hp")
        Game.state["actors"][key].erase("high_alert_093")
    var foe := Enemy.new()
    foe.actor_key = key
    foe.player = scene.player
    scene.world.add_child(foe)
    foe.global_position = at
    foe.rotation.y = yaw
    foe.sense_092.base_yaw = yaw
    foe.sense_092.home = at
    return foe

func _run() -> void:
    # Pure (2)
    Callouts.reset()
    var a: Array = [Callouts.next_line("MAN_DOWN"), Callouts.next_line("MAN_DOWN"), Callouts.next_line("MAN_DOWN"), Callouts.next_line("MAN_DOWN")]
    Callouts.reset()
    var b: Array = [Callouts.next_line("MAN_DOWN"), Callouts.next_line("MAN_DOWN"), Callouts.next_line("MAN_DOWN"), Callouts.next_line("MAN_DOWN")]
    check(a == b and a[0] != a[1] and a[3] == a[0], "lines rotate in a fixed order, the same every run: " + str(a))
    check(Callouts.next_line("NOT_AN_EVENT") == "", "unknown events stay silent")
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
    # Rate limit (2)
    Callouts.reset()
    var talker: Node = _spawn("slag_sifter", Vector3(12, 0.15, 8), 0.0)
    var other: Node = _spawn("chain_hauler", Vector3(6, 0.15, 11), 0.0)
    await physics(0.1)
    var first: bool = Callouts.say(talker, "PAIN")
    var crowded: bool = Callouts.say(other, "PAIN")
    check(first and not crowded, "one voice at a time: a second callout within 0.9 s is held back")
    await physics(1.0)
    check(not Callouts.say(talker, "PAIN") and Callouts.say(other, "PAIN"), "the same enemy waits 3.5 s before speaking again; another may speak")
    talker.queue_free()
    other.queue_free()
    await physics(0.2)
    # Wind-up callout (1): a hostile in reach telegraphs and says what it does.
    Callouts.reset()
    scene.player.global_position = Vector3(8, 0.05, 4)
    var shooter: Node = _spawn("slag_sifter", Vector3(8, 0.15, 10), 0.0)
    await physics(0.1)
    shooter.anger()
    var t: float = 0.0
    while shooter.windup <= 0.0 and t < 6.0:
        await get_tree().physics_frame
        t += 1.0 / Engine.physics_ticks_per_second
    var said: String = shooter.sense_092.bark_text
    check(shooter.windup > 0.0 and said in Callouts.LINES["WINDUP_" + shooter.role_attack], "its wind-up is called as it starts: '%s' (%s attack)" % [said, shooter.role_attack])
    # Reload callout (2): it sees the reload, says so, and presses.
    await physics(2.0)
    Callouts.reset()
    shooter.attack_timer = 2.0
    shooter.windup = 0.0
    Game.state["magazine"] = 1   # the Covenant's magazine lives at the top level
    Game.state["weapon_state"]["reserves"]["covenant"] = 30
    scene.player.reloading = false
    scene.player.reload_weapon()
    check(shooter.sense_092.bark_text in Callouts.LINES["RELOAD"], "a hostile that sees Ninth reload calls it: '%s'" % shooter.sense_092.bark_text)
    check(shooter.attack_timer <= Callouts.RELOAD_PRESS + 0.001, "and attacks sooner (next attack in %.2f s)" % shooter.attack_timer)
    shooter.queue_free()
    await physics(0.2)
    # Man down, witnessed (2)
    Callouts.reset()
    scene.player.global_position = Vector3(-22, 0.05, -18)
    var victim: Node = _spawn("chain_hauler", Vector3(10, 0.15, 6), 0.0)
    var witness: Node = _spawn("slag_sifter", Vector3(10, 0.15, 11), 0.0)   # 5 m away, clear floor
    await physics(0.2)
    victim.take_hit(99999)
    await physics(0.1)
    check(witness.sense_092.bark_text in Callouts.LINES["MAN_DOWN"], "an ally who saw the death calls it: '%s'" % witness.sense_092.bark_text)
    check(witness.sense_092.state in ["INVESTIGATE", "SEARCH"] and witness.sense_092.high_alert and witness.sense_092.last_known.distance_to(victim.global_position) < 0.5, "goes to the body and stays on high alert (%s)" % witness.sense_092.state)
    witness.queue_free()
    victim.queue_free()
    await physics(0.2)
    # Man down, unwitnessed (1)
    Callouts.reset()
    # A far corner: no district enemy within 15 m, the other ally 20 m off.
    var lone: Node = _spawn("chain_hauler", Vector3(-20, 0.15, -16), 0.0)
    var far: Node = _spawn("slag_sifter", Vector3(0, 0.15, -16), 0.0)
    await physics(0.2)
    lone.take_hit(99999)
    await physics(0.1)
    check(far.sense_092.bark_text == "" and far.sense_092.state == "UNAWARE" and Callouts.spoken.is_empty(), "a death nobody saw goes unremarked")
    # The dead never speak (1)
    check(not Callouts.say(lone, "PAIN"), "the dead never speak")
    var total: int = passes + failures.size()
    print("CALL095_SUMMARY: %d passed, %d failed, %d of %d declared checks ran" % [passes, failures.size(), total, DECLARED])
    Music.request_quit(1 if failures.size() > 0 or total != DECLARED else 0)
