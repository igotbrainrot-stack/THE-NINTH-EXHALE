extends Node3D
## BUILD 07.0 - Real, fixed-orientation 3D municipal furniture.
## Replaces 66 camera-facing/cardboard Sprite3D props. The same per-district
## silhouettes are reconstructed as spatially valid low-poly meshes; each face
## remains visible as the viewer walks around it. No new gameplay collision is
## introduced, preserving authored quest and traversal clearance.
const TEXTURES: Dictionary = {
    "linen":"res://assets/textures/ward_linen.png",
    "ward":"res://assets/textures/ward_enamel_v4.png",
    "iron":"res://assets/textures/furnace_iron.png",
    "metal":"res://assets/textures/requisition_steel.png",
    "stone":"res://assets/textures/basilica_stone_v4.png",
    "book":"res://assets/textures/basilica_paper.png"
}
var material: Dictionary = {}
var district: String = "hearth"
var profile: int = 1

func setup(region: String, index: int, size_factor: float = 1.0) -> void:
    district = region
    profile = index
    name = "3D municipal prop / %s / %02d" % [region,index]
    scale = Vector3.ONE * size_factor
    _prepare_materials()
    match region:
        "hearth": _hearth(index)
        "sootworks": _sootworks(index)
        "basilica": _basilica(index)
    set_meta("visual_kind", "fixed_3d_mesh")
    set_meta("prop_profile", "%s_%02d" % [region,index])

func apply_finish_variation(variation_key: int) -> void:
    # Authored physical props repeat, but their enamel tint/roughness and
    # oxidation should not look like 66 identical copies. Material is local
    # to each prop instance, so varying it never affects neighbouring meshes.
    var shade: float = float(posmod(variation_key * 17 + profile * 11, 13) - 6) / 105.0
    for id in ["frame","dark","enamel","linen","copper","wood","paper","rust","soot","stone"]:
        if not material.has(id): continue
        var finish: StandardMaterial3D = material[id]
        finish.albedo_color = finish.albedo_color.lerp(Color("#8c806d"), maxf(0.0,shade * 0.12))
        finish.albedo_color = finish.albedo_color * (1.0 + shade)
        finish.roughness = clampf(finish.roughness + shade * 0.58,0.35,0.96)

func _paint(colour: Color, metallic: float = 0.0, texture_path: String = "") -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = colour
    m.roughness = 0.81 if metallic < 0.35 else 0.55
    m.metallic = minf(metallic, 0.2) # see CHANGELOG: no reflection source, so high metallic renders black
    m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
    if texture_path != "" and ResourceLoader.exists(texture_path):
        m.albedo_texture = load(texture_path)
        m.uv1_triplanar = true
        m.uv1_scale = Vector3(0.42,0.42,0.42)
        m.texture_repeat = true
    return m

func _prepare_materials() -> void:
    material["frame"] = _paint(Color("#606d6b"),0.56,TEXTURES["metal"])
    material["dark"] = _paint(Color("#363d3c"),0.48,TEXTURES["iron"])
    material["enamel"] = _paint(Color("#b9bbb0"),0.13,TEXTURES["ward"])
    material["linen"] = _paint(Color("#d8d2be"),0.0,TEXTURES["linen"])
    material["copper"] = _paint(Color("#b17850"),0.70)
    material["rubber"] = _paint(Color("#252e2c"),0.0)
    material["wood"] = _paint(Color("#6b5543"),0.0)
    material["paper"] = _paint(Color("#d4bc85"),0.0,TEXTURES["book"])
    material["glass"] = _paint(Color("#5a8887"),0.16)
    material["rust"] = _paint(Color("#9b573c"),0.36)
    material["hazard"] = _paint(Color("#b38c3c"),0.38)
    material["soot"] = _paint(Color("#3a3231"),0.15)
    material["red"] = _paint(Color("#753f3c"),0.0)
    material["stone"] = _paint(Color("#829083"),0.06,TEXTURES["stone"])
    material["amber"] = _paint(Color("#d3a663"),0.06)

