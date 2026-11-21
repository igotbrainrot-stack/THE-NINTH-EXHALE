extends Node3D
## First genuine story/physics integration for The Ninth Exhale.
## Build 06: Hearth Nine + Sootworks + Flood Basilica, with two real Writ records and a civic hearing.
## A two-Writ test lift exists separately. Build 07.8 adds the terminal civic settlement.
const WorldBuilder = preload("res://scripts/world_builder.gd")
const SootworksBuilder = preload("res://scripts/sootworks_builder.gd")
const BasilicaBuilder = preload("res://scripts/basilica_builder.gd")
const AshmarketBuilder = preload("res://scripts/ashmarket_builder.gd")
const OrchardBuilder077 = preload("res://scripts/orchard_builder_077.gd")
const BarracksBuilder077 = preload("res://scripts/barracks_builder_077.gd")
const CoreBuilder076 = preload("res://scripts/core_builder_076.gd")
const AssemblyBuilder078 = preload("res://scripts/assembly_builder_078.gd")
const LiftBuilder = preload("res://scripts/lift_builder.gd")
const OfficeEnforcer = preload("res://scripts/enemy.gd")
const CombatTracer079X = preload("res://scripts/combat_tracer_079x.gd")
const EnemyRoster068 = preload("res://scripts/enemy_roster_068.gd")
const PressureFixture = preload("res://scripts/pressure_fixture.gd")
const AmbientMachinery = preload("res://scripts/ambient_machinery.gd")
const GameUI = preload("res://scripts/game_ui.gd")
const DistrictMood074 = preload("res://scripts/district_mood_074.gd")
const IndustrialArt081 = preload("res://scripts/industrial_art_pass_081.gd")
const Hazard079 = preload("res://scripts/encounter_hazard_079.gd")
const Impact079 = preload("res://scripts/combat_impact_079.gd")
const PhysicalHearing079 = preload("res://scripts/physical_hearing_079.gd")
const AssemblyResponse079 = preload("res://scripts/assembly_response_079.gd")
@onready var player = $Player
var world
var hud
var guard
var intro_sentry: CharacterBody3D
var additional_enemies: Dictionary = {}
var nav_refresh_clock: float = 0.0
var world_environment: WorldEnvironment
var key_light: DirectionalLight3D
var service_hazard_079: Node3D
var health_seen_079: int = -1
var attempt_seen_079: String = ""

func _ready() -> void:
    print("THE NINTH EXHALE: Hearth Nine loading. Choose NEW NINTH in the on-screen docket.")
    setup_environment()
    world=WorldBuilder.new()
    world.name="HearthNine"
    add_child(world)
    world.build()
    hud=GameUI.new()
    hud.name="PressureDocketUI"
    add_child(hud)
    hud.action_selected.connect(_on_action)
    player.interact_requested.connect(_on_interact)
    player.shot_fired.connect(_on_shot)
    player.impact_event_079.connect(_on_impact_079)
    player.tracer_event_079x.connect(_on_tracer_079x)
    Game.state_changed.connect(_update_vitals_079)
    player.weapon_switched.connect(hud.set_weapon)
    player.weapon_anim.connect(hud.weapon_event)
    player.aim_prompt_changed.connect(hud.set_interact_prompt)
    player.hit_confirmed_090.connect(hud.hit_confirmed_090)
    player.docket_requested.connect(_show_dossier)
    player.save_requested.connect(_save_now)
    player.load_requested.connect(_load_now)
    player.heal_requested.connect(_heal)
    player.escape_requested.connect(_show_dossier)
    player.weapon_message.connect(_show_message)
    Game.attempt_failed.connect(_on_attempt_failed)
    Game.level_changed.connect(_on_level_changed_089)
    player.set_control_active(false)
    Music.set_listener(player)
    hud.set_weapon("covenant")
    open_main_menu()

func setup_environment() -> void:
    var ambient := WorldEnvironment.new()
    var environment := Environment.new()
    environment.background_mode=Environment.BG_COLOR
    environment.background_color=Color("#202b29")
    environment.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color=Color("#aeb4a6")
    environment.ambient_light_energy=0.55
    ambient.environment=environment
    add_child(ambient)
    world_environment = ambient
    var direction := DirectionalLight3D.new()
    direction.rotation_degrees=Vector3(-58,-28,0)
    direction.light_energy=0.3
    direction.light_color=Color("#dfd8c7")
    add_child(direction)
    key_light = direction

func _tune_district_illumination(zone: String) -> void:
    if not is_instance_valid(world_environment): return
    var env: Environment = world_environment.environment
    match zone:
        "sootworks":
            env.background_color = Color("#24251f")
            env.ambient_light_color = Color("#b09d84")
        "basilica":
            env.background_color = Color("#1b2d2d")
            env.ambient_light_color = Color("#94b0ac")
        "ashmarket":
            env.background_color = Color("#2c251e")
            env.ambient_light_color = Color("#d2ba95")
        "orchard":
            env.background_color = Color("#23392e")
            env.ambient_light_color = Color("#aac8a8")
        "barracks":
            env.background_color = Color("#262b2a")
            env.ambient_light_color = Color("#b7b4a2")
        "assembly":
            env.background_color = Color("#282b26")
            env.ambient_light_color = Color("#b8bba8")
        "core":
            env.background_color = Color("#1c2526")
            env.ambient_light_color = Color("#90aeb0")
        "lift":
            env.background_color = Color("#282320")
            env.ambient_light_color = Color("#ae9c94")
        _:
            env.background_color = Color("#202b29")
            env.ambient_light_color = Color("#aeb4a6")
    env.ambient_light_energy = 0.43
    if is_instance_valid(key_light):
        key_light.light_energy = 0.33

func reload_district_world() -> void:
    pending_quiet_service_079 = ""
    pending_quiet_service_deadline_079 = 0
    if is_instance_valid(guard):
        guard.queue_free()
    if is_instance_valid(intro_sentry):
        intro_sentry.queue_free()
    guard = null
    intro_sentry = null
    additional_enemies.clear()
    service_hazard_079 = null
    if Game.has_attempt(): Game.ensure_build079_state()
    if is_instance_valid(world):
        # Detach immediately: queue_free() alone leaves the old district's
        # physics bodies in the scene tree until the end of this frame.
        # Disabling first also prevents late enemy/hazard callbacks during swap.
        world.process_mode = Node.PROCESS_MODE_DISABLED
        if world.get_parent() == self:
            remove_child(world)
        world.queue_free()
    var zone: String = str(Game.state.get("zone","hearth")) if Game.has_attempt() else "hearth"
    if zone == "assembly":
        world = AssemblyBuilder078.new()
        world.name = "PublicAssemblyAndEmergencyRail"
    elif zone == "core":
        world = CoreBuilder076.new()
        world.name = "FullThreeWritArchives"
    elif zone == "lift":
        world = LiftBuilder.new()
        world.name = "FreightLiftTrial"
    elif zone == "sootworks":
        world = SootworksBuilder.new()
        world.name = "Sootworks"
    elif zone == "basilica":
        world = BasilicaBuilder.new()
        world.name = "FloodBasilica"
    elif zone == "ashmarket":
        world = AshmarketBuilder.new()
        world.name = "Ashmarket"
    elif zone == "orchard":
        world = OrchardBuilder077.new()
        world.name = "GlassOrchard"
    elif zone == "barracks":
        world = BarracksBuilder077.new()
        world.name = "QuietBarracks"
    else:
        world = WorldBuilder.new()
        world.name = "HearthNine"
    add_child(world)
    world.build()
    _tune_district_illumination(zone)
    var atmosphere := DistrictMood074.new()
    atmosphere.name = "Authored practical lights and material wear"
    world.add_child(atmosphere)
    atmosphere.configure(zone)
    var art_pass := IndustrialArt081.new()
    art_pass.name = "District-specific 08.1 dimensional architecture and machinery"
    world.add_child(art_pass)
    art_pass.configure(zone)
    spawn_guard()
    _hook_named_witnesses_085()
    spawn_intro_sentry()
    _populate_living_wards()
    _spawn_additional_enemies_068()
    _setup_environmental_encounter_079(zone)
    if zone == "basilica":
        var signal_field := PhysicalHearing079.new()
        signal_field.name = "Actual Rootkin hearing field / physical tactical readout"
        world.add_child(signal_field)
    if zone == "assembly":
        var civic_board := AssemblyResponse079.new()
        world.add_child(civic_board)

func _hook_named_witnesses_085() -> void:
    # One-time civilian intimidation is recorded by the named actor at the
    # actual HP threshold. The district's living authority may intervene.
    for witness_name in ["Brin Harker", "Sister Ossa"]:
        var witness: Node = world.get_node_or_null(witness_name)
        if is_instance_valid(witness) and witness.has_signal("threatened_085"):
            witness.connect("threatened_085",Callable(self,"_on_named_witness_threatened_085").bind(witness_name))

func _on_named_witness_threatened_085(witness_name: String) -> void:
    if not Game.has_attempt(): return
    if is_instance_valid(guard) and int(guard.hp) > 0:
        guard.anger()
    player._play_action_audio("pressure_warning.wav",-10.0)
    hud.notify("WITNESS UNDER THREAT / %s / DISTRICT SECURITY ALERTED" % witness_name.to_upper(),4.5)

func _setup_environmental_encounter_079(zone: String) -> void:
    if not Game.has_attempt() or zone not in ["hearth","sootworks","basilica"]: return
    var hazard := Hazard079.new()
    hazard.name = "Timed physical environmental danger / 07.9"
    hazard.configure(zone, player, bool(Game.state["hazards_079"][zone].get("disabled",false)), int(Game.state["world_plan"].get("seed",0)))
    hazard.shutdown_requested.connect(_shutdown_environmental_encounter_079)
    hazard.shutdown_rejected.connect(_show_message)
    world.add_child(hazard)
    service_hazard_079 = hazard

var pending_quiet_service_079: String = ""
var pending_quiet_service_deadline_079: int = 0

func _shutdown_environmental_encounter_079(zone: String, method: String) -> void:
    if method != "quiet":
        pending_quiet_service_079 = ""
        pending_quiet_service_deadline_079 = 0
    if method == "quiet":
        var now: int = Time.get_ticks_msec()
        if pending_quiet_service_079 != zone or now > pending_quiet_service_deadline_079:
            pending_quiet_service_079 = zone
            pending_quiet_service_deadline_079 = now + 4000
            var live: bool = is_instance_valid(service_hazard_079) and bool(service_hazard_079.call("is_danger_active"))
            hud.notify("CONFIRM E WITHIN 4 SEC / 1 ENERGY + 1 LABOUR / %s" % ("ACTIVE PULSE" if live else "PREVENTIVE ISOLATION"),4.0)
            return
        pending_quiet_service_079 = ""
        pending_quiet_service_deadline_079 = 0
    if Game.shut_down_hazard_079(zone,method):
        if is_instance_valid(service_hazard_079): service_hazard_079.call("confirm_shutdown")
        player._play_action_audio("mechanical_reload.wav",-12.0)
        hud.notify("%s / %s / SERVICE DISABLED / %s" % [zone.to_upper(),method.to_upper(),"1 ENERGY + 1 LABOUR" if method == "quiet" else "2 ENERGY"],3.1)
    else:
        hud.notify("UNAVAILABLE / CHECK POWER, STAFFED LABOUR OR SERVICE RECORD",2.4)

func _on_tracer_079x(origin: Vector3, destination: Vector3, kind: String) -> void:
    var beam := CombatTracer079X.new()
    add_child(beam)
    var tint: Color = Color("#9fcde0") if kind == "coil" else (Color("#d29b63") if kind == "nail" else Color("#eddd9e"))
    beam.configure(origin,destination,tint)

func _on_impact_079(point: Vector3, normal: Vector3, material_kind: String) -> void:
    var spark := Impact079.new()
    add_child(spark)
    spark.global_position = point + normal*0.045
    spark.configure(material_kind,normal)

func _update_vitals_079() -> void:
    if not Game.has_attempt():
        health_seen_079 = -1
        return
    var key: String = str(Game.state.get("attempt_id",""))
    var now: int = int(Game.state.get("health",0))
    if key != attempt_seen_079:
        attempt_seen_079 = key
    elif health_seen_079 >= 0 and now < health_seen_079 and is_instance_valid(hud):
        hud.impact_damage_079(health_seen_079-now)
    health_seen_079 = now

func _spawn_additional_enemies_068() -> void:
    if not Game.has_attempt(): return
    var zone: String = str(Game.state.get("zone","hearth"))
    if zone == "hearth" and Game.intro_stage() in ["unwoken","alarm","cleared"]:
        # The opening combat remains a readable single-crawler tutorial.
        return
    for id in Game.selected_enemy_068(zone):
        var key: String = str(id)
        var spec: Dictionary = EnemyRoster068.spec(key)
        var saved: Dictionary = Game.state["actors"].get(key,{})
        if not bool(saved.get("alive",true)) or spec.is_empty(): continue
        var foe := OfficeEnforcer.new()
        foe.actor_key = key
        foe.name = str(spec["name"]).replace(" ","")
        foe.max_hp = int(spec["hp"])
        foe.hp = foe.max_hp
        foe.shot_interval = float(spec["interval"])
        foe.attack_timer = 1.25 + 0.38 * float(int(spec["rank"]) % 3)
        foe.position = Vector3(float(spec["pos"][0]),float(spec["pos"][1]),float(spec["pos"][2]))
        foe.player = player
        foe.defeated.connect(_additional_enemy_defeated.bind(key))
        foe.telegraph_started.connect(_enemy_telegraph)
        world.add_child(foe)
        additional_enemies[key] = foe

func _additional_enemy_defeated(key: String) -> void:
    if not Game.has_attempt() or not Game.state["actors"].has(key): return
    Game.state["actors"][key]["alive"] = false
    Game.state["actors"][key]["hp"] = 0
    Game.record_event("combat.068.%s" % key,"one_time_ambient_enemy_defeat",{"actor":key,"zone":str(Game.state.get("zone",""))})
    # No repeat XP, loot or Writ transfer from optional population.
    Game.save_attempt()
    additional_enemies.erase(key)
    hud.notify("SERVICE THREAT DISABLED / %s / NO REPEAT BOUNTY" % key.to_upper().replace("_"," "),2.5)

func _populate_living_wards() -> void:
    # Decorative industrial rotation is based on fixed 3D meshes, not sprites.
    var zone: String = str(Game.state.get("zone","hearth"))
    var machinery := AmbientMachinery.new()
    machinery.name = "Visible running municipal plant"
    machinery.region = zone
    world.add_child(machinery)
    var positions: Dictionary = {
        "sootworks_stack":Vector3(18.2,0.0,-3.5),
        "basilica_receiver":Vector3(18.8,0.0,7.9),
        "lift_regulator":Vector3(9.7,0.0,5.7)}
    var target_id: String = ""
    match zone:
        "sootworks": target_id = "sootworks_stack"
        "basilica": target_id = "basilica_receiver"
        "lift": target_id = "lift_regulator"
    if target_id != "":
        var fixture := PressureFixture.new()
        fixture.name = "Fireable vent / " + target_id
        fixture.fixture_id = target_id
        fixture.spent = bool(Game.state.get("pressure_067",{}).get(target_id,false))
        fixture.position = positions[target_id]
        fixture.burst.connect(_on_pressure_fixture_burst)
        world.add_child(fixture)

func _pressure_fixture_has_path_079z(point: Vector3, actor: Node3D) -> bool:
    # A cylinder shockwave can travel through open space, not sealed masonry.
    var query := PhysicsRayQueryParameters3D.create(point+Vector3(0,1.1,0),actor.global_position+Vector3(0,1.1,0))
    query.collision_mask = 1
    return get_world_3d().direct_space_state.intersect_ray(query).is_empty()

func _on_pressure_fixture_burst(fixture_id: String, at: Vector3) -> void:
    if not Game.vent_pressure_fixture(fixture_id): return
    var distance: float = INF
    var affected: bool = false
    if is_instance_valid(guard):
        distance = guard.global_position.distance_to(at)
        if distance <= 8.0 and _pressure_fixture_has_path_079z(at,guard):
            affected = true
            guard.apply_environmental_stagger(2.8)
            if distance <= 4.5: guard.take_hit(10)
    # Industrial fixtures are real one-use tactical tools, not just another
    # terminal: stagger nearby optional hostiles as well as the Writ guard.
    # Actor death, XP and any finite record remain in their existing systems.
    for foe in additional_enemies.values():
        if not is_instance_valid(foe) or foe == guard: continue
        var separation: float = foe.global_position.distance_to(at)
        if separation <= 7.0 and _pressure_fixture_has_path_079z(at,foe):
            affected = true
            foe.apply_environmental_stagger(1.6 if separation > 3.8 else 2.4)
            if separation <= 3.8: foe.take_hit(8)
    # Visual/civic feedback stays in the real room; no recycled loot.
    _show_civic_consequence(at + Vector3(0,1.15,0),true)
    player._play_action_audio("valve_steam.wav",-6.5)
    hud.notify("PRESSURE CYLINDER DISCHARGED / ONE USE / ENEMY INTERRUPTED" if affected else "PRESSURE CYLINDER DISCHARGED / STORED ENERGY SPENT",3.1)

