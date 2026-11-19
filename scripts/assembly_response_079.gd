extends Node3D
## A physical visualizer of already recorded civic facts; not invented crowd,
## testimony, passengers or votes. Lights respond to actual save-state facts.
var board_lights: Dictionary = {}
var board_labels: Dictionary = {}
var rail_tokens: Dictionary = {}
var mandate_lamp: OmniLight3D
var audit_clock: float = 0.0
const GROUPS: Array[String] = ["clinic","labour","choir","market","growth","defence"]
const COHORTS: Array[String] = ["patients","families","crews","claimant"]

func _ready() -> void:
    name = "Visible constituency accountability and staged—not boarded—rail manifest"
    for i in range(GROUPS.size()):
        var group: String = GROUPS[i]
        var assembly_x: float = -21.0 + 7.0*float(i)
        var status_marker := MeshInstance3D.new()
        var housing := BoxMesh.new()
        housing.size = Vector3(0.65,0.42,0.25)
        status_marker.mesh = housing
        status_marker.position = Vector3(assembly_x,2.25,-3.5)
        var light_mat := StandardMaterial3D.new()
        light_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
        status_marker.material_override = light_mat
        add_child(status_marker)
        board_lights[group] = status_marker
        var label := Label3D.new()
        label.position = Vector3(assembly_x,2.82,-3.5)
        label.font_size = 19
        label.pixel_size = 0.005
        label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
        label.modulate = Color("#d8d4bf")
        add_child(label)
        board_labels[group] = label
    for i in range(COHORTS.size()):
        var key: String = COHORTS[i]
        var token := MeshInstance3D.new()
        var packet := BoxMesh.new()
        packet.size = Vector3(1.0,0.3,0.25)
        token.mesh = packet
        var material := StandardMaterial3D.new()
        material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
        material.albedo_color = Color("#d9b875")
        token.material_override = material
        token.position = Vector3(9.0+float(i)*2.1,1.65,18.1)
        add_child(token)
        rail_tokens[key] = token
    mandate_lamp = OmniLight3D.new()
    mandate_lamp.position = Vector3(0.0,2.9,-13.5)
    mandate_lamp.light_color = Color("#b97d51")
    mandate_lamp.light_energy = 0.6
    mandate_lamp.omni_range = 7.0
    add_child(mandate_lamp)
    _refresh()

func _process(delta: float) -> void:
    audit_clock += delta
    if audit_clock >= 0.18:
        audit_clock = 0.0
        _refresh()

func _refresh() -> void:
    if not Game.has_attempt() or str(Game.state.get("zone","")) != "assembly": return
    var civic: Dictionary = Game.state.get("civic",{})
    var votes: Dictionary = civic.get("votes",{})
    for group in GROUPS:
        var supported: bool = Game.assembly_support_078(group)
        var recorded: bool = bool(votes.get(group,false)) and supported
        var display: MeshInstance3D = board_lights[group]
        var material: StandardMaterial3D = display.material_override as StandardMaterial3D
        material.albedo_color = Color("#95ce9d") if recorded else (Color("#e0b46f") if supported else Color("#724d43"))
        var label: Label3D = board_labels[group]
        label.text = "%s / %s" % [group.to_upper(),"ATTESTED" if recorded else ("UNSIGNED" if supported else "NO VALID TESTIMONY")]
    for key in COHORTS:
        var staged: bool = bool(civic.get("staged_groups",{}).get(key,false))
        var token: MeshInstance3D = rail_tokens[key]
        token.visible = staged
    if bool(civic.get("mandate_revoked",false)):
        mandate_lamp.light_color = Color("#d05e4f")
        mandate_lamp.light_energy = 1.15
    elif bool(civic.get("mandate",false)):
        mandate_lamp.light_color = Color("#90caa4")
        mandate_lamp.light_energy = 1.10
    else:
        mandate_lamp.light_color = Color("#c3a36d")
        mandate_lamp.light_energy = 0.50
