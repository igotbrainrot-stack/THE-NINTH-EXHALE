extends Node3D
## Three authored area encounters built around positioning and judgement.
## Low-health/tutorial safety, finite resource consequences, no new quest gates.
signal shutdown_requested(hazard_key: String, method: String)
signal shutdown_rejected(message: String)
const SwitchScript = preload("res://scripts/hazard_switch_079.gd")
var hazard_key: String = "hearth"
var player: CharacterBody3D
var switch: StaticBody3D
var floor_indicator: MeshInstance3D
var status_light: OmniLight3D
var status_label: Label3D
var material: StandardMaterial3D
var phase_clock: float = 0.0
var hit_cooldown: float = 0.0
var last_mode: String = "quiet"
var was_active: bool = false
var was_warning: bool = false
var cue: AudioStreamPlayer3D
var disabled: bool = false
var danger_radius: float = 3.4
var cycle_time: float = 4.2
var warning_start: float = 2.7
var attack_start: float = 3.6
var attack_end: float = 4.05

func configure(zone: String, target: CharacterBody3D, is_disabled: bool, seed: int) -> void:
    hazard_key = zone
    player = target
    disabled = is_disabled
    phase_clock = float(abs(seed) % 3) * 0.42

func _ready() -> void:
    if hazard_key == "hearth":
        position = Vector3(-14.0,0.01,10.8)
        danger_radius = 2.15
        cycle_time = 4.4
        warning_start = 2.9
        attack_start = 3.65
        attack_end = 4.2
    elif hazard_key == "sootworks":
        position = Vector3(12.3,0.01,-3.4)
        danger_radius = 3.25
        cycle_time = 4.7
        warning_start = 2.65
        attack_start = 3.55
        attack_end = 4.3
    else:
        position = Vector3(13.7,0.01,5.4)
        danger_radius = 4.05
        cycle_time = 5.1
        warning_start = 2.8
        attack_start = 3.85
        attack_end = 4.55
    _build_visuals()
    cue = AudioStreamPlayer3D.new()
    var file_name: String = "arc_discharge_079.wav" if hazard_key == "hearth" else ("forge_exhaust_079.wav" if hazard_key == "sootworks" else "basilica_reed_079.wav")
    cue.stream = load("res://assets/audio/" + file_name)
    cue.max_distance = 15.0
    cue.volume_db = -14.0
    add_child(cue)
    if disabled:
        _mark_disabled()

func _build_visuals() -> void:
    floor_indicator = MeshInstance3D.new()
    floor_indicator.name = "Telegraphed hazard floor / no physical barrier"
    floor_indicator.position = Vector3(0,0.035,0)
    var ring := CylinderMesh.new()
    ring.top_radius = danger_radius
    ring.bottom_radius = danger_radius
    ring.height = 0.055
    if hazard_key == "sootworks":
        # Furnace exhaust is a directed vent lane rather than a round blast.
        var vent := BoxMesh.new()
        vent.size = Vector3(2.6,0.055,8.4)
        floor_indicator.mesh = vent
    else:
        floor_indicator.mesh = ring
    material = StandardMaterial3D.new()
    material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    material.albedo_color = Color(0.35,0.55,0.42,0.06)
    floor_indicator.material_override = material
    add_child(floor_indicator)
    if hazard_key == "basilica":
        var shelter := MeshInstance3D.new()
        shelter.name = "Resonator inner shelter / no Breath damage"
        shelter.position.y = 0.07
        var disc := CylinderMesh.new()
        disc.top_radius = 1.25
        disc.bottom_radius = 1.25
        disc.height = 0.075
        shelter.mesh = disc
        var safe_mat := StandardMaterial3D.new()
        safe_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
        safe_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
        safe_mat.albedo_color = Color(0.20,0.85,0.65,0.35)
        shelter.material_override = safe_mat
        add_child(shelter)
    # A painted industrial pressure docket is a floor-mounted marking, not
    # a camera-facing cardboard prop; its footprint matches the danger ring.
    var floor_decal := MeshInstance3D.new()
    floor_decal.name = "Fixed pressure circuit / painted floor safety stencil"
    floor_decal.position.y = 0.09
    floor_decal.rotation_degrees.x = -90.0
    var plate := QuadMesh.new()
    plate.size = Vector2(2.6,8.4) if hazard_key == "sootworks" else Vector2(danger_radius*2.0,danger_radius*2.0)
    floor_decal.mesh = plate
    var decal_material := StandardMaterial3D.new()
    decal_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    decal_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    decal_material.albedo_texture = load("res://assets/textures/pressure_docket_079.png")
    decal_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
    decal_material.cull_mode = BaseMaterial3D.CULL_DISABLED
    floor_decal.material_override = decal_material
    add_child(floor_decal)
    status_light = OmniLight3D.new()
    status_light.name = "Pressure / signal indicator"
    status_light.position = Vector3(0,1.6,0)
    status_light.light_color = Color("#e7b667")
    status_light.light_energy = 0.0
    status_light.omni_range = 5.5
    add_child(status_light)
    status_label = Label3D.new()
    status_label.position = Vector3(0,1.95,0)
    status_label.font_size = 21
    status_label.pixel_size = 0.007
    status_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    status_label.modulate = Color("#e8d3af")
    add_child(status_label)
    switch = SwitchScript.new()
    switch.name = "Physical safety lever"
    switch.set("hazard_key",hazard_key)
    switch.set("director",self)
    # The lever lives outside the pulse's walkable danger disc.
    switch.position = Vector3(-5.6,0,-3.2) if hazard_key == "basilica" else Vector3(-4.7,0,-4.2)
    add_child(switch)