func _nav_target() -> Dictionary:
    if not Game.has_attempt(): return {}
    var zone: String = str(Game.state.get("zone","hearth"))
    if zone == "hearth":
        match Game.intro_stage():
            "unwoken": return {"label":"REPRINT RELAY","pos":Vector3(-24.5,0,10.2)}
            "alarm":
                if is_instance_valid(intro_sentry): return {"label":"INSPECTION CRAWLER","pos":intro_sentry.global_position}
                return {"label":"QUENCH VENT","pos":Vector3(-11.1,0,14.5)}
            "cleared": return {"label":"MANUAL VALVE","pos":Vector3(-17.2,0,5.2)}
        if bool(Game.state["lung"].get("acquired",false)) and not bool(Game.state["lung"].get("installed",false)):
            return {"label":"DR SELA","pos":Vector3(-18.5,0,-6.0)}
        if not bool(Game.state["lung"].get("installed",false)):
            if not bool(Game.state["flags"].get("allocation_record_seen",false)):
                return {"label":"PUBLIC ARCHIVE","pos":Vector3(-6,0,-11.3)}
            return {"label":"RESERVE LUNG","pos":Vector3(13,0,9)}
        if Game.can_register_three_writ_quorum():
            return {"label":"THREE-WRIT AUTHENTICATION","pos":Vector3(7.1,0,14)}
        return {"label":"FIVE FOUNDING SERVICE RAILS","pos":Vector3(2.7,0,14)}
    if zone == "sootworks":
        if not bool(Game.state["brin"].get("payroll_seen",false)):
            return {"label":"PAYROLL CYLINDER","pos":Vector3(-20,0,-12)}
        if str(Game.state["brin"].get("decision","")) == "" and bool(Game.state["brin"].get("alive",true)):
            return {"label":"BRIN HARKER","pos":Vector3(-11,0,6)}
        if not Game.state["writs"].has("qobj_writ_of_labour"):
            return {"label":"LABOUR PUBLIC REGISTRY","pos":Vector3(-20,0,15)}
        return {"label":"RETURN SERVICE RAIL","pos":Vector3(-20,0,20)}
    if zone == "basilica":
        if not bool(Game.state["ossa"].get("hymn_seen",false)):
            return {"label":"ORIGINAL HYMN REEL","pos":Vector3(-22,0,-17)}
        if not bool(Game.state["hearing"].get("passed",false)):
            return {"label":"ROOTKIN HEARING","pos":Vector3(10,0,-17)}
        if not Game.state["writs"].has("qobj_writ_of_faith"):
            return {"label":"FAITH PUBLIC WICKET","pos":Vector3(-22,0,15)}
        return {"label":"RETURN SERVICE RAIL","pos":Vector3(-22,0,21)}
    if zone == "ashmarket":
        var trade: Dictionary = Game.state.get("trade",{})
        if not bool(trade.get("duplicate_contracts",false)):
            return {"label":"DUPLICATE CONTRACTS","pos":Vector3(-20,0,-12)}
        if not bool(trade.get("buyer_testimony",false)):
            return {"label":"BUYER TESTIMONY","pos":Vector3(-20,0,6)}
        if not bool(trade.get("coalition_recorded",false)):
            return {"label":"BUYER COALITION","pos":Vector3(-18,0,14)}
        if not Game.state["writs"].has("qobj_writ_of_trade"):
            return {"label":"TRADE WRIT REGISTRY","pos":Vector3(20,0,14)}
        return {"label":"RETURN SERVICE RAIL","pos":Vector3(-22,0,19)}
    if zone == "orchard":
        var growth: Dictionary = Game.state.get("growth",{})
        if not bool(growth.get("sample_separated",false)):
            return {"label":"INDEPENDENT FRUIT SAMPLE","pos":Vector3(-20,0,-15)}
        if not bool(growth.get("researcher_vote",false)) and not Game.state["writs"].has("qobj_writ_of_growth"):
            return {"label":"RESEARCHER VOTE","pos":Vector3(-20,0,11)}
        if not Game.state["writs"].has("qobj_writ_of_growth"):
            return {"label":"GROWTH WRIT","pos":Vector3(20,0,15)}
        if not bool(growth.get("root_seed_found",false)):
            return {"label":"ORCHARD ROOT SEED","pos":Vector3(21,0,-16)}
        return {"label":"RETURN SERVICE RAIL","pos":Vector3(-23,0,20)}
    if zone == "barracks":
        var defence: Dictionary = Game.state.get("defence",{})
        if not bool(defence.get("casualty_roll",false)):
            return {"label":"ANALOGUE CASUALTY ROLL","pos":Vector3(-21,0,-15)}
        if not bool(defence.get("guard_roster",false)):
            return {"label":"STAFFED GATE ROSTER","pos":Vector3(-21,0,7)}
        if not Game.state["writs"].has("qobj_writ_of_defence"):
            return {"label":"DEFENCE WRIT","pos":Vector3(20,0,16)}
        if not bool(defence.get("heat_survey_found",false)):
            return {"label":"DEEP HEAT SURVEY","pos":Vector3(21,0,-18)}
        return {"label":"RETURN SERVICE RAIL","pos":Vector3(-23,0,20)}
    if zone == "assembly":
        var civic: Dictionary = Game.state.get("civic",{})
        if not bool(civic.get("risk_disclosed",false)):
            return {"label":"PUBLIC RISK DISCLOSURE","pos":Vector3(-21,0,-14)}
        if not bool(civic.get("petition_read",false)):
            return {"label":"SIGNED PATIENT PETITION","pos":Vector3(-14,0,-14)}
        if Game.dawn_technical_prerequisites_078() and not bool(civic.get("mandate",false)):
            return {"label":"CIVIC WITNESS ROLLS","pos":Vector3(-7,0,-3)}
        if int(civic.get("staged_seats",0)) == 0:
            return {"label":"FINITE RAIL ROSTERS","pos":Vector3(-14,0,12)}
        return {"label":"TERMINAL CIVIC DOCKET","pos":Vector3(18,0,-14)}
    if zone == "core":
        var core: Dictionary = Game.state.get("core",{})
        if not bool(core.get("order_read",false)):
            return {"label":"SIGNED CONSCRIPTION ORDER","pos":Vector3(-19,0,-15)}
        if not bool(core.get("objection_heard",false)):
            return {"label":"ARCHITECT'S OBJECTION","pos":Vector3(19,0,-15)}
        if not bool(core.get("rail_read",false)):
            return {"label":"EMERGENCY RAIL CHARTER","pos":Vector3(-19,0,12)}
        var target_key: String = Game.core_target_evidence()
        if target_key != "" and not bool(core.get(target_key,false)):
            var proof_pos: Vector3 = Vector3(-19,0,-3)
            if target_key == "independent_radio": proof_pos = Vector3(19,0,3)
            elif target_key == "excluded_wards": proof_pos = Vector3(-19,0,3)
            return {"label":"CUSTODIAN COUNTEREVIDENCE","pos":proof_pos}
        return {"label":"EXECUTIVE DOCKET","pos":Vector3(-8,0,-19)} if str(core.get("custodian_method","")) == "" else {"label":"PUBLIC ASSEMBLY GATE","pos":Vector3(-10,0,18)}
    if zone == "lift":
        if not bool(Game.state["slice_finale"].get("petition_seen",false)):
            return {"label":"VOLUNTARY PETITION","pos":Vector3(-7,0,-5)}
        return {"label":"EDDA TRIAL RECORD","pos":Vector3(6,0,-8)}
    return {}

func _process(delta: float) -> void:
    # Compact compass to actual physical machines; advisory, never a gate.
    if not is_instance_valid(hud) or not Game.has_attempt(): return
    nav_refresh_clock -= delta
    if nav_refresh_clock > 0.0: return
    nav_refresh_clock = 0.20
    var target: Dictionary = _nav_target()
    if target.is_empty(): return
    var goal: Vector3 = target["pos"]
    var direction: Vector3 = goal - player.global_position
    direction.y = 0.0
    var range_metres: int = roundi(direction.length())
    var arrow: String = "•"
    if direction.length_squared() > 0.01:
        var forward: Vector3 = -player.global_transform.basis.z
        var signed: float = forward.signed_angle_to(direction.normalized(),Vector3.UP)
        if absf(signed) < PI/4.0: arrow = "↑"
        elif absf(signed) > 3.0*PI/4.0: arrow = "↓"
        elif signed > 0.0: arrow = "←"
        else: arrow = "→"
    hud.set_navigation("%s  %s · %dm" % [arrow,str(target["label"]),range_metres])

func spawn_intro_sentry() -> void:
    if not Game.has_attempt() or str(Game.state.get("zone","hearth")) != "hearth":return
    if Game.intro_stage() != "alarm" or not bool(Game.state["actors"]["sentry"].get("alive",true)):return
    if is_instance_valid(intro_sentry):return
    var sentry := OfficeEnforcer.new()
    sentry.name="FaultyIntakeFilterCrawler"
    sentry.actor_key="sentry"
    sentry.max_hp=32
    sentry.hp=32
    sentry.shot_interval=2.8
    sentry.attack_timer=1.7
    sentry.player=player
    sentry.defeated.connect(_intro_sentry_defeated)
    sentry.telegraph_started.connect(_enemy_telegraph)
    world.add_child(sentry)
    intro_sentry=sentry
    sentry.anger()

func _intro_sentry_defeated() -> void:
    if Game.record_intake_sentry_defeat():
        hud.notify("PRESSURE CRAWLER STOPPED / FIND THE MANUAL VALVE AT THE NORTH DOOR",5.0)
    intro_sentry=null

func open_intake_shutter() -> void:
    if not is_instance_valid(world):return
    for shutter in get_tree().get_nodes_in_group("intake_airlock_shutter"):
        if is_instance_valid(shutter):
            shutter.queue_free()
    # Optional threats only join after the single-crawler teaching encounter.
    if additional_enemies.is_empty(): _spawn_additional_enemies_068()

func spawn_guard() -> void:
    if not Game.has_attempt():
        return
    if is_instance_valid(guard):
        guard.queue_free()
    var sootworks: bool = str(Game.state.get("zone","hearth")) == "sootworks"
    var basilica: bool = str(Game.state.get("zone","hearth")) == "basilica"
    var ashmarket: bool = str(Game.state.get("zone","hearth")) == "ashmarket"
    var full_core: bool = str(Game.state.get("zone","hearth")) == "core"
    var orchard: bool = str(Game.state.get("zone","hearth")) == "orchard"
    var barracks: bool = str(Game.state.get("zone","hearth")) == "barracks"
    var lift_trial: bool = str(Game.state.get("zone","hearth")) == "lift"
    var key: String = "enforcer"
    var display_name: String = "RequisitionEnforcer"
    var origin: Vector3 = Vector3(18,0.15,0)
    var health: int = 70
    if sootworks:
        key = "millwright"
        display_name = "MillwrightPowerFrame"
        origin = Vector3(14,0.15,-3)
        health = 125
    elif basilica:
        key = "cantor"
        display_name = "CantorSignalKeeper"
        origin = Vector3(14,0.15,5)
        health = 125
    elif ashmarket:
        key = "collector"
        display_name = "CollectorTradeOffice"
        origin = Vector3(16,0.15,-2.5)
        health = 95
    elif lift_trial:
        key = "edda_machine"
        display_name = "EddaTriageRegulator"
        origin = Vector3(7,0.15,3)
        health = 90
    elif full_core:
        key = "core_actuator"
        display_name = "CentralExecutiveActuator"
        origin = Vector3(8,0.15,-11)
        health = 210
    elif orchard:
        key = "gardener"
        display_name = "GardenRootActuator"
        origin = Vector3(15,0.15,0)
        health = 150
    elif barracks:
        key = "commandant"
        display_name = "CommandantServiceFrame"
        origin = Vector3(16,0.15,0)
        health = 165
    var saved: Dictionary = Game.state["actors"].get(key,{})
    if not bool(saved.get("alive",true)):
        guard = null
        return
    guard = OfficeEnforcer.new()
    guard.actor_key = key
    guard.max_hp = health
    guard.hp = health
    guard.name = display_name
    guard.position = origin
    guard.player = player
    guard.defeated.connect(_guard_defeated)
    guard.became_hostile.connect(_guard_hostile)
    guard.telegraph_started.connect(_enemy_telegraph)
    world.add_child(guard)
    if orchard or barracks:
        guard.role_move = "skirmish" if orchard else "boss"
        guard.role_attack = "line" if orchard else "heavy"
        guard.role_reach = 11.0 if orchard else 14.0
        guard.role_damage = 8 if orchard else 12
        guard.role_speed = 2.3 if orchard else 1.75
        guard.shot_interval = 1.35 if orchard else 1.70
    if full_core:
        # One executive control actuator, NOT the living Custodian. Its
        # destruction never implies the person was murdered.
        guard.role_move = "boss"
        guard.role_attack = "heavy"
        guard.role_reach = 15.0
        guard.role_damage = 12
        guard.role_speed = 1.75
        guard.shot_interval = 1.65
        guard.sprite.modulate = Color("#bdd4cc")
    if lift_trial:
        guard.sprite.modulate = Color("#d4b8a5")
    elif sootworks:
        guard.sprite.modulate = Color("#d0a66c")
    elif basilica:
        guard.sprite.modulate = Color("#b7dad1")
    elif ashmarket:
        guard.sprite.modulate = Color("#dfb98a")
    elif orchard:
        guard.sprite.modulate = Color("#a5d2a3")
    elif barracks:
        guard.sprite.modulate = Color("#bdb89c")


func open_main_menu() -> void:
    player.set_control_active(false)
    var opts: Array = []
    if Game.has_saved_active():
        opts.append({"label":"RESUME / last active attempt","action":"resume"})
    else:
        var failed: Dictionary = Game.failed_attempt_awaiting_reprint()
        if not failed.is_empty():
            var last_death: Dictionary = failed["nix_archived_failures"].back()
            opts.append({"label":"RECONSTRUCT / %s after death at %s" % [str(failed.get("build","Witness")).to_upper(), str(last_death.get("site","Vesper"))],"action":"reprint_saved"})
    if Game.profile.get("completed_endings",[]).size() > 0:
        opts.append({"label":"ARCHIVED SETTLEMENTS / NOT REWOUND","action":"ending:archive"})
    for name in ["Witness","Breaker","Mechanist","Stalker"]:
        opts.append({"label":"NEW NINTH / %s" % name,"action":"new:"+name})
    opts.append({"label":"QUIT TO DESKTOP","action":"quit"})
    hud.open_modal("THE NINTH EXHALE", "An original municipal horror FPS/RPG. Five founding offices, the central Custodian and a finite civic assembly now form a full authored campaign route.\n\nVesper is still running. A reserve Cinder Lung has been withheld by the allocation office. Every method of retrieving it affects someone else's allotment.",opts)

func begin_attempt(build: String, continuing_chain: bool = false) -> void:
    var fixed_seed: int = -1
    # Optional developer QA arg, absent in ordinary play; seeded attempts
    # can be repeated without a new debug panel in the production UI.
    for arg in OS.get_cmdline_user_args():
        if str(arg).begins_with("--ninth-seed="):
            fixed_seed = int(str(arg).trim_prefix("--ninth-seed="))
    Game.start_new(build, fixed_seed, continuing_chain)
    Game.state["yaw"]=0.0
    Game.save_attempt()
    reload_district_world()
    player.restore_position()
    player.set_control_active(false)
    hud.open_modal("NINTH / PRESSURE WAKE", "NIX: 'Number nine. Intake pressure is falling. You're standing on the last working relay.'\n\nWASD / MOUSE — move and look. E — work the relay or valve. LMB — fire. F / right-click — emergency intervention, even with no ammunition.\n\n%s" % Game.intro_text(),[{"label":"STAND / REACH THE RELAY","action":"close"}])

func resume_loaded_attempt() -> void:
    if not Game.load_attempt():
        hud.notify("No active saved attempt / choose a new build")
        open_main_menu()
        return
    reload_district_world()
    player.restore_position()
    player.set_control_active(false)
    hud.open_modal("RESUMED / CIVIC RECORD", "Attempt %s restored. Events already resolved cannot be claimed a second time.\n\n%s" % [Game.state["attempt_id"],Game.intro_text()],[{"label":"RETURN TO CURRENT DISTRICT","action":"close"}])

func resume_controls() -> void:
    hud.close_modal()
    player.set_control_active(true)

func _on_shot(hit: bool) -> void:
    hud.animate_shot(hit)
    if Game.has_attempt() and str(Game.state.get("zone","hearth"))=="sootworks" and not bool(Game.state["brin"]["alive"]) and not bool(Game.state["flags"].get("brin_death_notified",false)):
        Game.state["flags"]["brin_death_notified"] = true
        hud.notify("BRIN HARKER / DEATH WITNESSED. HIS VOICE IS GONE.",2.3)

func _show_message(text: String) -> void:
    hud.notify(text)

func _enemy_telegraph(message: String) -> void:
    hud.notify(message,1.25)


func _open_development_shortcut(group_name: String) -> void:
    for piece in get_tree().get_nodes_in_group(group_name):
        if is_instance_valid(piece): piece.queue_free()

func _fun_interaction(interaction_id: String) -> void:
    # Physical E-button service switches deliberately avoid the modal menu.
    # Exactly one finite event per district; no repeat XP or infinite supplies.
    var fs: Dictionary = Game.state["fun_slice"]
    var message: String = "SERVICE ALREADY RECORDED"
    match interaction_id:
        "intake_quench":
            if Game.intro_stage() == "alarm" and not bool(fs["hearth_vent_used"]) and is_instance_valid(intro_sentry):
                if Game.record_event("hearth.intake_quench_066","physical_interruption",{"source":"one-shot vent pressure reservoir"}):
                    fs["hearth_vent_used"] = true
                    intro_sentry.apply_environmental_stagger(3.6)
                    message = "AIR QUENCH / CRAWLER STUNNED — MOVE OR USE F INTERVENTION"
            else: message = "VENT / single charge; only available during the intake alarm"
        "sootworks_service_bypass":
            if not bool(fs["sootworks_service_open"]):
                if Game.record_event("sootworks.worker_bypass_066","physical_shortcut",{"source":"union service latch"}):
                    fs["sootworks_service_open"] = true
                    _open_development_shortcut("sootworks_shortcut_shutter")
                    message = "UNION BYPASS OPEN / NEW NORTHERN ROUTE TO FURNACE"
            else: message = "WORKER BYPASS / already open"
        "sootworks_steam_diverter":
            if not bool(fs["sootworks_steam_used"]):
                if Game.record_event("sootworks.steam_diverter_066","finite_pressure_interrupt",{"source":"factory service cylinder"}):
                    fs["sootworks_steam_used"] = true
                    if is_instance_valid(guard): guard.apply_environmental_stagger(4.0)
                    message = "STEAM VENTED / MILLWRIGHT PRESSURE CYCLE INTERRUPTED"
            else: message = "STEAM CYLINDER / pressure exhausted, no refill"
        "basilica_side_passage":
            if not bool(fs["basilica_side_open"]):
                if Game.record_event("basilica.lay_side_passage_066","physical_shortcut",{"source":"independent choir latch"}):
                    fs["basilica_side_open"] = true
                    _open_development_shortcut("basilica_shortcut_shutter")
                    message = "LAY CHOIR PASSAGE OPEN / BYPASS THE KEEPER'S CENTRAL LANE"
            else: message = "SIDE NAVE / already unsealed"
        "basilica_resonator":
            if not bool(fs["basilica_resonator_used"]):
                if Game.record_event("basilica.resonator_observation_066","optional_signal_discovery",{"source":"public acoustic dial"}):
                    fs["basilica_resonator_used"] = true
                    Game.state["hearing"]["familiarity"] = int(Game.state["hearing"].get("familiarity",0)) + 1
                    message = "SIGNAL RISING / SHIELDED / EXPOSED: ATTUNE AND BRACE BEFORE PRESS"
            else: message = "RESONATOR / original reading is already documented"
    if interaction_id in ["intake_quench","sootworks_steam_diverter","basilica_resonator"] and message != "SERVICE ALREADY RECORDED":
        player._play_action_audio("valve_steam.wav",-12.0)
    Game.save_attempt()
    hud.notify(message,4.0)

func _optional_discovery(key: String) -> void:
    var gained: bool = Game.claim_discovery(key)
    if gained:
        player._play_action_audio("metal_hit.wav",-14.0)
        if key == "sootworks_relief":
            hud.notify("WORKER RELIEF CACHE / ONE SEALED BREATH AMPOULE ADDED",3.2)
        else:
            hud.notify("ORIGINAL CHOIR NOTES / ONE HEARING OPENING OBSERVATION",3.2)
        _show_civic_consequence(player.global_position+Vector3(0,2.1,0),true)
    else:
        hud.notify("PUBLIC SERVICE CACHE / ALREADY RECORDED, NO RESTOCK",3.0)

func _show_civic_consequence(point: Vector3, helped: bool) -> void:
    # Lighting changes are visible in the 3D world immediately, not only in text.
    if not is_instance_valid(world): return
    var fixture := OmniLight3D.new()
    fixture.name = "Recorded local civic consequence"
    fixture.position = point
    fixture.light_color = Color("#8dc5ab") if helped else Color("#d67d5f")
    fixture.light_energy = 1.75
    fixture.omni_range = 8.0
    world.add_child(fixture)

