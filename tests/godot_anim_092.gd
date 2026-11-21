extends Node
## Build 09.2: drop-in animation sets for enemies, NPCs and weapons.
## Writes synthetic strips into a user:// scratch folder (never into assets/),
## points the loader there, and checks frame selection, facing fallback,
## one-shot holds, weapon state flow and fallbacks. Exits 1 on any failure.
const A = preload("res://scripts/sprite_anim_092.gd")
const DIR := "user://anim_092_test/"
const DECLARED := 14
var passes: int = 0
var failures: Array[String] = []

func _ready() -> void:
    call_deferred("_run")

func check(ok: bool, label: String) -> void:
    if ok: passes += 1; print("ANIM092_PASS: ", label)
    else: failures.append(label); print("ANIM092_FAIL: ", label)

## A strip whose frame i is filled with a colour encoding (i, tag).
func _strip(path: String, frames: int, cell: Vector2i, tag: int) -> void:
    var img := Image.create(cell.x * frames, cell.y, false, Image.FORMAT_RGBA8)
    for i in range(frames):
        img.fill_rect(Rect2i(i * cell.x, 0, cell.x, cell.y), Color8(i * 20, tag, 7, 255))
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
    img.save_png(ProjectSettings.globalize_path(path))

func _json(path: String, data: Dictionary) -> void:
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
    var f := FileAccess.open(path, FileAccess.WRITE)
    f.store_string(JSON.stringify(data))
    f.close()

func _frame_of(tex: Texture2D) -> int:
    var at := tex as AtlasTexture
    return int(at.region.position.x / at.region.size.x) if at != null else -1