func is_danger_active() -> bool:
    return not disabled and _encounter_is_live() and fmod(phase_clock,cycle_time) >= attack_start and fmod(phase_clock,cycle_time) < attack_end

func _encounter_is_live() -> bool:
    if not Game.has_attempt(): return false
    if hazard_key == "hearth":
        return Game.intro_stage() == "alarm"
    # Nonviolent routes are real. Machines only become hazardous when the
    # associated enforcement system is actively fighting the player.
    var key: String = "millwright" if hazard_key == "sootworks" else "cantor"
    var saved: Dictionary = Game.state.get("actors",{}).get(key,{})
    if not bool(saved.get("alive",true)): return false
    if hazard_key == "sootworks" and str(Game.state.get("brin",{}).get("decision","")) == "help": return false
    if hazard_key == "basilica" and bool(Game.state.get("faith",{}).get("governor_isolated",false)): return false
    if hazard_key == "basilica" and str(Game.state.get("ossa",{}).get("decision","")) == "help": return false
    return bool(saved.get("hostile",false))

func can_quiet_shutdown() -> bool:
    # Acoustic service dials have a safe interval the player can learn.
    # Furnace and intake have a stable manual shutdown latch at all times.
    if hazard_key == "basilica":
        var t: float = fmod(phase_clock,cycle_time)
        return t <= warning_start or t >= attack_end
    return true

func try_shutdown(method: String) -> void:
    if disabled or not Game.has_attempt(): return
    if method == "quiet" and not can_quiet_shutdown():
        status_label.text = "HIGH SIGNAL / WAIT FOR THE LOW NOTE"
        shutdown_rejected.emit("BASILICA / WAIT FOR THE LOW SIGNAL WINDOW")
        return
    last_mode = method
    shutdown_requested.emit(hazard_key,method)

func confirm_shutdown() -> void:
    disabled = true
    _mark_disabled()

func _mark_disabled() -> void:
    material.albedo_color = Color(0.21,0.40,0.29,0.08)
    status_light.light_energy = 0.0
    status_label.text = "ISOLATED / NO REPEATING DANGER"
    if is_instance_valid(switch) and switch.has_method("mark_spent"):
        switch.mark_spent()

func _has_clear_pressure_path_079y() -> bool:
    # World geometry blocks a hazardous pressure pulse. The ray only checks
    # environment collision layer 1: a nearby enemy must not shield the player.
    if not is_instance_valid(player): return false
    var from_point: Vector3 = global_position + Vector3(0,1.1,0)
    var to_point: Vector3 = player.global_position + Vector3(0,1.1,0)
    var query := PhysicsRayQueryParameters3D.create(from_point,to_point)
    query.collision_mask = 1
    return get_world_3d().direct_space_state.intersect_ray(query).is_empty()