func _guard_hostile() -> void:
    var zone: String = str(Game.state.get("zone","hearth"))
    if zone == "orchard":
        hud.notify("GARDENER ROOT FRAME / WATCH THE GROWTH PULSE",2.0)
        return
    if zone == "barracks":
        hud.notify("BARRACKS COMMANDANT FRAME / WATCH THE HEAVY WINDUP",2.0)
        return
    hud.notify("CENTRAL EXECUTIVE ACTUATOR / POWERED CONTROL ENGAGED" if zone == "core" else ("COLLECTOR / BONDED SECURITY ENGAGED" if zone == "ashmarket" else ("CANTOR / COERCIVE SIGNAL FRAME ENGAGED" if zone == "basilica" else ("MILLWRIGHT / SECURITY FRAME ENGAGED" if zone == "sootworks" else "OFFICE ENFORCER / ORDER TO FIRE"))),2.0)

func _guard_defeated() -> void:
    if not Game.has_attempt():
        return
    player.capture_position()
    if str(Game.state.get("zone","hearth")) == "orchard":
        if Game.mark_office_defeat_077("orchard"):
            hud.notify("GARDENER ROOT FRAME STOPPED / GROWTH WRIT IN PUBLIC WICKET",4.5)
    elif str(Game.state.get("zone","hearth")) == "barracks":
        if Game.mark_office_defeat_077("barracks"):
            hud.notify("COMMANDANT FRAME DISABLED / DEFENCE REGISTRY STILL STAFFED",4.5)
    elif str(Game.state.get("zone","hearth")) == "core":
        if Game.record_core_actuator_defeat_076():
            hud.notify("EXECUTIVE ACTUATOR DISABLED / RETURN TO THE CUSTODIAN DOCKET",4.5)
    elif str(Game.state.get("zone","hearth")) == "lift":
        Game.record_event("slice.edda_machine_shutdown","apparatus_defeat",{"source":"powered triage regulator","patients":"kept outside arena"})
        Game.state["slice_finale"]["apparatus_defeated"] = true
        Game.state["actors"]["edda_machine"]["alive"] = false
        Game.award_xp_once("slice.edda_machine",15)
        hud.notify("TRIAGE REGULATOR DISABLED / RETURN TO EDDA HEARING",4.0)
    elif str(Game.state.get("zone","hearth")) == "ashmarket":
        Game.record_event("ashmarket.collector_defeated", "office_security_defeated", {"actor":"Collector", "witness":"independent trade wicket"})
        Game.state["trade"]["collector_defeated"] = true
        Game.state["actors"]["collector"]["alive"] = false
        Game.award_xp_once("ashmarket.collector_encounter",15)
        hud.notify("COLLECTOR REMOVED / TRADE WRIT REMAINS IN PUBLIC REGISTRY",4.5)
    elif str(Game.state.get("zone","hearth")) == "basilica":
        Game.record_event("basilica.cantor_defeated", "keeper_defeated", {"actor":"Cantor", "witness":"public faith register"})
        Game.state["faith"]["cantor_defeated"] = true
        Game.state["actors"]["cantor"]["alive"] = false
        Game.award_xp_once("basilica.cantor_encounter",15)
        hud.notify("CANTOR SILENCED / FAITH WRIT RECOVERABLE FROM PUBLIC WICKET",4.5)
    elif str(Game.state.get("zone","hearth")) == "sootworks":
        Game.record_event("sootworks.millwright_defeated", "keeper_defeated", {"actor":"Millwright", "witness":"public labour counter"})
        Game.state["labour"]["millwright_defeated"] = true
        Game.state["actors"]["millwright"]["alive"] = false
        Game.award_xp_once("sootworks.millwright_encounter",15)
        hud.notify("MILLWRIGHT DEFEATED / RECOVER THE WRIT AT THE PUBLIC REGISTER",4.5)
    else:
        Game.record_event("hearth.enforcer_defeated","guard_defeat",{"place":"requisition wing","witness":"public counter"})
        Game.state["flags"]["guard_defeated"] = true
        Game.state["actors"]["enforcer"]["alive"] = false
        Game.award_xp_once("hearth.enforcer_encounter",15)
        hud.notify("ENFORCER DOWN / WITNESS RECORDED. Ask clerk for the reserve.",4.5)
    Game.save_attempt()


func _on_attempt_failed() -> void:
    player.set_control_active(false)
    hud.open_modal("FAILURE / ANOTHER NINTH", "A witnessed body has fallen. The Lumen Engine can reprint a new attempt at real cost. Its modular wards will be assigned a new seed.\n\nNix's analogue record will refer only to this actually observed failure.",[{"label":"RECONSTRUCT / same build, new seed","action":"reprint"},{"label":"RETURN TO REGISTER","action":"menu"}])

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and event.keycode==KEY_ESCAPE and hud.modal_open and Game.has_attempt():
        resume_controls()
        get_viewport().set_input_as_handled()

func _play_npc_voice_083(interaction_id: String) -> void:
    if not is_instance_valid(world): return
    for actor in world.get_children():
        if not (actor is Node3D): continue
        if actor.has_meta("interaction_id") and str(actor.get_meta("interaction_id")) == interaction_id:
            var voice: Node = actor.get_node_or_null("Voice083")
            if is_instance_valid(voice):
                voice.call("play_npc_grunt")
            return

func _on_interact(interaction_id: String) -> void:
    if not Game.has_attempt():return
    player.capture_position()
    _play_npc_voice_083(interaction_id)
    # 08.0: animate a living witness only during an actual conversation.
    if interaction_id in ["brin", "ossa"] and is_instance_valid(world):
        var witness_name: String = "Brin Harker" if interaction_id == "brin" else "Sister Ossa"
        var witness: Node3D = world.get_node_or_null(witness_name) as Node3D
        if is_instance_valid(witness):
            for visual in witness.get_children():
                if visual.has_method("talk_079x"):
                    visual.talk_079x()
    # Simple physical operations occur in the 3D world without an interruption panel.
    if interaction_id == "wake_panel" and Game.intro_stage() == "unwoken":
        if Game.wake_reprint_relay():
            spawn_intro_sentry()
            player._play_action_audio("pressure_warning.wav",-6.0)
            hud.notify("RELAY LIVE / CRAWLER UNLATCHED — WATCH ITS RUSH, F INTERVENE",4.0)
        return
    if interaction_id == "intake_valve" and Game.intro_stage() == "cleared":
        if Game.stabilise_intake_valve():
            open_intake_shutter()
            player._play_action_audio("valve_steam.wav",-8.0)
            hud.notify("PRESSURE RELEASED / SHUTTER OPENING — FIND SELA",4.0)
        return
    if interaction_id in ["intake_quench","sootworks_service_bypass","sootworks_steam_diverter","basilica_side_passage","basilica_resonator"]:
        _fun_interaction(interaction_id)
        return
    if interaction_id in ["sootworks_relief","basilica_notes"]:
        _optional_discovery(interaction_id)
        return
    if interaction_id.ends_with("_switch_079"):
        var zone_key: String = interaction_id.trim_suffix("_switch_079")
        if is_instance_valid(service_hazard_079) and str(service_hazard_079.get("hazard_key")) == zone_key:
            service_hazard_079.call("try_shutdown","quiet")
        return
    player.set_control_active(false)
    if str(Game.state.get("zone","hearth")) == "assembly":
        assembly_interaction_078(interaction_id)
        return
    if str(Game.state.get("zone","hearth")) == "orchard":
        orchard_interaction_077(interaction_id)
        return
    if str(Game.state.get("zone","hearth")) == "barracks":
        barracks_interaction_077(interaction_id)
        return
    if str(Game.state.get("zone","hearth")) == "core":
        core_interaction_076(interaction_id)
        return
    if str(Game.state.get("zone","hearth")) == "lift":
        lift_interaction(interaction_id)
        return
    if str(Game.state.get("zone","hearth")) == "sootworks":
        sootworks_interaction(interaction_id)
        return
    if str(Game.state.get("zone","hearth")) == "basilica":
        basilica_interaction(interaction_id)
        return
    if str(Game.state.get("zone","hearth")) == "ashmarket":
        ashmarket_interaction(interaction_id)
        return
    match interaction_id:
        "slice_lift":
            if Game.can_enter_slice_lift():
                show_choice("FREIGHT LIFT / DEVELOPMENT TRIAL", "Two authenticated Writs and the completed public hearing permit entry to a SHORT TEST of Canon Edda's review. Full campaign Quorum STILL requires three separate Writs.",[{"label":"ENTER TWO-WRIT TEST LIFT","action":"slice:enter"},go_back()])
            else:
                show_choice("FREIGHT LIFT / STILL SEALED", "For this short test: install Lung, record Labour and Faith Writs and complete the Rootkin hearing. The full campaign lift will require three distinct Writs.",[go_back()])
        "wake_panel":
            var phase: String = Game.intro_stage()
            if phase == "unwoken":
                show_choice("INTAKE / AIR RELAY", "The relay has one remaining pressure charge. Waking it might blow the seal. Sela is beyond the northern shutter, but no ward can run without the intake reading.",[{"label":"WAKE PRESSURE RELAY / SOUND ALARM","action":"intro:wake"},go_back()])
            elif phase == "alarm":
                show_choice("INTAKE / RELAY FAILURE", "The pressure crawler is loose. It is mechanical, not a creature to be captured. Use the Covenant Pistol and the nearby cover, or move around it to avoid direct fire.",[go_back()])
            else:
                show_choice("INTAKE / SEALED RECORD", "The original relay failure is in the docket. Cycling this panel cannot create a second encounter or XP reward.",[go_back()])
        "intake_valve":
            var phase: String = Game.intro_stage()
            if phase == "cleared":
                show_choice("INTAKE / MANUAL SEAL", "The faulty crawler is disabled. The pressure wheel will open the shutter without consuming another ward's air allocation.",[{"label":"OPEN THE AIRLOCK / ENTER CLINIC","action":"intro:valve"},go_back()])
            elif phase == "stabilised":
                show_choice("INTAKE / STABLE", "The shutter is open. The route to Dr Sela is clear; the Cinder Lung remains contested.",[go_back()])
            else:
                show_choice("INTAKE / VALVE LOCKED", "The pressure relay must be woken and its failed inspection crawler stopped before this valve can safely open.",[go_back()])
        "sela":
            if bool(Game.state["lung"]["installed"]):
                show_choice("DR SELA VALE / AIR WARD", "The Cinder Lung is fitted. Energy drives the pumps; a separate human-derived correction pattern keeps the boundary stable. Sela will not call this arrangement harmless.",[go_back()])
            elif bool(Game.state["lung"]["acquired"]):
                show_choice("DR SELA VALE / INSTALLATION", "The spare Lung is now here. The claimant ward still has a legitimate need. Installing it transfers eight allocation units: five from their share and three from idle reserve, while the grid loses one Energy and one Correction integrity.",[{"label":"INSTALL THE CONTESTED CINDER LUNG","action":"install_lung"},go_back()])
            else:
                show_choice("DR SELA VALE / WITHHELD AIR", "'The reserve exists. Somebody assigned it elsewhere.' Sela points toward the municipal requisitions wing east of the service door. She can repair the ward but cannot personally alter the legal claim.",[go_back()])
        "oren":
            show_choice("OREN / THE UNMENDED DOOR", "'Somebody will have to pay for the air you take. Put it in the record.' The old soldier keeps adjusting the hinge. He knows the building's blind corridors, not the source of the entire Engine's policy.",[go_back()])
        "nix":
            show_choice("NIX / COPPER ARCHIVE", "%s\n\n'An ink mark can be forged. It cannot be rewritten from a distant switch. Please distinguish the two.'" % Game.intro_text(),[go_back()])
        "archive":
            if bool(Game.state["flags"]["allocation_record_seen"]):
                show_choice("PUBLIC REQUISITION COPY", "A signed office record confirms the existing reserve Lung and its competing ward's claim. The copy remains public; it cannot invent the consent of either ward.",[go_back()])
            else:
                show_choice("PUBLIC REQUISITION COPY", "A paper register survives the digital alterations. A spare Cinder Lung was not lost: its electrical reserve is isolated under a competing ward claim. This copy can support one legitimate negotiation.",[{"label":"COPY SOURCE DOCUMENT / KEEP AUDIT TRAIL","action":"record_evidence"},go_back()])
        "clerk":
            clerk_dialogue()
        "lung_rack":
            if bool(Game.state["lung"]["acquired"]):
                show_choice("CONTESTED RESERVE", "The signed transfer now lists Ninth as custodian of the single spare Lung. No duplicate unit remains on this rack.",[go_back()])
            else:
                show_choice("RESERVE RACK / TWO WARDS", "The spare is real. Its claim tag names another ward. An unapproved removal can save Hearth Nine immediately, but creates a documented shortage elsewhere.",[{"label":"REMOVE SPARE / STEAL WITH TRACEABLE COST","action":"claim:steal"},go_back()])
        "tech_panel":
            var tech_message := "A measured diversion can free the known reserve without erasing the audit trail."
            show_choice("MAINTENANCE / POWER REDIRECTION",tech_message,[check_option("REROUTE THE LOAD / CLAIM LUNG","claim:tech",Game.check_attribute("Tech",5)),go_back()])
        "ammo_locker":
            if Game.state["event_ids"].has("hearth.mandatory_ammo"):
                show_choice("EMERGENCY SUPPLIES", "The single authorised issue has been collected. The ledger cannot restock on another visit.",[go_back()])
            else:
                show_choice("EMERGENCY SUPPLIES", "24 Ledger Slugs and two Breath Ampoules are reserved for unavoidable emergency defence. Stock cannot regenerate when you walk through a door.",[{"label":"CLAIM FINITE SUPPLIES","action":"claim_ammo"},go_back()])
        "pressure_display":
            var numbers:Dictionary=Game.state["resources"]
            show_choice("WARD PRESSURE / TWO CHANNELS", "POWER %s  CORRECTION %s  BIOMASS %s  AIR %s  LABOUR %s\n\nThese are five distinct city capacities, not player health. Heat can run the filters; it cannot supply the mnemonic correction pattern." % [numbers["Energy"],numbers["Correction"],numbers["Biomass"],numbers["Air"],numbers["Labour"]],[go_back()])
        "quorum_audit_desk":
            if bool(Game.state["trade"].get("quorum_audit",false)):
                show_choice("FREIGHT LIFT OF NAMES / THREE-WRIT QUORUM", "Three unique founding offices and the public hearing have authenticated this lift. The analogue core archives contain two conflicting original signatures and the current Custodian's executive terminal.",[ {"label":"ENTER FULL THREE-WRIT ARCHIVES","action":"core:enter"},go_back()])
            elif Game.can_register_three_writ_quorum():
                show_choice("THREE-WRIT QUORUM / AUTHENTICATION", "The Cinder Lung operates; any three different founding offices have transferred their Writs, and the Rootkin hearing passed. The register records actual document IDs, not a fixed scripted trio.",[{"label":"REGISTER THREE WRITS / PUBLIC AUDIT","action":"trade:quorum_audit"},go_back()])
            else:
                show_choice("THREE-WRIT QUORUM / NOT READY", "Install the Lung, authenticate any THREE distinct Writs from the five founding offices, and complete the public hearing. The two-Writ Edda trial remains a separate prototype.",[go_back()])
        "future_gate":
            if bool(Game.state["lung"]["installed"]):
                show_choice("RAIL ACCESS / FIVE FOUNDING OFFICES", "All five district offices now have physical Writ registries. Any three independent Writs can satisfy the central charter; the remaining offices are optional but still reachable.", [{"label":"TRAVEL TO SOOTWORKS / LABOUR","action":"travel:sootworks"},{"label":"TRAVEL TO FLOOD BASILICA / FAITH","action":"travel:basilica"},{"label":"TRAVEL TO ASHMARKET / TRADE","action":"travel:ashmarket"},{"label":"TRAVEL TO GLASS ORCHARD / GROWTH","action":"travel:orchard"},{"label":"TRAVEL TO QUIET BARRACKS / DEFENCE","action":"travel:barracks"},go_back()])
            else:
                show_choice("HEARTH NINE / FIRST OBLIGATION", "Install the contested Cinder Lung before leaving the ward to pursue founding Writs.",[go_back()])
        _:
            show_choice("UNREGISTERED SERVICE", "No authored interaction is attached to this object.",[go_back()])

func orchard_interaction_077(interaction_id: String) -> void:
    var growth: Dictionary = Game.state.get("growth",{})
    var venn: Dictionary = Game.state.get("venn",{})
    match interaction_id:
        "orchard_control_sample":
            show_choice("CONTROL FRUIT / PROOF OF INDEPENDENCE", "A fruit survives outside the forced-memory feed. It repeats a person's name, but its response to a command can be tested separately. This is original evidence, not proof of ownership.",[{"label":"SEPARATE SAMPLE / RECORD CONTROL","action":"orchard:sample"},go_back()])
        "orchard_scientists", "orchard_technician":
            show_choice("RESEARCH STAFF / VOICE OF THE ORCHARD", "Two living control cultures must be compared before the researchers can challenge the Gardener. A private declaration of good intentions is not a public vote.",[{"label":"PRESENT CONTROL / CALL PUBLIC VOTE","action":"orchard:vote"},go_back()])
        "orchard_feed_line":
            show_choice("FORCED MEMORY FEED / ISOLATION", "A trained technician can cut the root motor's coercive pattern feed with a staffed mineral rinse. This costs 2 Energy and 1 Labour; existing plants still require care.",[check_option("ISOLATE ROOT FEED / 2E + 1L","orchard:isolate",Game.check_attribute("Tech",5)),go_back()])
        "orchard_gardener":
            show_choice("GARDENER / PROPAGATION AUTHORITY", "'A fruit that speaks is not necessarily a person,' says the Gardener. The keeper requires a controlled separation test, not a speech. Its powered root apparatus can also be stopped.",[{"label":"CONFRONT POWERED ROOT ASSEMBLY","action":"orchard:fight"},go_back()])
        "orchard_writ":
            show_choice("GROWTH WRIT / PUBLIC SUCCESSION", "The regional Writ belongs to a civic office, not to the Gardener's body. Independent research testimony, a disconnected coercive feed or disabled keeper machinery can each permit lawful succession.",[{"label":"TRANSFER / RESEARCHER VOTE","action":"orchard:writ:researchers"},{"label":"TRANSFER / TECHNICAL ISOLATION","action":"orchard:writ:isolation"},{"label":"TRANSFER / KEEPER APPARATUS DISABLED","action":"orchard:writ:registry"},go_back()])
        "venn":
            show_choice("VENN-OF-GLASS / THE OPEN CAGE", "Venn keeps the latch inside a battered cage: 'She can leave. That's the part the wardens keep trying to improve.' The occupant's choice is not Ninth's property.",[{"label":"MEET VENN / LISTEN FIRST","action":"arc077:venn:meet"},{"label":"INVESTIGATE / ASK WHAT CONSENT MEANS","action":"arc077:venn:investigate"},go_back()])
        "venn_record":
            show_choice("NURSERY RECORD / REMOTE STAPLE ORDERS", "Original clinic orders authorise remote obedience staples for created organisms. The legal authority is explicit; their consent is not.",[{"label":"COPY ORIGINAL REMOTE ORDER","action":"arc077:venn:evidence"},go_back()])
        "venn_choice":
            show_choice("VENN / A DOOR THAT OPENS BOTH WAYS", "Ninth can protect the unlocked nursery and let the creatures choose; retain a temporary monitored enclosure; take control by coercion; or let Venn leave. None creates an owned companion prize.",[{"label":"HELP / INDEPENDENT NURSERY","action":"arc077:venn:decide:help"},{"label":"COMPROMISE / TEMPORARY PROTECTION","action":"arc077:venn:decide:compromise"},{"label":"EXPLOIT / FORCED STAPLES","action":"arc077:venn:decide:exploit"},{"label":"ABANDON / LET THE CAGES DEPART","action":"arc077:venn:decide:abandon"},go_back()])
        "venn_aftermath":
            show_choice("VENN / THE NEXT MORNING", "The nursery remains an actual place. Creatures may come or leave; a temporary enclosure needs further review. Your chosen action has a witnessed aftermath.",[{"label":"RECORD WITNESSED AFTERMATH","action":"arc077:venn:aftermath"},go_back()])
        "orchard_root_seed":
            show_choice("ORCHARD ROOT SEED / INDEPENDENT PATTERN", "One viable experimental root has survived without harvested human memory. The seed is a physical restoration clue, not a functioning city-wide correction replacement or a mandate.",[{"label":"RECORD AND PRESERVE UNIQUE ROOT SEED","action":"orchard:seed"},go_back()])
        "orchard_supplies":
            show_choice("NURSERY PUBLIC MEDICINE", "A single sealed Breath Ampoule is allocated here. Re-entering the district does not restock it.",[{"label":"CLAIM ONE FINITE MEDICAL ISSUE","action":"orchard:supplies"},go_back()])
        "hearth_return":
            show_choice("GLASS ORCHARD / SERVICE RAIL", "Return to Hearth Nine without losing growth, testimony, original samples or the rescued ward record.",[{"label":"RETURN TO HEARTH NINE","action":"travel:hearth"},go_back()])
        _:
            show_choice("UNREGISTERED ORCHARD SERVICE","No authored decision is attached here.",[go_back()])