func _box(label: String, pos: Vector3, size: Vector3, finish: String, angle: Vector3 = Vector3.ZERO) -> MeshInstance3D:
    var model := MeshInstance3D.new()
    model.name = label
    model.position = pos
    model.rotation = angle
    var cube := BoxMesh.new()
    cube.size = size
    model.mesh = cube
    model.material_override = material[finish]
    add_child(model)
    return model

func _rod(label: String, pos: Vector3, length: float, radius: float, axis: String, finish: String) -> MeshInstance3D:
    var model := MeshInstance3D.new()
    model.name = label
    model.position = pos
    var bar := CylinderMesh.new()
    bar.height = length
    bar.top_radius = radius
    bar.bottom_radius = radius
    bar.radial_segments = 8
    model.mesh = bar
    model.material_override = material[finish]
    if axis == "x": model.rotation.z = PI / 2.0
    elif axis == "z": model.rotation.x = PI / 2.0
    add_child(model)
    return model

func _conic(label: String, pos: Vector3, length: float, low_radius: float, high_radius: float, axis: String, finish: String) -> void:
    var model := MeshInstance3D.new()
    model.name = label
    model.position = pos
    var cone := CylinderMesh.new()
    cone.height = length
    cone.bottom_radius = low_radius
    cone.top_radius = high_radius
    cone.radial_segments = 12
    model.mesh = cone
    model.material_override = material[finish]
    if axis == "x": model.rotation.z = PI / 2.0
    elif axis == "z": model.rotation.x = PI / 2.0
    add_child(model)

func _four_legs(width: float, depth: float, top: float, radius: float, finish: String = "frame") -> void:
    for x in [-width * 0.43,width * 0.43]:
        for z in [-depth * 0.42,depth * 0.42]:
            _rod("Structural leg",Vector3(x,top * 0.5,z),top,radius,"y",finish)

func _wheel(x: float, y: float, z: float, r: float = 0.13) -> void:
    _rod("Caster wheel",Vector3(x,y,z),r * 0.75,r,"x","rubber")
    _rod("Wheel axle",Vector3(x,y,z),r * 1.12,r * 0.28,"x","frame")

func _gauge(pos: Vector3, radius: float = 0.16) -> void:
    _rod("Gauge outer rim",pos,0.09,radius,"z","copper")
    _rod("Ivory gauge face",pos + Vector3(0,0,0.053),0.02,radius * 0.76,"z","paper")
    _box("Red needle",pos + Vector3(0.035,0.02,0.07),Vector3(radius * 0.7,0.025,0.017),"red",Vector3(0,0,0.52))
    _rod("Gauge spindle",pos + Vector3(0,0,0.081),0.03,0.024,"z","dark")

func _crate(pos: Vector3, dim: Vector3, finish: String = "wood") -> void:
    _box("Supplies crate",pos,dim,finish)
    _box("Crate top band",pos + Vector3(0,dim.y * 0.40,0),Vector3(dim.x + 0.035,0.065,dim.z + 0.035),"rust")
    _box("Crate bottom band",pos - Vector3(0,dim.y * 0.4,0),Vector3(dim.x + 0.035,0.065,dim.z + 0.035),"frame")
    _box("Crate vertical strap",pos + Vector3(0,0,dim.z * 0.51),Vector3(0.07,dim.y + 0.035,0.03),"copper")

func _bench(back: bool = true, length: float = 1.55, pew: bool = false) -> void:
    var finish: String = "wood" if pew else "rust"
    _box("Actual solid seat",Vector3(0,0.55,0),Vector3(length,0.13,0.64),finish)
    for x in [-length * 0.43,length * 0.43]:
        _box("Bench foot",Vector3(x,0.26,0.03),Vector3(0.13,0.52,0.65),"frame" if not pew else "wood")
        _box("Arm rail",Vector3(x,0.82,-0.10),Vector3(0.13,0.10,0.75),"frame" if not pew else "copper")
    if back:
        _box("Actual solid seatback",Vector3(0,0.96,0.32),Vector3(length,0.70,0.14),finish,Vector3(-0.11,0,0))
        for x in [-length * 0.44,length * 0.44]:
            _box("Back frame",Vector3(x,0.93,0.35),Vector3(0.11,0.86,0.17),"frame")
    if not pew:
        for x in [-length * 0.26,0.0,length * 0.26]:
            _box("Worn seat cushion",Vector3(x,0.65,-0.04),Vector3(length * 0.29,0.11,0.49),"red")

