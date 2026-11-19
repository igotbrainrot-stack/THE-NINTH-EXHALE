extends "res://scripts/world_builder.gd"
## The Flood Basilica is a working flooded signal/ritual institution. 
## All core stations are physically placed and use actual 3D colliders.
const OssaActor = preload("res://scripts/ossa_actor.gd")
const AnimatedEchoform068 = preload("res://scripts/animated_echoform_068.gd")

func build() -> void:
    make_material("ceiling", Color("#ffffff"), "ward_ceiling_v3")
    make_material("floor", Color("#6f7972"), "basilica_floor_v3")
    make_material("ward", Color("#a5aaa0"), "basilica_stone_v4")
    make_material("requisition", Color("#6a8582"), "basilica_copper")
    make_material("chart", Color("#d4d4be"), "basilica_paper")
    make_material("dark", Color("#385450"), "basilica_copper")
    make_material("red", Color("#9b5d4d"), "hazard_ochre_v2")
    make_material("accent", Color("#bdad84"), "")
    # 52 x 48 metres; public walkway at y=0. Water is visually shallow, not a collision trap.
    solid_box("Basilica foundations",Vector3(0,-0.32,0),Vector3(52,0.64,48),"floor")
    solid_box("North choir retaining wall",Vector3(0,2.4,-24),Vector3(52,4.8,0.8),"ward")
    solid_box("South public registers",Vector3(0,2.4,24),Vector3(52,4.8,0.8),"requisition")
    solid_box("East keeper signal wall",Vector3(26,2.4,0),Vector3(0.8,4.8,48),"dark")
    solid_box("West railway bulkhead",Vector3(-26,2.4,0),Vector3(0.8,4.8,48),"requisition")
    # Bell-governor chamber to the east, with a permanent 8 m middle passage.
    # An optional side nave opening bypasses the central signal lane.
    solid_box("Lay partition N / upper",Vector3(2,2.2,-21),Vector3(0.9,4.4,6),"requisition")
    solid_box("Lay partition N / lower",Vector3(2,2.2,-9),Vector3(0.9,4.4,6),"requisition")
    if not bool(Game.state.get("fun_slice",{}).get("basilica_side_open",false)):
        var choir_gate := solid_box("Choir side passage shutter",Vector3(2,1.42,-15),Vector3(0.8,2.84,5.5),"dark")
        choir_gate.add_to_group("basilica_shortcut_shutter")
    solid_box("Lay public partition south",Vector3(2,2.2,15),Vector3(0.9,4.4,18),"requisition")
    solid_box("Signal channel header",Vector3(2,4.0,0),Vector3(0.9,0.7,12),"dark")
    var cover_variant: int = int(Game.state.get("fun_slice",{}).get("seed_variant",0))
    if cover_variant == 0:
        solid_box("Waterproof papers / seed 0",Vector3(9,0.50,-5),Vector3(1.3,1.0,1.6),"chart")
    elif cover_variant == 1:
        solid_box("Acoustic shutter stack / seed 1",Vector3(14,0.62,7),Vector3(1.6,1.24,1.4),"dark")
    else:
        solid_box("Damp service equipment / seed 2",Vector3(10,0.65,7),Vector3(1.8,1.30,1.2),"requisition")
    # Nonblocking public alcoves, practical nave furnishings and drying shelves.
    for z in [-16.5,-10.5,-4.5,4.5,10.5,16.5]:
        solid_box("Damp bench left %s" % z,Vector3(-15,0.43,z),Vector3(2.6,0.86,1.1),"ward")
    solid_box("Repair drying rack",Vector3(-23,0.9,-12),Vector3(1.1,1.8,4.2),"chart")
    solid_box("Flood depth marker",Vector3(-23,0.6,14),Vector3(1.0,1.2,2.2),"dark")
    solid_box("North signal barricade",Vector3(18,0.7,-15),Vector3(4.6,1.4,1.4),"dark")
    solid_box("South signal barricade",Vector3(19,0.7,16),Vector3(4.6,1.4,1.4),"requisition")
    solid_box("Old governor housing",Vector3(23,1.0,-9),Vector3(2.5,2,3.1),"dark")
    if Game.has_attempt() and bool(Game.state.get("ossa",{}).get("alive",true)):
        var ossa := OssaActor.new()
        ossa.name = "Sister Ossa"
        var decision: String = str(Game.state.get("ossa",{}).get("decision",""))
        if decision == "help":
            ossa.position = Vector3(-14,0,-13)
        elif decision == "exploit":
            ossa.position = Vector3(-21,0,17)
        elif decision == "abandon":
            ossa.position = Vector3(-16,0,-17)
        else:
            ossa.position = Vector3(-19,0,5)
        add_child(ossa)
    add_actor("Lay Council Attendant","faith_clerk",Vector3(-10,0,-7),"clerk.png","LAY COUNCIL / PUBLIC REGISTER")
    add_console("Original hymn governor reel","hymn_reel",Vector3(-22,0,-17),"ARCHIVE / SIXTH NOTE")
    add_console("Lay council assembly","faith_council",Vector3(-8,0,-18),"CONGREGATION / FREE VOTE")
    add_console("Bell governor isolator","basilica_signal",Vector3(20,0,4),"POWERED SIGNAL / TECH 5")
    add_console("Cantor orders kiosk","cantor_order",Vector3(9,0,18),"KEEPER / CONTROL SIGNAL")
    add_console("Faith Writ public wicket","faith_registry",Vector3(-22,0,15),"FAITH / FOUNDING WRIT")
    add_console("Independent choir counter-record", "basilica_notes", Vector3(7.7,0,-15.4), "LAY ARCHIVE / HEAR THE ORIGINAL PATTERN")
    add_console("Flood defence issue","basilica_locker",Vector3(-5,0,-10),"EMERGENCY RATION / FINITE")
    add_console("Transfer to Hearth Nine","hearth_return",Vector3(-22,0,21),"SERVICE RAIL / HEARTH NINE")
    add_transition_frame("Hearth Nine rail gate", Vector3(-22,0,23.55), 3.7, 3.0, "rail", "HEARTH NINE", "SERVICE RAIL")
    add_console("Transfer to Sootworks","sootworks_transfer",Vector3(-17,0,21),"SERVICE RAIL / SOOTWORKS")
    add_transition_frame("Sootworks rail gate", Vector3(-17,0,23.55), 3.7, 3.0, "rail", "SOOTWORKS", "FOUNDRY RAIL")
    add_console("Service rail / Ashmarket", "ashmarket_transfer", Vector3(-9,0,19), "ASHMARKET / TRADE OFFICE")
    add_transition_frame("Ashmarket rail gate", Vector3(-9,0,23.55), 3.7, 3.0, "rail", "ASHMARKET", "TRADE OFFICE")
    # Hearing is a spatially anchored civic instrument with an active creature and opponent.
    add_console("Public interference hearing","hearing_station",Vector3(10,0,-17),"CIVIC HEARING / ROOTKIN LOANER")
    add_console("Lay-choir side latch", "basilica_side_passage", Vector3(-3,0,-19), "E / OPEN CHOIR SIDE PASSAGE")
    add_console("Resonator service dial", "basilica_resonator", Vector3(-21,0,0), "E / INSPECT SIGNAL RHYTHM")
    _make_hearing_field()
    signboard("FLOOD BASILICA / THE CHOIR ALSO REPAIRS THE PUMPS",Vector3(-10,3.6,-22.6))
    signboard("FAITH OFFICE / FREE WORSHIP, CONTESTED ORDERS",Vector3(-11,3.7,22.5))
    signboard("HEARING / NOT AN OWNERSHIP CONTEST",Vector3(15,3.65,-22.1))
    if Game.has_attempt() and str(Game.state.get("ossa",{}).get("decision","")) == "help":
        var choir_light := OmniLight3D.new()
        choir_light.name = "Free choir / independent lamps"
        choir_light.position = Vector3(-10,3.0,-2)
        choir_light.light_color = Color("#91d0bc")
        choir_light.light_energy = 1.9
        choir_light.omni_range = 9
        add_child(choir_light)
        signboard("CHOIR / UNAMPLIFIED CONSENT",Vector3(-10,2.6,-4))
    # The nave visibly responds to independently recorded evidence and Ossa's
    # actual decision, never an assumed consensus or invented testimony.
    var hymn_seen: bool = bool(Game.state.get("ossa",{}).get("hymn_seen",false))
    var resolution: String = str(Game.state.get("ossa",{}).get("decision",""))
    var record_plate := solid_box("Original hymn / protected physical reel",Vector3(-22,0.9,-19.1),Vector3(1.35,0.18,0.75),"chart" if hymn_seen else "dark")
    record_plate.set_meta("surface_kind","wood" if hymn_seen else "metal")
    if hymn_seen:
        signboard("ORIGINAL REEL PRESERVED / SIXTH NOTE",Vector3(-19.2,2.6,-19.6))
    if resolution == "help":
        for z in [-7.0,-2.0,3.0]:
            var witness_lamp := OmniLight3D.new()
            witness_lamp.name = "Independent choir / consent lamp"
            witness_lamp.position = Vector3(-11,2.5,z)
            witness_lamp.light_color = Color("#8acdb9")
            witness_lamp.light_energy = 0.75
            witness_lamp.omni_range = 4.5
            add_child(witness_lamp)
        signboard("LAY CHOIR / SIGNAL GOVERNOR SILENCED",Vector3(-10,2.7,4))
    elif resolution == "exploit":
        solid_box("Coercive signal / retained order stand",Vector3(-7,0.55,9),Vector3(1.8,1.1,1.1),"red")
        signboard("BELL GOVERNOR / SIGNAL STILL CONTESTED",Vector3(-9,2.7,8))
    elif resolution == "abandon":
        signboard("LAY COUNCIL / APPEAL LEFT UNRESOLVED",Vector3(-11,2.7,5))
    _decorate_flood()
    var props := preload("res://scripts/art_detail.gd").new()
    props.name = "Basilica everyday civic furniture"
    add_child(props)
    props.prepare(material_cache)
    props.decorate_population("basilica")
    for pos in [Vector3(-17,3.8,-12),Vector3(-11,3.8,10),Vector3(17,3.7,-10),Vector3(17,3.7,12)]:
        var lamp := OmniLight3D.new()
        lamp.position = pos
        lamp.light_color = Color("#a6c8c1") if pos.x < 0 else Color("#dfc397")
        lamp.light_energy = 1.35
        lamp.omni_range = 19
        add_child(lamp)