func barracks_interaction_077(interaction_id: String) -> void:
    match interaction_id:
        "barracks_casualty_roll":
            show_choice("ANALOGUE CASUALTY ROLL", "These names were written before the defence orders erased personal identities. Read the paper as evidence; it does not automatically free soldiers or keep the gate guarded.",[{"label":"RECORD ORIGINAL SOLDIER NAMES","action":"barracks:roll"},go_back()])
        "barracks_guard_roster", "barracks_watch":
            show_choice("INDEPENDENT WATCH / STAFF COVER", "A separate guard roster assigns human staff to keep corridors safe after command authority changes. Freedom cannot simply abandon the clinic gates.",[{"label":"COPY REAL STAFFED SAFETY ROSTER","action":"barracks:roster"},go_back()])
        "barracks_platoon_vote":
            show_choice("PLATOON / THEIR OWN NAMES", "If the casualty roll and real watch staffing are both recorded, soldiers can vote to revoke illegal orders while leaving protection in place.",[{"label":"READ NAMES / CALL SOLDIERS ASSEMBLY","action":"barracks:vote"},go_back()])
        "barracks_signal":
            show_choice("SIGNAL ZERO / CONTRADICTORY ORDERS", "A Tech 5 operator can isolate the old coercive signal only after recording which real guards will stay. The intervention costs 2 Energy and 2 Labour.",[check_option("ISOLATE ORDER BUS / 2E + 2L","barracks:isolate",Game.check_attribute("Tech",5,0,"",bool(Game.state["defence"]["guard_roster"]),"staffed safety roster")),go_back()])
        "barracks_commandant":
            show_choice("BARRACKS COMMANDANT / DISTINCT FROM VOSS", "The regional Commandant controls this district's powered frame. Central Custodian Marshal Voss, if selected by the run, is a different individual.",[{"label":"CHALLENGE REGIONAL POWER FRAME","action":"barracks:fight"},go_back()])
        "barracks_writ":
            show_choice("DEFENCE WRIT / PUBLIC REGISTRY", "The registry accepts real soldiers' assembly, controlled signal isolation or succession after the Commandant's apparatus is stopped. It cannot be permanently destroyed in combat.",[{"label":"TRANSFER / SOLDIERS ASSEMBLY","action":"barracks:writ:platoon"},{"label":"TRANSFER / ORDER BUS ISOLATION","action":"barracks:writ:isolation"},{"label":"TRANSFER / APPARATUS DEFEAT","action":"barracks:writ:registry"},go_back()])
        "kest":
            show_choice("KEST-07 / A WARRANT IN NINTH'S HAND", "Kest shows Ninth a handwritten warrant. This alone proves nothing about Ninth having murdered him in an earlier run; the initial warrant is a deliberate forgery.",[{"label":"MEET KEST / CHALLENGE THE WARRANT","action":"arc077:kest:meet"},{"label":"COMPARE ORIGINAL REPRINT RECORDS","action":"arc077:kest:investigate"},go_back()])
        "kest_warrant":
            show_choice("FORGED WARRANT / PROVENANCE", "The warrant's signature resembles Ninth's, but no observed death record proves an earlier murder. The analogue forensics show a deliberate forgery.",[{"label":"COPY WARRANT AND LABEL FORGED","action":"arc077:kest:evidence"},go_back()])
        "kest_orders":
            show_choice("CONSECUTIVE SOLDIER PRINT ORDERS", "Multiple soldiers were ordered to execute successor prints of their own unit. Kest may decide to testify or demand vengeance; neither is Ninth's predetermined morality.",[{"label":"INVESTIGATE PRINT CHAIN WITH KEST","action":"arc077:kest:investigate"},go_back()])
        "kest_choice":
            show_choice("KEST / TESTIMONY OR OBEDIENCE", "Protect public testimony; accept a conditional memory-edit compromise; exploit Kest as a compliant guard; or let him depart. These decisions cannot fabricate a previous player's actions.",[{"label":"HELP / PROTECTED TESTIMONY","action":"arc077:kest:decide:help"},{"label":"COMPROMISE / LIMITED ERASURE","action":"arc077:kest:decide:compromise"},{"label":"EXPLOIT / IMPOSE NEW ORDERS","action":"arc077:kest:decide:exploit"},{"label":"ABANDON / LET HIM LEAVE","action":"arc077:kest:decide:abandon"},go_back()])
        "kest_aftermath":
            show_choice("KEST / WHO WEARS THE NAME", "The barracks reprint orders remain physically visible. A witnessed aftermath can be recorded after Ninth's actual decision, once.",[{"label":"RECORD LIVING AFTERMATH","action":"arc077:kest:aftermath"},go_back()])
        "barracks_heat_survey":
            show_choice("DEEP HEAT SURVEY / GEOLOGICAL MAP", "A dark linen field map records geothermal vents and evacuation routes. It may later power conventional pumps, but it contains no correction patterns and does not itself restore the city.",[{"label":"PRESERVE ONE UNIQUE HEAT SURVEY","action":"barracks:survey"},go_back()])
        "barracks_supplies":
            show_choice("PUBLIC DEFENCE ISSUE / FINITE", "One existing Breath Ampoule; not infinite consumables unlocked by crossing a district border.",[{"label":"ISSUE ONE SEALED AMPOULE","action":"barracks:supplies"},go_back()])
        "hearth_return":
            show_choice("QUIET BARRACKS / SERVICE RAIL", "Return to Hearth Nine. The Commandant's regional Defence Writ and Marshal Voss's central authority remain different legal stations.",[{"label":"RETURN TO HEARTH NINE","action":"travel:hearth"},go_back()])
        _:
            show_choice("UNREGISTERED BARRACKS SERVICE","No authored decision is attached here.",[go_back()])

func core_interaction_076(interaction_id: String) -> void:
    var core: Dictionary = Game.state.get("core",{})
    match interaction_id:
        "core_conscription_order":
            show_choice("FIRST SIGNATURE / HUMAN CONSCRIPTION ORDER", "The original architect signed an order allowing forced boundary-correction conscription. It was a human decision, not a machine error. The paper is physically preserved; Ninth's print lineage does not inherit the signer’s guilt.",[ {"label":"COPY ORIGINAL / PERMANENT EVIDENCE","action":"core:doc:order"},go_back()])
        "core_architect_objection":
            show_choice("SECOND SIGNATURE / ANALOGUE OBJECTION", "The same architect later objected to forced mnemonic correction. This recording is independent of the signed order. Nix corroborates only fragments preserved on her own analogue spool; she cannot know unseen events.",[ {"label":"PLAY AND COPY ORIGINAL RECORD","action":"core:doc:objection"},go_back()])
        "core_rail_charter":
            show_choice("EMERGENCY RAIL / CAPACITY IS FINITE", "The abandoned platform leads to breathable caverns, but the verified map lists fewer viable seats than Vesper has residents. Medicine, blankets and repair kits also occupy carriage space. No choice can evacuate everyone for free.",[ {"label":"COPY RAIL ROUTE AND CAPACITY LIMIT","action":"core:doc:rail"},go_back()])
        "core_excluded_wards":
            show_choice("UNREGISTERED NAMES / LATCH EVIDENCE", "Original ward-by-ward casualty lists show residents omitted from Archivist Latch's survival denominator. The totals were mathematically precise but the population counted was a policy choice.",[ {"label":"COPY LISTS WITH EVERY NAME","action":"core:doc:excluded"},go_back()])
        "core_voluntary_petition":
            show_choice("VOLUNTARY RISK / EDDA EVIDENCE", "Patients signed a revocable, limited-risk heating petition. Edda concealed it because it undermines compulsory triage. It is not permission to assign risk to nonconsenting patients.",[ {"label":"COPY ORIGINAL PATIENT PETITION","action":"core:doc:petition"},go_back()])
        "core_independent_radio":
            show_choice("INDEPENDENT GATE RADIO / VOSS EVIDENCE", "A sealed plan shows separate short-wave command would have reduced Voss's border disaster. He was right to fear coordination failure, but centralised orders were not the only possible response.",[ {"label":"COPY DATED RADIO PLAN","action":"core:doc:radio"},go_back()])
        "core_safety_bus":
            var bus_text: String = "The regulator can be isolated only if technicians prepare a staffed manual fallback. Costs 3 existing Energy and 2 Labour. Conventional electricity cannot replace correction patterns."
            show_choice("EXECUTIVE SAFETY BUS / PHYSICAL RETROFIT",bus_text,[check_option("WIRE SAFETY FALLBACK / PAY 3E + 2L","core:safety",Game.check_attribute("Tech",5)),go_back()])
        "core_carriage_repair":
            show_choice("SPARE CARRIAGE / PHYSICAL MAINTENANCE", "A second damaged carriage sits on existing track. Your local inspector verified 24 existing usable seats; repairs could make 12 more, still far below Vesper's population. Costs 2 physical salvage, 3 Labour and 2 Energy. None are free.",[ {"label":"REPAIR SPARE CARRIAGE / +12 REAL SEATS","action":"core:repair"},go_back()])
        "core_boarding_plan":
            show_choice("RAIL / PRIORITY IS NOT TRANSPORT", "A draft queue can prioritise vulnerable patients, maintenance crews, or defer allocation to public deliberation. No one boards from this menu; any future ending must check living people and actual vehicle capacity.",[ {"label":"DRAFT / PATIENTS AND INFANTS FIRST","action":"core:policy:patients_first"},{"label":"DRAFT / REPAIR AND ESCORT CREWS FIRST","action":"core:policy:repair_crews_first"},{"label":"DEFER TO OPEN PUBLIC ASSEMBLY","action":"core:policy:defer_public_vote"},go_back()])
        "core_cipher":
            show_choice("GOVERNOR'S MAINTENANCE CIPHER / OPTIONAL", "A single original brass punch card documents slow boundary re-calibration. It is the same item some records call the Founders' Cipher. The consent field is still blank. This does NOT grant a public mandate or replace the Deep Heat Survey and Orchard Root Seed.",[ {"label":"COPY UNIQUE CIPHER / REQUIRES TWO SIGNATURES + RAIL","action":"core:cipher"},go_back()])
        "core_custodian_docket":
            var custodian: String = Game.core_custodian()
            var names: Dictionary = {"Canon Edda":"The triage governor counted every bed and concealed a voluntary-risk petition. Patients must still be cared for after her removal.","Marshal Voss":"The gate commander's border disaster was real, but a separate radio plan existed. The defence positions need guards after his removal.","Archivist Latch":"Its survival forecasts omitted unregistered people. Even an accurate machine cannot choose whose lives count."}
            var text_body: String = str(names.get(custodian,"The executive charter must be reviewed."))
            if str(core.get("custodian_method","")) != "":
                show_choice("EXECUTIVE AUTHORITY / RESOLVED", "%s / %s. No canonical ending has been selected at this step. Present the signed record to the physical public assembly; the choice of settlement is still yours." % [custodian,str(core.get("custodian_fate",""))],[{"label":"ENTER THE CIVIC ASSEMBLY / FINITE EMERGENCY RAIL","action":"assembly:enter"},go_back()])
            else:
                text_body += "\n\nTwo original signatures and the rail charter must be copied before authority can change. The selected Custodian has its own counterevidence station."
                var options: Array = []
                if Game.core_main_records_complete():
                    options.append({"label":"PRESENT THREE-WRIT TRIBUNAL / NEED CUSTODIAN PROOF","action":"core:resolve:tribunal"})
                    options.append(check_option("SEEK ABDICATION","core:resolve:abdication",Game.abdication_check()))
                    options.append(check_option("CONTAIN AUTHORITY","core:resolve:containment",Game.check_attribute("Tech",5,0,"",bool(core.get("safety_bus_prepared",false)),"prepared safety bus")))
                    if bool(core.get("actuator_disabled",false)):
                        options.append({"label":"REMOVE POWERED ENFORCEMENT / NO PERSON KILLED","action":"core:resolve:apparatus_shutdown"})
                    else:
                        options.append({"label":"CHALLENGE THE POWERED EXECUTIVE ACTUATOR","action":"core:fight"})
                options.append(go_back())
                show_choice("%s / EXECUTIVE DOCKET" % custodian.to_upper(),text_body,options)
        "core_assembly_gate_078":
            if Game.can_enter_assembly_078():
                show_choice("PUBLIC ASSEMBLY / FINAL SETTLEMENT", "Executive authority has been resolved. The remaining decision concerns the human cost of the system, the finite railway and revocable public consent. No outcome is triggered by merely entering.",[ {"label":"ENTER PUBLIC ASSEMBLY","action":"assembly:enter"},go_back()])
            else:
                show_choice("PUBLIC ASSEMBLY / NOT YET OPEN", "Read both architect signatures and the rail charter; resolve the selected Custodian through a real alternative to coercion or a defeated actuator.",[go_back()])
        "core_return_rail":
            show_choice("FULL FREIGHT LIFT / RETURN", "Your archived signatures, railway capacity and any executive authority outcome remain saved. The two-Writ development trial remains a separate prototype.",[ {"label":"RETURN TO HEARTH NINE","action":"core:return"},go_back()])
        _:
            show_choice("UNREGISTERED CENTRAL SERVICE","No authored archive record at this physical station.",[go_back()])

