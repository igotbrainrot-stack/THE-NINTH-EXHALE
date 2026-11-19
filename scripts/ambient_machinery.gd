extends Node3D
## Non-colliding ambient plant for existing areas. Rotation belongs to actual
## cylinder meshes, never to a billboarded chair or quest character.
var rotors: Array[Node3D] = []
var lamps: Array[OmniLight3D] = []
var phase: float = 0.0
var region: String = "hearth"

func _ready() -> void:
    var locations: Array[Vector3] = []
    match region:
        "sootworks": locations = [Vector3(-20,3.25,-18),Vector3(21,3.25,-17),Vector3(20,3.25,17)]
        "basilica": locations = [Vector3(-23,3.15,-10),Vector3(22,3.15,9),Vector3(-23,3.15,15)]
        "lift": locations = [Vector3(-11,3.2,-10),Vector3(11,3.2,10)]
        _: locations = [Vector3(-26,3.25,-10),Vector3(-26,3.25,0),Vector3(26,3.25,9)]
    # Build 08.1: authored finishes replace unlit default-grey test primitives.
    var rotor_iron := StandardMaterial3D.new()
    rotor_iron.albedo_color = Color("#495854")
    rotor_iron.metallic = 0.65
    rotor_iron.roughness = 0.56
    var rotor_copper := StandardMaterial3D.new()
    rotor_copper.albedo_color = Color("#9a714e")
    rotor_copper.metallic = 0.65
    rotor_copper.roughness = 0.59
    var rotor_guard := StandardMaterial3D.new()
    rotor_guard.albedo_color = Color("#738681")
    rotor_guard.metallic = 0.55
    rotor_guard.roughness = 0.63
    for i in range(locations.size()):
        var rotor := Node3D.new()
        rotor.name = "Visible working air rotor %d" % i
        rotor.position = locations[i]
        add_child(rotor)
        var stem := CylinderMesh.new()
        stem.top_radius = 0.11
        stem.bottom_radius = 0.11
        stem.height = 0.17
        var hub := MeshInstance3D.new()
        hub.mesh = stem
        hub.material_override = rotor_copper
        hub.rotation.x = PI * 0.5
        rotor.add_child(hub)
        for j in range(3):
            var blade := MeshInstance3D.new()
            var box := BoxMesh.new()
            box.size = Vector3(0.16,0.72,0.06)
            blade.mesh = box
            blade.material_override = rotor_iron
            blade.rotation.z = TAU * float(j) / 3.0
            blade.position = Vector3(-sin(blade.rotation.z)*0.28,cos(blade.rotation.z)*0.28,0)
            rotor.add_child(blade)
        # A stationary visible guard surrounds the moving vanes without any
        # physics barrier or moving collider.
        for side in [-1.0,1.0]:
            for horizontal in [true,false]:
                var brace := MeshInstance3D.new()
                brace.name = "Fixed rotor guard / bronze edge"
                var rail := BoxMesh.new()
                rail.size = Vector3(0.068,1.52,0.10) if not horizontal else Vector3(1.52,0.068,0.10)
                brace.mesh = rail
                brace.material_override = rotor_guard
                if horizontal: brace.position = locations[i] + Vector3(0,side*0.81,-0.10)
                else: brace.position = locations[i] + Vector3(side*0.81,0,-0.10)
                add_child(brace)
        rotors.append(rotor)
        var lamp := OmniLight3D.new()
        lamp.position = locations[i] + Vector3(0.45,0.12,0)
        lamp.light_color = Color("#b5d5b3") if region == "hearth" else Color("#d5a46b")
        lamp.light_energy = 0.16
        lamp.omni_range = 3.8
        add_child(lamp)
        lamps.append(lamp)

func _process(delta: float) -> void:
    phase += delta
    for index in range(rotors.size()):
        var rotor: Node3D = rotors[index]
        if is_instance_valid(rotor):
            rotor.rotation.z += delta * (1.7 if region == "sootworks" else 1.05)
        var light: OmniLight3D = lamps[index]
        if is_instance_valid(light): light.light_energy = 0.13 + 0.11 * (0.5 + 0.5*sin(phase*2.5+float(index)))