func _run() -> void:
    var cell := Vector2i(16, 24)
    _json(DIR + "testfoe/testfoe.anim.json", {"cell": [16, 24], "states": {
        "idle": {"frames": 4, "fps": 4, "loop": true},
        "death": {"frames": 6, "fps": 10, "loop": false}}})
    for facing in [1, 3, 5, 7]:
        _strip(DIR + "testfoe/testfoe_idle_%d.png" % facing, 4, cell, facing)
    _strip(DIR + "testfoe/testfoe_death_1.png", 6, cell, 1)
    A.root_dir = DIR
    A.clear_cache()
    var s: RefCounted = A.load_set("testfoe")
    check(s != null and s.has_state("idle") and s.has_state("death") and not s.has_state("walk"), "manifest and strips load (un-imported PNGs)")
    check(s.resolve_facing("idle", 2) == 1 and s.resolve_facing("idle", 4) == 3 and s.resolve_facing("idle", 8) == 1 and s.resolve_facing("idle", 6) == 5, "missing facings borrow the nearest painted one (ties go to the front)")
    check(s.resolve_facing("death", 5) == 1, "a single-facing state serves every view")
    check(_frame_of(s.frame("idle", 1, 0.0)) == 0 and _frame_of(s.frame("idle", 1, 0.26)) == 1 and _frame_of(s.frame("idle", 1, 1.1)) == 0, "looping state advances and wraps")
    check(_frame_of(s.frame("death", 3, 5.0)) == 5 and is_equal_approx(s.duration("death"), 0.6), "one-shot death holds its last frame")
    check(A.load_set("nobody") == null, "an actor without a set returns null (legacy art stays)")
    # Enemy integration: a real enemy with this set plays idle from it and
    # falls back to the atlas for states the set lacks.
    var scene: Node = load("res://scenes/hearth_nine.tscn").instantiate()
    add_child(scene)
    await get_tree().process_frame
    scene.begin_attempt("Witness")
    for i in range(3): await get_tree().process_frame
    scene.hud.close_modal(true)
    _json(DIR + "slag_sifter/slag_sifter.anim.json", {"cell": [16, 24], "states": {"idle": {"frames": 4, "fps": 4, "loop": true}}})
    _strip(DIR + "slag_sifter/slag_sifter_idle_1.png", 4, cell, 9)
    A.clear_cache()
    var foe = load("res://scripts/enemy.gd").new()
    foe.actor_key = "slag_sifter"
    foe.player = scene.player
    scene.world.add_child(foe)
    await get_tree().process_frame
    await get_tree().process_frame
    check(foe.anim_092 != null and foe.sprite.texture is AtlasTexture and (foe.sprite.texture as AtlasTexture).region.size == Vector2(16, 24), "enemy idle comes from the 09.2 set")
    foe.animation_state = "windup"
    await get_tree().process_frame
    await get_tree().process_frame
    check(not ((foe.sprite.texture as AtlasTexture) != null and (foe.sprite.texture as AtlasTexture).region.size == Vector2(16, 24)), "states the set lacks fall back to the legacy atlas")
    foe.queue_free()
    # NPC death remains are silent sprites with no collision or interaction.
    _json(DIR + "brin/brin.anim.json", {"cell": [16, 24], "states": {"death": {"frames": 3, "fps": 10, "loop": false}}})
    _strip(DIR + "brin/brin_death_1.png", 3, cell, 4)
    A.clear_cache()
    var spawned: bool = A.spawn_death(scene.world, Vector3(0, 0, 0), "brin", 0.0072)
    await get_tree().process_frame
    var remains: Node = scene.world.get_node_or_null("Remains_brin")
    check(spawned and remains is Sprite3D and remains.get_child_count() == 0 and not remains.has_meta("interaction_id"), "NPC death leaves silent remains")
    # Weapons: painted states replace the static idle; reload fits the catalog time.
    var wcell := Vector2i(64, 40)
    _json(DIR + "weapons/covenant/covenant.anim.json", {"cell": [64, 40], "anchors": {"muzzle": [400, 120], "shell_port": [470, 190]},
        "procedural": {"recoil": 0.25, "reload_dip": false}, "states": {
        "idle": {"frames": 4, "fps": 4, "loop": true}, "fire": {"frames": 4, "fps": 24, "loop": false},
        "reload": {"frames": 12, "fps": 12, "loop": false}, "draw": {"frames": 5, "fps": 20, "loop": false}}})
    for st in [["idle", 4], ["fire", 4], ["reload", 12], ["draw", 5]]:
        _strip(DIR + "weapons/covenant/covenant_%s.png" % st[0], int(st[1]), wcell, 30)
    A.clear_cache()
    var hud = scene.hud
    hud.weapon_anim_092 = A.load_set("covenant", DIR + "weapons/")
    hud._weapon_play_092("draw")
    check(hud.weapon_state_092 == "draw", "switching weapons plays the draw")
    hud.weapon_event("fire", 0.1)
    check(hud.weapon_state_092 == "fire", "firing plays the painted fire")
    for i in range(20): await get_tree().process_frame
    hud._advance_weapon_frames_092(0.5)
    check(hud.weapon_state_092 == "idle", "one-shot fire returns to idle")
    hud.weapon_event("reload", 1.8)
    check(hud.weapon_state_092 == "reload" and is_equal_approx(hud.weapon_speed_092, 1.0 / 1.8), "reload is time-scaled to the catalog's 1.8 s")
    check(hud.weapon_anchor_092("muzzle", Vector2.ZERO) == Vector2(400, 120) and hud.weapon_anchor_092("shell_port", Vector2.ZERO) == Vector2(470, 190), "muzzle and shell anchors come from the manifest")
    A.root_dir = "res://assets/sprites/anim_092/"
    A.clear_cache()
    _cleanup(ProjectSettings.globalize_path(DIR))
    var total: int = passes + failures.size()
    print("ANIM092_SUMMARY: %d passed, %d failed, %d of %d declared checks ran" % [passes, failures.size(), total, DECLARED])
    Music.request_quit(1 if failures.size() > 0 or total != DECLARED else 0)

func _cleanup(path: String) -> void:
    var d := DirAccess.open(path)
    if d == null: return
    for f in d.get_files(): DirAccess.remove_absolute(path.path_join(f))
    for sub in d.get_directories(): _cleanup(path.path_join(sub))
    DirAccess.remove_absolute(path)
