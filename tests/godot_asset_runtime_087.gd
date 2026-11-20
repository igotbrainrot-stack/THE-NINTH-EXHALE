extends Node
## Verifies real Godot 4.4 imports, HUD mounts and fallback audio resources.
## This checks resource accessibility and live widget state, not human-visible quality.
var failed: Array[String] = []

func _ready() -> void:
    call_deferred("_check_assets")

func _check(ok: bool, label: String) -> void:
    if ok:
        print("ASSET087_OK: ", label)
    else:
        push_error("ASSET087_FAIL: " + label)
        failed.append(label)

func _check_assets() -> void:
    var main: Node = load("res://scenes/hearth_nine.tscn").instantiate()
    add_child(main)
    await get_tree().process_frame
    main.begin_attempt("Witness")
    await get_tree().process_frame
    var ui: Node = get_tree().get_first_node_in_group("game_ui")
    _check(is_instance_valid(ui), "game_ui_loaded")
    if not is_instance_valid(ui):
        get_tree().quit(1)
        return
    for entry in [
        [ui.vitals_panel, "icon_health"],
        [ui.vitals_panel, "icon_breath"],
        [ui.vitals_panel, "icon_ampoule"],
        [ui.weapon_panel, "icon_ammo"],
        [ui.weapon_panel, "icon_heat"],
        [ui.prompt_panel, "icon_interact"]
    ]:
        var node: TextureRect = entry[0].get_node_or_null("HUD086Icon_" + entry[1]) as TextureRect
        _check(node != null and node.texture != null, "live_widget_" + entry[1])
    for icon_name in ["icon_writ", "icon_evidence_tab", "icon_route_arrow"]:
        var res: Resource = load("res://assets/ui/hud_086/" + icon_name + ".png")
        _check(res is Texture2D, "runtime_available_" + icon_name)
    # Cosmetic sprite must reflect live weapon selection and only show heat in nail mode.
    Game.state["inventory"]["weapons"].append({"definition_id":"wp_nail_storm"})
    Game.state["weapon_state"]["equipped"] = "nail"
    ui.update_hud()
    _check(ui.heat_bar.visible and ui.heat_icon_087.visible, "nail_heat_icon_visible")
    Game.state["weapon_state"]["equipped"] = "covenant"
    ui.update_hud()
    _check(not ui.heat_bar.visible and not ui.heat_icon_087.visible, "nonheat_icon_hidden")
    var paths: Array[String] = []
    for i in range(4):
        paths.append("res://assets/audio/actor_083/npc_grunt_%d.wav" % i)
    for enemy_kind in ["mechanical", "organic"]:
        for event_name in ["alert", "windup", "attack", "hurt", "death"]:
            paths.append("res://assets/audio/actor_083/%s_%s.wav" % [enemy_kind, event_name])
    for path in paths:
        _check(ResourceLoader.exists(path) and load(path) is AudioStream, "fallback_audio_" + path.get_file())
    print("ASSET087_END: ", failed.size(), " failure(s)")
    get_tree().quit(0 if failed.is_empty() else 1)
