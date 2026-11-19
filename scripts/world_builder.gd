extends Node3D
## First authored map. Built from collidable 3D geometry, never fake 2D wall art.
## HEARTH NINE (-X) / MUNICIPAL REQUISITIONS (+X), fixed run anchor.
const PALETTE = {
    "iron": Color("#424A48"), "blue":"#718D9A", "paper":"#E1D1A6",
    "amber":"#C28A43","chalk":"#C8C7AE","green":"#86956A",
    "rust":"#A94D3B","ink":"#171918"
}
const ArtDetail = preload("res://scripts/art_detail.gd")
var material_cache: Dictionary = {}

func _ready() -> void:
    add_to_group("hearth_world")

func build() -> void:
    for child in get_children():child.queue_free()
    make_material("floor",Color("#727a70"),"ward_floor_v4")
    make_material("ceiling",Color("#ffffff"),"ward_ceiling_v3")
    make_material("ward",Color("#c8c7ae"),"ward_enamel_v4")
    make_material("requisition",Color("#7a8783"),"requisition_steel")
    make_material("chart",Color("#d9c899"),"corroded_paper")
    make_material("dark",Color("#303b39"),"furnace_iron")
    make_material("red",Color("#a94d3b"),"")
    make_material("accent",Color("#c28a43"),"")
    # Flat floor at 0.0. Collision on all walls and floor.
    solid_box("Public foundation",Vector3(0,-0.32,0),Vector3(56,0.64,36),"floor")
    solid_box("North boundary",Vector3(0,2.25,-18),Vector3(56,4.5,0.8),"ward")
    solid_box("South boundary",Vector3(0,2.25,18),Vector3(56,4.5,0.8),"ward")
    solid_box("East boundary",Vector3(28,2.25,0),Vector3(0.8,4.5,36),"requisition")
    solid_box("West boundary",Vector3(-28,2.25,0),Vector3(0.8,4.5,36),"ward")
    # Dividing pressure wall has a real 8m passage. No locked invisible door.
    solid_box("Pressure wall north",Vector3(0,2.25,-11),Vector3(0.8,4.5,14),"requisition")
    solid_box("Pressure wall south",Vector3(0,2.25,11),Vector3(0.8,4.5,14),"requisition")
    solid_box("Writ inspection lintel",Vector3(0,4.0,0),Vector3(0.8,0.7,8),"dark")
    # NEW INTRO / THREE SMALL WALKABLE BAYS. These are authored collision
    # structures, not billboard walls. A broad 5.6 m pressure doorway exits the
    # intake; it unlocks permanently after the small tutorial encounter.
    solid_box("Intake north-west partition",Vector3(-24.0,2.15,3.1),Vector3(8.0,4.3,0.45),"ward")
    solid_box("Intake north-east partition",Vector3(-11.5,2.15,3.1),Vector3(5.0,4.3,0.45),"ward")
    solid_box("Intake east service wall",Vector3(-8.8,2.15,10.5),Vector3(0.45,4.3,15.0),"requisition")
    solid_box("Intake low ceiling bulkhead",Vector3(-17.2,3.7,3.05),Vector3(5.8,0.55,0.6),"dark")
    if Game.has_attempt() and Game.intro_stage() != "stabilised":
        var shutter := solid_box("Intake airlock shutter",Vector3(-17.2,1.35,3.1),Vector3(5.8,2.7,0.55),"requisition")
        shutter.add_to_group("intake_airlock_shutter")
    # The ward remains an actual working shelter, not a vault.
    solid_box("Ward cot one",Vector3(-22,0.4,-11),Vector3(4.8,0.8,2),"ward")
    solid_box("Ward cot two",Vector3(-22,0.4,-15),Vector3(4.8,0.8,2),"ward")
    solid_box("Clinic instrumentation",Vector3(-25,1.0,-9),Vector3(1.2,2.0,3),"requisition")
    solid_box("Medical shelf",Vector3(-16.5,0.7,-16),Vector3(4,1.4,0.8),"dark")
    solid_box("Meal bench",Vector3(-17,0.5,13),Vector3(5.5,1.0,1.4),"ward")
    solid_box("Service air manifold",Vector3(-26,2.1,0),Vector3(0.8,3.6,6),"requisition")
    solid_box("Docket counter",Vector3(11,0.65,-11),Vector3(5.6,1.3,2),"dark")
    solid_box("Public archive racks",Vector3(22,1.15,-14.5),Vector3(5.2,2.3,1),"requisition")
    solid_box("Lung shipping pedestal",Vector3(13,0.45,11),Vector3(3,0.9,2.5),"ward")
    solid_box("Boiler service block",Vector3(24,1.15,8),Vector3(2,2.3,3.4),"dark")
    solid_box("Checkpoint cover",Vector3(18,0.70,-3),Vector3(2.0,1.4,1.2),"requisition")
    solid_box("Pressure control rail",Vector3(6.5,0.45,14),Vector3(6.0,0.9,0.9),"dark")
    # Occupied archive machines are interactable and have bounded collision.
    add_actor("Dr Sela Vale","sela",Vector3(-18.5,0,-6),"sela.png","S E L A   /  W A R D  C L I N I C")
    add_actor("Oren","oren",Vector3(-12.5,0,0),"oren.png","O R E N   /  M A I N T E N A N C E")
    add_actor("Requisition Clerk","clerk",Vector3(8.0,0,-7.5),"clerk.png","C L E R K   /  A L L O T M E N T S")
    add_console("Freight Lift trial berth","slice_lift",Vector3(23,0,13),"SLICE TEST LIFT / 2 WRITS + HEARING")
    add_transition_frame("Trial freight lift", Vector3(23,0,15.9), 3.4, 3.1, "lift", "FREIGHT LIFT", "TWO WRITS + HEARING")
    add_console("Three Writ public authentication","quorum_audit_desk",Vector3(22,0,-5),"PUBLIC QUORUM / LABOUR + FAITH + TRADE")
    add_console("Reprint pressure relay", "wake_panel", Vector3(-24.5,0,10.2),"INTAKE / PRESS E TO WAKE")
    add_console("Intake quench vent", "intake_quench", Vector3(-11.1,0,14.5),"QUENCH / ONE PRESSURE CHARGE")
    add_console("Manual pressure valve", "intake_valve", Vector3(-17.2,0,5.2),"AIRLOCK / REPAIR VALVE")
    add_console("Allotment archive", "archive", Vector3(-6.0,0,-11.3),"PUBLIC COPY / WITNESS")
    add_console("Nix receiver","nix",Vector3(-24,0,7),"COPPER RECEIVER / NIX")
    add_console("Emergency supplies","ammo_locker",Vector3(-6,0,12),"EMERGENCY AMMO / ONE ISSUE")
    add_console("Reserve lung register","lung_rack",Vector3(13,0,9),"CONTESTED RESERVE / 1 LUNG")
    add_console("Maintenance bypass", "tech_panel",Vector3(24,0,5),"LOAD DIVERSION / TECH")
    add_console("Ward pressure display","pressure_display",Vector3(-25,0,-3.2),"POWER != CORRECTION")
    add_console("Pressure seal inspection", "future_gate",Vector3(2.7,0,14),"SOOTWORKS / SERVICE RAIL")
    add_transition_frame("Sootworks service gate", Vector3(2.7,0,17.58), 4.6, 3.2, "rail", "TO SOOTWORKS", "SERVICE RAIL GATE")
    signboard("INTAKE / MANUAL AIRLOCK — FOLLOW THE PAINTED SEAM",Vector3(-18.5,3.5,4.4))
    # Visual modular alcoves, each fully static so no chair follows the camera.
    solid_box("Intake printer bed",Vector3(-25.9,0.32,16.1),Vector3(2.6,0.64,1.3),"ward")
    solid_box("Intake printer press",Vector3(-26.4,1.58,15.9),Vector3(0.4,2.6,1.9),"dark")
    solid_box("Intake spare filter cage",Vector3(-22.5,0.5,16.8),Vector3(1.0,1.0,0.8),"requisition")
    signboard("HEARTH NINE  /  COMMUNITY AIR WARD",Vector3(-14,3.7,-16.9))
    signboard("MUNICIPAL REQUISITIONS  /  SPOKEN OBJECTIONS",Vector3(15,3.7,-16.9))
    signboard("EMERGENCY QUORUM  /  THREE OFFICES",Vector3(0,3.9,0))
    make_lamps()
    # Visual evidence of Sela’s real Cinder Lung installation and finite ward loss.
    if Game.has_attempt() and bool(Game.state.get("lung",{}).get("installed",false)):
        var ward_feedback := OmniLight3D.new()
        ward_feedback.name = "Hearth working airflow indicator"
        ward_feedback.position = Vector3(-18.0,2.7,-5.0)
        ward_feedback.light_color = Color("#74ccac")
        ward_feedback.light_energy = 2.0
        ward_feedback.omni_range = 8.0
        add_child(ward_feedback)
    var detailing := ArtDetail.new()
    detailing.name = "Hearth Nine - painted civic architecture"
    add_child(detailing)
    detailing.prepare(material_cache)
    detailing.decorate_hearth()
    detailing.decorate_population("hearth")

