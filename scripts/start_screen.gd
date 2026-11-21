extends Control
## Editor-visible entry point: press F5 in Godot to run the project.
## Build 06.9 improves menu presentation and communication while still handing
## Legacy: BUILD 06.9 / UI + HUD POLISH
## actual new/resume selection to the in-world civic docket.

@onready var play_button: Button = $Frame/PlayButton
@onready var quit_button: Button = $Frame/QuitButton
@onready var gallery_button: Button = $Frame/GalleryButton
@onready var enemy_gallery_button: Button = $Frame/EnemyGalleryButton
@onready var prop_gallery_button: Button = $Frame/PropGalleryButton
@onready var npc_gallery_button: Button = $Frame/NPCGalleryButton
@onready var frame: Panel = $Frame
@onready var title: Label = $Frame/Title
@onready var subtitle: Label = $Frame/Subtitle
@onready var description: Label = $Frame/Description
@onready var footer: Label = $Footer

func _ready() -> void:
    _style_frame()
    _style_labels()
    _style_buttons()
    _add_status_chips()
    play_button.pressed.connect(_enter_hearth_nine)
    gallery_button.pressed.connect(_enter_weapon_gallery)
    enemy_gallery_button.pressed.connect(_enter_enemy_gallery)
    prop_gallery_button.pressed.connect(_enter_prop_gallery)
    npc_gallery_button.pressed.connect(_enter_npc_gallery)
    quit_button.pressed.connect(_quit_game)
    play_button.grab_focus()
    print("THE NINTH EXHALE: title screen ready. Click ENTER HEARTH NINE.")

func _panel_style(bg: Color, border: Color, radius: int = 6, width: int = 2) -> StyleBoxFlat:
    var skin := StyleBoxFlat.new()
    skin.bg_color = bg
    skin.border_color = border
    skin.set_border_width_all(width)
    skin.set_corner_radius_all(radius)
    skin.content_margin_left = 14
    skin.content_margin_top = 12
    skin.content_margin_right = 14
    skin.content_margin_bottom = 12
    skin.shadow_color = Color(0,0,0,0.35)
    skin.shadow_size = 5
    return skin

func _apply_button_style(button: Button, emphasis: bool = false) -> void:
    var normal := _panel_style(Color(0.13,0.16,0.15,0.92), Color("#b38a4f") if emphasis else Color("#6e786d"), 4, 2)
    var hover := _panel_style(Color(0.20,0.24,0.23,0.96), Color("#e0b46d") if emphasis else Color("#99a28e"), 4, 2)
    var pressed := _panel_style(Color(0.26,0.23,0.18,0.98), Color("#f1d4a1"), 4, 2)
    button.add_theme_stylebox_override("normal", normal)
    button.add_theme_stylebox_override("hover", hover)
    button.add_theme_stylebox_override("pressed", pressed)
    button.add_theme_stylebox_override("focus", hover)
    button.add_theme_stylebox_override("disabled", normal)
    button.add_theme_color_override("font_color", Color("#efe2c7"))
    button.add_theme_color_override("font_hover_color", Color("#fff9ef"))
    button.add_theme_color_override("font_pressed_color", Color("#fff9ef"))
    button.add_theme_color_override("font_focus_color", Color("#fff9ef"))
    button.add_theme_font_size_override("font_size", 16 if emphasis else 13)
    button.focus_mode = Control.FOCUS_ALL
    button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func _style_frame() -> void:
    frame.add_theme_stylebox_override("panel", _panel_style(Color(0.08,0.10,0.095,0.90), Color("#b38a4f"), 8, 2))
    frame.offset_left = 34.0
    frame.offset_top = 22.0
    frame.offset_right = 606.0
    frame.offset_bottom = 372.0

func _style_labels() -> void:
    # Build 09.0: the old copy was unwrapped and ran outside the frame and under
    # the buttons. Every label now wraps inside a fixed column.
    title.text = "THE NINTH EXHALE"
    title.add_theme_font_size_override("font_size", 34)
    title.add_theme_color_override("font_color", Color("#efe2c7"))
    title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
    title.add_theme_constant_override("shadow_offset_y", 2)
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _place(title, Vector2(20, 14), Vector2(532, 44))
    subtitle.text = "BUILD 08.7 / ASSET INTEGRATION"
    subtitle.add_theme_color_override("font_color", Color("#bda77e"))
    subtitle.add_theme_font_size_override("font_size", 13)
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _place(subtitle, Vector2(20, 58), Vector2(532, 20))
    description.text = "A municipal-industrial FPS/RPG of consent, scarcity and contested survival.\nWin any three Writs from five offices, pass the Rootkin hearing and confront the Custodian. Then the public assembly chooses one of four irreversible settlements."
    description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    description.add_theme_color_override("font_color", Color("#dae1d2"))
    description.add_theme_font_size_override("font_size", 13)
    _place(description, Vector2(44, 116), Vector2(484, 92))
    footer.text = "WASD MOVE  •  LMB FIRE  •  E INTERACT  •  TAB DOCKET  •  F10 MUSIC ON/OFF"
    footer.add_theme_color_override("font_color", Color("#d2ba8f"))
    footer.add_theme_font_size_override("font_size", 11)
    footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    footer.offset_left = 20
    footer.offset_right = 620
    footer.offset_top = 376
    footer.offset_bottom = 396

