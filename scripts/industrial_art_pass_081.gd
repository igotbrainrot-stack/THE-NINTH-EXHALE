extends Node3D
## World props have no Sky/ReflectionProbe to reflect, so metallic above this
## renders near-black on the Compatibility renderer.
const WORLD_METALLIC_MAX: float = 0.2
## Build 08.1: district-specific procedural mesh art, not a new quest/collision layer.
## All geometry in this file is decorative; physical traversal remains governed by
## the existing district builder. No decisions, loot, or save keys are changed.
var district: String = "hearth"
var finishes: Dictionary = {}
var moving_parts: Array[Dictionary] = []
var clock: float = 0.0

func configure(zone: String) -> void:
    district = zone
    _build_finishes()
    match zone:
        "hearth": _hearth()
        "sootworks": _sootworks()
        "basilica": _basilica()
        "ashmarket": _ashmarket()
        "orchard": _orchard()
        "barracks": _barracks()
        "core": _core()
        "assembly": _assembly()
        "lift": _lift()
    set_process(not moving_parts.is_empty())

func _material(tint: Color, metal: float, rough: float, emissive: bool = false) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = tint
    mat.roughness = rough
    mat.metallic = minf(metal, WORLD_METALLIC_MAX)
    mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
    if emissive:
        mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
        mat.emission_enabled = true
        mat.emission = tint
        mat.emission_energy_multiplier = 1.3
    return mat

func _build_finishes() -> void:
    finishes = {
        "cast": _material(Color("#424d4c"), 0.64, 0.60),
        "edge": _material(Color("#84918b"), 0.60, 0.47),
        "copper": _material(Color("#9a6e4b"), 0.75, 0.53),
        "iron": _material(Color("#303634"), 0.45, 0.82),
        "ceramic": _material(Color("#b9b9a7"), 0.06, 0.89),
        "salt": _material(Color("#8cb8b4"), 0.24, 0.56),
        "glass": _material(Color("#5c9690"), 0.25, 0.27),
        "green": _material(Color("#617d59"), 0.12, 0.83),
        "paper": _material(Color("#b6a17b"), 0.02, 0.92),
        "rust": _material(Color("#934d39"), 0.16, 0.92),
        "amber": _material(Color("#f0a54f"), 0.0, 1.0, true),
        "mint": _material(Color("#83bdae"), 0.0, 1.0, true),
        "cold": _material(Color("#9dbfd4"), 0.0, 1.0, true),
        "dark": _material(Color("#121a1b"), 0.10, 0.92),
    }
    var authored_tiles: Dictionary = {
        "cast":"cast_iron_rivets_081",
        "edge":"cast_iron_rivets_081",
        "ceramic":"ward_crazed_enamel_081",
        "copper":"patinated_copper_081",
        "salt":"basilica_salt_wash_081",
        "rust":"oxidized_forge_081",
    }
    for finish_name in authored_tiles.keys():
        var finish: StandardMaterial3D = finishes[finish_name]
        finish.albedo_texture = load("res://assets/textures/architectural_081/%s.png" % authored_tiles[finish_name])
        finish.uv1_triplanar = true
        finish.uv1_scale = Vector3(0.60,0.60,0.60)
        finish.texture_repeat = true

func _box(tag: String, p: Vector3, s: Vector3, finish: String) -> MeshInstance3D:
    var part := MeshInstance3D.new()
    part.name = tag
    part.position = p
    var mesh := BoxMesh.new()
    mesh.size = s
    part.mesh = mesh
    part.material_override = finishes[finish]
    add_child(part)
    return part

func _cylinder(tag: String, p: Vector3, height: float, radius: float, finish: String, axis: String = "y", facets: int = 12) -> MeshInstance3D:
    var part := MeshInstance3D.new()
    part.name = tag
    part.position = p
    var mesh := CylinderMesh.new()
    mesh.height = height
    mesh.top_radius = radius
    mesh.bottom_radius = radius
    mesh.radial_segments = facets
    part.mesh = mesh
    part.material_override = finishes[finish]
    if axis == "x": part.rotation.z = PI * 0.5
    elif axis == "z": part.rotation.x = PI * 0.5
    add_child(part)
    return part

