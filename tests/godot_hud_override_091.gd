extends Node
## Build 09.1: art dropped into assets/ui/hud_091/ overrides HUD slots without
## code changes, including PNGs Godot has not imported yet, with 9-slice
## margins from hud_091_slices.json. Missing or broken slots fall back to the
## 08.6 set. 09.2: it writes only into a scratch folder under user:// and
## points the loader there, so delivered hud_091 art is never touched.
## Exits 1 on failure.
const GameUI = preload("res://scripts/game_ui.gd")
const DIR := "user://hud_override_test_091/"
var failures: Array[String] = []
var passes: int = 0
var written: Array[String] = []

func _ready() -> void:
    call_deferred("_run")

func check(ok: bool, label: String) -> void:
    if ok: passes += 1; print("OVR091_PASS: ", label)
    else: failures.append(label); print("OVR091_FAIL: ", label)

func _png(slot: String, size: Vector2i, color: Color) -> void:
    var img := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
    img.fill(color)
    var path: String = DIR + slot + ".png"
    img.save_png(ProjectSettings.globalize_path(path))
    written.append(path)

func _run() -> void:
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DIR))
    var real_before: Dictionary = _snapshot_real_art()
    GameUI.art_override_dir = DIR
    _png("hud_frame_brass", Vector2i(96, 48), Color("#7a3b2e"))
    _png("hud_keycap", Vector2i(18, 18), Color("#efe2c7"))
    _png("hud_slip", Vector2i(64, 22), Color("#d8c8a0"))
    var f := FileAccess.open(DIR + "hud_091_slices.json", FileAccess.WRITE)
    f.store_string(JSON.stringify({"hud_frame_brass": [9, 8, 9, 8], "hud_keycap": [4, 3, 4, 5], "hud_slip": [6, 4, 6, 4]}))
    f.close()
    var scene: Node = load("res://scenes/hearth_nine.tscn").instantiate()
    add_child(scene)
    await get_tree().process_frame
    scene.begin_attempt("Witness")
    for i in range(3): await get_tree().process_frame
    scene.hud.close_modal(true)
    var hud = scene.hud
    var skin: StyleBox = hud.objective_panel.get_theme_stylebox("panel")
    check(skin is StyleBoxTexture and (skin as StyleBoxTexture).texture.get_size() == Vector2(96, 48), "un-imported hud_091 frame replaces the brass frame")
    check(skin is StyleBoxTexture and (skin as StyleBoxTexture).texture_margin_left == 9.0 and (skin as StyleBoxTexture).texture_margin_bottom == 8.0, "9-slice margins come from hud_091_slices.json")
    var steel: StyleBox = hud.vitals_panel.get_theme_stylebox("panel")
    check(steel is StyleBoxTexture and hud.hud_art_path("hud_frame_steel").begins_with("res://assets/ui/hud_086/") and (steel as StyleBoxTexture).texture_margin_left == 16.0, "slots without an override keep the 08.6 art and margins")
    hud.set_interact_prompt("[E] SPEAK TO OREN")
    check(hud.prompt_keycap.get_theme_stylebox("panel") is StyleBoxTexture, "keycap uses hud_091/hud_keycap.png")
    hud.notify("OVERRIDE TEST", 3.0)
    await get_tree().process_frame
    check(hud.fx.slips[0].get_theme_stylebox("panel") is StyleBoxTexture, "notice slip uses hud_091/hud_slip.png")
    check(hud.hud_optional_skin("hud_tab_active", StyleBoxFlat.new()) is StyleBoxFlat, "optional slot without art keeps its flat style")
    check(hud._hud086_texture("hud_reticle") == hud._hud086_texture("hud_reticle"), "textures are cached, not reloaded per frame")
    _cleanup()
    GameUI.art_override_dir = GameUI.HUD_091_PATH
    check(_snapshot_real_art() == real_before, "delivered hud_091 art is byte-identical after the test")
    print("OVR091_SUMMARY: %d passed, %d failed" % [passes, failures.size()])
    Music.request_quit(1 if failures.size() > 0 else 0)

func _cleanup() -> void:
    for path in written + [DIR + "hud_091_slices.json"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
    DirAccess.remove_absolute(ProjectSettings.globalize_path(DIR))

func _snapshot_real_art() -> Dictionary:
    var out: Dictionary = {}
    var d := DirAccess.open(GameUI.HUD_091_PATH)
    if d == null: return out
    for f in d.get_files():
        if f.ends_with(".png") or f.ends_with(".json"):
            out[f] = FileAccess.get_sha256(GameUI.HUD_091_PATH + f)
    return out
