extends Node3D
## Short-lived, diegetic hit materials: iron sparks, ceramic dust or
## living-fabric impact. No resource or quest flags created by visuals.
const LIFE: float = 0.24
var elapsed: float = 0.0
var pieces: Array[MeshInstance3D] = []
var velocities: Array[Vector3] = []
var spark_color: Color = Color("#d4aa75")

func configure(kind: String, outward: Vector3) -> void:
    match kind:
        "ceramic": spark_color = Color("#c4d4d0")
        "living": spark_color = Color("#b66a54")
        "metal": spark_color = Color("#f1c66a")
        "glass": spark_color = Color("#9fdde0")
        "wood": spark_color = Color("#b18b62")
        "cloth": spark_color = Color("#8e8273")
        _: spark_color = Color("#a1a79c")
    var normal: Vector3 = outward.normalized() if outward.length_squared() > 0.01 else Vector3.UP
    for i in range(11):
        var piece := MeshInstance3D.new()
        # Shared shard mesh per shape and shared material per tint: an impact used
        # to allocate 11 meshes + 11 materials, i.e. ~88 of each per shotgun blast.
        piece.mesh = _shard_mesh(kind == "metal")
        piece.material_override = _shard_material(spark_color.lightened(0.09 * float(i%3)))
        add_child(piece)
        pieces.append(piece)
        var spread := Vector3(sin(float(i)*2.4),cos(float(i)*3.1),sin(float(i)*4.4))
        velocities.append((normal*1.0 + spread * 1.5) * (0.7 + 0.06*float(i)))

func _process(delta: float) -> void:
    elapsed += delta
    for i in range(pieces.size()):
        if is_instance_valid(pieces[i]):
            pieces[i].position += velocities[i] * delta
            pieces[i].scale = Vector3.ONE * clampf(1.0-elapsed/LIFE,0.0,1.0)
    if elapsed >= LIFE: queue_free()

static var _shard_meshes: Dictionary = {}
static var _shard_materials: Dictionary = {}

## Called from Music.request_quit(); see combat_tracer_079x.gd.
static func clear_shared_cache() -> void:
    _shard_meshes.clear()
    _shard_materials.clear()

static func _shard_mesh(long_shard: bool) -> BoxMesh:
    if not _shard_meshes.has(long_shard):
        var shard := BoxMesh.new()
        shard.size = Vector3(0.025,0.06,0.025) if long_shard else Vector3(0.045,0.045,0.025)
        _shard_meshes[long_shard] = shard
    return _shard_meshes[long_shard]

static func _shard_material(color: Color) -> StandardMaterial3D:
    var key: String = color.to_html(false)
    if not _shard_materials.has(key):
        var mat := StandardMaterial3D.new()
        mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
        mat.albedo_color = color
        _shard_materials[key] = mat
    return _shard_materials[key]