func _clear_path_to_actor_079z(actor: Node3D) -> bool:
    # The vent may stagger enemies, but cannot reach through district walls.
    var source: Vector3 = global_position + Vector3(0,1.1,0)
    var goal: Vector3 = actor.global_position + Vector3(0,1.1,0)
    var query := PhysicsRayQueryParameters3D.create(source,goal)
    query.collision_mask = 1
    return get_world_3d().direct_space_state.intersect_ray(query).is_empty()

func _pulse_enemy_pressure_079y() -> void:
    # One visible opening per forge cycle. Do not damage a Writ holder or
    # silently kill a character: only a recoverable stagger is allowed.
    if hazard_key != "sootworks": return
    for foe in get_tree().get_nodes_in_group("hostile"):
        if not is_instance_valid(foe) or not (foe is Node3D): continue
        if not foe.has_method("apply_environmental_stagger"): continue
        if int(foe.get("hp")) <= 0 or not bool(foe.get("hostile")): continue
        var local_foe: Vector3 = to_local(foe.global_position)
        if absf(local_foe.x) < 1.3 and absf(local_foe.z) < 4.2 and _clear_path_to_actor_079z(foe):
            foe.apply_environmental_stagger(0.85)

func _physics_process(delta: float) -> void:
    if disabled or not Game.has_attempt(): return
    if not _encounter_is_live():
        was_warning = false
        was_active = false
        status_label.text = "INACTIVE SERVICE CHANNEL"
        material.albedo_color = Color(0.35,0.55,0.42,0.04)
        status_light.light_energy = 0.0
        return
    phase_clock += delta
    hit_cooldown = maxf(0.0,hit_cooldown-delta)
    var t: float = fmod(phase_clock,cycle_time)
    var warming: bool = t >= warning_start and t < attack_start
    var active_now: bool = is_danger_active()
    if active_now:
        if not was_active:
            if is_instance_valid(cue): cue.play()
            _pulse_enemy_pressure_079y()
        status_label.text = "LIVE / RING ONLY / INNER SHELTER" if hazard_key == "basilica" else ("VENT JET / STEP OUT OF LINE" if hazard_key == "sootworks" else "SERVICE ARC / MOVE TO COVER")
        material.albedo_color = Color(0.89,0.31,0.23,0.28)
        status_light.light_color = Color("#e8754a")
        status_light.light_energy = 0.85
        if is_instance_valid(player) and player.active and hit_cooldown <= 0.0:
            var planar_distance: float = Vector2(player.global_position.x-global_position.x,player.global_position.z-global_position.z).length()
            var local_player: Vector3 = to_local(player.global_position)
            var in_vent: bool = absf(local_player.x) < 1.3 and absf(local_player.z) < 4.2
            # The Basilica's resonator creates an annular pulse; the middle is
            # sheltered by the original instrument, unlike the furnace lane.
            var in_acoustic_ring: bool = planar_distance < danger_radius and planar_distance > 1.25
            var exposed: bool = in_vent if hazard_key == "sootworks" else (in_acoustic_ring if hazard_key == "basilica" else planar_distance < danger_radius)
            if exposed and _has_clear_pressure_path_079y():
                hit_cooldown = 1.45
                if hazard_key == "basilica":
                    Game.state["breath"] = maxf(0.0,float(Game.state.get("breath",0.0))-7.0)
                    Game.state_changed.emit()
                else:
                    Game.take_damage(4 if hazard_key == "hearth" else 7)
    elif warming:
        if not was_warning and is_instance_valid(cue): cue.play()
        status_label.text = "WARNING / RISING NOTE / USE INNER SHELTER" if hazard_key == "basilica" else ("WARNING / FURNACE WINDUP / CLEAR THE VENT" if hazard_key == "sootworks" else "WARNING / ARC CHARGING / TAKE COVER")
        material.albedo_color = Color(0.97,0.68,0.24,0.20)
        status_light.light_color = Color("#f1c55c")
        status_light.light_energy = 0.45
    else:
        status_label.text = "LOW CYCLE / SAFE TO CROSS"
        material.albedo_color = Color(0.40,0.55,0.43,0.07)
        status_light.light_energy = 0.0
    was_active = active_now
    was_warning = warming
