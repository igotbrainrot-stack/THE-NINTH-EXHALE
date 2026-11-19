extends "res://scripts/world_builder.gd"
## Short authored two-Writ DEVELOPMENT SLICE only. Not the three-Writ
## Freight Lift of the finished campaign. Physical rooms and real hulls.
func build() -> void:
    for child in get_children():child.queue_free()
    make_material("floor",Color("#a5a6a1"),"ward_floor_v4")
    make_material("ceiling",Color("#e1d1a6"),"ward_ceiling_v3")
    make_material("ward",Color("#c2bea8"),"basilica_stone_v4")
    make_material("requisition",Color("#879091"),"soot_wall_v4")
    make_material("dark",Color("#485153"),"furnace_iron")
    make_material("chart",Color("#e1d1a6"),"corroded_paper")
    make_material("red",Color("#b18b67"),"furnace_iron")
    solid_box("Lift docket floor",Vector3(0,-0.3,0),Vector3(28,0.6,30),"floor")
    solid_box("Lift rear bulkhead",Vector3(0,2.4,-15),Vector3(28,4.8,0.7),"ward")
    solid_box("Lift exit wall",Vector3(0,2.4,15),Vector3(28,4.8,0.7),"requisition")
    solid_box("Lift west wall",Vector3(-14,2.4,0),Vector3(0.7,4.8,30),"ward")
    solid_box("Lift east wall",Vector3(14,2.4,0),Vector3(0.7,4.8,30),"requisition")
    solid_box("Triage registry plinth",Vector3(-7,0.65,-7),Vector3(3,1.3,1.0),"dark")
    solid_box("Authority dial dais",Vector3(7,0.50,-10),Vector3(4,1.0,1.4),"dark")
    solid_box("Bellows counterweight",Vector3(10,1.0,3),Vector3(2.1,2.0,2.1),"dark")
    solid_box("Triage pressure bed A",Vector3(-9,0.4,0),Vector3(2.4,0.8,1.2),"ward")
    solid_box("Triage pressure bed B",Vector3(-9,0.4,-3),Vector3(2.4,0.8,1.2),"ward")
    add_actor("Canon Edda","edda",Vector3(4,0,-6),"edda.png","EDDA / NO CROWN, ONLY A TRIAGE CHART")
    add_console("Voluntary risk petition","eddas_petition",Vector3(-7,0,-5.0),"SIGNED PETITION / SOURCE RECORD")
    add_console("Emergency writ hearing","eddas_chamber",Vector3(6,0,-8.0),"EDDA / CIVIC MANDATE HEARING")
    add_console("Service lift return","slice_return",Vector3(-9,0,12),"RETURN TO HEARTH NINE")
    signboard("FREIGHT LIFT / TWO-WRIT DEVELOPMENT TRIAL",Vector3(-1,3.8,-13.8))
    signboard("REAL PATIENTS / REAL CONSEQUENCES",Vector3(-6,3.5,10))
    if Game.has_attempt() and bool(Game.state.get("slice_finale",{}).get("resolved",false)):
        var verdict: String = str(Game.state["slice_finale"].get("outcome",""))
        var result_label: String = "TRIAGE / RECORDED CIVIC TRANSFER"
        if verdict == "public_mandate": result_label = "TRIAGE / REVOCABLE VOLUNTARY MANDATE"
        elif verdict == "apparatus_shutdown": result_label = "TRIAGE / PRESSURE REGULATOR DISCONNECTED"
        elif verdict == "coercive_continuity": result_label = "TRIAGE / FORCED ASSIGNMENTS CONTINUE"
        signboard(result_label,Vector3(4,2.9,-11.0))
    var props := preload("res://scripts/art_detail.gd").new()
    add_child(props)
    props.prepare(material_cache)
    props.block("Fixed hydrostatic regulator",Vector3(10,2.6,-10),Vector3(1.4,1.9,1.0),"enamel_detail")
    props.tube("Pressure delivery pipe",Vector3(11.7,3.2,-4),8.0,0.11,"z","copper_detail")
    for where in [Vector3(-5,3.6,1),Vector3(8,3.6,-7)]:
        var light := OmniLight3D.new()
        light.position=where
        light.light_color=Color("#edbc87")
        light.light_energy=1.4
        light.omni_range=16
        add_child(light)
