extends StaticBody3D
## A single physical, inspectable service lever. E is quiet containment;
## shooting is a louder, costlier irreversible rupture. Both are finite.
var director: Node3D
var hazard_key: String = ""
var display: Label3D

func _ready() -> void:
    set_meta("surface_kind","metal")
    collision_layer = 5 # Walkways (1) + shooting rays (4); near walls only.
    collision_mask = 0
    set_meta("interaction_id",hazard_key + "_switch_079")
    var shape := CollisionShape3D.new()
    shape.position.y = 0.75
    var solid := BoxShape3D.new()
    solid.size = Vector3(0.75,1.50,0.52)
    shape.shape = solid
    add_child(shape)
    var housing := MeshInstance3D.new()
    housing.position.y = 0.75
    var body := BoxMesh.new()
    body.size = Vector3(0.75,1.50,0.52)
    housing.mesh = body
    var coating := StandardMaterial3D.new()
    coating.metallic = 0.18
    coating.roughness = 0.38
    coating.albedo_color = Color("#626f67")
    housing.material_override = coating
    add_child(housing)
    var lever := MeshInstance3D.new()
    lever.position = Vector3(0.0,1.28,-0.29)
    var face := BoxMesh.new()
    face.size = Vector3(0.20,0.40,0.15)
    lever.mesh = face
    var enamel := StandardMaterial3D.new()
    enamel.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    enamel.albedo_color = Color("#d6aa5a")
    lever.material_override = enamel
    add_child(lever)
    display = Label3D.new()
    display.position.y = 2.0
    display.text = "SERVICE LATCH / E: 1 ENERGY + 1 LABOUR / SHOT: 2 ENERGY"
    display.font_size = 17
    display.pixel_size = 0.007
    display.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    display.modulate = Color("#e2d3ae")
    add_child(display)

func take_hit(_damage: int) -> void:
    if is_instance_valid(director):
        director.try_shutdown("rupture")

func mark_spent() -> void:
    if is_instance_valid(display):
        display.text = "PRESSURE CIRCUIT ISOLATED / RECORDED"
    collision_layer = 1 # Physical casing remains, but it cannot be shot again.