func _work_table(width: float = 1.78, depth: float = 0.75, height: float = 0.88) -> void:
    _box("Physical worktop",Vector3(0,height,0),Vector3(width,0.14,depth),"wood")
    _four_legs(width,depth,height - 0.12,0.08)
    _box("Table lower brace",Vector3(0,0.3,0),Vector3(width * 0.91,0.08,depth * 0.78),"dark")
    _box("Tool drawer",Vector3(0,height - 0.19,-depth * 0.31),Vector3(width * 0.36,0.27,0.14),"frame")
    _box("Drawer pull",Vector3(0,height - 0.20,-depth * 0.40),Vector3(0.17,0.035,0.03),"copper")

func _cabinet(width: float = 1.2, height: float = 1.9, depth: float = 0.55) -> void:
    _box("Full-depth locker shell",Vector3(0,height * 0.5 + 0.08,0),Vector3(width,height,depth),"enamel")
    _box("Rear panel",Vector3(0,height * 0.5 + 0.08,depth * 0.51),Vector3(width, height, 0.045),"dark")
    for side in [-1.0,1.0]:
        _box("Recessed door",Vector3(side * width * 0.255,height * 0.51 + 0.08,-depth * 0.52),Vector3(width * 0.475,height * 0.91,0.06),"frame")
        _box("Door handle",Vector3(side * width * 0.06,1.1,-depth * 0.58),Vector3(0.035,0.22,0.045),"copper")
        _box("Door information plate",Vector3(side * width * 0.255,height * 0.78,-depth * 0.56),Vector3(width * 0.23,0.1,0.02),"paper")
        for k in range(3):
            _box("Door louvre",Vector3(side * width * 0.255,0.5 + 0.12 * k,-depth * 0.565),Vector3(width * 0.24,0.035,0.018),"dark")
    for x in [-width * 0.44,width * 0.44]:
        _box("Cabinet feet",Vector3(x,0.055,0),Vector3(0.14,0.11,depth * 0.86),"dark")

func _console() -> void:
    _box("Full depth industrial control plinth",Vector3(0,0.65,0.09),Vector3(1.15,1.30,0.72),"dark")
    _box("Tactile angled control lid",Vector3(0,1.35,-0.12),Vector3(1.23,0.13,0.76),"frame",Vector3(-0.38,0,0))
    for x in [-0.36,0.0,0.36]:
        _gauge(Vector3(x,1.42,-0.44),0.13)
        _box("Red action switch",Vector3(x,1.18,-0.45),Vector3(0.10,0.07,0.08),"red")
    _box("Maintenance access grille",Vector3(0,0.61,-0.31),Vector3(0.8,0.38,0.03),"enamel")
    for x in [-0.3,-0.15,0.0,0.15,0.3]:
        _box("Cooling grille slots",Vector3(x,0.61,-0.33),Vector3(0.055,0.3,0.015),"dark")
    _box("Caution lower lip",Vector3(0,0.13,-0.25),Vector3(1.2,0.12,0.18),"hazard")

func _pipe_cluster() -> void:
    for i in range(5):
        var x: float = -0.37 + 0.185 * float(i)
        _rod("Brass pressure pipe",Vector3(x,0.86,0.07),1.55,0.07,"y","copper" if i % 2 == 0 else "frame")
        _rod("Pipe valve nut",Vector3(x,0.36,0.10),0.14,0.15,"z","dark")
    _box("Pipe wall shroud",Vector3(0,0.95,0.25),Vector3(1.05,1.85,0.11),"dark")
    _gauge(Vector3(0.18,1.32,-0.16),0.22)
    _box("Lateral pressure handle",Vector3(-0.28,0.64,-0.20),Vector3(0.46,0.07,0.07),"red")

