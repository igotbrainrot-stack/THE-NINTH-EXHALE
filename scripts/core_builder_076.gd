extends "res://scripts/world_builder.gd"
## 07.6: real three-Writ Freight Lift / central analog archives.
## Not the two-Writ Edda development-slice chamber (zone "lift").
## Geometry is physical, fixed, walkable with a 10-m-wide cross-aisle.

func build() -> void:
    make_material("floor",Color("#9b9689"),"core_floor_076")
    make_material("ceiling",Color("#7c837e"),"ward_ceiling_v3")
    make_material("ward",Color("#c3c3b7"),"core_wall_076")
    make_material("requisition",Color("#8f9a98"),"requisition_steel")
    make_material("dark",Color("#4a5654"),"soot_wall_v4")
    make_material("red",Color("#89543f"),"furnace_iron")
    make_material("chart",Color("#e4cfaa"),"corroded_paper")
    make_material("accent",Color("#a88653"),"furnace_iron")

    solid_box("Archive floor / fixed foundation",Vector3(0,-0.3,0),Vector3(60,0.6,44),"floor")
    solid_box("Archive north wall",Vector3(0,2.4,-22),Vector3(60,4.8,0.8),"ward")
    solid_box("Archive south wall",Vector3(0,2.4,22),Vector3(60,4.8,0.8),"ward")
    solid_box("Archive west wall",Vector3(-30,2.4,0),Vector3(0.8,4.8,44),"ward")
    solid_box("Archive east wall",Vector3(30,2.4,0),Vector3(0.8,4.8,44),"requisition")
    # West archive and east memory recorder are connected at a broad 10m slot.
    solid_box("North ledger separator",Vector3(0,2.4,-13.5),Vector3(0.75,4.8,17),"requisition")
    solid_box("South ledger separator",Vector3(0,2.4,13.5),Vector3(0.75,4.8,17),"requisition")
    solid_box("Central charter lintel",Vector3(0,4.25,0),Vector3(0.75,0.65,10),"accent")
    # Equipment is real geometry, not camera-facing cardboard furniture.
    for pos in [Vector3(-27,1.0,-9),Vector3(-27,1.0,-3),Vector3(27,1.0,-9),Vector3(27,1.0,-3)]:
        solid_box("Fixed public archive rack / %s" % pos, pos, Vector3(1.6,2,3.8),"dark")
    for where in [Vector3(-11,0.62,-6),Vector3(10,0.62,-6),Vector3(-12,0.62,7),Vector3(13,0.62,8)]:
        solid_box("Archive counter / physical cover / %s" % where,where,Vector3(3.0,1.24,1.15),"requisition")
    solid_box("Mechanically insulated rail map",Vector3(-16,1.5,18),Vector3(5.5,3.0,0.6),"ward")
    solid_box("Recording spool plinth",Vector3(16,0.6,-15),Vector3(4.3,1.2,1.6),"dark")
    solid_box("Original conscription ledger plinth",Vector3(-16,0.6,-15),Vector3(4.3,1.2,1.6),"dark")
    solid_box("Executive authority control dais",Vector3(-8,0.55,-16),Vector3(4.5,1.1,1.5),"accent")
    solid_box("Executive actuator / isolated housing",Vector3(12,0.62,-13),Vector3(1.8,1.24,1.4),"red")
    # This console is in an open bay; no invisible quest lock is used.
    add_console("Original signed conscription order","core_conscription_order",Vector3(-19,0,-15),"SIGNATURE ONE / ORDER TO CONSCRIPT")
    add_console("Original architect objection spool","core_architect_objection",Vector3(19,0,-15),"SIGNATURE TWO / RECORDED OBJECTION")
    add_console("Emergency rail capacities","core_rail_charter",Vector3(-19,0,12),"RAIL / PASSAGE EXISTS, SEATS LIMITED")
    add_console("Spare carriage service coupler","core_carriage_repair",Vector3(-12,0,15),"RAIL / 2 SALVAGE + 3 LABOUR + 2 ENERGY")
    add_console("Draft rail boarding register","core_boarding_plan",Vector3(-8,0,12),"DRAFT PLAN ONLY / NO PASSENGERS BOARDED")
    add_console("Excluded wards casualty board","core_excluded_wards",Vector3(-19,0,3),"UNREGISTERED NAMES / WHO IS COUNTED")
    add_console("Voluntary-risk patient petition","core_voluntary_petition",Vector3(-19,0,-3),"PETITION / CONSENT IS REVOCABLE")
    add_console("Independent gate radio log","core_independent_radio",Vector3(19,0,3),"GATE / UNUSED OFFICER CHANNEL")
    add_console("Emergency staffing and pump plan","core_safety_bus",Vector3(19,0,-3),"SAFETY / CONVENTIONAL POWER ONLY")
    add_console("Maintenance cipher original","core_cipher",Vector3(19,0,12),"OPTIONAL / CORRECTION TRANSITION CIPHER")
    add_console("Executive docket","core_custodian_docket",Vector3(-8,0,-19),"CUSTODIAN / PUBLIC REMOVAL HEARING")
    add_console("Return service rail","core_return_rail",Vector3(-24,0,18),"LIFT / RETURN TO HEARTH NINE")
    add_transition_frame("Hearth return lift", Vector3(-24,0,20.55), 3.7, 3.0, "lift", "RETURN LIFT", "TO HEARTH NINE")
    add_console("Public civic assembly gate", "core_assembly_gate_078",Vector3(-10,0,18),"FINAL ACT / PUBLIC ASSEMBLY")
    add_transition_frame("Public assembly gate", Vector3(-10,0,20.55), 4.2, 3.2, "assembly", "PUBLIC ASSEMBLY", "FINAL CIVIC CHAMBER")
    signboard("FREIGHT LIFT OF NAMES / THREE DISTINCT WRITS",Vector3(-8,3.95,20))
    signboard("TWO ORIGINAL SIGNATURES / NEITHER ERASES THE OTHER",Vector3(-1,3.8,-20))
    signboard("EMERGENCY RAIL / LESS CAPACITY THAN VESPER",Vector3(-16,3.3,20.5))
    if Game.has_attempt():
        var core: Dictionary = Game.state.get("core",{})
        if bool(core.get("order_read",false)):
            signboard("ORIGINAL ORDER / COPIED",Vector3(-18,2.7,-19.5))
        if bool(core.get("objection_heard",false)):
            signboard("ARCHITECT'S OBJECTION / COPIED",Vector3(18,2.7,-19.5))
        if bool(core.get("rail_repaired",false)):
            signboard("SPARE CARRIAGE / 12 ADDITIONAL SEATS REPAIRED",Vector3(-15,3.1,17.5))
        if str(core.get("custodian_fate","")) != "":
            signboard("EXECUTIVE AUTHORITY / %s" % str(core.get("custodian_fate","released")).to_upper(),Vector3(0,3.5,-14))
    var detailing := preload("res://scripts/art_detail.gd").new()
    add_child(detailing)
    detailing.prepare(material_cache)
    # Details are nonblocking and do not cover the interaction points.
    for i in range(6):
        detailing.tube("Analog archive conduit %d" % i,Vector3(-23.5 + float(i)*9.0,3.55,0),7.0,0.09,"z","copper_detail")
    for where in [Vector3(-18,3.5,-13),Vector3(18,3.5,-13),Vector3(-18,3.5,10),Vector3(18,3.5,10),Vector3(0,3.6,-10)]:
        var lamp := OmniLight3D.new()
        lamp.name = "Archive emergency lamp / restored at fixed cost"
        lamp.position = where
        lamp.light_color = Color("#e6b988") if where.x < 0 else Color("#a0c0b1")
        lamp.light_energy = 1.10
        lamp.omni_range = 13.5
        add_child(lamp)