func make_material(id: String, tint: Color, texture_name: String) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color=tint
    mat.roughness=0.92 if id in ["ward","floor","chart","ceiling"] else 0.62
    mat.metallic=0.52 if id in ["requisition","dark","red"] else 0.02
    mat.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST
    mat.texture_repeat = true
    mat.uv1_triplanar = true
    mat.uv1_scale = Vector3(0.28,0.28,0.28)
    if texture_name!="":mat.albedo_texture=load("res://assets/textures/%s.png" % texture_name)
    material_cache[id]=mat
    return mat

func solid_box(display_name: String, location: Vector3, size: Vector3, mat_name: String) -> StaticBody3D:
    var body := StaticBody3D.new()
    body.name=display_name
    # Authored impact classification uses world material, not a naming heuristic.
    var surface: String = "stone"
    match mat_name:
        "dark", "red", "requisition": surface = "metal"
        "ward", "ceiling": surface = "ceramic"
        "chart": surface = "wood"
        "floor": surface = "stone"
    body.set_meta("surface_kind", surface)
    body.position=location
    body.collision_layer=1
    body.collision_mask=0
    var mesh := MeshInstance3D.new()
    var cube := BoxMesh.new()
    cube.size=size
    mesh.mesh=cube
    mesh.material_override=material_cache[mat_name]
    body.add_child(mesh)
    var collision := CollisionShape3D.new()
    var box := BoxShape3D.new()
    box.size=size
    collision.shape=box
    body.add_child(collision)
    add_child(body)
    return body