func ashmarket_interaction(interaction_id: String) -> void:
    var trade: Dictionary = Game.state["trade"]
    var has_writ: bool = Game.state["writs"].has("qobj_writ_of_trade")
    match interaction_id:
        "market_contract_archive":
            if bool(trade["duplicate_contracts"]):
                show_choice("PUBLIC ARCHIVE / DUPLICATE ORIGINALS", "Two different people are bonded under the same contractual identity. The ink remains available for public inspection, not another reward.",[go_back()])
            else:
                show_choice("TRADE ARCHIVE / DOUBLE SALE", "A physical carbon original lists the same person's legal identity as collateral in two unrelated transactions. The Collector's clearing machine approved both. The proof alone does not say what witnesses want done.",[{"label":"COPY BOTH CONTRACTS / ORIGINAL EVIDENCE","action":"market:contracts"},go_back()])
        "market_witness_counter":
            if bool(trade["buyer_testimony"]):
                show_choice("BUYERS / TESTIMONY ON RECORD", "The porter and a parent each confirmed their account independently. No additional testimony can be fabricated by reopening the counter.",[go_back()])
            else:
                show_choice("BUYERS / A SECOND ACCOUNT", "A parent recognises her child's name on a creditor's collateral sheet. The porter states he has been assigned another citizen's sentence. Neither witness asks Ninth to own the evidence.",[{"label":"TAKE TWO INDEPENDENT STATEMENTS","action":"market:testimony"},go_back()])
        "market_buyer_council":
            if bool(trade["coalition_recorded"]):
                show_choice("BUYERS / RECORD PUBLIC", "The contracts and independently witnessed protest have been registered. Speech 7 can now challenge the Collector without violence; other routes remain.",[go_back()])
            elif bool(trade["duplicate_contracts"]) and bool(trade["buyer_testimony"]):
                show_choice("BUYERS / A CONTESTABLE CLAIM", "Two originals and two independent witnesses can support a coalition. The Collector has not yet signed the emergency Writ transfer.",[{"label":"CONVENE PUBLIC BUYERS / RECORD COALITION","action":"market:coalition"},go_back()])
            else:
                show_choice("BUYERS / NO FABRICATED QUORUM", "Find the physical duplicate contracts and obtain independent buyer testimony before claiming a public coalition exists.",[go_back()])
        "market_counting_lock":
            if bool(trade["counting_lock_isolated"]):
                show_choice("TOKEN PRESS / ISOLATED", "The counting locks have physically withdrawn. This consumed two Energy and one Labour; the original disputed contracts remain preserved.",[go_back()])
            else:
                show_choice("TOKEN PRESS / CONTROL BUS", "A Tech 5 operator can isolate the bonded locks for two Energy and one Labour. The system can be stopped without erasing the buyer's contract evidence.",[check_option("ISOLATE THE COUNTING LOCKS","market:sabotage",Game.check_attribute("Tech",5)),go_back()])
        "market_collector_desk":
            if has_writ:
                show_choice("COLLECTOR / TRADE FILED", "The emergency Writ is in the three-office docket; no repeat transfer is possible. The clearing service still has to answer for its original debts.",[go_back()])
            elif bool(trade["collector_defeated"]):
                show_choice("COLLECTOR / VACATED OFFICE", "The keeper is absent. The public register, not a dropped personal trinket, holds the Trade Writ.",[go_back()])
            else:
                var opts: Array = []
                opts.append(check_option("PRESENT THE BUYERS' CONTRACT CHALLENGE","trade:coalition",Game.coalition_check()))
                opts.append(check_option("FORCE A SIGNATURE / SECURITY COST","market:intimidate",Game.check_attribute("Force",6)))
                opts.append({"label":"CHALLENGE THE COLLECTOR'S SECURITY / FIGHT","action":"market:fight"})
                opts.append(go_back())
                show_choice("COLLECTOR / THE SELLING PRICE", "'They wanted hinges once. Now they want the keys to someone they no longer own.' Documented buyers' contracts and testimony let a Speech case transfer the Writ publicly. Force has a witnessed institutional cost. Counting-lock isolation and combat remain possible.",opts)
        "market_trade_registry":
            if has_writ:
                show_choice("TRADE WRIT / EMERGENCY QUORUM", "The durable public register confirms the Trade Writ is already transferred. Labour and Faith remain distinct; no second copy is created.",[go_back()])
            else:
                var opts: Array = []
                if bool(trade["counting_lock_isolated"]):
                    opts.append({"label":"TRANSFER TRADE WRIT / RELEASED COUNTING LOCKS","action":"trade:sabotage"})
                if bool(trade["collector_defeated"]):
                    opts.append({"label":"TRANSFER TRADE WRIT / REGISTRY SUCCESSION","action":"trade:registry"})
                if bool(trade["intimidation_recorded"]):
                    opts.append({"label":"TRANSFER TRADE WRIT / WITNESSED THREAT","action":"trade:intimidation"})
                opts.append(go_back())
                show_choice("PUBLIC TRADE REGISTRY", "This Writ cannot be lost when the Collector dies. It may transfer after a public coalition signature, a disabled bonded counting lock, a witnessed coercive signature, or office succession.",opts)
        "market_rain_cistern":
            show_choice("THE PRICE OF RAIN / ORIGINAL ALLOTMENT", "The water tank is physically full. A broker charges the poorest queue more per cup. This dial establishes what is actually stored; the decision belongs at the staffed public hearing.",[ {"label":"COPY TANK DIAL AND SIGNED TARIFF","action":"market:rain_evidence"},go_back()])
        "market_rain_hearing":
            if str(trade["rain_claim"]) != "":
                show_choice("THE PRICE OF RAIN / DECISION RECORDED", "Outcome: %s. The tank's contents did not regenerate. The civic ledger records the transfer and its material or social cost." % str(trade["rain_claim"]),[go_back()])
            elif not bool(trade["rain_records_seen"]):
                show_choice("THE PRICE OF RAIN / NO VERIFIED READING", "Inspect the actual cistern dial and signed water tariff before deciding whose claim can be trusted.",[go_back()])
            else:
                show_choice("THE PRICE OF RAIN / PUBLIC DECISION", "Open the existing water tank with a finite shift of workers and electricity, or accept a broker's private levy. Neither option creates extra water or erases the other claimants.",[{"label":"OPEN PUBLIC TANK / COSTS 2 LABOUR + 1 ENERGY","action":"market:rain_open"},{"label":"TAKE THE BROKER'S CUT / PUBLIC TRUST COST","action":"market:rain_cut"},go_back()])
        "market_emergency_locker":
            if bool(trade["supplies_claimed"]):
                show_choice("MARKET DEFENCE ISSUE / EMPTY", "That lot was issued once. No repeat ammo or medical stock is created on revisits.",[go_back()])
            else:
                show_choice("MARKET DEFENCE ISSUE / SEALED", "One documented issue: 18 Ledger Slugs and one Breath Ampoule. A finite store, not a renewable kill reward.",[{"label":"CLAIM FINITE MARKET STORE","action":"market:supplies"},go_back()])
        "market_broker":
            show_choice("WATER BROKER / A CLEAR TANK", "'The water is there. I rent the right to touch the valve.' His entitlement is disputed by the public tariff near the cistern.",[go_back()])
        "market_porter":
            show_choice("MISNAMED PORTER / THE BORROWED VERDICT", "'It isn't my name on the sentence. They issued me somebody else's punishment. Find the originals before you say I agreed.' He can testify independently at the buyers' counter.",[go_back()])
        "hearth_return":
            show_choice("MUNICIPAL RAIL / HEARTH NINE", "The Trade Writ and evidence persist when the rail returns to the clinic.",[{"label":"TRAVEL TO HEARTH NINE","action":"travel:hearth"},go_back()])
        "sootworks_transfer":
            show_choice("MUNICIPAL RAIL / SOOTWORKS", "Trade and Labour offices remain independently staffed.",[{"label":"TRAVEL TO SOOTWORKS","action":"travel:sootworks"},go_back()])
        "basilica_transfer":
            show_choice("MUNICIPAL RAIL / FLOOD BASILICA", "The public hearing and Faith Writ remain independently accessible.",[{"label":"TRAVEL TO FLOOD BASILICA","action":"travel:basilica"},go_back()])
        _:
            show_choice("ASHMARKET / UNREGISTERED SERVICE", "No authored record exists for that equipment.",[go_back()])

func sootworks_interaction(interaction_id: String) -> void:
    # Defensive routing: ordinary play handles this directly in _on_interact.
    if interaction_id == "sootworks_relief":
        _optional_discovery(interaction_id)
        return
    var brin: Dictionary = Game.state["brin"]
    var labour: Dictionary = Game.state["labour"]
    var writ_owned: bool = Game.state["writs"].has("qobj_writ_of_labour")
    match interaction_id:
        "labour_clerk":
            if writ_owned:
                show_choice("LABOUR CLERK / TRANSFER SEALED", "The distinct Labour Writ is registered under the Emergency Quorum Charter. Its public source remains available for inspection.",[go_back()])
            elif bool(labour["millwright_defeated"]):
                show_choice("LABOUR CLERK / REGISTRY SUCCESSION", "'The office outlasts its officer.' With the Millwright gone, claim the durable Writ at the public wicket against the southern wall.",[go_back()])
            elif bool(brin["payroll_seen"]):
                show_choice("LABOUR CLERK / PAID DEBT", "'The cylinder is genuine. Brin may speak, but the stewards must decide.' A public hearing can follow the four-stage investigation; the sabotage and combat routes remain available.",[go_back()])
            else:
                show_choice("LABOUR CLERK / THE CHARTER", "'You cannot lose a public Writ by losing its keeper. Copy the original cylinder, seek the shop stewards, or confront the Millwright. We have to keep running the furnaces meanwhile.'",[go_back()])
        "basilica_transfer":
            show_choice("SERVICE RAIL / FLOOD BASILICA", "The Faith office is accessible over the municipal rail.",[{"label":"TRAVEL TO FLOOD BASILICA","action":"travel:basilica"},go_back()])
        "ashmarket_transfer":
            show_choice("SERVICE RAIL / ASHMARKET", "The Trade office is reachable through a separate staffed rail line.",[{"label":"TRAVEL TO ASHMARKET","action":"travel:ashmarket"},go_back()])
        "hearth_return":
            show_choice("SERVICE RAIL / HEARTH NINE", "The municipal transfer remains open. The current district, quest events and enemy damage will be saved before departing.",[{"label":"RETURN TO HEARTH NINE","action":"travel:hearth"},go_back()])
        "brin":
            if not bool(brin["alive"]):
                show_choice("BRIN / ABSENT", "The workshop has no living speaker. The payroll record and public Writ remain accessible.",[go_back()])
            elif str(brin["stage"])=="unmet":
                show_choice("BRIN HARKER / THE SHIFT CARD", "Brin repairs a spoon with wire. 'It isn't the work. It's that they charge rent for the hours I'm asleep.' His old card records ninety-one years across printed bodies. He asks you to inspect the original freight payroll cylinder.",[{"label":"HEAR HIM OUT / RECORD THE MEETING","action":"brin:meet"},go_back()])
            elif str(brin["stage"])=="encountered" and bool(brin["payroll_seen"]):
                show_choice("BRIN / A SETTLED DEBT", "You hold an original cylinder showing the debt was paid forty-three years ago. 'Well, there goes my excuse for being late home.' Brin asks you to keep the copy where the foremen cannot burn it.",[{"label":"SHOW HIM THE CYLINDER / INVESTIGATE","action":"brin:investigate"},go_back()])
            elif str(brin["stage"])=="encountered":
                show_choice("BRIN / EVIDENCE STILL MISSING", "'The copy is in the freight office. I don't want a promise; I want the original sum.' Find the cylinder behind the northwest benches.",[go_back()])
            elif str(brin["stage"])=="investigated":
                show_choice("BRIN / THE WORKERS' CHOICE", "'Please don't make a speech on our behalf. The shop stewards will hear evidence at the council desk.' Brin will not decide for every worker.",[go_back()])
            elif str(brin["stage"])=="decision":
                show_choice("BRIN / THE SECOND WHISTLE",brin_aftermath_text(),[{"label":"WITNESS THE CONSEQUENCE","action":"brin:aftermath"},go_back()])
            else:
                show_choice("BRIN / THE WORK CONTINUES",brin_aftermath_text(),[go_back()])
        "payroll_cylinder":
            if bool(brin["payroll_seen"]):
                show_choice("ORIGINAL PAYROLL / RETAINED", "The metal cylinder holds the same cancelled debt and date. Copies do not generate extra XP or evidence.",[go_back()])
            else:
                show_choice("ORIGINAL PAYROLL / FORTY-THREE YEARS", "The debt was cleared forty-three years ago. The reprint payroll continues charging new bodies for a settled obligation. This cylinder is independent documentary evidence, not a memory copied from Brin.",[{"label":"COPY ORIGINAL CYLINDER / +20 EVIDENCE XP","action":"brin:record_payroll"},go_back()])
        "workers_council":
            if writ_owned:
                show_choice("LABOUR COUNCIL / TRANSFER COMPLETE","The Writ of Labour has been transferred once. The record can be read, not claimed again.",[go_back()])
            elif not bool(brin["alive"]):
                show_choice("LABOUR COUNCIL / BRIN DEAD", "The workers cannot hear Brin now. His record remains, but Ninth cannot stage his living testimony. Other Writ routes are available.",[go_back()])
            elif str(brin["stage"])=="investigated":
                show_choice("LABOUR COUNCIL / SUBMIT THE CYLINDER", "The workers inspect the clear debt. An orderly stoppage can preserve the neighbouring ward's heat with real labour and energy costs. A partial emergency-crew compromise is also possible. Betrayal earns an immediate material reward but loses workshop support.",[
                    {"label":"SAFE STRIKE / RELEASE WORKERS / BRIN'S TORQUE","action":"brin:help"},
                    {"label":"WORKER VOTE / PARTIAL RELEASE / UNION RIVET KIT","action":"brin:compromise"},
                    {"label":"REPORT ORGANISERS TO SECURITY / CHAIN OF WAGES","action":"brin:exploit"},
                    {"label":"WITHDRAW SUPPORT / BRIN ACTS ALONE","action":"brin:abandon"}, go_back()])
            elif str(brin["decision"])=="help" and bool(brin["alive"]):
                show_choice("COUNCIL / WRIT OF LABOUR", "The stewards have recorded the cleared payroll debt and voted for a safe stoppage. They may legally transfer the Labour Writ from the Millwright's custody.",[{"label":"ACCEPT LABOUR WRIT / CIVIC TRANSFER","action":"writ:council"},go_back()])
            else:
                show_choice("WORKERS' COUNCIL / NOT YET READY", "Meet Brin and present original evidence to request a supported stoppage. Or disable the isolated control line, fight the Millwright, and use the public registry. None of these options requires a high-Speech build.",[go_back()])
        "sootworks_regulator":
            if writ_owned:
                show_choice("ISOLATION BUS / WRIT ACQUIRED", "The elected route has already recorded the Writ; the control bus must not produce another credential.",[go_back()])
            else:
                show_choice("SOOTWORKS / ISOLATION BUS", "This service switch cuts only the control circuit; it does not conjure power or rewrite the payroll. The shutdown uses 3 Energy and 2 Labour capacity.", [check_option("ISOLATE THE MILLWRIGHT'S CONTROL BUS","soot:sabotage",Game.check_attribute("Tech",5)),go_back()])
        "millwright_order":
            if writ_owned:
                show_choice("MILLWRIGHT / DISPUTED AUTHORITY", "The public registry has recorded your Labour Writ. Office hostility and civic consequences remain.",[go_back()])
            elif bool(labour["millwright_defeated"]):
                show_choice("MILLWRIGHT / OFFICE HOLDER GONE", "The frame lies silent, but public law outlives the keeper. Retrieve the Writ from the staffed register.",[go_back()])
            elif bool(labour["regulator_isolated"]):
                show_choice("MILLWRIGHT / REGULATOR DISCONNECTED", "The foreman's frame cannot enforce its control signal. The Writ is accessible by technical intervention, while workers inherit the maintenance burden.",[{"label":"REGISTER THE LABOUR WRIT / SABOTAGE ROUTE","action":"writ:sabotage"},go_back()])
            else:
                show_choice("MILLWRIGHT / ENFORCE THE SHIFT", "The order board promises heat to the city, but binds workers through a debt already cleared. The keeper can be defeated physically, or bypassed through the evidence-backed council or the regulator.",[{"label":"ISSUE OPEN CHALLENGE / FRAME TURNS HOSTILE","action":"soot:fight"},go_back()])
        "labour_registry":
            if writ_owned:
                show_choice("LABOUR WRIT / FILED", "A single stamped transfer is already on the public register. Repeated interaction cannot award another Writ or XP.",[go_back()])
            elif bool(labour["millwright_defeated"]):
                show_choice("PUBLIC WICKET / REGISTRY SUCCESSION", "The Millwright is dead or disabled. A living clerk checks the emergency charter and can legally transfer the distinct Labour Writ without Brin's cooperation.",[{"label":"TAKE WRIT / PUBLIC REGISTRY FALLBACK","action":"writ:registry"},go_back()])
            elif str(brin["decision"])=="help" and bool(brin["alive"]):
                show_choice("PUBLIC WICKET / WORKER VOTE", "The stewards have certified the cylinder and the strike. Transfer remains available at the council desk.",[go_back()])
            else:
                show_choice("PUBLIC WICKET / DURABLE RECORD", "The Writ cannot be burned with its office holder. Defeat the Millwright and file for succession, or bring the original payroll record to the living council.",[go_back()])
        "sootworks_weapon_rack":
            if Game.state["event_ids"].has("sootworks.worker_tool_issue"):
                show_choice("WORKER'S TOOLS / REGISTER", "One physical tool was issued to this Ninth. No additional weapon can be copied from the register.", [go_back()])
            else:
                show_choice("WORKER'S TOOLS / FINITE ISSUE", "The workshop can spare ONE service tool: a Coil Shotgun shutter opener or a Nail Storm factory riveter. Either replaces your empty heavy slot and carries a finite stock of ammunition. This is not an unlimited armory.", [{"label":"ISSUE COIL SHOTGUN + 10 SHELLS", "action":"issue_tool:coil"},{"label":"ISSUE NAIL STORM + 120 RIVETS", "action":"issue_tool:nail"},go_back()])
        "sootworks_locker":
            if Game.state["event_ids"].has("sootworks.emergency_supplies"):
                show_choice("SOOTWORKS / SUPPLIES ISSUED", "The one staffed emergency ration is exhausted for this attempt.",[go_back()])
            else:
                show_choice("SOOTWORKS / FINITE DEFENCE STOCK", "24 physical Ledger Slugs and two medical ampoules, one issued lot. The stock is not refreshed by travelling between districts.",[{"label":"CLAIM ONE-TIME DEFENCE ISSUE","action":"soot:ration"},go_back()])
        _:
            show_choice("UNREGISTERED LABOUR SERVICE", "This machine has no authored action in Build 04.",[go_back()])

