extends Node3D
## Development-only prop inspection gallery. Model can rotate through 360 deg;
## no Sprite3D plane, no fake perspective, no gameplay or save changes.
## 07.1: Q/E preview snaps through the same 45-degree increments as sprite angles 1..8. Geometry remains truly 3D in gameplay.
const PropMesh070 = preload("res://scripts/prop_mesh_070.gd")
const DISTRICTS: Array[String] = ["hearth","sootworks","basilica"]
var district_index: int = 0
var profile_index: int = 1
var displayed: Node3D
var title_label: Label
var status_label: Label
var auto_spin: bool = true

func _ready() -> void:
    var env_node := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color("#17211f")
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color("#9ca99f")
    env.ambient_light_energy = 0.66
    env_node.environment = env
    add_child(env_node)
    var light := DirectionalLight3D.new()
    light.rotation_degrees = Vector3(-56,-34,0)
    light.light_energy = 1.15
    add_child(light)
    var camera := Camera3D.new()
    camera.position = Vector3(3.7,2.6,5.2)
    camera.fov = 49.0
    camera.current = true
    add_child(camera)
    camera.look_at(Vector3(0,0.93,0))
    var floor := MeshInstance3D.new()
    floor.name = "Neutral inspection platform"
    var base := CylinderMesh.new()
    base.top_radius = 2.35
    base.bottom_radius = 2.35
    base.height = 0.15
    floor.mesh = base
    floor.position.y = -0.08
    var base_mat := StandardMaterial3D.new()
    base_mat.albedo_color = Color("#354440")
    base_mat.metallic = 0.35
    base_mat.roughness = 0.77
    floor.material_override = base_mat
    add_child(floor)

    var ui := CanvasLayer.new()
    add_child(ui)
    var layer := Control.new()
    layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    ui.add_child(layer)
    var bg := Panel.new()
    bg.position = Vector2(12,10)
    bg.size = Vector2(616,80)
    var frame := StyleBoxFlat.new()
    frame.bg_color = Color(0.08,0.11,0.10,0.92)
    frame.border_color = Color("#a08051")
    frame.set_border_width_all(2)
    frame.set_corner_radius_all(5)
    bg.add_theme_stylebox_override("panel",frame)
    layer.add_child(bg)
    title_label = Label.new()
    title_label.position = Vector2(17,8)
    title_label.size = Vector2(570,23)
    title_label.add_theme_font_size_override("font_size",20)
    title_label.add_theme_color_override("font_color",Color("#e8dcc4"))
    title_label.text = "MUNICIPAL OBJECT INSPECTION"
    bg.add_child(title_label)
    status_label = Label.new()
    status_label.position = Vector2(17,38)
    status_label.size = Vector2(580,34)
    status_label.add_theme_color_override("font_color",Color("#bfd1ba"))
    status_label.add_theme_font_size_override("font_size",12)
    bg.add_child(status_label)

    var footer := Panel.new()
    footer.position = Vector2(12,340)
    footer.size = Vector2(616,48)
    footer.add_theme_stylebox_override("panel",frame)
    layer.add_child(footer)
    var key_hint := Label.new()
    key_hint.position = Vector2(10,7)
    key_hint.size = Vector2(595,35)
    key_hint.text = "LEFT/RIGHT next prop  •  UP/DOWN district  •  Q/E 45° angle  •  SPACE spin on/off  •  ESC title"
    key_hint.add_theme_font_size_override("font_size",12)
    key_hint.add_theme_color_override("font_color",Color("#d4c0a0"))
    key_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    footer.add_child(key_hint)
    _show_current()

func _process(delta: float) -> void:
    if is_instance_valid(displayed) and auto_spin:
        displayed.rotation.y += 0.30 * delta

func _input(event: InputEvent) -> void:
    if not (event is InputEventKey) or not event.pressed or event.echo:
        return
    match event.keycode:
        KEY_LEFT:
            profile_index = 9 if profile_index == 1 else profile_index - 1
            _show_current()
        KEY_RIGHT:
            profile_index = 1 if profile_index == 9 else profile_index + 1
            _show_current()
        KEY_UP:
            district_index = (district_index + 2) % 3
            _show_current()
        KEY_DOWN:
            district_index = (district_index + 1) % 3
            _show_current()
        KEY_Q:
            if is_instance_valid(displayed): displayed.rotation.y -= PI / 4.0
        KEY_E:
            if is_instance_valid(displayed): displayed.rotation.y += PI / 4.0
        KEY_SPACE:
            auto_spin = not auto_spin
        KEY_ESCAPE:
            get_tree().change_scene_to_file("res://scenes/main.tscn")

func _show_current() -> void:
    if is_instance_valid(displayed): displayed.queue_free()
    var district_name: String = DISTRICTS[district_index]
    displayed = PropMesh070.new()
    add_child(displayed)
    displayed.setup(district_name,profile_index,1.0)
    displayed.rotation.y = -0.32
    title_label.text = "MUNICIPAL OBJECT INSPECTION / BUILD 07.1"
    status_label.text = "%s  /  PROFILE %02d OF 09  /  REAL 3D MESH + PHYSICAL MATERIALS" % [district_name.to_upper(),profile_index]
