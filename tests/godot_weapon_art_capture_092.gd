extends SceneTree
const WEAPONS := ["covenant", "coil", "nail", "choir"]

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var cap_dir := OS.get_environment("CAP_DIR")
    if cap_dir.is_empty():
        cap_dir = ProjectSettings.globalize_path("user://weapon_art_capture_092")
    DirAccess.make_dir_recursive_absolute(cap_dir)
    var packed := load("res://scenes/hearth_nine.tscn") as PackedScene
    assert(packed != null, "Could not load Hearth Nine scene")
    var game := packed.instantiate()
    root.add_child(game)
    await process_frame
    game.begin_attempt("Witness")
    Game.ensure_weapon_state()
    Game.state["inventory"]["weapons"] = [
        {"definition_id":"wp_covenant_pistol"},
        {"definition_id":"wp_coil_shotgun"},
        {"definition_id":"wp_nail_storm"},
        {"definition_id":"wp_choirbreaker"}
    ]
    for id in WEAPONS:
        Game.state["weapon_state"]["magazines"][id] = 24
        Game.state["weapon_state"]["reserves"][id] = 96
    await create_timer(1.5).timeout
    assert(game.get("hud") != null, "Hearth Nine HUD was not created")
    var hud = game.hud
    hud.close_modal(true)
    await create_timer(0.4).timeout
    for weapon in WEAPONS:
        Game.equip_weapon(weapon)
        hud.set_weapon(weapon)
        await create_timer(0.35).timeout
        await process_frame
        _capture(game, cap_dir, weapon + "_idle")
        hud.weapon_event("fire", 0.0)
        await create_timer(0.02).timeout
        await process_frame
        _capture(game, cap_dir, weapon + "_fire")
        await create_timer(0.25).timeout
        hud.weapon_event("reload", 1.8)
        await create_timer(0.28).timeout
        await process_frame
        _capture(game, cap_dir, weapon + "_reload_fallback")
        hud.weapon_event("intervene", 0.0)
        await create_timer(0.10).timeout
        await process_frame
        _capture(game, cap_dir, weapon + "_intervene_fallback")
        print("WEAPON_092_CAPTURED " + weapon)
    print("WEAPON_092_CAPTURE_ALL_OK")
    quit(0)

func _capture(game: Node, out_dir: String, name: String) -> void:
    var image := game.get_viewport().get_texture().get_image()
    var path := out_dir.path_join(name + ".png")
    var err := image.save_png(path)
    assert(err == OK, "Failed to save screenshot: " + path)