func basilica_interaction(interaction_id: String) -> void:
    if interaction_id == "basilica_notes":
        _optional_discovery(interaction_id)
        return
    var ossa: Dictionary = Game.state["ossa"]
    var faith: Dictionary = Game.state["faith"]
    var writ_owned: bool = Game.state["writs"].has("qobj_writ_of_faith")
    match interaction_id:
        "ossa":
            if not bool(ossa["alive"]):
                show_choice("OSSA / NO LIVING SPEAKER","Only the reel and public documents remain; nobody may ventriloquise Ossa's testimony.",[go_back()])
            elif str(ossa["stage"]) == "unmet":
                show_choice("SISTER OSSA / AN OMITTED NOTE","'There used to be a sixth note. We sang it when the west ward flooded. Then we kept singing after the water went away.' She wants to know what the maintenance reel proves.",[ {"label":"MEET OSSA / HEAR HER ACCOUNT","action":"ossa:meet"},go_back()])
            elif str(ossa["stage"]) == "encountered" and bool(ossa["hymn_seen"]):
                show_choice("OSSA / FOUND RECORD","The original governor reel proves the coercive sixth note was a machine signal; it does not mean all worship was false.",[ {"label":"COMPARE REEL / INVESTIGATE","action":"ossa:investigate"},go_back()])
            elif str(ossa["stage"]) == "encountered":
                show_choice("OSSA / SEEK THE REEL","'Please find the physical maintenance reel before you ask the other singers to decide.' It is at the northwestern dry archive shelf.",[go_back()])
            elif str(ossa["stage"]) == "investigated":
                show_choice("OSSA / LEAVE THE CHOICE TO THE CONGREGATION","'I will not order them to stop singing. Take this record to the lay council in the western nave.'",[go_back()])
            elif str(ossa["stage"]) == "decision":
                show_choice("OSSA / AFTERMATH",ossa_aftermath_text(),[{"label":"WITNESS HER AFTERMATH","action":"ossa:aftermath"},go_back()])
            else:
                show_choice("OSSA / CONSEQUENCE",ossa_aftermath_text(),[go_back()])
        "hymn_reel":
            if bool(ossa["hymn_seen"]):
                show_choice("ARCHIVAL REEL / COPIED","The same analogue timing survives. It cannot award XP twice or manufacture Ossa's consent.",[go_back()])
            else:
                show_choice("GOVERNOR REEL / SIXTH NOTE","An unchanged mechanical timing reel proves a hymn was used to enforce a command. It does not establish who voluntarily continued to sing.",[{"label":"COPY ORIGINAL REEL / RECORD EVIDENCE","action":"ossa:record_hymn"},go_back()])
        "faith_council":
            if writ_owned:
                show_choice("LAY COUNCIL / CREDENTIAL SEALED","The Faith Writ has already been recorded in the Quorum ledger; no duplicate can be awarded.",[go_back()])
            elif not bool(ossa["alive"]):
                show_choice("COUNCIL / OSSA ABSENT","The congregation retains autonomy but Ossa cannot lead this petition from the grave. The Cantor's technical or combat/registry route remains open.",[go_back()])
            elif str(ossa["stage"]) == "investigated":
                show_choice("LAY COUNCIL / GOVERNOR'S SIXTH NOTE","The congregation must decide whether to disconnect the coercive signal while retaining their shared prayers. The actions impose different recorded costs.",[
                    {"label":"PUBLIC VOTE / FREE THE CHOIR / CHOIRBREAKER","action":"ossa:help"},
                    {"label":"TEMPORARY LICENSE / LIMITED CONTINUATION","action":"ossa:compromise"},
                    {"label":"AMPLIFY FOR SECURITY / OVERRIDE CONSENT","action":"ossa:exploit"},
                    {"label":"LEAVE OSSA TO CONFRONT THE COUNCIL","action":"ossa:abandon"},go_back()])
            elif str(ossa["decision"]) == "help" and bool(ossa["alive"]):
                show_choice("LAY COUNCIL / WRIT OF FAITH","The lay vote lawfully removes the coercive Cantor's authority without dissolving faith. This is a witnessed civic Writ transfer.",[{"label":"TAKE FAITH WRIT / PUBLIC COUNCIL","action":"faith:council"},go_back()])
            else:
                show_choice("CONGREGATION / UNRESOLVED","Meet Ossa, study the source recording, then return. The public registry route is independent if the Cantor falls.",[go_back()])
        "basilica_signal":
            if writ_owned:
                show_choice("SIGNAL GOVERNOR / PUBLIC AUDIT","A Writ already exists in the docket. Isolation is not needed to duplicate it.",[go_back()])
            else:
                show_choice("GOVERNOR / COMMAND BUS","The dangerous command frequency can be isolated through an existing service bypass. Requires Tech 5; costs finite Energy and Labour; it does not stop citizens praying.",[check_option("ISOLATE CONTROL GOVERNOR","basilica:isolate",Game.check_attribute("Tech",5)),go_back()])
        "cantor_order":
            if writ_owned:
                show_choice("CANTOR / OFFICE DISPUTED","The public faith register already bears this attempt's single credential.",[go_back()])
            elif bool(faith["governor_isolated"]):
                show_choice("CANTOR / SIGNAL STANDS DOWN","The machine's enforcement line is physically isolated. The Cantor's Writ can be registered through lawful intervention.",[{"label":"REGISTER FAITH WRIT / ISOLATION","action":"faith:sabotage"},go_back()])
            elif bool(faith["cantor_defeated"]):
                show_choice("CANTOR / HOLDER DEFEATED","The office outlasts the keeper; the public wicket remains staffed.",[go_back()])
            else:
                show_choice("CANTOR / CONTROL SIGNAL","The Cantor coerced patients through an operational hymn. You may challenge the powered frame, present a supported congregation vote, or isolate the governor bus.",[{"label":"CHALLENGE CANTOR / FIGHT","action":"basilica:fight"},go_back()])
        "faith_registry":
            if writ_owned:
                show_choice("FAITH WRIT / FILED","This Writ is unique and survives in the public docket. Repeated interaction cannot duplicate it.",[go_back()])
            elif bool(faith["cantor_defeated"]):
                show_choice("PUBLIC WICKET / KEEPER GONE","The Cantor has been removed. The verger checks the charter and passes the actual Writ through a staffed window.",[{"label":"TAKE FAITH WRIT / REGISTRY SUCCESSION","action":"faith:registry"},go_back()])
            else:
                show_choice("PUBLIC WICKET / FAITH","The office's credential cannot disappear. Seek the original hymn reel and lay council, isolate the signal bus, or remove the Cantor and use registry succession.",[go_back()])
        "faith_clerk":
            show_choice("FAITH CLERK / PUBLIC REGISTER","'This is a register, not a confession. We keep the people's records even if the Cantor is gone.'",[go_back()])
        "hearing_station":
            var hearing: Dictionary = Game.state["hearing"]
            if bool(hearing["passed"]):
                show_choice("PUBLIC FIELD HEARING / PASSED","The original transcript remains in the pressure docket. The loaner Rootkin was returned; the Bell Wretch is not a prize.",[go_back()])
            elif bool(hearing["active"]):
                hearing_choices("The civic interference field is still open.")
            else:
                show_choice("CIVIC FIELD HEARING / FREE PUBLIC LOANER","A Rootkin volunteered for public-service interference calibration. This is one active participant against an independently recorded Bell Wretch signal. You may withdraw and retry freely; nobody is captured or granted as a prize.",[{"label":"BEGIN ROOTKIN HEARING / FREE LOANER","action":"hearing:start"},go_back()])
        "basilica_locker":
            if Game.state["event_ids"].has("basilica.emergency_supplies"):
                show_choice("DEFENCE RATION / EXHAUSTED","This staffed emergency lot was already issued in this attempt.",[go_back()])
            else:
                show_choice("BASILICA / FINITE SUPPLIES","24 physical Ledger Slugs and two Breath Ampoules; once per attempt.",[{"label":"ISSUE EMERGENCY SUPPLIES","action":"basilica:ration"},go_back()])
        "ashmarket_transfer":
            show_choice("BASILICA SERVICE RAIL / ASHMARKET", "The Trade Writ and original contracts remain accessible in the municipal market.",[{"label":"TRAVEL TO ASHMARKET","action":"travel:ashmarket"},go_back()])
        "hearth_return":
            show_choice("MUNICIPAL TRANSFER / HEARTH NINE","Your recorded Faith Writ, Ossa outcome and hearing transcript persist.",[{"label":"RETURN TO HEARTH NINE","action":"travel:hearth"},go_back()])
        "sootworks_transfer":
            show_choice("MUNICIPAL TRANSFER / SOOTWORKS","The service rail remains open; no false district closure is implied.",[{"label":"TRAVEL TO SOOTWORKS","action":"travel:sootworks"},go_back()])
        _:
            show_choice("BASILICA / UNREGISTERED MACHINE","This interaction is not authored in the current build.",[go_back()])

func _refresh_field_visuals() -> void:
    if not is_instance_valid(world) or str(Game.state.get("zone","")) != "basilica": return
    var phase: String = Game.hearing_phase()
    var tint: Color = Color("#db715e") if phase == "rising" else (Color("#9fa8c0") if phase == "shielded" else Color("#9cd9b2"))
    for node in world.get_children():
        if node is Sprite3D and str(node.name).begins_with("BELL WRETCH"):
            node.modulate = tint
            node.scale = Vector3.ONE * (1.17 if phase == "rising" else 1.0)
        elif node is Sprite3D and str(node.name).begins_with("PUBLIC ROOTKIN"):
            node.modulate = Color("#a1d7bb") if bool(Game.state["hearing"].get("active",false)) else Color.WHITE

func hearing_choices(note: String) -> void:
    var options: Array = [
        {"label":"PRESS / strong when EXPOSED, weak otherwise","action":"hearing:Press"},
        {"label":"ATTUNE / steady when RISING or SHIELDED; tires if repeated","action":"hearing:Attune"},
        {"label":"BRACE / cushion the next field response","action":"hearing:Brace"},
        {"label":"OBSERVE / document a signal rhythm","action":"hearing:Observe"},
        {"label":"WITHDRAW / free retry remains available","action":"hearing:Withdraw"}]
    show_choice("PUBLIC HEARING / FIVE CIVIC COMMANDS",note+"\n\n"+Game.hearing_summary(),options)

func ossa_aftermath_text() -> String:
    if not bool(Game.state["ossa"]["alive"]):
        return "Ossa is dead. Only the reel and other independent documents can testify."
    match str(Game.state["ossa"]["decision"]):
        "help": return "Ossa sings one unamplified note. The congregation may choose to answer. The coercive command channel is disconnected; its Energy/Labour costs are counted."
        "compromise": return "The temporary-use licence is posted in public. The patient risk remains explicit; Ossa refuses to call the agreement permanent."
        "exploit": return "The powered hymn grows louder. Ossa turns toward the wall while her objection is drowned out."
        "abandon": return "Ossa questions the other singers herself. Ninth did not decide for them, and the Faith Writ remains unresolved."
        _: return "Ossa has not reached a decision; she can speak only to events she has witnessed."

func brin_aftermath_text() -> String:
    if not bool(Game.state["brin"]["alive"]):
        return "Brin is dead. No later speech or reward can be attributed to him."
    match str(Game.state["brin"]["decision"]):
        "help": return "The next shift changes without Brin. He eats sitting down. A controlled heat reduction cost time but did not strip the neighbouring ward of its air."
        "compromise": return "Brin tightens a valve and asks which freed workers will take his old bunk. The emergency crew remains by vote, not forced labour."
        "exploit": return "The clock stamps a fresh debt card. Brin has been sent back inside; he will not offer another free decision."
        "abandon": return "Brin has taken his own evidence to the public desk. Ninth has no right to invent an outcome for him."
    return "His decision remains his own."

func clerk_dialogue() -> void:
    if bool(Game.state["lung"]["acquired"]):
        show_choice("REQUISITION CLERK / TRANSFER RECORDED", "The clerk checks the register. 'You've claimed one physical Lung. The receiving clinic will have to sign for it.'",[go_back()])
        return
    if bool(Game.state["flags"]["guard_defeated"]):
        show_choice("REQUISITION CLERK / GUARD REMOVED", "'The guard has stopped answering. The public rack and its record remain. The claim is still disputed, even if you take it by force.'",[{"label":"SEIZE LUNG / ENTER AN ASSAULT REPORT","action":"claim:fight"},go_back()])
        return
    show_choice("REQUISITION CLERK / COMPETING ALLOTMENTS", "'We have one spare Cinder Lung and more than one ward in need.'\n\nA public allocation hearing needs the copied requisition record. Force remains possible whatever your build.",[check_option("PUBLIC ALLOCATION HEARING","claim:bargain",Game.bargain_check()),{"label":"DEMAND RESERVE BY FORCE / ENFORCER RESPONDS","action":"begin_fight"},go_back()])

## A dialogue option gated by a deterministic check: always visible, showing the
## exact sum, and disabled (not clickable) until it is met. Bible 7.1 / 13.
func check_option(label: String, action: String, check: Dictionary) -> Dictionary:
    return {"label": "%s  %s" % [str(check["text"]), label], "action": action, "enabled": bool(check["ok"])}

func go_back() -> Dictionary:
    return {"label":"CLOSE DOCKET / RETURN TO WORLD","action":"close"}

func show_choice(title: String,body: String,options: Array) -> void:
    hud.open_modal(title,body,options)

func lift_interaction(interaction_id: String) -> void:
    match interaction_id:
        "edda":
            show_choice("CANON EDDA / TRIAGE GOVERNOR", "'I counted the beds twice. I cannot fit another child in a number.' Edda has withheld a voluntary-risk petition. Neither a personal threat nor a false copy can count as public consent.",[go_back()])
        "eddas_petition":
            if bool(Game.state["slice_finale"]["petition_seen"]):
                show_choice("EDDA / ORIGINAL PETITION", "The paper is copied into the public docket. It cannot be collected twice.",[go_back()])
            else:
                show_choice("EDDA / VOLUNTARY-RISK RECORD", "The original signed petition authorises carefully limited risk by consenting adults, not an unlimited right to assign other people's bodies.",[{"label":"COPY PETITION / PUBLIC EVIDENCE","action":"slice:petition"},go_back()])
        "eddas_chamber":
            if bool(Game.state["slice_finale"]["resolved"]):
                show_slice_card()
            else:
                var options: Array = []
                if bool(Game.state["slice_finale"]["petition_seen"]):options.append({"label":"PRESENT PETITION / REVOCABLE PUBLIC MANDATE","action":"slice:public_mandate"})
                if bool(Game.state["slice_finale"]["apparatus_defeated"]):options.append({"label":"SHUT DOWN APPARATUS / STABILISE PATIENTS","action":"slice:apparatus_shutdown"})
                else:options.append({"label":"CHALLENGE COERCIVE TRIAGE APPARATUS","action":"slice:fight"})
                options.append({"label":"ACCEPT COERCIVE CONTINUITY / LIMITED SAFETY","action":"slice:coercive_continuity"})
                options.append(go_back())
                show_choice("EDDA / PUBLIC DOCKET", "This is the two-Writ DEVELOPMENT slice, not a final campaign ending. The pressure-ward patients stay physically present. Evidence and coercion have different costs.",options)
        "slice_return":
            show_choice("FREIGHT TRIAL / RETURN", "The clinic and other two districts are still accessible. This temporary two-Writ test does not override the full three-Writ Quorum.",[{"label":"RETURN TO HEARTH NINE","action":"slice:return"},go_back()])
        _:
            show_choice("LIFT / NO RECORD", "No public docket is assigned to that piece of machinery.",[go_back()])

func show_slice_card() -> void:
    var code: String = str(Game.state.get("slice_finale",{}).get("outcome",""))
    var body: String = "An interim court report records your actions. The whole city remains unresolved; this is not one of the four canonical endings."
    if code == "public_mandate":
        body = "TRIAL RESULT / CONSENT-LED TRIAGE. Edda steps away from the order circuit. Consent is recorded as limited and revocable; repairs and real ward shortages remain. The four canonical endings are NOT reached in this preview."
    elif code == "apparatus_shutdown":
        body = "TRIAL RESULT / FORCED DISCONNECTION. The regulator stops, and the ward takes a hazardous but finite handover. The full campaign's ending choices remain beyond the three-Writ Quorum."
    elif code == "coercive_continuity":
        body = "TRIAL RESULT / MAINTAINED CONTROL. The pressure readings improve today, but voluntary patients are still treated as quotas. This is a development-slice consequence, not the Dominion ending."
    show_choice("FREIGHT TRIAL / INTERIM REPORT",body,[{"label":"RETURN TO HEARTH NINE","action":"slice:return"},go_back()])

func _completed_card_078() -> void:
    # The status is terminal; no free exploration continues after a completed
    # settlement and subsequent games are separate counterfactual campaigns.
    player.set_control_active(false)
    var outcome: String = str(Game.state.get("ending",""))
    hud.open_modal("VESPER / %s" % outcome.replace("_"," ").to_upper(),Game.ending_epilogue_078(),[
        {"label":"NEW COUNTERFACTUAL CAMPAIGN / WITNESS","action":"new:Witness"},
        {"label":"RETURN TO MAIN REGISTER","action":"ending:menu"},
        {"label":"QUIT TO DESKTOP","action":"quit"}])

func _refresh_assembly_platform_078(departed: bool = false) -> void:
    if not is_instance_valid(world) or str(Game.state.get("zone","")) != "assembly": return
    var c: Dictionary = Game.state.get("civic",{})
    var display: Label3D = world.get_node_or_null("Public platform manifest display") as Label3D
    if is_instance_valid(display):
        if departed:
            display.text = "DEPARTED %d / %d  •  %s" % [int(c.get("seats_used",0)),int(Game.state["core"].get("rail_capacity",24)),str(c.get("rail_state","closed")).to_upper()]
        else:
            display.text = "MUSTERED %d / %d  •  ZERO BOARDED" % [int(c.get("staged_seats",0)),int(Game.state["core"].get("rail_capacity",24))]
    var rail_signal: OmniLight3D = world.get_node_or_null("Emergency rail boarding signal") as OmniLight3D
    if is_instance_valid(rail_signal):
        rail_signal.light_color = Color("#80c9a2") if departed and str(c.get("rail_state","")) != "closed" else (Color("#c47b68") if departed else (Color("#deb87b") if int(c.get("staged_seats",0)) > 0 else Color("#bb704a")))
    if departed and str(c.get("rail_state","")) != "closed":
        var shutter: Node3D = world.get_node_or_null("Rail platform launch shutter") as Node3D
        if is_instance_valid(shutter):
            # The physical gate opens only at actual departure, not staging.
            shutter.queue_free()

func assembly_interaction_078(interaction_id: String) -> void:
    var c: Dictionary = Game.state.get("civic",{})
    match interaction_id:
        "assembly_risks_078":
            show_choice("PUBLIC NOTICE / COST OF AN ALTERNATIVE", "The architect's second signature allows a trial, not a miraculous repair. A slow boundary recalibration will darken some sectors, reduce hospital schedules and risk lives. The existing railway cannot carry Vesper's entire population.",[
                {"label":"DISCLOSE THESE ORIGINAL RISKS IN PUBLIC","action":"assembly:risks"},go_back()])
        "assembly_petition_078":
            show_choice("PATIENT PETITION / EXPLICIT LIMITED CONSENT", "The original signed voluntary-risk petition must be copied from the central archives and read aloud here. It cannot be used as universal consent for all patients.",[
                {"label":"PRESENT ORIGINAL PETITION / ACKNOWLEDGE REVOCATION","action":"assembly:petition"},go_back()])
        "assembly_mandate_078":
            var lines: String = "Public deliberation requires full disclosure, an original patient petition, and at least three separately verified affirmative constituencies. High Speech cannot invent a voter.\n\nAffirmative rolls: %d / 3.\n" % Game.assembly_vote_count_078()
            if bool(c.get("mandate",false)):
                lines += "Public authority has approved a LIMITED, REVOCABLE trial. A public withdrawal can cancel the attempt before the settlement is chosen."
            elif bool(c.get("mandate_revoked",false)):
                lines += "The assembly has withdrawn consent. A forced True Dawn cannot proceed."
            else:
                lines += "No mandate has been passed. The first three final outcomes remain eligible without it."
            var opts: Array = []
            if not bool(c.get("mandate",false)) and not bool(c.get("mandate_revoked",false)):
                opts.append({"label":"COUNT VERIFIED VOTES / REQUEST REVOCABLE TRIAL","action":"assembly:mandate"})
            if bool(c.get("mandate",false)):
                opts.append({"label":"WITHDRAW PUBLIC CONSENT / CANCEL TRIAL","action":"assembly:revoke"})
            opts.append(go_back())
            show_choice("CIVIC ASSEMBLY / MANDATE",lines,opts)
        "assembly_vote_clinic_078", "assembly_vote_labour_078", "assembly_vote_choir_078", "assembly_vote_market_078", "assembly_vote_growth_078", "assembly_vote_defence_078":
            var group: String = interaction_id.trim_prefix("assembly_vote_").trim_suffix("_078")
            var reliable: bool = Game.assembly_support_078(group)
            var existing: bool = bool(c.get("votes",{}).get(group,false))
            var summary: String = "Original signed case evidence supports a voluntary witness." if reliable else "No independent affirmative constituency is verified here. This is not a yes vote; return to the relevant living witnesses or public records."
            if existing: summary = "This constituency has already been counted; a second interview is not an extra vote."
            show_choice("ASSEMBLY ROLL / %s" % group.to_upper(),summary,[
                {"label":"RECORD INDEPENDENT ASSENT / IF EVIDENCED","action":"assembly:vote:"+group},go_back()])
        "assembly_rail_patients_078", "assembly_rail_families_078", "assembly_rail_crews_078", "assembly_rail_claimant_078":
            var index: Dictionary = {"assembly_rail_patients_078":"ward_patients","assembly_rail_families_078":"guardian_families","assembly_rail_crews_078":"repair_crew","assembly_rail_claimant_078":"claimant_residents"}
            var group: String = str(index[interaction_id])
            var spec: Dictionary = Game.rail_group_078(group)
            var total: int = int(c.get("staged_seats",0))
            var capacity: int = int(Game.state["core"].get("rail_capacity",24))
            var text_body: String = "%s. Source: %s. %d seats required; %d / %d seats already MUSTERED. No person has boarded or departed yet." % [spec["name"],spec["source"],int(spec["seats"]),total,capacity]
            var opts: Array = []
            if bool(c.get("staged_groups",{}).get(group,false)):
                opts.append({"label":"RELEASE THIS GROUP / REASSIGN ITS SEATS","action":"assembly:release:"+group})
            else:
                opts.append({"label":"REGISTER THIS GROUP / FINITE SEATS","action":"assembly:stage:"+group})
            opts.append(go_back())
            show_choice("EMERGENCY PLATFORM / VERIFIED COHORT",text_body,opts)
        "assembly_final_078":
            var eligible: Dictionary = Game.ending_eligibility_078()
            var options: Array = [
                {"label":"LIBERATION / OPEN LIMITED RAIL; DISCONNECT ENGINE","action":"assembly:end:liberation"},
                {"label":"DOMINION / KEEP EXITS SHUT; INSTITUTIONAL MEMORY TAX","action":"assembly:end:dominion"},
                {"label":"THE CROWN / NINTH RULES PERSONALLY; EXITS CLOSED","action":"assembly:end:crown"}]
            if bool(eligible.get("true_dawn",false)):
                options.append({"label":"TRUE DAWN / REVOCABLE AND COSTLY PUBLIC TRIAL","action":"assembly:end:true_dawn"})
            var text_body: String = "This final operation is irreversible for this campaign. Staged local seats: %d of %d; BOARDING so far: 0. Liberation departs with only the signed cohorts. Dominion and the Crown depart with zero passengers.\n\nTRUE DAWN: Heat Survey, Root Seed, one Cipher, public mandate, at least one staged cohort, 3 Energy and 2 Labour. Prerequisites met: %s.\n\nCustodian %s / %s." % [int(c.get("staged_seats",0)),int(Game.state["core"].get("rail_capacity",24)),str(eligible.get("true_dawn",false)),Game.core_custodian(),str(Game.state["core"].get("custodian_fate",""))]
            options.append(go_back())
            show_choice("LAST SIGNATURE / FOUR TERMINAL OUTCOMES",text_body,options)
        "assembly_return_078":
            show_choice("ARCHIVES / RETURN TO ORIGINAL SIGNATURES", "You may leave the public assembly to gather remaining clues or original witnesses. No passenger departs just by crossing a district boundary.",[
                {"label":"RETURN TO CORE ARCHIVE","action":"assembly:return"},go_back()])
        _:
            show_choice("ASSEMBLY / NO PUBLIC REGISTER", "There is no legally recorded action at this station.",[go_back()])

