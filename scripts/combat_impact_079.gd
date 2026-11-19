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
        var shard := BoxMesh.new()
        shard.size = Vector3(0.025,0.06,0.025) if kind == "metal" else Vector3(0.045,0.045,0.025)
        piece.mesh = shard
        var mat := StandardMaterial3D.new()
        mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
        mat.albedo_color = spark_color.lightened(0.09 * float(i%3))
        piece.material_override = mat
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
