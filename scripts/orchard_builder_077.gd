extends "res://scripts/world_builder.gd"
## Glass Orchard / Growth office, authored 07.7. All service points are reachable
## from the west entrance via open ten-metre central crossing. Machinery, plants
## and independent samples are physically separate, never magical inventory.

func build() -> void:
    make_material("floor",Color("#9fada2"),"orchard_floor_077")
    make_material("ceiling",Color("#849c93"),"ward_ceiling_v3")
    make_material("ward",Color("#bfd2c1"),"orchard_glass_077")
    make_material("requisition",Color("#91b09f"),"orchard_glass_077")
    make_material("dark",Color("#435c56"),"soot_wall_v4")
    make_material("red",Color("#a26759"),"furnace_iron")
    make_material("chart",Color("#d7e4bf"),"corroded_paper")
    make_material("accent",Color("#9ab28d"),"orchard_floor_077")
    solid_box("Glass Orchard foundation",Vector3(0,-0.3,0),Vector3(60,0.6,48),"floor")
    solid_box("North translucent wall",Vector3(0,2.4,-24),Vector3(60,4.8,0.8),"ward")
    solid_box("South greenhouse wall",Vector3(0,2.4,24),Vector3(60,4.8,0.8),"ward")
    solid_box("West clinic wall",Vector3(-30,2.4,0),Vector3(0.8,4.8,48),"ward")
    solid_box("East propagation wall",Vector3(30,2.4,0),Vector3(0.8,4.8,48),"requisition")
    solid_box("Nursery separator north",Vector3(0,2.4,-14),Vector3(0.7,4.8,19),"dark")
    solid_box("Nursery separator south",Vector3(0,2.4,14),Vector3(0.7,4.8,19),"dark")
    # Walkable passage around the 10m central bay. Beds along the outside edges
    # avoid any state-dependent roadblock or console overlap.
    for x in [-25.0,25.0]:
        for z in [-18.0,-10.0,0.0,10.0,18.0]:
            _bed(Vector3(x,0.0,z))
    for x in [-27.0,27.0]:
        for z in [-14.0,3.0,15.0]:
            _pipe(Vector3(x,1.6,z),2.7)
    var venn_choice: String = str(Game.state.get("venn",{}).get("decision","")) if Game.has_attempt() else ""
    if venn_choice == "abandon":
        signboard("VENN'S CAGES LEFT / THEIR LATCHES FACED OUTWARD",Vector3(-19,2.9,2))
    elif venn_choice == "exploit":
        add_actor("VennOfGlass","venn",Vector3(-24,0,16),"venn.png","VENN / REFUSES THE NEW STAPLES")
    elif venn_choice == "help":
        add_actor("VennOfGlass","venn",Vector3(-15,0,15),"venn.png","VENN / OPEN NURSERY")
    else:
        add_actor("VennOfGlass","venn",Vector3(-20,0,0),"venn.png","VENN / FREE TO REFUSE")
    add_actor("Growing-culture technician","orchard_technician",Vector3(-19,0,15),"sela.png","HORTICULTURAL WITNESS")
    add_console("Fruit identity test spool","orchard_control_sample",Vector3(-20,0,-15),"SEPARATE CONTROL / INDEPENDENT PATTERN")
    add_console("Root-feed disconnector","orchard_feed_line",Vector3(17,0,-16),"ISOLATE FORCED MEMORY FEED / TECH 5")
    add_console("Researchers public vote","orchard_scientists",Vector3(-20,0,11),"RESEARCHERS / PROOF NOT SLOGANS")
    add_console("Gardener executive station","orchard_gardener",Vector3(15,0,0),"GARDENER / PROPAGATION AUTHORITY")
    add_console("Growth Writ public wicket","orchard_writ",Vector3(20,0,15),"GROWTH WRIT / COMMUNAL REGISTRY")
    add_console("Independent nursery instruction","venn_record",Vector3(-22,0,6),"VENN / COERCIVE STAPLE ORDERS")
    add_console("Nursery autonomy hearing","venn_choice",Vector3(-13,0,14),"VENN / CONSENT AND RELEASE")
    add_console("Nursery aftermath","venn_aftermath",Vector3(-10,0,20),"VENN / CONSEQUENCES")
    add_console("Independent Orchard Root Seed","orchard_root_seed",Vector3(21,0,-16),"OPTIONAL / ONE INDEPENDENT ROOT SEED")
    add_console("One emergency medical issue","orchard_supplies",Vector3(-7,0,20),"MEDICINE / LIMITED WARD STOCK")
    add_console("Service rail / Hearth Nine","hearth_return",Vector3(-23,0,20),"SERVICE RAIL / HEARTH NINE")
    add_transition_frame("Hearth Nine rail gate", Vector3(-23,0,21.55), 3.7, 3.0, "rail", "HEARTH NINE", "SERVICE RAIL")
    signboard("GLASS ORCHARD / NOT EVERY PATTERN IS PROPERTY",Vector3(-6,3.5,-22))
    signboard("ROOTS GROW / PEOPLE MUST STILL CHOOSE",Vector3(12,3.4,22))
    if Game.has_attempt():
        var growth: Dictionary = Game.state.get("growth",{})
        if str(growth.get("method","")) != "":
            signboard("GROWTH WRIT / %s" % str(growth["method"]).to_upper(),Vector3(18,2.8,18))
    for pos in [Vector3(-21,3.5,-15),Vector3(-20,3.5,12),Vector3(15,3.5,-13),Vector3(18,3.5,12)]:
        var light := OmniLight3D.new()
        light.position=pos
        light.light_color=Color("#b2dca8") if pos.x < 0 else Color("#cee8c5")
        light.light_energy=0.85
        light.omni_range=12.5
        add_child(light)

func _bed(pos: Vector3) -> void:
    # Real tri-planar mesh—not a camera-facing cardboard plant sprite.
    var basin := MeshInstance3D.new()
    basin.name="Fixed planter / original glass culture"
    basin.position=pos + Vector3(0,0.38,0)
    var form := BoxMesh.new()
    form.size=Vector3(1.25,0.7,3.1)
    basin.mesh=form
    basin.material_override=material_cache["dark"]
    add_child(basin)
    for i in range(3):
        var leaf := MeshInstance3D.new()
        leaf.name="Non-colliding nutrient column"
        leaf.position=pos + Vector3(0,1.0+0.23*float(i),-0.85+0.8*float(i))
        var cylinder:=CylinderMesh.new()
        cylinder.height=0.65+0.20*float(i)
        cylinder.top_radius=0.08
        cylinder.bottom_radius=0.19
        leaf.mesh=cylinder
        leaf.material_override=material_cache["accent"]
        add_child(leaf)

func _pipe(pos: Vector3, height: float) -> void:
    var mesh := MeshInstance3D.new()
    mesh.position=pos
    var form:=CylinderMesh.new()
    form.height=height
    form.bottom_radius=0.13
    form.top_radius=0.13
    mesh.mesh=form
    mesh.material_override=material_cache["requisition"]
    add_child(mesh)