func add_actor(display_name: String, interaction: String, pos: Vector3, picture: String, heading: String) -> void:
    var actor := StaticBody3D.new()
    actor.name=display_name
    actor.position=pos
    actor.collision_layer=1
    actor.set_meta("interaction_id",interaction)
    var collider := CollisionShape3D.new()
    var shape := CapsuleShape3D.new()
    shape.height=1.8
    shape.radius=0.38
    collider.position.y=0.9
    collider.shape=shape
    actor.add_child(collider)
    var visual := Sprite3D.new()
    visual.texture=load("res://assets/sprites/"+picture)
    visual.pixel_size=0.017
    visual.billboard=BaseMaterial3D.BILLBOARD_ENABLED
    visual.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST
    visual.shaded=false
    visual.position.y=1.0
    var sprite_stem: String = picture.get_basename()
    if sprite_stem in ["sela", "oren", "clerk", "venn", "kest"]:
        visual.set_script(preload("res://scripts/directional_npc_sprite.gd"))
        visual.set("sprite_stem", sprite_stem)
    actor.add_child(visual)
    var voice := preload("res://scripts/actor_voice_083.gd").new()
    voice.name = "Voice083"
    actor.add_child(voice)
    add_child(actor)
    var label := Label3D.new()
    label.text=heading
    label.position=pos + Vector3(0,2.3,0)
    label.pixel_size=0.006
    label.font_size=26
    label.billboard=BaseMaterial3D.BILLBOARD_ENABLED
    label.modulate=Color(PALETTE["paper"])
    add_child(label)

func add_console(name_text: String, interaction: String, pos: Vector3, heading: String) -> void:
    var body := solid_box(name_text,pos+Vector3(0,0.72,0),Vector3(1.6,1.44,0.85),"dark")
    body.set_meta("interaction_id",interaction)
    var lamp := MeshInstance3D.new()
    var cube := BoxMesh.new()
    cube.size=Vector3(1.35,0.65,0.08)
    lamp.mesh=cube
    lamp.position=Vector3(0,0.3,-0.46)
    lamp.material_override=material_cache["chart"]
    body.add_child(lamp)
    var label := Label3D.new()
    label.text=heading
    label.position=pos+Vector3(0,2.0,0)
    label.font_size=24
    label.pixel_size=0.006
    label.billboard=BaseMaterial3D.BILLBOARD_ENABLED
    label.modulate=Color(PALETTE["amber"])
    add_child(label)