func _label(tag: String, p: Vector3, tint: Color = Color("#ead5aa")) -> void:
    var label := Label3D.new()
    label.name = "Painted civic marking"
    label.text = tag
    label.position = p
    label.pixel_size = 0.006
    label.font_size = 23
    label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    label.modulate = tint
    add_child(label)

func _lamp(p: Vector3, tint: Color, strength: float = 0.53) -> void:
    var emitter := OmniLight3D.new()
    emitter.position = p
    emitter.light_color = tint
    emitter.light_energy = strength
    emitter.omni_range = 4.4
    emitter.shadow_enabled = false
    add_child(emitter)

func _gauge(p: Vector3, front: String = "z") -> void:
    _cylinder("Brass dial bezel", p, 0.07, 0.27, "copper", front, 16)
    var offset := Vector3(0, 0, -0.05)
    if front == "x": offset = Vector3(-0.05,0,0)
    _cylinder("Ceramic pressure scale", p + offset, 0.025, 0.205, "ceramic", front, 16)
    if front == "z":
        var pointer := _box("Red pressure needle",p + Vector3(0.045,0,-0.079),Vector3(0.015,0.245,0.025),"rust")
        pointer.rotation.z = 0.68

func _pressure_bank(p: Vector3, title: String, type_color: String) -> void:
    _box("Riveted pressure board",p + Vector3(0,1.16,0),Vector3(2.7,2.35,0.25),"cast")
    _box("Recessed enamel fascia",p + Vector3(0,1.46,-0.15),Vector3(2.38,1.35,0.10),"ceramic")
    for i in range(3):
        _gauge(p + Vector3(-0.73 + float(i) * 0.73,1.74,-0.23))
        _box("Manual isolator slot",p + Vector3(-0.73 + float(i)*0.73,0.92,-0.23),Vector3(0.34,0.12,0.05),"iron")
    _box("Live pressure diode",p + Vector3(0,0.61,-0.21),Vector3(1.5,0.12,0.07),type_color)
    _label(title,p + Vector3(0,2.58,-0.22))

func _arch(p: Vector3, width: float, high: float, material: String, accent: String, title: String) -> void:
    # Arch crown is built from faceted wedges; keeps the 1990s low-poly silhouette.
    for side in [-1.0,1.0]:
        _box("Ribbed arch pier",p + Vector3(side * width * 0.5, high * 0.43,0),Vector3(0.42,high*0.86,0.6),material)
        for height_frac in [0.12,0.41,0.72]:
            _box("Arch pier band",p + Vector3(side*width*0.5,high*height_frac,-0.04),Vector3(0.53,0.14,0.73),accent)
    for i in range(7):
        var t := float(i)/6.0
        var x := (t-0.5)*width
        var crown_y := high - 0.50 + 0.50 * (1.0 - pow(absf(t-0.5)*2.0, 2.0))
        _box("Segmented load-bearing crown",p+Vector3(x,crown_y,0),Vector3(width/6.0+0.06,0.28,0.60),material)
    _label(title,p+Vector3(0,high+0.65,-0.24))

func _ribbed_tank(p: Vector3, height: float, width: float, label_text: String) -> void:
    _cylinder("Cast iron pressure vessel",p+Vector3(0,height*0.5,0),height,width,"cast","y",16)
    for y in [0.15,height*0.5,height-0.14]:
        _cylinder("Vessel clamp ring",p+Vector3(0,y,0),0.13,width+0.09,"copper","y",16)
    _cylinder("Pipe relief valve",p+Vector3(0,height+0.25,0),0.6,0.13,"edge")
    _gauge(p+Vector3(0,height*0.67,-width-0.07))
    _label(label_text,p+Vector3(0,height+0.65,0))