func _box_stack() -> void:
    _crate(Vector3(0,0.37,0),Vector3(1.05,0.72,0.72),"frame")
    _crate(Vector3(-0.2,1.01,0.12),Vector3(0.64,0.50,0.62),"wood")
    _crate(Vector3(0.28,1.02,-0.13),Vector3(0.47,0.49,0.47),"wood")
    _box("Strapped cargo linen",Vector3(-0.18,1.3,0.16),Vector3(0.5,0.09,0.36),"linen")

func _hearth(index: int) -> void:
    match index:
        1:
            _four_legs(2.1,0.95,0.51,0.06)
            _box("Medical bed lower chassis",Vector3(0,0.48,0),Vector3(2.1,0.18,0.94),"frame")
            _box("Linen mattress with real thickness",Vector3(0,0.65,0),Vector3(1.98,0.18,0.86),"linen")
            _box("Bed blanket with folded edge",Vector3(0.40,0.77,0),Vector3(0.82,0.09,0.87),"glass")
            _box("Separate pillow",Vector3(-0.74,0.77,0),Vector3(0.42,0.11,0.7),"paper")
            for z in [-0.42,0.42]:
                _rod("Gurney side rail",Vector3(0,0.91,z),1.91,0.036,"x","copper")
            for x in [-1.04,1.04]:
                _box("Welded gurney upright",Vector3(x,0.88,0),Vector3(0.065,0.62,0.9),"frame")
                for z in [-0.40,0.40]:_wheel(x * 0.88,0.11,z)
        2:
            for x in [-0.95,0.0,0.95]:
                _box("Folding privacy screen",Vector3(x,1.05,0),Vector3(0.9,1.58,0.07),"linen",Vector3(0,x * 0.1,0))
                for off in [-0.42,0.42]:
                    _rod("Screen frame",Vector3(x + off,1.08,0),1.89,0.03,"y","copper")
                _rod("Screen top",Vector3(x,2.02,0),0.91,0.035,"x","frame")
                _wheel(x - 0.37,0.10,0)
                _wheel(x + 0.37,0.10,0)
        3:
            _four_legs(1.3,0.68,1.45,0.048)
            for y in [0.42,0.9,1.42]:
                _box("Medicine cart metal tray",Vector3(0,y,0),Vector3(1.4,0.08,0.74),"enamel")
            for x in [-0.52,0.52]:
                for z in [-0.25,0.25]: _wheel(x,0.10,z,0.10)
            for x in [-0.38,-0.08,0.24,0.43]:
                _rod("Supply bottle",Vector3(x,1.60,0.10),0.28,0.09,"y","glass")
            _box("Docket paper stack",Vector3(-0.20,1.49,-0.22),Vector3(0.36,0.07,0.26),"paper")
        4:_box_stack()
        5:_cabinet(1.32,1.94,0.62)
        6:_pipe_cluster()
        7:_bench(true,1.95)
        8:
            _rod("IV stand spindle",Vector3(0,1.06,0),2.0,0.035,"y","frame")
            for theta in [0.0,2.09,4.19]:
                var off := Vector3(cos(theta) * 0.40,0.10,sin(theta) * 0.40)
                _rod("Caster foot",Vector3(off.x * 0.5,0.12,off.z * 0.5),0.68,0.026,"x","frame")
                _wheel(off.x,0.10,off.z,0.10)
            _rod("Support hook",Vector3(0.0,2.03,0),0.62,0.035,"x","copper")
            _rod("Hanging glass bottle",Vector3(0.23,1.72,0),0.38,0.095,"y","glass")
            _rod("Fluid feed tube",Vector3(0.23,1.33,0),0.4,0.018,"y","rubber")
        9:
            _work_table(1.72,0.86,0.83)
            _cabinet(0.50,0.60,0.55)
            _box("Desk ledger",Vector3(-0.33,0.97,-0.08),Vector3(0.53,0.07,0.35),"paper")
            _rod("Task lamp upright",Vector3(0.58,1.16,0.1),0.56,0.028,"y","copper")
            _conic("Task lamp shade",Vector3(0.58,1.48,0.1),0.24,0.05,0.19,"y","enamel")