func _make_hearing_field() -> void:
    # Visible pressure ring and two separate organisms. No prize capture, no elemental ring.
    # Field is decorative so the mandatory fallback route cannot become blocked.
    var platform := MeshInstance3D.new()
    platform.name = "Hearing field / signal insulation"
    platform.position = Vector3(16,0.025,-12.5)
    var cylinder := CylinderMesh.new()
    cylinder.top_radius = 3.1
    cylinder.bottom_radius = 3.1
    cylinder.height = 0.05
    platform.mesh = cylinder
    var material := StandardMaterial3D.new()
    material.albedo_color = Color("#466d6c")
    material.roughness = 0.8
    platform.material_override = material
    add_child(platform)
    _field_sprite("PUBLIC ROOTKIN / LOANER", "rootkin.png",Vector3(14.5,0,-12.5),0.019)
    _field_sprite("BELL WRETCH / FIELD OPPOSITION","bell_wretch.png",Vector3(17.5,0,-12.5),0.018)
    var marker := Label3D.new()
    marker.text = "PRESSURE RECORDING / WITHDRAW IS ALWAYS PERMITTED"
    marker.position = Vector3(16,2.45,-12.5)
    marker.pixel_size = 0.0055
    marker.font_size = 24
    marker.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    marker.modulate = Color("#e1d1a6")
    add_child(marker)

