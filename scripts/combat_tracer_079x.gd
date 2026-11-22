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
    # One shared unit box, stretched along Z; one shared material per colour.
    # Previously every pellet allocated its own BoxMesh and material.
    beam.mesh = _unit_beam()
    beam.material_override = _beam_material(color)
    add_child(beam)
    beam.global_position = (origin+destination)*0.5
    beam.look_at(destination, safe_up(travel))
    beam.scale = Vector3(1.0, 1.0, travel.length())

## An up vector that is never colinear with `direction` (look_at warns otherwise,
## e.g. for shots fired straight up or down).
static func safe_up(direction: Vector3) -> Vector3:
    if direction.length_squared() < 0.000001: return Vector3.UP
    return Vector3.FORWARD if absf(direction.normalized().dot(Vector3.UP)) > 0.99 else Vector3.UP

static var _shared_beam_mesh: BoxMesh
static var _shared_beam_materials: Dictionary = {}

## Called from Music.request_quit(): static caches outlive the scene tree and
## would otherwise be reported as leaked resources at exit.
static func clear_shared_cache() -> void:
    _shared_beam_mesh = null
    _shared_beam_materials.clear()

static func _unit_beam() -> BoxMesh:
    if _shared_beam_mesh == null:
        _shared_beam_mesh = BoxMesh.new()
        _shared_beam_mesh.size = Vector3(0.018,0.018,1.0)
    return _shared_beam_mesh

static func _beam_material(color: Color) -> StandardMaterial3D:
    var key: String = color.to_html(true)
    if not _shared_beam_materials.has(key):
        var mat := StandardMaterial3D.new()
        mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
        mat.albedo_color = color
        mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
        _shared_beam_materials[key] = mat
    return _shared_beam_materials[key]

func _process(delta: float) -> void:
    remaining -= delta
    if is_instance_valid(beam):
        beam.transparency = clampf(1.0-remaining/LIFE,0.0,1.0)
    if remaining <= 0.0: queue_free()
