extends Node3D
## Build 07.4 non-colliding atmosphere: physically placed practical bulbs,
## subdued district-color lighting and worn floor-material patches.
## No new physical barriers, quest flags, spawn conditions or save state.
var region: String = "hearth"
var lamps: Array = []
var clock: float = 0.0

const FLOOR_WEAR: Dictionary = {
    "hearth": "res://assets/textures/decals_074/hearth_wear.png",
    "sootworks": "res://assets/textures/decals_074/soot_oil.png",
    "basilica": "res://assets/textures/decals_074/basilica_salt.png",
    "ashmarket": "res://assets/textures/decals_074/soot_oil.png",
    "orchard": "res://assets/textures/decals_074/basilica_salt.png",
    "barracks": "res://assets/textures/decals_074/hearth_wear.png",
    "lift": "res://assets/textures/decals_074/hearth_wear.png",
    "core": "res://assets/textures/decals_074/hearth_wear.png"
}

func configure(zone: String) -> void:
    region = zone
    var positions: Array = []
    var colors: Array = []
    match zone:
        "hearth":
            positions = [Vector3(-19,3.4,-7), Vector3(-15,3.4,10), Vector3(13,3.4,7), Vector3(23,3.4,-12)]
            colors = [Color("#c3dbcc"),Color("#e0c89e"),Color("#a7d2c4"),Color("#dda873")]
        "sootworks":
            positions = [Vector3(-17,3.4,-11), Vector3(18,3.4,-3), Vector3(12,3.4,13), Vector3(-14,3.4,16)]
            colors = [Color("#e4b57b"),Color("#ef9a57"),Color("#e2a35e"),Color("#9bb4a8")]
        "basilica":
            positions = [Vector3(-19,3.4,-13), Vector3(15,3.4,-13), Vector3(-3,3.4,15), Vector3(18,3.4,7)]
            colors = [Color("#b6e1d7"),Color("#86bcb4"),Color("#b4c7b0"),Color("#d2b38a")]
        "ashmarket":
            positions = [Vector3(-16,3.4,-11),Vector3(-16,3.4,12),Vector3(16,3.4,-9),Vector3(18,3.4,12)]
            colors = [Color("#e4c68f"),Color("#d2a177"),Color("#c2afa1"),Color("#b8c4aa")]
        "orchard":
            positions = [Vector3(-18,3.4,-13),Vector3(-18,3.4,11),Vector3(18,3.4,-10),Vector3(18,3.4,15)]
            colors = [Color("#b2dca8"),Color("#d1dfab"),Color("#91c0ad"),Color("#c5ddbf")]
        "barracks":
            positions = [Vector3(-19,3.4,-12),Vector3(-18,3.4,13),Vector3(18,3.4,-10),Vector3(18,3.4,14)]
            colors = [Color("#c3c3a6"),Color("#dcb98b"),Color("#abb19d"),Color("#cd9b79")]
        "core":
            positions = [Vector3(-17,3.5,-13),Vector3(17,3.5,-13),Vector3(-17,3.5,11),Vector3(17,3.5,10)]
            colors = [Color("#b4c1ad"),Color("#cdb88e"),Color("#adc5c4"),Color("#d8bc96")]
        "lift":
            positions = [Vector3(3,3.2,-2),Vector3(9,3.2,-8)]
            colors = [Color("#d7b49f"),Color("#dc9b73")]
    for i in range(positions.size()):
        _add_lamp(positions[i], colors[i], i)
    _add_wear(zone)
    set_process(not lamps.is_empty())

func _add_lamp(pos: Vector3, tint: Color, index: int) -> void:
    var bulb := OmniLight3D.new()
    bulb.position = pos
    bulb.light_color = tint
    bulb.light_energy = 0.78 if index%2==0 else 0.58
    bulb.omni_range = 10.0 if region != "lift" else 8.5
    bulb.omni_attenuation = 1.45
    bulb.shadow_enabled = false  # Four low-cost practical lights per district.
    add_child(bulb)
    var mount := MeshInstance3D.new()
    mount.name = "Industrial practical lamp shell"
    mount.position = pos + Vector3(0,0.12,0)
    var shade := CylinderMesh.new()
    shade.top_radius = 0.21
    shade.bottom_radius = 0.28
    shade.height = 0.19
    mount.mesh = shade
    var dark := StandardMaterial3D.new()
    dark.albedo_color = Color("#4b4f45")
    dark.metallic = 0.65
    dark.roughness = 0.49
    mount.material_override = dark
    add_child(mount)
    var diode := MeshInstance3D.new()
    diode.name = "Recessed lantern diffuser"
    diode.position = pos + Vector3(0,-0.01,0)
    var glass := SphereMesh.new()
    glass.radius = 0.13
    glass.height = 0.13
    diode.mesh = glass
    var glow := StandardMaterial3D.new()
    glow.albedo_color = tint
    glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    glow.emission_enabled = true
    glow.emission = tint
    glow.emission_energy_multiplier = 1.3
    diode.material_override = glow
    add_child(diode)
    lamps.append({"light":bulb,"base":bulb.light_energy,"phase":float(index)*1.6})

func _add_wear(zone: String) -> void:
    var path: String = str(FLOOR_WEAR.get(zone,""))
    if path == "" or not ResourceLoader.exists(path): return
    var finish := StandardMaterial3D.new()
    finish.albedo_texture = load(path)
    finish.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    finish.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    finish.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
    finish.cull_mode = BaseMaterial3D.CULL_DISABLED
    var positions: Array = [Vector3(-17.0,0.039,0.4),Vector3(-9.5,0.041,-11),Vector3(8.0,0.042,10.0),Vector3(16.5,0.040,-4.0)]
    for i in range(positions.size()):
        var model := MeshInstance3D.new()
        model.name = "Embedded floor wear / no collision"
        var plane := PlaneMesh.new()
        plane.size = Vector2(2.6 + float(i)*0.5,1.8+float(i%2)*0.6)
        model.mesh = plane
        model.position = positions[i]
        model.rotation.y = float(i)*0.83
        model.material_override = finish
        add_child(model)

func _process(delta: float) -> void:
    clock += delta
    for n in lamps.size():
        var item: Dictionary = lamps[n]
        var bulb: OmniLight3D = item["light"]
        if not is_instance_valid(bulb): continue
        var wave: float = 0.014*sin(clock*2.25+float(item["phase"]))
        bulb.light_energy = float(item["base"])*(1.0+wave)