func add_transition_frame(display_name: String, center: Vector3, width: float, height: float, style: String, header: String, subheader: String = "") -> void:
    var frame_material: Material = material_cache.get("requisition", material_cache.get("dark"))
    var accent_material: Material = material_cache.get("accent", material_cache.get("chart"))
    var void_material := StandardMaterial3D.new()
    void_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    void_material.albedo_color = Color("#171918")
    var depth: float = 0.16
    var side_gap: float = width * 0.5
    for side in [-1.0, 1.0]:
        var upright := MeshInstance3D.new()
        upright.name = "%s / frame upright" % display_name
        upright.position = center + Vector3(side * side_gap, height * 0.5, 0)
        var upright_box := BoxMesh.new()
        upright_box.size = Vector3(0.34, height, depth)
        upright.mesh = upright_box
        upright.material_override = frame_material
        add_child(upright)
    var lintel := MeshInstance3D.new()
    lintel.name = "%s / lintel" % display_name
    lintel.position = center + Vector3(0, height + 0.12, 0)
    var lintel_box := BoxMesh.new()
    lintel_box.size = Vector3(width + 0.75, 0.28, depth)
    lintel.mesh = lintel_box
    lintel.material_override = accent_material
    add_child(lintel)
    var threshold := MeshInstance3D.new()
    threshold.name = "%s / threshold" % display_name
    threshold.position = center + Vector3(0, 0.03, 0)
    var threshold_box := BoxMesh.new()
    threshold_box.size = Vector3(width + 0.95, 0.06, 0.95)
    threshold.mesh = threshold_box
    threshold.material_override = accent_material
    add_child(threshold)
    var recess := MeshInstance3D.new()
    recess.name = "%s / recess" % display_name
    recess.position = center + Vector3(0, height * 0.5 + 0.02, 0.02)
    var recess_box := BoxMesh.new()
    recess_box.size = Vector3(width - 0.22, maxf(0.8, height - 0.22), 0.05)
    recess.mesh = recess_box
    recess.material_override = void_material
    add_child(recess)
    var lamp_color: Color = Color("#8fc7b7")
    if style == "rail": lamp_color = Color("#cda06c")
    elif style == "assembly": lamp_color = Color("#d7c18c")
    elif style == "lift": lamp_color = Color("#9ac1cf")
    # One low-cost light per exit; readable guide fixtures stay self-lit.
    # Previous implementation spawned two real-time lights at every door,
    # compounding lighting cost across the busiest rail clusters.
    var entrance_light := OmniLight3D.new()
    entrance_light.name = "%s / shared guide lamp" % display_name
    entrance_light.position = center + Vector3(0,height + 0.30,-0.18)
    entrance_light.light_color = lamp_color
    entrance_light.light_energy = 0.65
    entrance_light.omni_range = 4.5
    add_child(entrance_light)
    var guide_finish := StandardMaterial3D.new()
    guide_finish.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    guide_finish.albedo_color = lamp_color
    for side in [-1.0,1.0]:
        var plate := MeshInstance3D.new()
        plate.name = "%s / luminous exit indicator" % display_name
        plate.position = center + Vector3(side * (width * 0.32),height + 0.28,-0.27)
        var plate_mesh := BoxMesh.new()
        plate_mesh.size = Vector3(0.24,0.15,0.08)
        plate.mesh = plate_mesh
        plate.material_override = guide_finish
        add_child(plate)
    # 08.1: visual distinction between actual service gates, freight lifts and
    # a civic chamber entrance. These are mesh-only facades, not invisible locks.
    var panel_mat: Material = material_cache.get("dark", frame_material)
    if style == "assembly":
        # A deep legal arch replaces the former flat black rectangle silhouette.
        for k in range(7):
            var fraction: float = float(k) / 6.0
            var crown: float = 0.45 * (1.0 - pow(absf(fraction - 0.5) * 2.0, 2.0))
            var stone := MeshInstance3D.new()
            stone.name = "%s / legal chamber keystone" % display_name
            stone.position = center + Vector3((fraction-0.5)*width, height - 0.06 + crown, -0.22)
            var key_mesh := BoxMesh.new()
            key_mesh.size = Vector3(width/6.0+0.04,0.31,0.54)
            stone.mesh = key_mesh
            stone.material_override = frame_material
            add_child(stone)
        for j in range(5):
            var fin := MeshInstance3D.new()
            fin.name = "%s / chamber bronze fin" % display_name
            fin.position = center + Vector3(-width*0.40 + float(j)*width*0.20,1.42,-0.19)
            var blade := BoxMesh.new()
            blade.size = Vector3(0.065,2.45,0.13)
            fin.mesh = blade
            fin.material_override = accent_material
            add_child(fin)
    elif style == "lift":
        for side in [-1.0,1.0]:
            var cargo_panel := MeshInstance3D.new()
            cargo_panel.name = "%s / sliding cargo door" % display_name
            cargo_panel.position = center + Vector3(side * width * 0.245,height*0.45,-0.24)
            var leaf := BoxMesh.new()
            leaf.size = Vector3(width*0.48,height*0.84,0.13)
            cargo_panel.mesh = leaf
            cargo_panel.material_override = panel_mat
            add_child(cargo_panel)
            for j in range(3):
                var rail := MeshInstance3D.new()
                rail.name = "%s / lift pressure rib" % display_name
                rail.position = center + Vector3(side * width*0.245,0.80+float(j)*0.65,-0.36)
                var rib := BoxMesh.new()
                rib.size = Vector3(width*0.41,0.075,0.1)
                rail.mesh = rib
                rail.material_override = accent_material
                add_child(rail)
    else:
        for side in [-1.0,1.0]:
            var gate_panel := MeshInstance3D.new()
            gate_panel.name = "%s / reinforced rail leaf" % display_name
            gate_panel.position = center + Vector3(side*width*0.245,height*0.47,-0.25)
            var leaf := BoxMesh.new()
            leaf.size = Vector3(width*0.47,height*0.88,0.09)
            gate_panel.mesh = leaf
            gate_panel.material_override = panel_mat
            add_child(gate_panel)
        for j in range(5):
            var crossbar := MeshInstance3D.new()
            crossbar.name = "%s / embossed safety shutter rib" % display_name
            crossbar.position = center + Vector3(0,0.54+float(j)*0.49,-0.36)
            var strip := BoxMesh.new()
            strip.size = Vector3(width*0.91,0.085,0.08)
            crossbar.mesh = strip
            crossbar.material_override = accent_material if j % 2 == 0 else frame_material
            add_child(crossbar)
        var release_plate := MeshInstance3D.new()
        release_plate.name = "%s / visible handle plate" % display_name
        release_plate.position = center + Vector3(width*0.34,1.23,-0.43)
        var release_mesh := BoxMesh.new()
        release_mesh.size = Vector3(0.26,0.52,0.12)
        release_plate.mesh = release_mesh
        release_plate.material_override = accent_material
        add_child(release_plate)
    # Station controls retain their original interaction IDs; door art has no
    # interaction collider of its own and cannot grant access or spend resources.
    signboard(header, center + Vector3(0, height + 0.72, 0))
    if subheader != "":
        var sub := Label3D.new()
        sub.text = subheader
        sub.position = center + Vector3(0, height + 0.18, 0)
        sub.font_size = 26
        sub.pixel_size = 0.006
        sub.billboard = BaseMaterial3D.BILLBOARD_ENABLED
        sub.modulate = Color(PALETTE["amber"])
        add_child(sub)

func signboard(message: String, point: Vector3) -> void:
    var label := Label3D.new()
    label.text=message
    label.position=point
    label.font_size=38
    label.pixel_size=0.011
    label.modulate=Color(PALETTE["paper"])
    label.billboard=BaseMaterial3D.BILLBOARD_ENABLED
    add_child(label)

func make_lamps() -> void:
    for pos in [Vector3(-19,3.5,-7),Vector3(-10,3.5,8),Vector3(12,3.5,-8),Vector3(20,3.5,8)]:
        var light := OmniLight3D.new()
        light.position=pos
        light.light_color=Color("#f3dfaf") if pos.x<0 else Color("#b6cac6")
        light.light_energy=1.3
        light.omni_range=19.0
        light.shadow_enabled=false
        add_child(light)
