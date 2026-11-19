extends "res://scripts/world_builder.gd"
## THE NINTH EXHALE / public assembly + finite emergency railway.
## Full-campaign zone; the unrelated two-Writ development trial remains in
## "lift". Fixed 3D architecture and open traversable civic stations.

func build() -> void:
    make_material("floor", Color("#a2a095"), "assembly_floor_078")
    make_material("ward", Color("#c1beb2"), "assembly_wall_078")
    make_material("ceiling", Color("#c3c1b6"), "ward_ceiling_v3")
    make_material("dark", Color("#455451"), "requisition_steel")
    make_material("rail", Color("#4d3f37"), "furnace_iron")
    make_material("accent", Color("#bd925d"), "corroded_paper")
    make_material("chart", Color("#d8c6a2"), "corroded_paper")
    make_material("requisition", Color("#697877"), "requisition_steel")

    solid_box("Public assembly floor / legal anchor", Vector3(0,-0.3,0), Vector3(56,0.6,44), "floor")
    solid_box("Assembly north outer wall", Vector3(0,2.4,-22), Vector3(56,4.8,0.8), "ward")
    solid_box("Assembly south outer wall", Vector3(0,2.4,22), Vector3(56,4.8,0.8), "ward")
    solid_box("Assembly west outer wall", Vector3(-28,2.4,0), Vector3(0.8,4.8,44), "ward")
    solid_box("Assembly east outer wall", Vector3(28,2.4,0), Vector3(0.8,4.8,44), "rail")
    # Perimeter architectural bodies: leave a 9m-wide central route and
    # generous clearance around each console. No untracked quest blockers.
    for x in [-25.0,25.0]:
        for z in [-15.0,0.0,15.0]:
            solid_box("Structural civic pier / %s / %s" % [x,z], Vector3(x,2.0,z), Vector3(1.0,4.0,1.0), "rail")
    solid_box("Assembly governing table / recessed south edge",Vector3(0,0.4,-18.5),Vector3(7.0,0.8,1.6),"dark")
    solid_box("Rail track left / west side",Vector3(16,-0.02,15),Vector3(0.25,0.06,10),"rail")
    solid_box("Rail track right / east side",Vector3(19,-0.02,15),Vector3(0.25,0.06,10),"rail")
    for z in [11.0,13.0,15.0,17.0,19.0]:
        solid_box("Rail sleeper / %.1f" % z,Vector3(17.5,-0.015,z),Vector3(4.0,0.04,0.35),"dark")
    # Physical waiting benches: not billboards, no fake passenger avatars.
    for x in [-12.0,-5.0,2.0,9.0]:
        solid_box("Signed cohort bench %s" % x,Vector3(x,0.32,6.5),Vector3(2.5,0.64,0.7),"dark")
        solid_box("Back of cohort bench %s" % x,Vector3(x,0.77,6.95),Vector3(2.5,1.0,0.13),"ward")
    # Independent public evidence stations around the unobstructed aisle.
    add_console("Disclose real risks to the public", "assembly_risks_078", Vector3(-21,0,-14), "RISKS / POWER AND CARE CUTS")
    add_console("Read original voluntary petition", "assembly_petition_078", Vector3(-14,0,-14), "PETITION / NOT A BLANKET CONSENT")
    add_console("Convene public assent", "assembly_mandate_078", Vector3(0,0,-14), "ASSEMBLY / REVOCABLE MANDATE")
    add_console("Hearth Nine patient testimony", "assembly_vote_clinic_078", Vector3(-21,0,-3), "HEARTH WARD / RECORD")
    add_console("Labour witnesses' desk", "assembly_vote_labour_078", Vector3(-14,0,-3), "LABOUR / BRIN'S ORIGINAL RECORD")
    add_console("Choir witnesses' desk", "assembly_vote_choir_078", Vector3(-7,0,-3), "CHOIR / OSSA'S TESTIMONY")
    add_console("Trade witnesses' desk", "assembly_vote_market_078", Vector3(0,0,-3), "TRADE / BUYERS' ORIGINALS")
    add_console("Growth researchers' desk", "assembly_vote_growth_078", Vector3(7,0,-3), "GROWTH / CONTROLLED TEST")
    add_console("Defence soldiers' desk", "assembly_vote_defence_078", Vector3(14,0,-3), "DEFENCE / NAMED CASUALTIES")
    add_console("Hearth Nine patient transport roster", "assembly_rail_patients_078", Vector3(-21,0,12), "RAIL / PATIENTS / 10 SEATS")
    add_console("Infants and guardian signed register", "assembly_rail_families_078", Vector3(-14,0,12), "RAIL / FAMILIES / 8 SEATS")
    add_console("Line maintenance volunteer roll", "assembly_rail_crews_078", Vector3(-7,0,12), "RAIL / CREWS / 8 SEATS")
    add_console("Claimant Ward transport requests", "assembly_rail_claimant_078", Vector3(0,0,12), "RAIL / CLAIMANT / 10 SEATS")
    add_console("Final civic settlement docket", "assembly_final_078", Vector3(18,0,-14), "CHOOSE / FOUR TERMINAL OUTCOMES")
    add_console("Return to first signatures", "assembly_return_078", Vector3(-22,0,18), "RETURN / CENTRAL ARCHIVES")

    signboard("PUBLIC ASSEMBLY / THREE-WRIT QUORUM",Vector3(0,3.7,-21))
    signboard("SIGNED REPORTS ARE NOT AUTOMATIC CONSENT",Vector3(-6,3.4,-9))
    signboard("EMERGENCY RAIL / FINITE LOCAL SEATS",Vector3(12,3.7,20))
    signboard("ONE COMPLETED ENDING / THIS CAMPAIGN CANNOT REWIND",Vector3(17,3.5,-20))
    # Physical departure indicators make a register decision visible in the
    # world, rather than only reporting numbers in an overlay.
    var manifest := Label3D.new()
    manifest.name = "Public platform manifest display"
    manifest.position = Vector3(-6,3.2,18.8)
    manifest.font_size = 28
    manifest.pixel_size = 0.008
    manifest.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    manifest.modulate = Color("#e7d3a4")
    add_child(manifest)
    var rail_signal := OmniLight3D.new()
    rail_signal.name = "Emergency rail boarding signal"
    rail_signal.position = Vector3(17.5,3.2,18.0)
    rail_signal.light_color = Color("#bb704a")
    rail_signal.light_energy = 2.0
    rail_signal.omni_range = 7.0
    add_child(rail_signal)
    # Fixed physical rail barrier; standing by the sign does not open it.
    solid_box("Rail platform launch shutter",Vector3(17.5,1.2,20.3),Vector3(4.5,2.4,0.3),"requisition")
    if Game.has_attempt():
        var civic: Dictionary = Game.state.get("civic",{})
        manifest.text = "MUSTERED %d / %d  •  NO PASSENGERS BOARDED" % [int(civic.get("staged_seats",0)),int(Game.state["core"].get("rail_capacity",24))]
        if int(civic.get("staged_seats",0)) > 0:
            rail_signal.light_color = Color("#dcb171")
    else:
        manifest.text = "PLATFORM / AUTHENTICATED PASSENGERS ONLY"

    if Game.has_attempt():
        var c: Dictionary = Game.state.get("civic",{})
        if bool(c.get("mandate",false)):
            signboard("PUBLIC / REVOCABLE TRIAL APPROVED",Vector3(-4,3.0,-15))
        if int(c.get("staged_seats",0)) > 0:
            signboard("MANIFEST / %d OF %d REGISTERED; NO TRAIN YET" % [int(c.get("staged_seats",0)),int(Game.state["core"].get("rail_capacity",24))],Vector3(-7,2.6,19))

    for point in [Vector3(-18,3.5,-12),Vector3(0,3.5,-12),Vector3(17,3.5,-12),Vector3(-17,3.5,8),Vector3(17,3.5,8)]:
        var lamp := OmniLight3D.new()
        lamp.name = "Staffed assembly lamp / original pressure dome"
        lamp.position = point
        lamp.light_color = Color("#cfb18b") if point.x < 0 else Color("#b2c7be")
        lamp.light_energy = 1.05
        lamp.omni_range = 11.5
        add_child(lamp)
    var detailing := preload("res://scripts/art_detail.gd").new()
    detailing.name = "Public docket conduits and wear"
    add_child(detailing)
    detailing.prepare(material_cache)
    for x in [-20.0,-12.0,-4.0,4.0,12.0,20.0]:
        detailing.tube("Civic analogue conduit %.1f" % x,Vector3(x,3.7,1.0),7.0,0.075,"z","copper_detail")