func _sootworks(index: int) -> void:
    match index:
        1:
            _work_table(1.95,0.88,0.9)
            _box("Riveter jig",Vector3(-0.28,1.05,0),Vector3(0.58,0.24,0.30),"rust")
            _rod("Forging tool barrel",Vector3(0.38,1.08,0.04),0.61,0.12,"x","copper")
            _box("Sooty paper docket",Vector3(0.0,1.00,-0.27),Vector3(0.3,0.03,0.18),"paper")
        2:_cabinet(1.38,2.0,0.65)
        3:_console()
        4:
            _box("Pallet",Vector3(0,0.09,0),Vector3(1.5,0.18,0.95),"wood")
            for row in range(3):
                for n in range(3 - row):
                    _box("Actual stacked furnace ingot",Vector3(-0.4 + 0.45 * float(n) + 0.21 * float(row),0.28 + 0.18 * float(row),0.0),Vector3(0.40,0.16,0.65),"frame" if n % 2 else "rust")
        5:
            for x in [-0.46,0.46]:
                _box("Steel pipe rack",Vector3(x,0.39,0),Vector3(0.10,0.78,0.76),"frame")
            for height in [0.34,0.70]:
                for z in [-0.23,0.0,0.23]:
                    _rod("Full cylindrical pipe stock",Vector3(0,height,z),1.15,0.14,"x","frame")
                    _rod("Tube seam collar",Vector3(0.46,height,z),0.04,0.15,"x","copper")
        6:
            for x in [-0.89,0.89]:
                _rod("Freestanding safety post",Vector3(x,0.61,0),1.13,0.08,"y","hazard")
                _box("Post foot",Vector3(x,0.10,0),Vector3(0.32,0.20,0.32),"frame")
            for y in [0.38,0.78,1.08]:
                _rod("Rail",Vector3(0,y,0),1.95,0.05,"x","hazard")
            for x in [-0.65,-0.24,0.17,0.58]:
                _box("Caution diagonal band",Vector3(x,0.79,-0.06),Vector3(0.12,0.64,0.03),"dark",Vector3(0,0,-0.45))
        7:
            _box("Coal hopper body",Vector3(0,0.65,0),Vector3(1.47,1.15,0.98),"rust")
            _four_legs(1.38,0.94,0.5,0.08)
            for x in [-0.50,-0.12,0.28,0.52]:
                for z in [-0.28,0.06,0.31]:
                    _box("Individual soot ore",Vector3(x,1.31 + absf(x) * 0.15,z),Vector3(0.28,0.23,0.25),"soot",Vector3(0.1,0.05,0.18))
        8:
            _box("Lifting hoist housing",Vector3(0,1.78,0),Vector3(1.1,0.72,0.78),"hazard")
            _rod("Wound chain cable reel",Vector3(0,1.76,0.43),0.6,0.31,"z","copper")
            for i in range(8):
                _rod("Heavy chain link",Vector3(0,1.33 - 0.13 * float(i),0),0.11,0.024,"y","frame")
            _conic("Lower forged tow hook",Vector3(0,0.22,0),0.34,0.13,0.03,"y","dark")
        9:
            _cabinet(1.45,1.62,0.74)
            for i in range(4):
                _box("Archive indexing drawer",Vector3(0.0,0.37 + 0.32 * float(i),-0.42),Vector3(1.2,0.23,0.06),"rust")
                _box("Drawer pull bar",Vector3(0.0,0.38 + 0.32 * float(i),-0.47),Vector3(0.33,0.045,0.04),"copper")

