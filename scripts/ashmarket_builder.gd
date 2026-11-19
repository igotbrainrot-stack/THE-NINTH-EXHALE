extends "res://scripts/world_builder.gd"
## Build 07.5: third authored Writ district. A working, physically connected
## trading market; no random corridor gates or false platforming. 52 x 44 m.
## World meshes are solid. Small decorative fittings are non-colliding.

func build() -> void:
    make_material("floor", Color("#80786c"), "ashmarket_floor_075")
    make_material("ceiling", Color("#d8d0c3"), "ward_ceiling_v3")
    make_material("ward", Color("#a49a86"), "ashmarket_ledger_wall_075")
    make_material("requisition", Color("#7e786c"), "requisition_steel")
    make_material("chart", Color("#d5c49b"), "corroded_paper")
    make_material("dark", Color("#575c56"), "soot_wall_v4")
    make_material("red", Color("#985747"), "ashmarket_awning_075")
    make_material("accent", Color("#c28a43"), "ashmarket_awning_075")
    # The central market aisle is at least 8 m wide at every divider, with
    # navigable side lanes and reachable staffed counters on both sides.
    solid_box("Market stone floor", Vector3(0,-0.32,0), Vector3(52,0.64,44), "floor")
    solid_box("North cistern retaining wall", Vector3(0,2.25,-22), Vector3(52,4.5,0.8), "ward")
    solid_box("South rail-front wall", Vector3(0,2.25,22), Vector3(52,4.5,0.8), "requisition")
    solid_box("East counting-vault wall", Vector3(26,2.25,0), Vector3(0.8,4.5,44), "dark")
    solid_box("West tenant stalls wall", Vector3(-26,2.25,0), Vector3(0.8,4.5,44), "ward")
    # Small counting partitions leave a broad central opening from z=-6 to 6.
    solid_box("North ledger partition", Vector3(1,2.25,-14), Vector3(0.8,4.5,16), "requisition")
    solid_box("South ledger partition", Vector3(1,2.25,14), Vector3(0.8,4.5,16), "requisition")
    solid_box("Market bridge lintel", Vector3(1,4.05,0), Vector3(0.8,0.8,12), "dark")
    # Physical low-poly market stalls, separated to preserve the west passage.
    for z in [-15.0,-4.0,7.0,16.0]:
        var counter := solid_box("Vendor's staffed counter / %s" % z, Vector3(-12,0.51,z), Vector3(3.7,1.02,1.3),"requisition")
        counter.set_meta("scenery_kind","fixed_civic_furniture")
        _canopy(Vector3(-12,2.85,z),Vector3(5.1,0.25,2.8))
        _stall_support(Vector3(-14,1.65,z-1.0))
        _stall_support(Vector3(-10,1.65,z+1.0))
    # A contested water cistern and archive cabinet make each route visible.
    solid_box("Tenant cistern body",Vector3(-6.5,1.0,-17.5),Vector3(2.6,2.0,2.8),"ward")
    solid_box("Archive cabinet / contracts",Vector3(-22,1.1,-13),Vector3(1.2,2.2,3.2),"dark")
    solid_box("Buyers' speaker shelf",Vector3(-22,0.65,6),Vector3(1.2,1.3,2.8),"requisition")
    solid_box("Counting lock mechanism",Vector3(19,0.85,-8),Vector3(2.4,1.7,2.6),"dark")
    solid_box("Collector desk",Vector3(14,0.60,5),Vector3(3.6,1.2,1.5),"requisition")
    solid_box("Writ register wicket",Vector3(20,0.85,15),Vector3(3.1,1.7,1.2),"ward")
    # Seed modifies one optional cover position only. Main and side routes
    # remain open; these crates never become mandatory quest locks.
    var variant: int = int(Game.state.get("fun_slice",{}).get("seed_variant",0))
    if variant == 0:
        solid_box("Freight scales / north",Vector3(10,0.5,-14),Vector3(2.2,1.0,1.2),"dark")
    elif variant == 1:
        solid_box("Stamped boxes / mid",Vector3(8,0.6,12),Vector3(1.9,1.2,1.6),"ward")
    else:
        solid_box("Toll cage / east",Vector3(22,0.55,-1),Vector3(1.2,1.1,2.2),"dark")
    # Broker/porter use already painted authored civilians temporarily. They
    # keep distinct names, physical collision and non-combat dialogue.
    add_actor("Market Broker","market_broker",Vector3(-19,0,0),"clerk.png","BROKER / WATER CLAIMS")
    add_actor("Misnamed Porter","market_porter",Vector3(-18,0,-8),"oren.png","PORTER / BORROWED NAME")
    add_console("Duplicate contract archive","market_contract_archive",Vector3(-20,0,-12),"PUBLIC ARCHIVE / CONTRACT EVIDENCE")
    add_console("Buyers' testimony desk","market_witness_counter",Vector3(-20,0,6),"BUYERS / INDEPENDENT TESTIMONY")
    add_console("Open buyers' coalition","market_buyer_council",Vector3(-18,0,14),"PUBLIC CHALLENGE / RECORD THE VOTE")
    add_console("Counting-lock switch","market_counting_lock",Vector3(18,0,-8),"TOKEN PRESS / TECH 5")
    add_console("Collector's board","market_collector_desk",Vector3(14,0,4),"COLLECTOR / THE WITNESS PRICE")
    add_console("Trade Writ registry","market_trade_registry",Vector3(20,0,14),"WRIT OF TRADE / PUBLIC SUCCESSION")
    add_console("Contested rain cistern","market_rain_cistern",Vector3(-6,0,-17),"THE PRICE OF RAIN / PUBLIC TANK")
    add_console("Public water hearing","market_rain_hearing",Vector3(-6,0,-11),"THE PRICE OF RAIN / FINITE DECISION")
    add_console("Market emergency ration","market_emergency_locker",Vector3(-5,0,17),"EMERGENCY STORES / ONE ISSUE")
    add_console("Service rail / Hearth Nine","hearth_return",Vector3(-22,0,19),"RAIL / HEARTH NINE")
    add_transition_frame("Hearth Nine rail gate", Vector3(-22,0,21.55), 3.7, 3.0, "rail", "HEARTH NINE", "SERVICE RAIL")
    add_console("Service rail / Sootworks","sootworks_transfer",Vector3(-15,0,19),"RAIL / SOOTWORKS")
    add_transition_frame("Sootworks rail gate", Vector3(-15,0,21.55), 3.7, 3.0, "rail", "SOOTWORKS", "SERVICE RAIL")
    add_console("Service rail / Flood Basilica","basilica_transfer",Vector3(-8,0,19),"RAIL / FLOOD BASILICA")
    add_transition_frame("Basilica rail gate", Vector3(-8,0,21.55), 3.7, 3.0, "rail", "FLOOD BASILICA", "SERVICE RAIL")
    signboard("ASHMARKET / OWNERSHIP IS AN ENTRY ON A LEDGER",Vector3(-8,3.7,-20))
    signboard("TRADE OFFICE / NO IDENTITY IS FOR SALE",Vector3(17,3.7,-20))
    signboard("KEEP PUBLIC RECEIPTS / THE OFFICE OUTLIVES THE KEEPER",Vector3(10,3.65,20))
    # Visual consequences are restored on load, not just a one-time HUD toast.
    if Game.has_attempt() and str(Game.state.get("trade",{}).get("method","")) != "":
        var verdict: String = str(Game.state["trade"]["method"])
        signboard("TRADE WRIT / %s" % verdict.to_upper().replace("_"," "),Vector3(18,2.6,16))
        var light := OmniLight3D.new()
        light.name="Transfer recorded / public wicket"
        light.position=Vector3(19,3.1,14)
        light.light_color=Color("#92c6ae") if verdict in ["coalition","sabotage"] else Color("#d7a078")
        light.light_energy=1.5
        light.omni_range=7.0
        add_child(light)
    for spot in [Vector3(-17,3.45,-14),Vector3(-16,3.45,10),Vector3(16,3.45,-12),Vector3(18,3.45,9)]:
        var lamp:=OmniLight3D.new()
        lamp.position=spot
        lamp.light_color=Color("#dfc18d") if spot.x<0 else Color("#9bb8aa")
        lamp.light_energy=1.15
        lamp.omni_range=15.0
        add_child(lamp)

func _canopy(at: Vector3, size: Vector3) -> void:
    var roof:=MeshInstance3D.new()
    roof.name="Market low-poly canvas awning / fixed orientation"
    roof.position=at
    var box:=BoxMesh.new()
    box.size=size
    roof.mesh=box
    roof.material_override=material_cache["red"]
    add_child(roof)

func _stall_support(at: Vector3) -> void:
    var post:=MeshInstance3D.new()
    post.name="Non-colliding canopy support"
    post.position=at
    var rod:=CylinderMesh.new()
    rod.height=3.1
    rod.top_radius=0.065
    rod.bottom_radius=0.065
    post.mesh=rod
    post.material_override=material_cache["accent"]
    add_child(post)
