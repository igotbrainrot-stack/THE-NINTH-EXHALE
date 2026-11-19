extends StaticBody3D
## Diegetic, finite, shootable pressure equipment. Lives inside the current
## authored room but is deliberately not an obstacle to the walking route.
## No new enemy or ammunition is generated when it bursts.
signal burst(fixture_id: String, at: Vector3)
var fixture_id: String = ""
var spent: bool = false
var hp: int = 14
var body_mesh: MeshInstance3D
var indicator: MeshInstance3D
var lamp: OmniLight3D

func _ready() -> void:
    collision_layer = 4   # Shot and emergency-intervention raycasts; not a walking wall.
    collision_mask = 0
    var geometry := CylinderMesh.new()
    geometry.top_radius = 0.35
    geometry.bottom_radius = 0.43
    geometry.height = 1.25
    body_mesh = MeshInstance3D.new()
    body_mesh.name = "Retained pressure cylinder / visual"
    body_mesh.position.y = 0.70
    body_mesh.mesh = geometry
    var steel := StandardMaterial3D.new()
    steel.albedo_color = Color("#555b51")
    steel.metallic = 0.45
    steel.roughness = 0.38
    steel.albedo_texture = load("res://assets/textures/pressure_vessel_067.png")
    steel.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
    body_mesh.material_override = steel
    add_child(body_mesh)
    var collision := CollisionShape3D.new()
    var solid := CylinderShape3D.new()
    solid.height = 1.25
    solid.radius = 0.43
    collision.position.y = 0.70
    collision.shape = solid
    add_child(collision)
    indicator = MeshInstance3D.new()
    var ring := CylinderMesh.new()
    ring.top_radius = 0.49
    ring.bottom_radius = 0.49
    ring.height = 0.12
    indicator.mesh = ring
    indicator.position.y = 1.22
    var status := StandardMaterial3D.new()
    status.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    status.albedo_color = Color("#e7a760")
    indicator.material_override = status
    add_child(indicator)
    lamp = OmniLight3D.new()
    lamp.position.y = 1.65
    lamp.light_color = Color("#e7a760")
    lamp.light_energy = 0.55
    lamp.omni_range = 4.0
    add_child(lamp)
    var plate := Label3D.new()
    plate.text = "LIVE PRESSURE / SHOOT TO VENT"
    plate.position.y = 1.95
    plate.font_size = 21
    plate.pixel_size = 0.007
    plate.modulate = Color("#ebd8a6")
    plate.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    add_child(plate)
    if spent:
        _make_spent()
        plate.text = "VENTED / EMPTY"

func take_hit(damage: int) -> void:
    if spent or not Game.has_attempt(): return
    hp -= damage
    if hp <= 0:
        spent = true
        _make_spent()
        burst.emit(fixture_id, global_position)
    else:
        lamp.light_energy = 1.1

func _make_spent() -> void:
    indicator.visible = false
    lamp.light_energy = 0.0
    var black := StandardMaterial3D.new()
    black.albedo_color = Color("#30332f")
    black.metallic = 0.1
    black.roughness = 1.0
    if is_instance_valid(body_mesh): body_mesh.material_override = black
    collision_layer = 0