func _on_action(action: String) -> void:
    # Bible 13: Ninth learns before committing when a choice would make True Dawn
    # impossible (fewer than three constituencies left). Never a silent lockout.
    if action.ends_with("#confirmed"):
        action = action.trim_suffix("#confirmed")
    elif Game.has_attempt():
        var lockout: String = Game.true_dawn_lockout_warning_089(action)
        if lockout != "":
            show_choice("TRUE DAWN WOULD CLOSE", lockout, [{"label":"CONFIRM / ACCEPT THE CONSEQUENCE","action":action + "#confirmed"}, go_back()])
            return
    if action == "ending:menu":
        open_main_menu()
        return
    if action == "ending:archive":
        player.set_control_active(false)
        var records: Array = Game.profile.get("completed_endings",[])
        var report: String = "No completed settlement is recorded. Failed attempts are tracked separately by Nix."
        if not records.is_empty():
            var history: Array[String] = []
            for record in records.slice(maxi(0,records.size()-8),records.size()):
                history.append("%s — %s / %d local passengers / custodian %s" % [str(record.get("attempt_id","?")),str(record.get("ending","?")),int(record.get("rail_seats",0)),str(record.get("custodian","not recorded"))])
            report = "\n".join(history)+"\n\nA new campaign does not undo any settlement listed here."
        show_choice("NIX / PERMANENT COMPLETED SETTLEMENTS",report,[{"label":"RETURN TO MAIN REGISTER","action":"ending:menu"}])
        return
    if action == "assembly:enter" and Game.has_attempt():
        player.capture_position()
        if Game.visit_assembly_078():
            reload_district_world()
            player.restore_position()
            show_choice("THE NINTH EXHALE / PUBLIC ASSEMBLY", "No ending begins automatically. Disclose the risks, inspect the original petition, count actual constituency testimony and stage only the groups the finite railway can seat. You may choose among three endings without a mandate. True Dawn is an exceptional consenting trial.",[go_back()])
        else:
            show_choice("ASSEMBLY / NOT OPEN", "Resolve the Custodian after the original central archive signatures, public hearing and three founding Writs.",[go_back()])
        return
    if action == "assembly:return" and Game.has_attempt():
        if str(Game.state.get("zone","")) == "assembly":
            Game.state["zone"] = "core"
            Game.state["player_pos"] = [-24.0,0.15,18.0]
            Game.state["zone_positions"]["core"] = Game.state["player_pos"].duplicate()
            Game.record_event("assembly.return.%d" % Game.state["events"].size(),"return_to_original_archive",{"reversible_before_ending":true})
            Game.save_attempt()
            reload_district_world()
            player.restore_position()
            show_choice("ARCHIVE / FIRST SIGNATURE", "Return to the five districts for records, witnesses or the optional technical clues. The assembly is not a one-way trap.",[go_back()])
        return
    if action.begins_with("assembly:") and Game.has_attempt():
        var step: String = action.trim_prefix("assembly:")
        var done: bool = false
        match step:
            "risks": done = Game.disclose_assembly_risk_078()
            "petition": done = Game.verify_assembly_petition_078()
            "mandate": done = Game.grant_public_mandate_078()
            "revoke": done = Game.revoke_public_mandate_078()
        if step.begins_with("vote:"):
            done = Game.record_assembly_support_078(step.trim_prefix("vote:"))
        elif step.begins_with("stage:"):
            done = Game.stage_rail_group_078(step.trim_prefix("stage:"))
        elif step.begins_with("release:"):
            done = Game.release_rail_group_078(step.trim_prefix("release:"))
        elif step.begins_with("end:"):
            # Prevent accidentally completing a terminal campaign via one
            # click in a scrolled, high-stakes dialogue list.
            var kind: String = step.trim_prefix("end:")
            if not bool(Game.ending_eligibility_078().get(kind,false)):
                show_choice("LAST SIGNATURE / NOT ELIGIBLE", "Missing prerequisites. A private Speech check cannot invent public consent, nor can an unsigned roster become a passenger.",[go_back()])
                return
            var costs: String = ""
            if kind in ["liberation","true_dawn"]:
                costs = "The gate will depart with exactly %d registered passengers out of %d seats. Unregistered people cannot be counted as rescued." % [int(Game.state["civic"].get("staged_seats",0)),int(Game.state["core"].get("rail_capacity",24))]
            else:
                costs = "Both the emergency exits and passenger rail will remain shut. Zero passengers depart, even if some were mustered."
            if kind == "true_dawn":
                costs += " A revocable public mandate authorises a difficult trial; this consumes 3 conventional Energy and 2 Labour, dims sectors and does not guarantee technical success."
            show_choice("FINAL AUTHORISATION / NO REWIND", "Ending: %s.\n\n%s\n\nThis will permanently complete this attempt. Other completed campaigns remain as separate historical outcomes." % [kind.replace("_"," ").to_upper(),costs],[{"label":"AUTHORISE THIS TERMINAL ENDING / NO UNDO","action":"assembly:commit:"+kind},go_back()])
            return
        elif step.begins_with("commit:"):
            var kind: String = step.trim_prefix("commit:")
            if Game.complete_ending_078(kind):
                _refresh_assembly_platform_078(true)
                player._play_action_audio("valve_steam.wav" if kind in ["liberation","true_dawn"] else "pressure_warning.wav",-13.0)
                _completed_card_078()
            else:
                show_choice("LAST SIGNATURE / NOT ELIGIBLE", "The chosen outcome's conditions have changed. No irreversible settlement was applied.",[go_back()])
            return
        if done:
            _refresh_assembly_platform_078()
        show_choice("PUBLIC ASSEMBLY / %s" % ("RECORDED" if done else "NOT RECORDED"), "The physical record is unique and saved. No cohort was boarded by adding it to a departure queue." if done else "This needs missing testimony, disclosure, a physical original, free seats or an unspent public mandate. The action has not been applied.",[go_back()])
        return
    if action.begins_with("arc077:") and Game.has_attempt():
        var parts: PackedStringArray = action.split(":")
        var person: String = str(parts[1]) if parts.size() > 1 else ""
        var step: String = str(parts[2]) if parts.size() > 2 else ""
        var choice: String = str(parts[3]) if parts.size() > 3 else ""
        var done: bool = Game.arc_event_077(person,step,choice)
        if done and step == "decide":
            var actor_name: String = "VennOfGlass" if person == "venn" else "Kest07"
            var actor_node: Node3D = world.get_node_or_null(actor_name) as Node3D
            if is_instance_valid(actor_node):
                if choice == "abandon":
                    actor_node.queue_free()
                elif choice == "help":
                    actor_node.position = Vector3(-15,0,15) if person == "venn" else Vector3(-13,0,15)
                elif choice == "exploit":
                    actor_node.position = Vector3(-24,0,16)
        show_choice("%s / %s" % [person.to_upper(), "EVENT RECORDED" if done else "REQUIREMENTS MISSING"],"Only actual witnessed events may advance this four-beat NPC arc. Meet, preserve evidence, investigate, decide, then record the aftermath. Decisions persist; repeated dialogue grants no extra XP." if done else "Complete the preceding steps in order. The person must be alive and in the correct district.",[go_back()])
        return
    if (action.begins_with("orchard:") or action.begins_with("barracks:")) and Game.has_attempt():
        var orchard: bool = action.begins_with("orchard:")
        var office: String = "orchard" if orchard else "barracks"
        var verb: String = action.trim_prefix("orchard:") if orchard else action.trim_prefix("barracks:")
        if verb == "fight":
            if is_instance_valid(guard) and str(Game.state.get("zone","")) == office:
                guard.anger()
                resume_controls()
                hud.notify("REGIONAL SERVICE FRAME ENGAGED / LEGAL WRIT SURVIVES",4.0)
            else:
                show_choice("APPARATUS UNAVAILABLE","The machinery is absent; original registry succession remains available.",[go_back()])
            return
        var done: bool = false
        match verb:
            "sample": done = Game.record_orchard_sample_077()
            "vote": done = Game.vote_orchard_researchers_077() if orchard else Game.convene_barracks_platoon_077()
            "isolate": done = Game.isolate_orchard_feed_077() if orchard else Game.isolate_barracks_signal_077()
            "seed": done = Game.claim_restoration_clue_077("orchard_root_seed")
            "survey": done = Game.claim_restoration_clue_077("deep_heat_survey")
            "supplies": done = Game.claim_office_supplies_077(office)
            "roll": done = Game.record_barracks_roll_077()
            "roster": done = Game.record_guard_roster_077()
            "vote_barracks": done = Game.convene_barracks_platoon_077()
        if verb.begins_with("writ:"):
            var method: String = verb.trim_prefix("writ:")
            done = Game.grant_growth_writ_077(method) if orchard else Game.grant_defence_writ_077(method)
        show_choice("%s / %s" % [office.to_upper(), "ORIGINAL RECORDED" if done else "NO CHANGE"],"One physical event was recorded and its real consequences persist. The Writ, when eligible, is transferred by the public registry." if done else "The required independent evidence, Tech skill, resources, public mandate or apparatus defeat is missing; other valid routes remain available.",[go_back()])
        return
    if action.begins_with("perk:") and Game.has_attempt():
        var perk_id: String = action.trim_prefix("perk:")
        var taken: bool = Game.choose_perk_089(perk_id)
        var perk: Dictionary = Game.PERKS_089.get(perk_id, {})
        show_choice("NINTH / PERK %s" % ("CHOSEN" if taken else "UNAVAILABLE"), ("%s: %s" % [perk.get("name",""), perk.get("effect","")]) if taken else "No perk choice is available, the perk is already taken, or its attribute requirement is not met.", [go_back()])
        return
    if action.begins_with("level7:") and Game.has_attempt():
        var kind: String = action.trim_prefix("level7:")
        var chosen: bool = Game.choose_level7_bonus(kind)
        show_choice("NINTH / LEVEL 7", ("You took %s. Open the docket to spend it." % ("one attribute point" if kind == "attribute" else "a fourth perk")) if chosen else "The level 7 bonus is not available.", [go_back()])
        return
    if action.begins_with("attribute:") and Game.has_attempt():
        var stat_name: String = action.trim_prefix("attribute:")
        var upgraded: bool = Game.choose_attribute_075(stat_name)
        show_choice("NINTH / ATTRIBUTE %s" % ("ALLOCATED" if upgraded else "UNAVAILABLE"),"Your chosen attribute rose by one permanent point in this attempt. Levels 3 and 5 each provide one point; level 7 can provide another." if upgraded else "You have no unspent attribute point, the stat is already at ten, or the stat name is invalid.",[go_back()])
        return
    if action.begins_with("market:") and Game.has_attempt():
        var which: String = action.trim_prefix("market:")
        if which == "fight":
            if is_instance_valid(guard) and str(Game.state.get("zone","")) == "ashmarket":
                guard.anger()
                resume_controls()
                hud.notify("COLLECTOR SECURITY ENGAGED / USE COVER, PUBLIC REGISTRY SURVIVES",4.0)
            else:
                show_choice("COLLECTOR / NO HOSTILE HOLDER", "The Collector is absent. The public Writ register still survives.",[go_back()])
            return
        var done: bool = false
        var response: String = "The required record or equipment is missing. No Writ or stock was duplicated."
        match which:
            "contracts":
                done=Game.record_market_contracts()
                response="Two contradictory contract originals copied. Their public identities remain independent."
            "testimony":
                done=Game.record_market_testimony()
                response="Independent buyer and porter testimony recorded without inventing their consent."
            "coalition":
                done=Game.convene_market_coalition()
                response="Buyers have formed a documented public coalition; Speech 7 may now challenge the Collector."
            "sabotage":
                done=Game.isolate_market_counting_lock()
                response="Counting locks withdrawn with two Energy and one Labour spent. Original contracts remain available."
            "intimidate":
                done=Game.intimidate_market_collector()
                response="A coerced signature is now possible at the public register. The market's trust falls sharply."
            "rain_evidence":
                done=Game.record_market_rain_reading()
                response="Public tank dial and broker's original tariff recorded."
            "rain_open":
                done=Game.resolve_market_rain("open_tank")
                response="One existing water tank opened with two crew shifts and electricity. The water is finite."
            "rain_cut":
                done=Game.resolve_market_rain("take_cut")
                response="A private broker's levy is accepted. The water stock is unchanged and public trust falls."
            "supplies":
                done=Game.claim_market_emergency_lot()
                response="Issued 18 Ledger Slugs and one Breath Ampoule from a one-use physical store."
        show_choice("ASHMARKET / %s" % ("PUBLIC RECORD ENTERED" if done else "NO CHANGE"),response if done else "The action was refused by its current physical, evidence, skill or resource requirements. No double claim is possible.",[go_back()])
        return
    if action.begins_with("trade:") and Game.has_attempt():
        var way: String = action.trim_prefix("trade:")
        var legal: bool = Game.register_three_writ_quorum() if way == "quorum_audit" else Game.grant_trade_writ(way)
        var message: String = "Three unique founding Writs and the hearing are VERIFIED. Return to the public authentication desk and enter the Freight Lift of Names. Any three of five offices qualify." if way == "quorum_audit" else "The durable Trade Writ was transferred once. The register records HOW it changed hands and the Collector cannot erase it."
        show_choice("TRADE OFFICE / %s" % ("RECORDED" if legal else "TRANSFER REJECTED"),message if legal else "The required independent evidence, skill, public authority, defeated keeper or technical isolation has not been recorded. Other routes remain available.",[go_back()])
        return
    if action == "core:enter":
        player.capture_position()
        if Game.visit_core_076():
            reload_district_world()
            player.restore_position()
            show_choice("FREIGHT LIFT / FIRST SIGNATURE", "The three-Writ lift has accepted the authenticated civic quorum. Read BOTH original architect signatures and the damaged emergency rail charter. The elected Custodian is %s. Your choices here do not force an ending." % Game.core_custodian(),[go_back()])
        else:
            show_choice("THREE-WRIT LIFT / SEALED", "Record the real Quorum at Hearth Nine: Cinder Lung, three distinct Writs and the public Echoform hearing.",[go_back()])
        return
    if action == "core:return":
        player.capture_position()
        if Game.change_zone("hearth"):
            reload_district_world()
            player.restore_position()
            show_choice("HEARTH NINE / ORIGINAL CORE RECORDS", "The core archive remains revisitable from the three-Writ authentication desk; decisions and unique evidence persist.",[go_back()])
        else:
            show_choice("RETURN RAIL / SERVICE DENIED", "The current district cannot transfer while the ward Lung is unavailable.",[go_back()])
        return
    if action.begins_with("core:doc:"):
        var kind: String = action.trim_prefix("core:doc:")
        var copied: bool = Game.record_core_document_076(kind)
        show_choice("INDEPENDENT ARCHIVE / %s" % ("COPIED" if copied else "NO NEW RECORD"), "The physical source has been witnessed and recorded once. It does not grant a second reward on return." if copied else "The original is already in the docket, or the core archive has not been entered.",[go_back()])
        return
    if action == "core:safety":
        var wired: bool = Game.prepare_core_safety_bus_076()
        show_choice("SAFETY BUS / %s" % ("MANUAL FALLBACK PREPARED" if wired else "NOT PREPARED"),"Three Energy and two Labour are assigned to actual staffed equipment. Correction and air were not invented." if wired else "Requires both architect records, the rail charter, Tech 5 and available real resources. No duplicate charges or free energy.",[go_back()])
        return
    if action == "core:repair":
        var repaired: bool = Game.repair_rail_carriage_076()
        show_choice("SPARE CARRIAGE / %s" % ("REPAIRED" if repaired else "NOT REPAIRED"),"Existing parts, crew shifts and grid power restored 12 actual seats; no person has boarded and the city's population remains far larger." if repaired else "Read the rail charter, verify 2 salvage + 3 Labour + 2 Energy, and check if the repair was already recorded.",[go_back()])
        return
    if action.begins_with("core:policy:"):
        var plan: String = action.trim_prefix("core:policy:")
        var recorded: bool = Game.record_rail_boarding_policy_076(plan)
        show_choice("RAIL / %s" % ("DRAFT RECORDED" if recorded else "UNAVAILABLE"),"The public service queue is only a draft; no train has departed and no passenger is invented." if recorded else "You must read the rail charter and may record only one draft per attempt.",[go_back()])
        return
    if action == "core:cipher":
        var found: bool = Game.claim_core_cipher_076()
        show_choice("MAINTENANCE CIPHER / %s" % ("ONE ORIGINAL COPIED" if found else "UNAVAILABLE"),"The single Governor's Maintenance Cipher is in the quest records. Its consent field is unsigned; True Dawn is not unlocked." if found else "Copy both signatures and the railway charter first, or check your existing unique record.",[go_back()])
        return
    if action == "core:fight":
        if is_instance_valid(guard) and not bool(Game.state.get("core",{}).get("actuator_disabled",false)):
            guard.anger()
            resume_controls()
            hud.notify("EXECUTIVE ACTUATOR / AMBER WINDUP — USE COVER AND FINITE AMMO",4.0)
        else:
            show_choice("EXECUTIVE ACTUATOR / ALREADY DISABLED", "The powered enforcement frame is no longer active. Return to the public docket to resolve authority.",[go_back()])
        return
    if action.begins_with("core:resolve:"):
        var method: String = action.trim_prefix("core:resolve:")
        var resolved: bool = Game.resolve_core_custodian_076(method)
        if resolved and is_instance_valid(guard):
            # A public removal must physically disarm its enforcement hardware.
            # The lawful resolution does not assert a human Custodian's death.
            guard.queue_free()
            guard = null
        var core_state: Dictionary = Game.state.get("core",{})
        var resolution_text: String = "%s / %s. The legal executive authority is now removed or suspended. No person is declared dead by a machine-only fight. Return to the public Assembly Gate in this archive to begin the final civic chapter." % [Game.core_custodian(),str(core_state.get("custodian_fate",""))]
        show_choice("CENTRAL REVIEW / %s" % ("AUTHORITY RESOLVED" if resolved else "REQUIREMENTS MISSING"), resolution_text if resolved else "Obtain BOTH signatures and the real rail charter; present this Custodian's own evidence for tribunal or abdication, prepare the staffed safety bus for containment, or physically disable the executive actuator. Low Speech/Tech never permanently blocks the main path.",[go_back()])
        return
    if action == "slice:enter":
        player.capture_position()
        if Game.visit_slice_lift():
            reload_district_world()
            player.restore_position()
            show_choice("FREIGHT LIFT / CANON EDDA", "The two-Writ trial reaches a small triage hall. Search the voluntary-risk petition and decide what the governor is allowed to do.",[go_back()])
        else:
            show_choice("LIFT SEALED", "The Lung, both founding Writs and public hearing must be recorded first.",[go_back()])
        return
    if action == "slice:petition":
        var ok: bool = Game.record_eddas_petition()
        show_choice("EDDA PETITION / %s" % ("RECORDED" if ok else "ALREADY COPIED"), "The original limited voluntary-risk record is now independently verified." if ok else "You cannot duplicate this source.",[go_back()])
        return
    if action == "slice:fight":
        if is_instance_valid(guard):
            guard.anger()
            resume_controls()
            hud.notify("TRIAGE REGULATOR ENGAGED / AVOID THE PATIENT BEDS",4.0)
        else:
            show_choice("APPARATUS ABSENT", "No coercive circuit remains to destroy.",[go_back()])
        return
    if action.begins_with("slice:") and action != "slice:return":
        var outcome: String = action.trim_prefix("slice:")
        if Game.resolve_slice(outcome):
            _show_civic_consequence(Vector3(7,3,-10),outcome == "public_mandate")
            show_slice_card()
        else:
            show_choice("TRIAL / EVIDENCE OR ACTION MISSING", "Produce the original petition or defeat the apparatus, or choose documented continuity.",[go_back()])
        return
    if action == "slice:return":
        player.capture_position()
        Game.state["zone"] = "hearth"
        Game.state["player_pos"] = [-4.0,0.15,11.0]
        Game.state["zone_positions"]["hearth"] = Game.state["player_pos"].duplicate()
        Game.save_attempt()
        reload_district_world()
        player.restore_position()
        show_choice("HEARTH NINE / TRIAL COMPLETE", "Your short-campaign report is recorded. No canonical full-game ending has been claimed.",[go_back()])
        return
    if action == "intro:wake":
        if Game.wake_reprint_relay():
            spawn_intro_sentry()
            resume_controls()
            hud.notify("INTAKE ALARM / FILTER CRAWLER LOOSE — LMB FIRE, R RELOAD",5.0)
        else:
            show_choice("RELAY ALREADY RECORDED", "The intake relay cannot be reactivated for extra rewards.",[go_back()])
        return
    if action == "intro:valve":
        if Game.stabilise_intake_valve():
            open_intake_shutter()
            resume_controls()
            hud.notify("PRESSURE SEAL OPEN / FIND DR SELA NORTH OF INTAKE",5.0)
        else:
            show_choice("AIRLOCK STILL HELD", "Stop the crawler first and return to the valve.",[go_back()])
        return
    if action.begins_with("issue_tool:"):
        var id: String = action.trim_prefix("issue_tool:")
        if Game.issue_sootworks_tool(id):
            player.select_weapon(id)
            hud.notify("WORKSHOP TOOL ISSUED / 2–5 TO SWITCH / R TO RELOAD")
        else:
            hud.notify("TOOL ISSUE DENIED / ALREADY ISSUED OR WRONG DISTRICT")
        hud.close_modal()
        player.set_control_active(true)
        return
    if action.begins_with("new:"):
        begin_attempt(action.trim_prefix("new:"))
        return
    if action=="resume":
        resume_loaded_attempt()
        return
    if action=="quit":
        Music.request_quit()
        return
    if action=="reprint_saved":
        # Same chain as the in-game "RECONSTRUCT", after an app restart.
        if Game.load_failed_chain_for_reprint():
            begin_attempt(str(Game.state.get("build","Witness")), true)
        else:
            open_main_menu()
        return
    if action=="reprint":
        begin_attempt(str(Game.state.get("build","Witness")), true)
        return
    if action=="menu":
        open_main_menu()
        return
    if action=="save_and_close":
        _save_now()
        resume_controls()
        return
    if action=="close":
        resume_controls()
        return
    if not Game.has_attempt():return
    if action.begins_with("travel:"):
        player.capture_position()
        if Game.change_zone(action.trim_prefix("travel:")):
            reload_district_world()
            player.restore_position()
            player.set_control_active(false)
            var new_zone: String = str(Game.state["zone"])
            var message: String = "HEARTH NINE / WARD TRANSFER\nYour Lung, Writs, hearing results and evidence remain recorded."
            if new_zone == "sootworks":
                message = "SOOTWORKS / LABOUR OFFICE\nFind Brin, verify the original debt and resolve the Labour Writ."
            elif new_zone == "basilica":
                message = "FLOOD BASILICA / FAITH OFFICE\nMeet Ossa, examine the sixth-note reel, petition the lay council and complete the Rootkin public hearing."
            elif new_zone == "orchard":
                message = "GLASS ORCHARD / GROWTH OFFICE\nSeparate the fruit sample, review Venn's nursery, and inspect the Gardener's feed line."
            elif new_zone == "barracks":
                message = "QUIET BARRACKS / DEFENCE OFFICE\nRecover original soldier names, preserve a staffed watch and confront the regional Commandant."
            elif new_zone == "ashmarket":
                message = "ASHMARKET / TRADE OFFICE\nInspect two original contracts, hear the buyers and deal with the Collector. Four distinct legal and conflict routes are available."
            show_choice("MUNICIPAL SERVICE TRANSFER",message,[go_back()])
        else:
            show_choice("TRANSFER DENIED","Install the Lung before district travel.",[go_back()])
        return
    if action.begins_with("ossa:"):
        var verb_ossa: String = action.trim_prefix("ossa:")
        var recorded: bool = false
        if verb_ossa == "meet": recorded = Game.meet_ossa()
        elif verb_ossa == "record_hymn": recorded = Game.record_hymn_reel()
        elif verb_ossa == "investigate": recorded = Game.investigate_ossa()
        elif verb_ossa == "aftermath": recorded = Game.complete_ossa_aftermath()
        elif verb_ossa in ["help","compromise","exploit","abandon"]: recorded = Game.decide_ossa(verb_ossa)
        if recorded and verb_ossa in ["help","compromise","exploit","abandon"]:
            _show_civic_consequence(Vector3(-10,3,-2),verb_ossa in ["help","compromise"])
            var actor_ossa: Node3D = world.get_node_or_null("Sister Ossa") as Node3D
            if is_instance_valid(actor_ossa):
                match verb_ossa:
                    "help": actor_ossa.position = Vector3(-14,0,-13)
                    "exploit": actor_ossa.position = Vector3(-21,0,17)
                    "abandon": actor_ossa.position = Vector3(-16,0,-17)
        show_choice("SISTER OSSA / %s" % ("EVENT RECORDED" if recorded else "UNAVAILABLE"),ossa_aftermath_text() if recorded and verb_ossa in ["help","compromise","exploit","abandon","aftermath"] else ("The actual evidence and NPC stage were recorded once." if recorded else "Meet Ossa, find the reel and investigate first; she must be alive to speak."),[go_back()])
        return
    if action.begins_with("faith:"):
        var faith_method: String = action.trim_prefix("faith:")
        var legal: bool = Game.grant_faith_writ(faith_method)
        show_choice("FAITH WRIT / %s" % ("RECORDED" if legal else "LEGAL TRANSFER REJECTED"),"The Faith Writ was transferred once through the public register. +165 unique XP; the full campaign still requires three separate office credentials." if legal else "A live council petition, isolated governor or defeated Cantor is required. No optional quest can permanently delete this Writ.",[go_back()])
        return
    if action == "basilica:isolate":
        var isolated: bool = Game.disable_basilica_governor()
        show_choice("BELL GOVERNOR / %s" % ("ISOLATED" if isolated else "UNCHANGED"),"The harmful command channel has been isolated with recorded Energy and Labour costs. File the Writ at the Cantor's board." if isolated else "Tech 5 is required and the bus may only be isolated once. Fight and registry succession remain possible.",[go_back()])
        return
    if action == "basilica:fight":
        if is_instance_valid(guard):
            guard.anger()
            resume_controls()
            hud.notify("CANTOR SIGNAL FRAME HOSTILE / CONTROL R TO RELOAD",3.5)
        else:
            show_choice("CANTOR ABSENT","Use the public Faith registry to recover the office Writ.",[go_back()])
        return
    if action == "basilica:ration":
        var issued: bool = Game.basilica_supplies()
        show_choice("BASILICA DEFENCE ISSUE / %s" % ("RELEASED" if issued else "EXHAUSTED"),"A finite issue: 24 physical Ledger Slugs and two medical Breath Ampoules." if issued else "This specific lot was already taken.",[go_back()])
        return
    if action == "hearing:start":
        if Game.begin_public_hearing():
            _refresh_field_visuals()
            hearing_choices("The public Rootkin agrees to the limited civic test. It will not become your property.")
        else:
            show_choice("HEARING / NO NEW TEST","You must stand in Flood Basilica with the Lung installed. A completed hearing cannot be farmed for rewards.",[go_back()])
        return
    if action.begins_with("hearing:"):
        var hearing_verb: String = action.trim_prefix("hearing:")
        var result: Dictionary = Game.hearing_command(hearing_verb)
        _refresh_field_visuals()
        if not bool(result.get("ok",false)):
            show_choice("HEARING / COMMAND REJECTED",str(result.get("message","Invalid field state")),[go_back()])
        elif bool(result.get("passed",false)):
            show_choice("CIVIC HEARING / PASSED",str(result.get("message",""))+"\n\n110 unique XP awarded. Rootkin is returned to public care. The opposing Bell Wretch remains free.",[go_back()])
        elif not bool(result.get("active",false)):
            show_choice("CIVIC HEARING / CLOSED",str(result.get("message",""))+"\n\nReturn to the hearing station to begin another free attempt.",[go_back()])
        else:
            hearing_choices(str(result.get("message","")))
        return
    if action.begins_with("brin:"):
        var verb: String = action.trim_prefix("brin:")
        var ok: bool = false
        if verb == "meet": ok = Game.meet_brin()
        elif verb == "record_payroll": ok = Game.record_payroll()
        elif verb == "investigate": ok = Game.investigate_brin()
        elif verb == "aftermath": ok = Game.complete_brin_aftermath()
        elif verb in ["help","compromise","exploit","abandon"]: ok = Game.decide_brin(verb)
        if ok and verb in ["help","compromise","exploit","abandon"]:
            _show_civic_consequence(Vector3(-13,3,-11),verb in ["help","compromise"])
            var actor: Node3D = world.get_node_or_null("Brin Harker") as Node3D
            if is_instance_valid(actor):
                match verb:
                    "help": actor.position = Vector3(-14,0,-11)
                    "compromise": actor.position = Vector3(-10,0,11)
                    "exploit": actor.position = Vector3(18,0,16)
                    "abandon": actor.position = Vector3(-14,0,-15)
        show_choice("BRIN / %s" % ("RECORD COMMITTED" if ok else "ACTION NOT AVAILABLE"),brin_aftermath_text() if ok and verb in ["help","compromise","exploit","abandon","aftermath"] else ("Evidence and event state updated. Return to the labour office." if ok else "Check the four-stage quest order and whether Brin is alive."),[go_back()])
        return
    if action.begins_with("writ:"):
        var method: String = action.trim_prefix("writ:")
        var granted: bool = Game.grant_labour_writ(method)
        show_choice("LABOUR WRIT / %s" % ("TRANSFER CONFIRMED" if granted else "TRANSFER REJECTED"), "The founding Writ of Labour is now recorded as a distinct office credential. +165 one-time XP. The full campaign still requires three different Writs." if granted else "This method is not legally supported by your actual evidence, regulator status or the keeper's fate.",[go_back()])
        return
    if action == "soot:sabotage":
        var sabotaged: bool = Game.disable_sootworks_regulator()
        show_choice("ISOLATION BUS / %s" % ("CONTROL DISCONNECTED" if sabotaged else "NOT AUTHORISED"),"The technical intervention is real and costs recorded Energy and Labour. Return to the order board to file a Writ." if sabotaged else "Tech 5 is required, or this control line was already isolated. Combat and public registry fallback remain available.",[go_back()])
        return
    if action == "soot:fight":
        if is_instance_valid(guard):
            guard.anger()
            resume_controls()
            hud.notify("MILLWRIGHT HOSTILE / TAKE COVER. R TO RELOAD",3.5)
        else:
            show_choice("FRAME ABSENT","Recover the Writ from the durable labour registry.",[go_back()])
        return
    if action == "soot:ration":
        var stocked: bool = Game.sootworks_supplies()
        show_choice("DEFENCE STOCK / %s" % ("ISSUED" if stocked else "EXHAUSTED"),"The lot was taken from finite district supplies. No restock on reentry." if stocked else "This lot was already collected.",[go_back()])
        return
    if action=="record_evidence":
        var got:=Game.record_evidence()
        show_choice("PUBLIC RECORD COPIED", "The source document has been logged once. A negotiated case now has admissible evidence." if got else "This evidence was already recorded.",[go_back()])
    elif action=="begin_fight":
        if is_instance_valid(guard):
            guard.anger()
        hud.notify("THE ENFORCER IS HOSTILE / use cover, reload with R")
        resume_controls()
    elif action.begins_with("claim:"):
        var method:=action.trim_prefix("claim:")
        if Game.claim_lung(method):
            show_choice("SINGLE SPARE LUNG CLAIMED", "Recorded method: %s. The physical component must now be installed by Dr Sela Vale in Hearth Nine. There is still a competing claim; the record was not erased." % method.to_upper(),[go_back()])
        else:
            var reason:="This route is not supported by the available evidence, stat or observed facts."
            if method=="bargain":reason="Negotiation requires a documented requisition copy and Speech 6 after its +1 evidence bonus. Find the public archive; fighting or theft remain possible."
            if method=="tech":reason="The safe load diversion requires Tech 5. Fighting, theft and evidence-backed negotiation remain possible."
            if method=="fight":reason="The enforcer has not been defeated. This is not a dialogue-only combat resolution."
            show_choice("REJECTED / INVALID CLAIM",reason,[go_back()])
    elif action=="install_lung":
        if Game.install_lung():
            _show_civic_consequence(Vector3(-18,3,-5),true)
            show_choice("HEARTH NINE / CINDER LUNG ONLINE", "Sela fits the real spare into the intake. The pumps take power from the grid; damaged human correction patterns stabilise the separate boundary channel.\n\nAn enclosed voice asks about a son. Sela turns down the speaker rather than pretending it is a motor fault.\n\n+140 unique-resolution XP. The competing ward's loss is visible in the Pressure Docket.",[go_back()])
        else:
            show_choice("INSTALLATION NOT AUTHORISED","A valid spare has not been claimed or was already installed.",[go_back()])
    elif action=="claim_ammo":
        if Game.ammo_pickup():
            show_choice("EMERGENCY ISSUE SIGNED","24 Ledger Slugs and two Breath Ampoules are now issued. Reopening this locker cannot duplicate stock.",[go_back()])
        else:
            show_choice("ALREADY CLAIMED","This ration was already consumed.",[go_back()])