func _hearth() -> void:
    for i in range(3):
        _pressure_bank(Vector3(6.6+float(i)*6.2,0,-16.86),"AIR / %02d" % (i+1),"mint")
    for x in [-25.0,-21.0,-17.0]:
        _box("Ward oxygen service rail",Vector3(x,3.09,-17.55),Vector3(2.3,0.09,0.16),"edge")
        _cylinder("Hanging translucent treatment vessel",Vector3(x,2.38,-17.45),0.94,0.24,"glass")
        _cylinder("Breathing feed valve",Vector3(x,1.78,-17.45),0.28,0.10,"copper")
    _arch(Vector3(-18.5,0,2.85),5.6,3.0,"ceramic","copper","INTAKE AIRLOCK / STAFF ONLY")

func _sootworks() -> void:
    for z in [-18.0,-7.0,5.0,17.0]:
        _ribbed_tank(Vector3(22.6,0,z),3.15,0.65,"STATION / %02d" % int((z+18.0)/11.0+1.0))
        _cylinder("Furnace exhaust header",Vector3(21.55,3.58,z),2.05,0.15,"rust","z")
    for z in [-19.0,-13.5,-7.0,1.0,8.0,14.0,20.0]:
        _box("Worn treadplate seam",Vector3(6.7,0.024,z),Vector3(3.2,0.04,0.07),"rust")
    for z in [-17.0,0.0,17.0]:
        _box("Reciprocating piston housing",Vector3(22.8,2.60,z),Vector3(0.35,0.70,1.1),"edge")
        var rod := _cylinder("Live piston rod",Vector3(22.45,2.6,z),0.75,0.10,"copper","x")
        moving_parts.append({"node":rod,"base":rod.position,"axis":"x","phase":z*0.19,"amplitude":0.18,"rate":2.8})
    _label("CAUTION / PRESSURE ABOVE PAY",Vector3(12,3.0,21.8),Color("#edbb71"))

func _basilica() -> void:
    for z in [-17.0,-7.5,3.0,13.0]:
        _arch(Vector3(-23.6,0,z),3.2,3.45,"salt","copper","SIGNAL / %02d" % int((z+17.0)/10.0+1.0))
        _cylinder("Ritual bell rim",Vector3(-23.6,2.7,z),0.39,0.46,"copper")
        _cylinder("Tonal clapper",Vector3(-23.6,2.34,z),0.36,0.07,"ceramic")
    for x in [-18.0,-12.0,-6.0,0.0]:
        _box("Shallow brine channel",Vector3(x,0.021,22.1),Vector3(3.7,0.035,0.65),"glass")
        _box("Mineral seam edging",Vector3(x,0.047,21.66),Vector3(3.8,0.055,0.10),"ceramic")
    _label("KEEPER / THE SIGNAL IS NOT CONSENT",Vector3(11,3.25,-22.4))

func _ashmarket() -> void:
    for z in [-15.0,-4.0,7.0,16.0]:
        _cylinder("Hanging trade weight",Vector3(-15.0,2.3,z),0.68,0.18,"copper")
        _cylinder("Weight chain",Vector3(-15.0,3.2,z),1.36,0.025,"iron")
        for off in [-1.2,1.2]:
            _box("Awning embossed border",Vector3(-12.0+off,3.03,z),Vector3(0.15,0.08,2.2),"rust")
        _box("Ledger plaque",Vector3(-15.0,1.70,z),Vector3(0.09,0.65,0.92),"paper")
    _pressure_bank(Vector3(23.1,0,-11.0),"PRICE / OF RAIN","amber")
    _label("NO PERSON IS A TRANSFERABLE TITLE",Vector3(-5,3.3,-20.7))

