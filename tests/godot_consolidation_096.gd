extends Node
## Build 09.6 consolidation: the Unsaid (bible §2.2, §9), the fixed pellet
## pattern (§8) and the three difficulty modes (§14.10, Testimony).
## Counts declared vs completed checks and exits 1 on any failure.
const Callouts = preload("res://scripts/callouts_095.gd")
const Enemy = preload("res://scripts/enemy.gd")
const WalkGrid = preload("res://scripts/walk_grid_093.gd")
const DECLARED := 14
var scene: Node
var passes: int = 0
var failures: Array[String] = []

func _ready() -> void:
    call_deferred("_run")

func check(ok: bool, label: String) -> void:
    if ok: passes += 1; print("CONS096_PASS: ", label)
    else: failures.append(label); print("CONS096_FAIL: ", label)

func physics(seconds: float) -> void:
    var frames: int = int(ceil(seconds * Engine.physics_ticks_per_second))
    for i in range(frames): await get_tree().physics_frame

func _unsaid() -> Node:
    for n in get_tree().get_nodes_in_group("hostile"):
        if is_instance_valid(n) and str(n.get("actor_key")) == "unsaid_residue": return n
    return null

func _run() -> void:
    scene = load("res://scenes/hearth_nine.tscn").instantiate()
    add_child(scene)
    await get_tree().process_frame
    Game.profile["difficulty"] = "Steady"
    scene.begin_attempt("Witness")
    for i in range(3): await get_tree().process_frame
    scene.hud.close_modal(true)
    Game.state["zone"] = "sootworks"
    scene.reload_district_world()
    await physics(0.3)
    scene.player.set_control_active(true)
    # The Unsaid (8)
    var u: Node = _unsaid()
    check(u != null and u.hp == 70, "Sootworks has its resident Unsaid, 70 HP (bible grunt)")
    if u == null:
        _finish()
        return
    var open_cell: bool = WalkGrid.path_length(scene.world, u.global_position, scene.player.global_position) < INF
    check(u.voice_kind() == "echo" and u.art_key_096() == "saltbound_porter" and u.sprite.modulate == u.base_modulate_096() and u.base_modulate_096() != Color.WHITE and u._attack_label().begins_with("UNSAID") and open_cell, "it is an echo, drawn as a tinted placeholder with its own telegraph, on walkable floor")
    Callouts.reset()
    scene.player.global_position = u.global_position + Vector3(0, -0.1, -1.5)
    await physics(0.1)
    u.anger()
    await physics(0.1)
    check(u.sense_092.bark_text == u.echo_bark("HOSTILE") and u.sense_092.bark_text.begins_with("..."), "it repeats a fragment, never reasons: '%s'" % u.sense_092.bark_text)
    var seen_windup: float = 0.0
    var t: float = 0.0
    while t < 8.0 and seen_windup <= 0.0:
        await get_tree().physics_frame
        t += 1.0 / Engine.physics_ticks_per_second
        if u.windup > 0.0: seen_windup = u.windup
    check(seen_windup > 0.6 and seen_windup <= 0.65 and u.sense_092.bark_text in u.echo_lines("WINDUP_rush"), "its lunge has the bible's 0.65 s cue and an echo line (%.2f s, '%s')" % [seen_windup, u.sense_092.bark_text])
    var hp_before: int = u.hp
    u.take_weapon_hit_096(8, 2.0, "nail")
    check(u.windup > 0.0, "a light non-sonic hit does not break the loop")
    u.take_weapon_hit_096(30, 17.0, "choir")
    check(u.windup <= 0.0 and u.stagger_time > 0.0 and u.hp == hp_before - 38, "the Choirbreaker (Sonic) breaks it every time (bible §9)")
    check(not (u.sense_092.bark_text in Callouts.LINES["RELOAD"]) and Callouts.voice_of(u) != "speech", "it never makes tactical callouts")
    u.take_hit(9999)
    await physics(1.2)
    scene.reload_district_world()
    await physics(0.3)
    check(_unsaid() == null and not bool(Game.state["actors"]["unsaid_residue"]["alive"]), "once put down it stays down (finite encounter budget)")
    # Pellet pattern (2)
    var p: Node = scene.player
    var a: Array = []
    var b: Array = []
    for i in range(8): a.append(p.spread_offset_096("coil", i))
    for i in range(8): b.append(p.spread_offset_096("coil", i))
    check(a == b and a[0] == Vector2.ZERO and a.size() == 8, "the Coil's eight pellets fly the same fixed pattern every shot")
    p.nail_step_096 = 0
    var n1: Array = []
    for i in range(12): n1.append(p.spread_offset_096("nail", 0))
    check(n1.slice(0, 6) == n1.slice(6, 12) and n1[0] != n1[1], "the Nail Storm walks a fixed six-step cycle")
    # Difficulty (4)
    var order: Array = []
    for i in range(3): order.append(Game.cycle_difficulty_096())
    check(order == ["Severe", "Testimony", "Steady"], "the title docket cycles Steady, Severe, Testimony " + str(order))
    Game.state["difficulty"] = "Severe"
    var dummy: Node = Enemy.new()
    dummy.actor_key = "slag_sifter"
    dummy.player = scene.player
    scene.world.add_child(dummy)
    dummy.global_position = Vector3(-21, 0.15, -17)
    await physics(0.1)
    var before: int = dummy.hp
    dummy.take_hit(56)
    check(before - dummy.hp == 50 and dummy._scaled_damage_096(20) == 23, "Severe: enemies take 1/1.12 damage (56 -> 50) and hit 15% harder (20 -> 23)")
    dummy.queue_free()
    Game.state["difficulty"] = "Testimony"
    var spare: int = int(Game.state["spare_ammo"])
    Game.state["spare_ammo"] = 0
    check(Game.ammo_gain_096(24) == 29 and dummy._scaled_damage_096(20) == 16, "Testimony: 20% more ammunition (24 -> 29), enemies hit 20% softer (20 -> 16)")
    Game.state["spare_ammo"] = spare
    Game.state["difficulty"] = "Severe"
    check(Game.difficulty_scale_096("telegraph_min") == 0.6 and Game.difficulty_scale_096("enemy_hp") == 1.12, "Severe never telegraphs under 0.6 s")
    Game.state["difficulty"] = "Steady"
    _finish()

func _finish() -> void:
    Game.profile["difficulty"] = "Steady"
    var total: int = passes + failures.size()
    print("CONS096_SUMMARY: %d passed, %d failed, %d of %d declared checks ran" % [passes, failures.size(), total, DECLARED])
    Music.request_quit(1 if failures.size() > 0 or total != DECLARED else 0)