func _basilica(index: int) -> void:
    match index:
        1:
            _box("Choir cylinder cabinet",Vector3(0,0.9,0),Vector3(1.6,1.75,0.73),"stone")
            for i in range(3):
                _rod("Playable evidence recorder roll",Vector3(-0.48 + float(i) * 0.48,1.06,-0.39),0.6,0.17,"x","copper")
            _rod("Civic indicator crown",Vector3(0,1.82,0),0.92,0.11,"x","copper")
            _gauge(Vector3(0.58,1.56,-0.43),0.15)
        2:
            _four_legs(0.7,0.7,0.63,0.055,"wood")
            _rod("Acoustic horn riser",Vector3(0,0.93,0),0.73,0.065,"y","copper")
            _conic("Gramophone civic horn",Vector3(0,1.52,0.10),0.73,0.09,0.47,"z","copper")
            _box("Horn base",Vector3(0,0.45,0),Vector3(0.73,0.18,0.72),"wood")
        3:_bench(true,1.8,true)
        4:
            _work_table(1.4,0.78,0.92)
            _box("Public hymn pages",Vector3(-0.18,1.03,-0.08),Vector3(0.52,0.03,0.38),"paper")
            _rod("Lamp pole",Vector3(0.45,1.33,0.18),0.68,0.028,"y","copper")
            _conic("Lantern hood",Vector3(0.45,1.64,0.18),0.26,0.06,0.19,"y","copper")
            _box("Lectern face",Vector3(0.0,0.69,-0.38),Vector3(1.28,0.60,0.11),"wood")
        5:
            _box("Municipal flood pump",Vector3(0,0.43,0),Vector3(1.29,0.75,0.72),"stone")
            _rod("Power shaft",Vector3(0.12,0.83,-0.06),0.70,0.26,"x","frame")
            _rod("Water outlet",Vector3(-0.61,0.49,0),0.82,0.22,"x","copper")
            _rod("Flood manual handle",Vector3(0.10,1.24,-0.05),0.52,0.06,"y","copper")
            _gauge(Vector3(0.33,1.03,-0.50),0.18)
        6:
            _box("Civic records pedestal",Vector3(0,0.73,0),Vector3(0.65,1.45,0.56),"stone")
            _box("Record lectern top",Vector3(0,1.51,-0.08),Vector3(0.92,0.13,0.68),"copper",Vector3(-0.28,0,0))
            _box("Scroll case",Vector3(0,1.56,-0.03),Vector3(0.53,0.22,0.22),"wood")
            _box("Document in locked holder",Vector3(0,1.67,-0.21),Vector3(0.42,0.04,0.29),"paper")
        7:
            _console()
            for row in range(2):
                for col in range(4):
                    _rod("Small resonance valve",Vector3(-0.40 + 0.25 * float(col),1.52 + 0.22 * float(row),0.07),0.21,0.06,"y","copper")
                    _box("Small acoustic signal",Vector3(-0.40 + 0.25 * float(col),1.70 + 0.20 * float(row),-0.04),Vector3(0.14,0.08,0.12),"amber")
        8:
            _box("Archive shelf frame",Vector3(0,1.0,0),Vector3(1.45,2.03,0.58),"wood")
            for y in [0.45,0.97,1.51]:
                _box("Full depth wooden shelf",Vector3(0,y,-0.20),Vector3(1.35,0.07,0.57),"copper")
                for j in range(6):
                    _box("Individual bound ledger",Vector3(-0.53 + 0.19 * float(j),y + 0.21,-0.28),Vector3(0.13,0.36 + 0.04 * float(j % 3),0.25),"paper" if j % 3 == 0 else "wood")
        9:
            for x in [-0.75,0.75]:
                _rod("Public queue stanchion",Vector3(x,0.51,0),0.92,0.06,"y","copper")
                _rod("Heavy stanchion foot",Vector3(x,0.09,0),0.14,0.23,"y","stone")
                _rod("Ball end finial",Vector3(x,1.04,0),0.20,0.11,"y","copper")
            for n in range(7):
                var t: float = float(n) / 6.0
                _rod("Actual 3D chain catenary",Vector3(lerpf(-0.73,0.73,t),0.83 - 0.26 * sin(PI*t),0.0),0.21,0.022,"x","copper")
