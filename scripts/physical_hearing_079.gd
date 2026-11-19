extends Node3D
## The existing five-command loaner hearing remains the sole authority.
## This is a spatial, live readout of its *real saved tactical state*.
## No invented creature ownership, additional damage or auto-win.
var field_ring: MeshInstance3D
var field_material: StandardMaterial3D
var field_label: Label3D
var rootkin_light: OmniLight3D
var bars: Array[MeshInstance3D] = []
var clock: float = 0.0

func _ready() -> void:
    position = Vector3(10.0,0.0,-17.0)
    field_ring = MeshInstance3D.new()
    field_ring.position.y = 0.03
    var disc := CylinderMesh.new()
    disc.top_radius = 2.1
    disc.bottom_radius = 2.1
    disc.height = 0.06
    field_ring.mesh = disc
    field_material = StandardMaterial3D.new()
    field_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    field_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    field_material.albedo_color = Color(0.35,0.6,0.6,0.12)
    field_ring.material_override = field_material
    add_child(field_ring)
    field_label = Label3D.new()
    field_label.position = Vector3(0.0,2.85,-1.0)
    field_label.font_size = 24
    field_label.pixel_size = 0.007
    field_label.modulate = Color("#d4decd")
    field_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    add_child(field_label)
    rootkin_light = OmniLight3D.new()
    rootkin_light.position = Vector3(-1.35,1.1,0.5)
    rootkin_light.light_color = Color("#9dbf91")
    rootkin_light.light_energy = 0.75
    rootkin_light.omni_range = 3.5
    add_child(rootkin_light)
    for i in range(4):
        var bar := MeshInstance3D.new()
        var mesh := BoxMesh.new()
        mesh.size = Vector3(0.08,0.8,0.08)
        bar.mesh = mesh
        var mat := StandardMaterial3D.new()
        mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
        mat.albedo_color = Color("#b7a16a")
        bar.material_override = mat
        bar.position = Vector3(-1.2+float(i)*0.8,0.5,1.9)
        add_child(bar)
        bars.append(bar)

func _process(delta: float) -> void:
    if not Game.has_attempt(): return
    var hearing: Dictionary = Game.state.get("hearing",{})
    if not bool(hearing.get("active",false)) and not bool(hearing.get("passed",false)):
        field_label.text = "PUBLIC LOANER / ROOTKIN / FIVE COMMANDS"
        field_material.albedo_color = Color(0.35,0.6,0.6,0.09)
        return
    clock += delta
    var remaining: int = int(hearing.get("integrity",31))
    var strain: int = int(hearing.get("strain_margin",46))
    var phase: String = Game.hearing_phase() if bool(hearing.get("active",false)) else "settled"
    var colour: Color = Color("#d6b46c")
    if phase == "shielded": colour = Color("#90b5b5")
    elif phase == "exposed": colour = Color("#dc8065")
    elif phase == "settled": colour = Color("#95ba8e")
    field_material.albedo_color = Color(colour.r,colour.g,colour.b,0.12 + 0.06 * sin(clock*2.2))
    var pressure_fraction: float = clampf(float(remaining)/31.0,0.05,1.0)
    field_ring.scale = Vector3(pressure_fraction,1.0,pressure_fraction)
    field_label.text = "FIELD %d / 31   ROOTKIN %d / 46   %s" % [remaining,strain,phase.to_upper()]
    rootkin_light.light_energy = 0.30 + 0.35*clampf(float(strain)/46.0,0.0,1.0)
    for i in range(bars.size()):
        var fraction: float = clampf((float(remaining)+float(i)*3.0)/31.0,0.08,1.0)
        bars[i].scale.y = fraction
