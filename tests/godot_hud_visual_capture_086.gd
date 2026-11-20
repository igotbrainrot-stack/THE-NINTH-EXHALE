extends Node
func _ready() -> void:
    call_deferred("_take_capture")

func _take_capture() -> void:
    var scene: Node = load("res://scenes/hearth_nine.tscn").instantiate()
    add_child(scene)
    scene.begin_attempt("Witness")
    for i in range(15):
        await get_tree().process_frame
    # Force visible UI state in this non-interactive screenshot only.
    var ui: Node = get_tree().get_first_node_in_group("game_ui")
    if not is_instance_valid(ui):
        get_tree().quit(1)
        return
    ui.prompt_panel.visible = true
    ui.prompt_label.text = "E / INSPECT CIVIC RECORD"
    ui.banner_panel.visible = true
    ui.banner.text = "SERVICE RAIL / PRESSURE ACTIVE"
    for i in range(6):
        await get_tree().process_frame
    var image: Image = get_viewport().get_texture().get_image()
    var err: Error = image.save_png("/mnt/data/hud086_integration/HUD_086_IN_ENGINE.png")
    print("HUD086_CAPTURE: ", err, " ", image.get_width(), "x", image.get_height())
    get_tree().quit(0 if err == OK else 1)