func _heal() -> void:
    if Game.heal_ampoule():
        hud.notify("BREATH AMPOULE / medical stock -1")
    else:
        hud.notify("NO BREATH AMPOULES REMAIN")

func _save_now() -> void:
    if not Game.has_attempt():return
    player.capture_position()
    hud.notify("PRESSURE DOCKET / COMMIT SAVED" if Game.save_attempt() else "SAVE ERROR / FILE NOT COMMITTED")

func _load_now() -> void:
    pending_quiet_service_079 = ""
    pending_quiet_service_deadline_079 = 0
    if Game.has_attempt():
        # Bible: the active checkpoint "cannot be manually rewound through the
        # game UI". Damage, ammo and ampoule use are not autosaved, so loading
        # used to refill them; commit the live state first, and refuse to load
        # while hostiles are engaged so F9 cannot be used to escape a fight.
        if is_instance_valid(Music) and Music.active_combat:
            hud.notify("CHECKPOINT LOCKED / NOT DURING COMBAT")
            return
        Game.save_attempt()
    if Game.load_attempt():
        reload_district_world()
        player.restore_position()
        hud.notify("SAVED ATTEMPT RESTORED / district, actors and grants preserved")
    else:
        hud.notify("NO VALID ACTIVE SAVE")

func _on_level_changed_089(new_level: int) -> void:
    var reward: String = "choose a perk" if new_level in [2,4,6] else ("spend an attribute point" if new_level in [3,5] else "choose +1 attribute or a fourth perk")
    hud.notify("LEVEL %d / %s IN THE DOCKET (TAB)" % [new_level, reward.to_upper()], 4.0)

func _show_dossier() -> void:
    if not Game.has_attempt():return
    player.set_control_active(false)
    var options: Array = [go_back(),{"label":"COMMIT SAVE AT THIS POSITION","action":"save_and_close"}]
    if int(Game.state.get("unspent_attribute_points",0)) > 0:
        for stat_name in ["Force","Reflex","Insight","Speech","Tech","Resolve"]:
            if Game.stat(stat_name) < 10:
                options.append({"label":"SPEND ATTRIBUTE POINT / +1 %s" % stat_name.to_upper(),"action":"attribute:"+stat_name})
    if Game.level7_choice_pending():
        options.append({"label":"LEVEL 7 BONUS / +1 ATTRIBUTE POINT","action":"level7:attribute"})
        options.append({"label":"LEVEL 7 BONUS / A FOURTH PERK","action":"level7:perk"})
    if Game.perk_points_available() > 0:
        for perk_id in Game.PERKS_089.keys():
            if not Game.has_perk(perk_id):
                var perk: Dictionary = Game.PERKS_089[perk_id]
                options.append(check_option("PERK %s %s: %s" % [perk_id, str(perk["name"]).to_upper(), perk["effect"]], "perk:" + perk_id, Game.perk_check(perk_id)))
    hud.open_modal("CIVIC PRESSURE DOCKET",hud.dossier_text(),options,hud.dossier_sections())


func _exit_tree() -> void:
    if is_instance_valid(Music):
        Music.set_listener(null)