## Sets a Control's rectangle from code, overriding the scene's stale offsets.
func _place(node: Control, at: Vector2, size_px: Vector2) -> void:
    node.set_anchors_preset(Control.PRESET_TOP_LEFT)
    node.offset_left = at.x
    node.offset_top = at.y
    node.offset_right = at.x + size_px.x
    node.offset_bottom = at.y + size_px.y

func _style_buttons() -> void:
    play_button.text = "ENTER HEARTH NINE"
    gallery_button.text = "WEAPONS"
    enemy_gallery_button.text = "ENEMIES"
    prop_gallery_button.text = "3D PROPS"
    npc_gallery_button.text = "NPC TURNS"
    quit_button.text = "QUIT"
    _apply_button_style(play_button, true)
    for b in [gallery_button, enemy_gallery_button, prop_gallery_button, npc_gallery_button, quit_button]:
        _apply_button_style(b)
        b.add_theme_font_size_override("font_size", 11)
    _place(play_button, Vector2(146, 216), Vector2(280, 38))
    # The art galleries are review tools, so they sit in one quiet row.
    var x: float = 66.0
    for b in [gallery_button, enemy_gallery_button, prop_gallery_button, npc_gallery_button]:
        _place(b, Vector2(x, 278), Vector2(104, 24))
        x += 112.0
    _place(quit_button, Vector2(236, 310), Vector2(100, 24))
    play_button.focus_neighbor_bottom = play_button.get_path_to(enemy_gallery_button)

func _add_status_chips() -> void:
    var save_chip := Panel.new()
    save_chip.position = Vector2(20, 84)
    save_chip.size = Vector2(166, 24)
    save_chip.add_theme_stylebox_override("panel", _panel_style(Color(0.13,0.16,0.15,0.88), Color("#62766a"), 3, 1))
    frame.add_child(save_chip)
    var save_label := Label.new()
    save_label.position = Vector2(8, 4)
    save_label.size = Vector2(150, 16)
    save_label.add_theme_font_size_override("font_size", 10)
    save_label.add_theme_color_override("font_color", Color("#dce9d2"))
    save_label.text = "ACTIVE SAVE DETECTED" if Game.has_saved_active() else "NO ACTIVE SAVE"
    save_chip.add_child(save_label)

    var note_chip := Panel.new()
    note_chip.position = Vector2(386, 84)
    note_chip.size = Vector2(166, 24)
    note_chip.add_theme_stylebox_override("panel", _panel_style(Color(0.16,0.12,0.09,0.88), Color("#8f6f3d"), 3, 1))
    frame.add_child(note_chip)
    var note_label := Label.new()
    note_label.position = Vector2(8, 4)
    note_label.size = Vector2(150, 16)
    note_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    note_label.add_theme_font_size_override("font_size", 10)
    note_label.add_theme_color_override("font_color", Color("#f0dfbe"))
    note_label.text = "ART GALLERIES BELOW"
    note_chip.add_child(note_label)

    var lower_note := Label.new()
    lower_note.position = Vector2(52, 260)
    lower_note.size = Vector2(468, 18)
    lower_note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    lower_note.add_theme_font_size_override("font_size", 10)
    lower_note.add_theme_color_override("font_color", Color("#90a190"))
    lower_note.text = "New and resume attempt choices appear inside the diegetic docket after entering the ward."
    lower_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    frame.add_child(lower_note)

func _enter_hearth_nine() -> void:
    var error: Error = get_tree().change_scene_to_file("res://scenes/hearth_nine.tscn")
    if error != OK:
        push_error("HEARTH NINE FAILED TO LOAD: error code %d" % error)

func _enter_weapon_gallery() -> void:
    var error: Error = get_tree().change_scene_to_file("res://scenes/weapon_gallery.tscn")
    if error != OK:
        push_error("WEAPON GALLERY FAILED TO LOAD: error code %d" % error)

func _enter_enemy_gallery() -> void:
    var error: Error = get_tree().change_scene_to_file("res://scenes/enemy_gallery_068.tscn")
    if error != OK:
        push_error("ENEMY GALLERY FAILED TO LOAD: %d" % error)

func _enter_prop_gallery() -> void:
    var error: Error = get_tree().change_scene_to_file("res://scenes/prop_gallery_070.tscn")
    if error != OK:
        push_error("PROP GALLERY FAILED TO LOAD: %d" % error)

func _enter_npc_gallery() -> void:
    var error: Error = get_tree().change_scene_to_file("res://scenes/npc_gallery_071.tscn")
    if error != OK:
        push_error("NPC ROTATION GALLERY FAILED: %d" % error)

func _quit_game() -> void:
    Music.request_quit()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F10:
        Music.toggle_mute()