func _field_sprite(display: String, file_name: String, location: Vector3, size: float) -> void:
    var visual := AnimatedEchoform068.new()
    visual.echoform_id = "rootkin" if file_name == "rootkin.png" else "bell_wretch"
    visual.name = display
    visual.texture = load("res://assets/sprites/" + file_name)
    visual.position = location + Vector3(0,1.05,0)
    visual.pixel_size = size
    visual.shaded = false
    visual.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    visual.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
    add_child(visual)

func _decorate_flood() -> void:
    var brass := StandardMaterial3D.new()
    brass.albedo_color = Color("#6e8076")
    brass.metallic = 0.38
    brass.roughness = 0.6
    for x in [-22.5,-16.5,-10.5,-4.5,6.0,12.0,18.0,23.0]:
        var column := MeshInstance3D.new()
        var column_mesh := CylinderMesh.new()
        column_mesh.top_radius = 0.28
        column_mesh.bottom_radius = 0.36
        column_mesh.height = 4.2
        column.mesh = column_mesh
        column.material_override = brass
        column.position = Vector3(x,2.15,-22.5)
        add_child(column)
        var other: MeshInstance3D = column.duplicate() as MeshInstance3D
        other.position = Vector3(x,2.15,22.5)
        add_child(other)
    var water := MeshInstance3D.new()
    water.name = "Contained shallow flood / environmental visual"
    var plane := PlaneMesh.new()
    plane.size = Vector2(51.0,47.0)
    water.mesh = plane
    water.position.y = 0.017
    var wet := StandardMaterial3D.new()
    wet.albedo_color = Color(0.09,0.23,0.24,0.25)
    wet.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    wet.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    water.material_override = wet
    add_child(water)
    # A landmarked hanging bell and service conduits create a distinct place identity.
    for z in [-16.0,-8.0,0.0,8.0,16.0]:
        var tube := MeshInstance3D.new()
        var mesh := CylinderMesh.new()
        mesh.top_radius = 0.11
        mesh.bottom_radius = 0.11
        mesh.height = 47.0
        tube.mesh = mesh
        tube.position = Vector3(0,4.4,z)
        tube.rotation.z = PI * 0.5
        tube.material_override = brass
        add_child(tube)
    var bell := MeshInstance3D.new()
    bell.name = "Voluntary choir maintenance bell"
    var bell_mesh := CylinderMesh.new()
    bell_mesh.top_radius = 0.38
    bell_mesh.bottom_radius = 0.65
    bell_mesh.height = 0.72
    bell.mesh = bell_mesh
    bell.position = Vector3(-10,3.38,0)
    bell.material_override = brass
    add_child(bell)