func _orchard() -> void:
    for z in [-17.0,-8.0,0.5,9.0,17.0]:
        for x in [21.7,23.4]:
            _cylinder("Glass culture vat",Vector3(x,1.3,z),2.1,0.34,"glass")
            _cylinder("Culture vat base",Vector3(x,0.19,z),0.38,0.45,"cast")
            _cylinder("Culture vat clamp",Vector3(x,2.38,z),0.18,0.46,"edge")
            _cylinder("Suspended root stem",Vector3(x,1.27,z),1.32,0.043,"green")
        _box("Culture rank marker",Vector3(22.5,2.84,z),Vector3(1.4,0.14,0.3),"mint")
    _label("MEMORY IS NOT A CROP",Vector3(-2.0,3.15,-19.9))

func _barracks() -> void:
    for z in [-17.0,-8.0,1.0,10.0,17.0]:
        _box("Night watch armour shield",Vector3(23.7,1.6,z),Vector3(0.17,2.1,1.35),"cast")
        _box("Shield ceramic centre",Vector3(23.58,1.69,z),Vector3(0.09,1.65,0.70),"ceramic")
        _box("Enamel signal band",Vector3(23.51,2.38,z),Vector3(0.08,0.16,0.78),"amber")
        _cylinder("Fixed ration pipe",Vector3(23.3,3.25,z),1.45,0.11,"copper","z")
    _label("ORDERS REQUIRE NAMED WITNESSES",Vector3(-4,3.2,-19.0))

func _core() -> void:
    for x in [-17.0,-9.0,-1.0,7.0,15.0]:
        _cylinder("Vertical evidence coil",Vector3(x,2.0,-18.7),2.9,0.45,"cast")
        for j in range(6):
            _cylinder("Coil binding",Vector3(x,0.75+0.44*float(j),-18.7),0.09,0.52,"copper")
        _box("Attested indicator",Vector3(x,3.7,-18.76),Vector3(1.15,0.12,0.32),"cold")
    _label("THREE DISTINCT WRITS / NEVER THREE COPIES",Vector3(0,3.15,20.2))

func _assembly() -> void:
    for x in [-24.0,-16.0,-8.0,0.0,8.0,16.0,24.0]:
        _box("Civic gallery fluted pilaster",Vector3(x,2.55,-21.57),Vector3(0.38,3.95,0.3),"ceramic")
        _box("Gallery bronze capital",Vector3(x,4.27,-21.51),Vector3(0.78,0.22,0.38),"copper")
    for x in [-18.0,-11.0,-4.0,3.0,10.0]:
        _cylinder("Separate public speaking lamp",Vector3(x,2.24,-4.5),0.18,0.11,"mint")
        _cylinder("Public docket pedestal",Vector3(x,1.1,-4.5),2.2,0.05,"copper")
    for z in [9.0,13.0,17.0]:
        _box("Rail warning chevron",Vector3(21.2,0.029,z),Vector3(1.2,0.06,0.11),"amber")
    _label("STAGED IS NOT BOARDED",Vector3(15.0,3.3,19.1))

func _lift() -> void:
    for x in [-11.5,11.5]:
        _box("Freight lift vertical guide",Vector3(x,2.65,9.1),Vector3(0.25,5.0,0.35),"edge")
        for y in [0.7,1.55,2.4,3.25,4.1]:
            _box("Freight lift guide stop",Vector3(x,y,9.0),Vector3(0.45,0.09,0.55),"copper")
    _pressure_bank(Vector3(7.2,0,-10.7),"LIFT / FINITE LOAD","amber")

func _process(delta: float) -> void:
    clock += delta
    for part_data in moving_parts:
        var part: MeshInstance3D = part_data["node"]
        if not is_instance_valid(part): continue
        var pos: Vector3 = part_data["base"]
        var displacement: float = sin(clock*float(part_data["rate"])+float(part_data["phase"]))*float(part_data["amplitude"])
        if str(part_data["axis"]) == "x": pos.x += displacement
        else: pos.y += displacement
        part.position = pos
