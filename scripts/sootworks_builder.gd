extends "res://scripts/world_builder.gd"
## Authored, physically collidable early Sootworks sector. Not procedural yet.
## The district is a functional industrial municipality, not an abstract combat room.
const BrinActor = preload("res://scripts/brin_actor.gd")

func build() -> void:
    make_material("ceiling", Color("#ffffff"), "ward_ceiling_v3")
    make_material("floor", Color("#50524c"), "soot_floor_v4")
    make_material("ward", Color("#99917c"), "ward_linen")
    make_material("requisition", Color("#76766a"), "soot_wall_v4")
    make_material("chart", Color("#e1d1a6"), "corroded_paper")
    make_material("dark", Color("#838078"), "soot_wall_v4")
    make_material("red", Color("#a94d3b"), "")
    make_material("accent", Color("#c28a43"), "")
    # Industrial lane 48 x 46 metres with open sightline along an offset conveyor.
    solid_box("Sootworks floor", Vector3(0,-0.32,0), Vector3(48,0.64,46), "floor")
    solid_box("North furnace wall", Vector3(0,2.3,-23), Vector3(48,4.6,0.8), "dark")
    solid_box("South workers wall", Vector3(0,2.3,23), Vector3(48,4.6,0.8), "requisition")
    solid_box("East furnace bulkhead", Vector3(24,2.3,0), Vector3(0.8,4.6,46), "dark")
    solid_box("West railway door", Vector3(-24,2.3,0), Vector3(0.8,4.6,46), "requisition")
    # Separate workers' office from control catwalk with a full 5 m opening.
    # Second genuine opening in the office divider: a worker service bypass.
    # The main 8m central passage remains available regardless of run seed.
    solid_box("Office divider N / upper", Vector3(1,2.2,-19.5), Vector3(0.9,4.4,7), "requisition")
    solid_box("Office divider N / lower", Vector3(1,2.2,-7.5), Vector3(0.9,4.4,7), "requisition")
    if not bool(Game.state.get("fun_slice",{}).get("sootworks_service_open",false)):
        var gate := solid_box("Worker service bypass shutter", Vector3(1,1.42,-13.5), Vector3(0.8,2.84,4.7), "dark")
        gate.add_to_group("sootworks_shortcut_shutter")

    solid_box("Office divider S", Vector3(1,2.2,13.5), Vector3(0.9,4.4,19), "requisition")
    solid_box("Labour header", Vector3(1,4.0,0), Vector3(0.9,0.7,8), "dark")
    # One of three small authored cover placements, seeded by the campaign.
    var cover_variant: int = int(Game.state.get("fun_slice",{}).get("seed_variant",0))
    if cover_variant == 0:
        solid_box("Slag cart / seed 0",Vector3(9,0.48,-8),Vector3(1.4,0.96,2.0),"dark")
    elif cover_variant == 1:
        solid_box("Finished billets / seed 1",Vector3(10,0.55,7),Vector3(1.8,1.1,1.6),"requisition")
    else:
        solid_box("Control shielding / seed 2",Vector3(16,0.58,-7),Vector3(1.4,1.16,1.6),"ward")
    # Working infrastructure, safe for a capsule radius 0.35 m.
    solid_box("Worker meal table", Vector3(-14,0.5,-14), Vector3(7,1,1.6), "ward")
    solid_box("Work bench", Vector3(-12,0.55,13), Vector3(4.5,1.1,1.5), "requisition")
    solid_box("Safety guard north", Vector3(12,0.75,-15), Vector3(5,1.5,1.5), "dark")
    solid_box("Safety guard south", Vector3(16,0.75,12), Vector3(5,1.5,1.5), "dark")
    solid_box("Press block", Vector3(21,1.0,-10), Vector3(2.3,2,4.0), "red")
    solid_box("Cooled scrap stack", Vector3(16,0.75,18), Vector3(5,1.5,2), "requisition")
    solid_box("Emergency heating pipe", Vector3(-20,2.5,-19), Vector3(2,3.0,1.7), "red")
    # Independent witnesses and public records ensure killing a Writ holder is nonblocking.
    if Game.has_attempt() and bool(Game.state.get("brin",{}).get("alive",true)):
        var brin = BrinActor.new()
        brin.name = "Brin Harker"
        var brin_outcome: String = str(Game.state["brin"].get("decision",""))
        if brin_outcome == "help":
            brin.position = Vector3(-14,0,-11)
        elif brin_outcome == "compromise":
            brin.position = Vector3(-10,0,11)
        elif brin_outcome == "exploit":
            brin.position = Vector3(18,0,16)
        elif brin_outcome == "abandon":
            brin.position = Vector3(-14,0,-15)
        else:
            brin.position = Vector3(-11,0,6)
        add_child(brin)
    add_actor("Labour Registry Clerk", "labour_clerk", Vector3(-17,0,-6), "clerk.png", "P U B L I C   R E G I S T E R")
    add_console("Freight payroll cylinder", "payroll_cylinder", Vector3(-20,0,-12), "PAYROLL / CLEARED 43 YEARS AGO")
    add_console("Worker council ledger", "workers_council", Vector3(-7,0,-16), "SHOP STEWARDS / PUBLIC HEARING")
    add_console("Heat isolation bus", "sootworks_regulator", Vector3(19,0,4), "CONTROL LINE / TECH 5")
    add_console("Millwright's order board", "millwright_order", Vector3(7,0,16), "CONTROL / KEEP OR DISABLE")
    add_console("Labour Writ public registry", "labour_registry", Vector3(-20,0,15), "LABOUR / EMERGENCY WRIT")
    add_console("Union night-shift relief box", "sootworks_relief", Vector3(6.7,0,-14.7), "WORKER CACHE / PHYSICAL RELIEF - ONE ONLY")
    add_console("One-time defence ration", "sootworks_locker", Vector3(-4,0,-9), "EMERGENCY DEFENCE / ONE ISSUE")
    add_console("Worker tools issue", "sootworks_weapon_rack", Vector3(-18,0,2), "ISSUE / ONE WORKER TOOL")
    add_console("Union service-door release", "sootworks_service_bypass", Vector3(-3,0,-18), "E / OPEN WORKER-ONLY SHORTCUT")
    add_console("Finite steam diversion", "sootworks_steam_diverter", Vector3(18,0,15), "E / RELIEVE MILLWRIGHT PRESSURE")
    add_console("Rail transfer to Hearth Nine", "hearth_return", Vector3(-21,0,19), "HEARTH NINE / RETURN TRANSFER")
    add_transition_frame("Hearth Nine rail gate", Vector3(-21,0,22.55), 3.7, 3.0, "rail", "HEARTH NINE", "RETURN SERVICE GATE")
    add_console("Rail transfer to Flood Basilica", "basilica_transfer", Vector3(-15,0,19), "FLOOD BASILICA / FAITH OFFICE")
    add_transition_frame("Basilica rail gate", Vector3(-15,0,22.55), 3.7, 3.0, "rail", "FLOOD BASILICA", "CHOIR AND FAITH OFFICE")
    add_console("Rail transfer to Ashmarket", "ashmarket_transfer", Vector3(-9,0,19), "ASHMARKET / TRADE OFFICE")
    add_transition_frame("Ashmarket rail gate", Vector3(-9,0,22.55), 3.7, 3.0, "rail", "ASHMARKET", "TRADE OFFICE GATE")
    signboard("SOOTWORKS / THE CITY RUNS ON UNPAID HOURS",Vector3(-8,3.75,-21.5))
    signboard("LABOUR OFFICE / PUBLIC AUDIT",Vector3(-13,3.8,21))
    signboard("FURNACE LOAD / ISOLATE THE REGULATOR, NOT THE WARD",Vector3(13,3.65,-21))
    if Game.has_attempt() and str(Game.state.get("brin",{}).get("decision","")) == "help":
        var strike_light := OmniLight3D.new()
        strike_light.name = "Shift ended / relief lamps"
        strike_light.position = Vector3(-13,3.0,-11)
        strike_light.light_color = Color("#a6d8aa")
        strike_light.light_energy = 1.7
        strike_light.omni_range = 8.0
        add_child(strike_light)
        signboard("THE WORKER CLOCK IS STOPPED / BRIN RESTS",Vector3(-13,2.5,-13))
    # Physical labour dispute: scene props change when evidence is discovered and
    # the council reaches a recorded outcome. These do not grant quest progress.
    var record_seen: bool = bool(Game.state.get("brin",{}).get("payroll_seen",false))
    var resolution: String = str(Game.state.get("brin",{}).get("decision",""))
    var evidence_panel := solid_box("Original payroll evidence / witness table",Vector3(-20.5,0.94,-14.3),Vector3(1.3,0.12,0.85),"chart" if record_seen else "dark")
    evidence_panel.set_meta("surface_kind","wood" if record_seen else "metal")
    if record_seen:
        signboard("ORIGINAL CYLINDER / DEBT CLEARED 43 YEARS AGO",Vector3(-20,2.3,-15.2))
    if resolution == "help":
        # Machinery remains on site but workers have shut their stations safely.
        solid_box("Tagged off shift / locked-out drive",Vector3(11,0.24,4),Vector3(3.4,0.48,1.3),"ward")
        signboard("SHIFT ENDED / HEAT MAINTAINED BY EMERGENCY CREW",Vector3(7,2.5,4.2))
    elif resolution == "compromise":
        solid_box("Emergency crew / allocated service kit",Vector3(-8,0.35,11),Vector3(1.5,0.7,1.5),"chart")
        signboard("CREW ROTATION / VOLUNTARY EMERGENCY WATCH",Vector3(-9,2.5,11))
    elif resolution == "exploit":
        solid_box("Security seizure / wage chain crate",Vector3(-8,0.65,10),Vector3(1.8,1.3,1.4),"red")
        signboard("COUNCIL FLOOR CLOSED / WORKERS STILL ON THE LINE",Vector3(-8,2.5,9))
    elif resolution == "abandon":
        signboard("NO AGREEMENT / SHIFT CLOCK STILL RUNNING",Vector3(-8,2.5,-11))
    var detailing := ArtDetail.new()
    detailing.name = "Sootworks - foundry pressure architecture"
    add_child(detailing)
    detailing.prepare(material_cache)
    detailing.decorate_sootworks()
    detailing.decorate_population("sootworks")
    for light_position in [Vector3(-14,3.8,0),Vector3(12,3.8,-11),Vector3(16,3.8,13)]:
        var lamp := OmniLight3D.new()
        lamp.position = light_position
        lamp.light_energy = 1.5
        lamp.light_color = Color("#ffac65") if light_position.x>0 else Color("#d7d5b5")
        lamp.omni_range = 21.0
        add_child(lamp)
