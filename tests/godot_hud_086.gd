extends Node
## Godot 4.4.1 skin integration smoke: real scene/UI nodes and art resources.
var failed: Array[String] = []
func _ready() -> void:
    call_deferred("_check")

func _assert_check(ok: bool, label: String) -> void:
    if ok:
        print("HUD086_OK: ", label)
    else:
        failed.append(label)
        push_error("HUD086_FAILED: " + label)

func _check() -> void:
    var main: Node = load("res://scenes/hearth_nine.tscn").instantiate()
    add_child(main)
    await get_tree().process_frame
    var ui: Node = get_tree().get_first_node_in_group("game_ui")
    _assert_check(is_instance_valid(ui), "game_ui_instantiated")
    if not is_instance_valid(ui):
        get_tree().quit(1)
        return
    for pair in [
        [ui.objective_panel, "hud_frame_brass"],
        [ui.navigation_panel, "hud_frame_steel"],
        [ui.vitals_panel, "hud_frame_steel"],
        [ui.weapon_panel, "hud_frame_brass"],
        [ui.prompt_panel, "hud_prompt_tab"],
        [ui.banner_panel, "hud_banner_alert"]
    ]:
        var skin: StyleBox = pair[0].get_theme_stylebox("panel")
        _assert_check(skin is StyleBoxTexture, str(pair[1]) + "_panel")
        if skin is StyleBoxTexture:
            _assert_check(skin.texture != null, str(pair[1]) + "_loaded")
    _assert_check(ui.reticle.texture != null, "reticle_loaded")
    for bar in [ui.hp_bar, ui.breath_bar, ui.heat_bar]:
        _assert_check(bar.get_theme_stylebox("background") is StyleBoxTexture, "gauge_track")
        _assert_check(bar.get_theme_stylebox("fill") is StyleBoxTexture, "gauge_live_fill")
    _assert_check(ui.vitals_panel.get_node_or_null("HUD086Icon_icon_health") != null, "health_icon")
    _assert_check(ui.weapon_panel.get_node_or_null("HUD086Icon_icon_ammo") != null, "ammo_icon")
    _assert_check(ui.prompt_panel.get_node_or_null("HUD086Icon_icon_interact") != null, "prompt_icon")
    ui.open_modal("HEARING", "Record evidence.", [{"label":"CONTINUE", "action":"close"}])
    var modal_skin: StyleBox = ui.modal.get_theme_stylebox("panel")
    _assert_check(modal_skin is StyleBoxTexture, "docket_modal")
    var count: int = 0
    for child in ui.modal.get_children():
        if child is ScrollContainer:
            for options in child.get_children():
                for button in options.get_children():
                    if button is Button:
                        count += 1
                        _assert_check(button.get_theme_stylebox("normal") is StyleBoxTexture, "button_normal")
                        _assert_check(button.get_theme_stylebox("hover") is StyleBoxTexture, "button_hover")
                        _assert_check(button.get_theme_stylebox("pressed") is StyleBoxTexture, "button_pressed")
    _assert_check(count == 1, "modal_action_exists")
    ui.close_modal()
    _assert_check(ui.hp_bar.max_value == 100.0, "hp_live_value_range")
    print("HUD086_END: ", failed.size(), " failure(s)")
    Music.request_quit(0 if failed.is_empty() else 1)
