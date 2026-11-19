extends "res://scripts/world_builder.gd"
## Quiet Barracks / Defence office. Regional Barracks Commandant is NOT the
## separately WorldPlan-selected central Custodian Marshal Voss.

func build() -> void:
    make_material("floor",Color("#a4a49c"),"barracks_floor_077")
    make_material("ceiling",Color("#818986"),"ward_ceiling_v3")
    make_material("ward",Color("#b0b7aa"),"barracks_wall_077")
    make_material("requisition",Color("#949c8a"),"barracks_wall_077")
    make_material("dark",Color("#474c48"),"soot_wall_v4")
    make_material("red",Color("#8f5c4a"),"furnace_iron")
    make_material("chart",Color("#d9d4b9"),"corroded_paper")
    make_material("accent",Color("#9a896b"),"furnace_iron")
    solid_box("Barracks solid ground",Vector3(0,-0.3,0),Vector3(62,0.6,48),"floor")
    solid_box("Northern defence school wall",Vector3(0,2.4,-24),Vector3(62,4.8,0.8),"ward")
    solid_box("Southern ration kitchen wall",Vector3(0,2.4,24),Vector3(62,4.8,0.8),"ward")
    solid_box("Western quarantine wall",Vector3(-31,2.4,0),Vector3(0.8,4.8,48),"ward")
    solid_box("Eastern protected armoury wall",Vector3(31,2.4,0),Vector3(0.8,4.8,48),"requisition")
    solid_box("North memory divider",Vector3(0,2.4,-14),Vector3(0.75,4.8,19),"dark")
    solid_box("South memory divider",Vector3(0,2.4,14),Vector3(0.75,4.8,19),"dark")
    # Guard cover and drill lanes occupy corners, central crossover stays free.
    for x in [-27.0,27.0]:
        for z in [-17.0,-7.0,8.0,17.0]:
            solid_box("Concrete defensible service post",Vector3(x,0.63,z),Vector3(1.35,1.26,1.6),"dark")
    var kest_choice: String = str(Game.state.get("kest",{}).get("decision","")) if Game.has_attempt() else ""
    if kest_choice == "abandon":
        signboard("KEST DEPARTED / WARRANT LEFT ON THE DESK",Vector3(-17,2.9,2))
    elif kest_choice == "help":
        add_actor("Kest07","kest",Vector3(-13,0,15),"kest.png","KEST-07 / INDEPENDENT TESTIMONY")
    elif kest_choice == "exploit":
        add_actor("Kest07","kest",Vector3(-24,0,16),"kest.png","KEST-07 / ORDERS ARE NOT CONSENT")
    else:
        add_actor("Kest07","kest",Vector3(-20,0,0),"kest.png","KEST-07 / UNPROVEN WARRANT")
    add_actor("Independent gate watch officer","barracks_watch",Vector3(-18,0,15),"oren.png","WATCH / REAL GUARD ROSTER")
    add_console("Original analogue casualty roll","barracks_casualty_roll",Vector3(-21,0,-15),"ORIGINAL NAMES / NEVER ERASED FROM PAPER")
    add_console("Watch coverage proof","barracks_guard_roster",Vector3(-21,0,7),"SAFETY / STAFFED CHECKPOINTS")
    add_console("Public soldiers assembly","barracks_platoon_vote",Vector3(-18,0,13),"PLATOON / READ NAMES INTO RADIO")
    add_console("Contradictory signal cabinet","barracks_signal",Vector3(20,0,-14),"ORDER ZERO / TECH 5 / STAFF COVER")
    add_console("Commandant office terminal","barracks_commandant",Vector3(16,0,0),"REGIONAL COMMANDANT / NOT MARSHAL VOSS")
    add_console("Defence Writ public registry","barracks_writ",Vector3(20,0,16),"DEFENCE WRIT / PUBLIC REGISTRY")
    add_console("Kest's forged warrant","kest_warrant",Vector3(-13,0,-13),"KEST / SIGNATURE IS NOT A MEMORY")
    add_console("Kest's consecutive print orders","kest_orders",Vector3(-13,0,-7),"KEST / FORENSIC IDENTITY ROLL")
    add_console("Kest's independent testimony","kest_choice",Vector3(-10,0,13),"KEST / TESTIMONY OR REVENGE")
    add_console("Kest's aftermath station","kest_aftermath",Vector3(-8,0,20),"KEST / CONSEQUENCES")
    add_console("Deep Heat Survey cabinet","barracks_heat_survey",Vector3(21,0,-18),"OPTIONAL / ONE DARK LINEN HEAT SURVEY")
    add_console("Barracks finite defence issue","barracks_supplies",Vector3(-5,0,20),"DEFENCE / LIMITED ISSUE")
    add_console("Service rail / Hearth Nine","hearth_return",Vector3(-23,0,20),"SERVICE RAIL / HEARTH NINE")
    add_transition_frame("Hearth Nine rail gate", Vector3(-23,0,21.55), 3.7, 3.0, "rail", "HEARTH NINE", "SERVICE RAIL")
    signboard("QUIET BARRACKS / NAMES ARE NOT NUMBERS",Vector3(-9,3.6,-22))
    signboard("GUARDS MUST REMAIN AFTER ORDERS END",Vector3(12,3.4,22))
    if Game.has_attempt() and str(Game.state.get("defence",{}).get("method","")) != "":
        signboard("DEFENCE WRIT / %s" % str(Game.state["defence"]["method"]).to_upper(),Vector3(18,2.8,18))
    for pos in [Vector3(-20,3.4,-13),Vector3(-18,3.4,14),Vector3(15,3.4,-13),Vector3(17,3.4,11)]:
        var lamp:=OmniLight3D.new()
        lamp.position=pos
        lamp.light_color=Color("#c9c29e") if pos.x<0 else Color("#d6b19a")
        lamp.light_energy=1.15
        lamp.omni_range=13.0
        add_child(lamp)
