extends Node3D
## 079X: short, geometry-only line of fire; never raycasts or changes damage.
const LIFE: float = 0.075
var remaining: float = LIFE
var beam: MeshInstance3D
func configure(origin: Vector3, destination: Vector3, color: Color) -> void:
    var travel: Vector3 = destination-origin
    if travel.length_squared() < 0.04:
        queue_free()
        return
    beam = MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = Vector3(0.018,0.018,travel.length())
    beam.mesh = mesh
    var mat := StandardMaterial3D.new()
    mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    mat.albedo_color = color
    mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    beam.material_override = mat
    add_child(beam)
    beam.global_position = (origin+destination)*0.5
    beam.look_at(destination,Vector3.UP)
func _process(delta: float) -> void:
    remaining -= delta
    if is_instance_valid(beam):
        beam.transparency = clampf(1.0-remaining/LIFE,0.0,1.0)
    if remaining <= 0.0: queue_free()
