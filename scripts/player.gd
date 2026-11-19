extends CharacterBody3D
## FPV controller + original four-weapon prototype. Animation deliberately uses
## one painted pose per weapon; no frame-by-frame AI body drift.
signal interact_requested(interaction_id: String)
signal shot_fired(hit_something: bool)
signal docket_requested
signal save_requested
signal load_requested
signal heal_requested
signal escape_requested
signal weapon_message(message: String)
signal weapon_switched(id: String)
signal weapon_anim(kind: String, duration: float)
signal aim_prompt_changed(message: String)
signal impact_event_079(at: Vector3, normal: Vector3, material_kind: String)
signal tracer_event_079x(origin: Vector3, destination: Vector3, weapon_kind: String)

const WeaponCatalog = preload("res://scripts/weapon_catalog.gd")
const GRAVITY = 17.0
@onready var camera: Camera3D = $Camera3D
var active := false
var sprint_speed := 5.6
var mouse_sensitivity := 0.0021
var pitch := 0.0
var current_fire_cooldown := 0.0
var dash_time := 0.0
var intervention_cooldown: float = 0.0
var reloading := false
var reload_remaining := 0.0
var reload_item := ""
var reload_attempt := ""
var reload_zone := ""
var nail_overheated := false
var rng := RandomNumberGenerator.new()
var prompt_refresh := 0.0
var last_prompt := ""
# 08.0 optional camera impulse, capped for accessibility and never changes ray origin.
@export var camera_impulse_enabled_080: bool = true
@export_range(0.0, 1.0, 0.05) var camera_impulse_strength_080: float = 0.55
var camera_impulse_080: float = 0.0


func _ready() -> void:
    rng.seed = 20261117
    add_to_group("player_controller")

func set_control_active(enabled: bool) -> void:
    active = enabled
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if enabled else Input.MOUSE_MODE_VISIBLE
    if not enabled:
        camera_impulse_080 = 0.0
        if is_instance_valid(camera): camera.rotation.x = pitch
        velocity.x=0.0
        velocity.z=0.0
        _emit_prompt("")
    if enabled and Game.has_attempt():
        Game.ensure_weapon_state()
        weapon_switched.emit(Game.equipped_weapon())

func _input(event: InputEvent) -> void:
    if not active:return
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        rotate_y(-event.relative.x*mouse_sensitivity)
        pitch=clampf(pitch-event.relative.y*mouse_sensitivity,-1.35,1.35)
        camera.rotation.x=pitch + camera_impulse_080
    if event.is_action_pressed("fire"):
        fire_equipped()
    elif event.is_action_pressed("reload"):
        reload_weapon()
    elif event.is_action_pressed("intervene"):
        intervene()
    elif event.is_action_pressed("interact"):
        try_interact()
    elif event.is_action_pressed("view_docket"):
        docket_requested.emit()
    elif event.is_action_pressed("quick_save"):
        save_requested.emit()
    elif event.is_action_pressed("quick_load"):
        load_requested.emit()
    elif event.is_action_pressed("dash"):
        try_dash()
    elif event is InputEventKey and event.pressed and not event.echo:
        if event.physical_keycode==KEY_1:heal_requested.emit()
        elif event.physical_keycode==KEY_2:select_weapon("covenant")
        elif event.physical_keycode==KEY_3:select_weapon("coil")
        elif event.physical_keycode==KEY_4:select_weapon("nail")
        elif event.physical_keycode==KEY_5:select_weapon("choir")
        elif event.keycode==KEY_F10:
            Music.toggle_mute()
            weapon_message.emit("MUSIC / MUTED" if Music.muted else "MUSIC / ENABLED")
        elif event.keycode==KEY_ESCAPE:escape_requested.emit()

func _physics_process(delta: float) -> void:
    if not active or not Game.has_attempt():
        return
    prompt_refresh=maxf(0.0,prompt_refresh-delta)
    if prompt_refresh<=0.0:
        prompt_refresh=0.08
        _refresh_aim_prompt()
    current_fire_cooldown=maxf(0.0,current_fire_cooldown-delta)
    camera_impulse_080 = move_toward(camera_impulse_080,0.0,delta * 2.1)
    camera.rotation.x = pitch + camera_impulse_080
    intervention_cooldown=maxf(0.0,intervention_cooldown-delta)
    dash_time=maxf(0.0,dash_time-delta)
    if not is_on_floor():velocity.y-=GRAVITY*delta
    else:velocity.y=-0.3
    var movement := Input.get_vector("move_left","move_right","move_forward","move_back")
    var direction := (transform.basis*Vector3(movement.x,0.0,movement.y)).normalized()
    var speed := 5.2
    var sprinting := Input.is_action_pressed("sprint") and movement.length()>0.0 and float(Game.state["breath"])>0.0
    if sprinting:
        speed=minf(8.5,7.25+0.16*(Game.stat("Reflex")-3))
        Game.state["breath"]=maxf(0.0,float(Game.state["breath"])-6.0*delta)
    else:
        var regen_ceiling := Game.max_breath()*0.6
        if float(Game.state["breath"])<regen_ceiling:
            Game.state["breath"]=minf(regen_ceiling,float(Game.state["breath"])+2.0*delta)
    if dash_time>0.0:speed=13.5
    velocity.x=direction.x*speed
    velocity.z=direction.z*speed
    move_and_slide()
    if reloading:
        reload_remaining-=delta
        if reload_remaining<=0.0:
            reloading=false
            if Game.has_attempt() and str(Game.state["attempt_id"])==reload_attempt and str(Game.state.get("zone",""))==reload_zone and Game.equipped_weapon()==reload_item:
                var capacity: int = int(WeaponCatalog.spec(reload_item)["mag"])
                Game.refill_weapon_mag(reload_item,capacity)
                weapon_anim.emit("reload_complete",0.0)
    var equipment: Dictionary = Game.state["weapon_state"]
    var heat: float = float(equipment.get("nail_heat",0.0))
    equipment["nail_heat"]=maxf(0.0,heat-18.0*delta)
    if nail_overheated and float(equipment["nail_heat"])<=55.0:
        nail_overheated=false
        weapon_message.emit("NAIL STORM / Cooling cage released")
    if Game.equipped_weapon()=="nail" and Input.is_action_pressed("fire"):
        fire_equipped()

func select_weapon(id: String) -> void:
    if not Game.has_attempt():return
    if not Game.weapon_owned(id):
        weapon_message.emit("WEAPON NOT ISSUED / use the Sootworks register or help Ossa")
        return
    if Game.equipped_weapon()==id:return
    reloading=false
    reload_remaining=0.0
    if Game.equip_weapon(id):
        weapon_switched.emit(id)
        weapon_anim.emit("switch",0.24)
        weapon_message.emit(str(WeaponCatalog.spec(id)["name"])+" / EQUIPPED")


const ACTION_AUDIO_VOICES: int = 8
var _action_voices: Array[AudioStreamPlayer] = []
var _action_voice_next: int = 0

## Round-robin pool of non-positional players. Previously each shot created a new
## AudioStreamPlayer freed on `finished`, which also leaked a node whenever a
## stream failed to load (it never finishes).
func _play_action_audio(file_name: String, loudness: float = -8.0) -> void:
    var stream: AudioStream = load("res://assets/audio/" + file_name) as AudioStream
    if stream == null:
        push_warning("Missing action audio: " + file_name)
        return
    if _action_voices.is_empty():
        for i in range(ACTION_AUDIO_VOICES):
            var voice := AudioStreamPlayer.new()
            voice.name = "ActionVoice%d" % i
            add_child(voice)
            _action_voices.append(voice)
    var sound: AudioStreamPlayer = _action_voices[_action_voice_next]
    _action_voice_next = (_action_voice_next + 1) % ACTION_AUDIO_VOICES
    sound.stream = stream
    sound.volume_db = loudness
    sound.play()

func intervene() -> void:
    # Low-output, reusable industrial butt-stroke, not an infinite-ammo weapon.
    if not active or not Game.has_attempt() or intervention_cooldown > 0.0 or reloading: return
    intervention_cooldown = 0.88
    _play_action_audio("metal_hit.wav",-11.0)
    var origin: Vector3 = camera.global_position
    var query := PhysicsRayQueryParameters3D.create(origin,origin-camera.global_transform.basis.z*2.6)
    query.exclude = [get_rid()]
    query.collision_mask = 5
    var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
    weapon_anim.emit("dry",0.16)
    if not hit.is_empty():
        var target: Object = hit.get("collider")
        if is_instance_valid(target) and target.has_method("take_hit"):
            target.take_hit(7)
            shot_fired.emit(true)
            weapon_message.emit("EMERGENCY INTERVENTION / 7 IMPACT — KEEP MOVING")
            return
    weapon_message.emit("EMERGENCY INTERVENTION / OUT OF REACH")

func try_dash() -> void:
    if not active or float(Game.state.get("breath",0.0))<14.0 or dash_time>0.0:return
    Game.state["breath"]=float(Game.state["breath"])-14.0
    dash_time=0.24

func fire_equipped() -> void:
    if not Game.has_attempt() or current_fire_cooldown>0.0 or reloading:return
    var id: String = Game.equipped_weapon()
    var spec: Dictionary = WeaponCatalog.spec(id)
    if id=="nail" and (nail_overheated or float(Game.state["weapon_state"].get("nail_heat",0.0))>=90.0):
        nail_overheated=true
        weapon_message.emit("NAIL STORM / PRESSURE CAGE HOT — LET IT COOL")
        weapon_anim.emit("dry",0.12)
        return
    if not Game.consume_weapon_round(id):
        current_fire_cooldown=0.16
        weapon_anim.emit("dry",0.13)
        weapon_message.emit(str(spec["name"])+" / EMPTY — R TO RELOAD")
        return
    current_fire_cooldown=maxf(0.09,float(spec["interval"])*0.88)
    weapon_anim.emit("fire",0.10)
    if camera_impulse_enabled_080:
        var impulse: float = 0.013 if Game.equipped_weapon() == "nail" else (0.038 if Game.equipped_weapon() == "coil" else 0.024)
        camera_impulse_080 = clampf(camera_impulse_080-impulse*camera_impulse_strength_080,-0.055,0.0)
    _play_action_audio("%s_fire.wav" % id,-10.0)
    var hit_enemy := false
    var pellets: int = int(spec.get("pellets",1))
    for i in range(pellets):
        if _resolve_shot(id,int(spec["damage"])):
            hit_enemy=true
    if id=="nail":
        Game.state["weapon_state"]["nail_heat"]=float(Game.state["weapon_state"].get("nail_heat",0.0))+float(spec["heat"])
        if float(Game.state["weapon_state"]["nail_heat"])>=90.0:nail_overheated=true
    shot_fired.emit(hit_enemy)

func _resolve_shot(id: String, damage: int) -> bool:
    var spec: Dictionary=WeaponCatalog.spec(id)
    var origin: Vector3=camera.global_position
    var forward: Vector3=-camera.global_transform.basis.z
    var spread: float=0.0
    if id=="coil":spread=0.075
    elif id=="nail":spread=0.023
    var aim: Vector3=(forward+camera.global_transform.basis.x*rng.randf_range(-spread,spread)+camera.global_transform.basis.y*rng.randf_range(-spread,spread)).normalized()
    var query:=PhysicsRayQueryParameters3D.create(origin,origin+aim*48.0)
    query.exclude=[get_rid()]
    query.collision_mask=5
    var hit: Dictionary=get_world_3d().direct_space_state.intersect_ray(query)
    var end: Vector3 = hit["position"] if not hit.is_empty() else origin+aim*48.0
    tracer_event_079x.emit(origin,end,id)
    if hit.is_empty():return false
    var target: Object=hit.get("collider")
    # Author surface metadata wins over naming heuristics. Unknown world geometry
    # is stone, not inexplicably metal; the impact is purely visual.
    var kind: String = "stone"
    if is_instance_valid(target):
        if target.is_in_group("hostile"):
            kind = "living"
        elif target.has_meta("surface_kind"):
            var declared_kind: String = str(target.get_meta("surface_kind"))
            if declared_kind in ["stone","ceramic","glass","metal","wood","cloth","living"]:
                kind = declared_kind
    impact_event_079.emit(hit["position"],hit["normal"],kind)
    if not is_instance_valid(target) or not target.has_method("take_hit"):return false
    var distance: float=origin.distance_to(hit["position"])
    var effective_range: float=float(spec["range"])
    var falloff: float=1.0 if distance<=effective_range else lerpf(1.0,0.40,clampf((distance-effective_range)/maxf(effective_range,1.0),0.0,1.0))
    target.take_hit(maxi(1,roundi(float(damage)*falloff)))
    return true

func reload_weapon() -> void:
    if not Game.has_attempt() or reloading:return
    var id: String=Game.equipped_weapon()
    var spec: Dictionary=WeaponCatalog.spec(id)
    if Game.weapon_mag(id)>=int(spec["mag"]) or Game.weapon_reserve(id)<=0:
        weapon_message.emit(str(spec["name"])+" / NO RELOAD REQUIRED OR NO RESERVE")
        return
    reloading=true
    _play_action_audio("mechanical_reload.wav",-10.0)
    reload_remaining=float(spec["reload"])
    reload_item=id
    reload_attempt=str(Game.state["attempt_id"])
    reload_zone=str(Game.state.get("zone","hearth"))
    weapon_anim.emit("reload",reload_remaining)
    weapon_message.emit(str(spec["name"])+" / CYCLING SERVICE MAGAZINE")


func _emit_prompt(message: String) -> void:
    if message == last_prompt:
        return
    last_prompt = message
    aim_prompt_changed.emit(message)

func _prompt_for_interaction(id: String) -> String:
    match id:
        "wake_panel": return "[E] WAKE REPRINT RELAY"
        "intake_valve": return "[E] TURN MANUAL VALVE"
        "sela": return "[E] SPEAK TO DR SELA"
        "archive": return "[E] REVIEW PUBLIC ARCHIVE"
        "service_rail", "sootworks_service_rail", "basilica_service_rail", "return_rail": return "[E] BOARD SERVICE RAIL"
        "brin": return "[E] SPEAK TO BRIN HARKER"
        "ossa": return "[E] SPEAK TO SISTER OSSA"
        "payroll": return "[E] INSPECT PAYROLL CYLINDER"
        "register": return "[E] OPEN PUBLIC REGISTER"
        "governor_reel": return "[E] EXAMINE HYMN REEL"
        "hearing_desk": return "[E] BEGIN PUBLIC HEARING"
        "core_assembly_gate_078": return "[E] PUBLIC ASSEMBLY GATE"
        "assembly_final_078": return "[E] CHOOSE FINAL CIVIC SETTLEMENT"
        "assembly_mandate_078": return "[E] PUBLIC MANDATE ROLL"
        "quorum_audit_desk": return "[E] THREE-WRIT QUORUM / FREIGHT LIFT"
        "core_conscription_order": return "[E] READ ORIGINAL CONSCRIPTION ORDER"
        "core_architect_objection": return "[E] PLAY ARCHITECT'S OBJECTION"
        "core_rail_charter": return "[E] INSPECT EMERGENCY RAIL CAPACITY"
        "core_excluded_wards": return "[E] REVIEW EXCLUDED WARD NAMES"
        "core_voluntary_petition": return "[E] READ SIGNED PATIENT PETITION"
        "core_independent_radio": return "[E] EXAMINE RADIO PLAN"
        "core_safety_bus": return "[E] INSPECT SAFETY FALLBACK"
        "core_carriage_repair": return "[E] INSPECT SPARE CARRIAGE REPAIRS"
        "core_boarding_plan": return "[E] DRAFT RAIL PRIORITY LIST"
        "core_cipher": return "[E] INSPECT UNIQUE MAINTENANCE CIPHER"
        "core_custodian_docket": return "[E] REVIEW CUSTODIAN'S AUTHORITY"
        "core_return_rail": return "[E] RETURN TO HEARTH NINE"
        "market_contract_archive": return "[E] INSPECT DUPLICATE CONTRACTS"
        "market_witness_counter": return "[E] RECORD BUYER TESTIMONY"
        "market_buyer_council": return "[E] ASSEMBLE BUYER COALITION"
        "market_counting_lock": return "[E] ISOLATE COUNTING LOCK"
        "market_collector_desk": return "[E] CHALLENGE COLLECTOR"
        "market_trade_registry": return "[E] FILE TRADE WRIT"
        "market_rain_cistern": return "[E] CHECK WATER ALLOTMENT"
        "quorum_audit_desk": return "[E] VERIFY THREE WRITS"
        _:
            return "[E] " + id.replace("_", " ").to_upper()

func _refresh_aim_prompt() -> void:
    var origin: Vector3 = camera.global_position
    var query := PhysicsRayQueryParameters3D.create(origin, origin - camera.global_transform.basis.z * 3.5)
    query.exclude = [get_rid()]
    query.collision_mask = 1
    var result: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
    if result.is_empty():
        _emit_prompt("")
        return
    var target: Object = result.get("collider")
    if is_instance_valid(target) and target.has_meta("interaction_id"):
        _emit_prompt(_prompt_for_interaction(str(target.get_meta("interaction_id"))))
    else:
        _emit_prompt("")

func try_interact() -> void:
    var origin: Vector3=camera.global_position
    var query:=PhysicsRayQueryParameters3D.create(origin,origin-camera.global_transform.basis.z*3.5)
    query.exclude=[get_rid()]
    query.collision_mask=1
    var result: Dictionary=get_world_3d().direct_space_state.intersect_ray(query)
    if result.is_empty():
        weapon_message.emit("No service point in reach")
        return
    var target: Object=result.get("collider")
    if is_instance_valid(target) and target.has_meta("interaction_id"):
        for child in target.get_children():
            if child.has_method("talk_079x"):
                child.talk_079x()
        interact_requested.emit(str(target.get_meta("interaction_id")))
    else:weapon_message.emit("No accessible docket on this object")

func capture_position() -> void:
    if not Game.has_attempt():return
    Game.state["player_pos"]=[position.x,position.y,position.z]
    if Game.state.has("zone_positions"):
        Game.state["zone_positions"][str(Game.state.get("zone","hearth"))]=Game.state["player_pos"].duplicate()
    Game.state["yaw"]=rotation.y
    Game.state["pitch"]=pitch
    if not Game.state.has("zone_yaws"): Game.state["zone_yaws"] = {}
    Game.state["zone_yaws"][str(Game.state.get("zone","hearth"))]=rotation.y

func restore_position() -> void:
    # World replacement and F9 restore must discard transient per-frame state.
    # Otherwise an old reload, dash, recoil or vertical velocity can leak into
    # a restored attempt and complete after a different save has been loaded.
    reloading = false
    reload_remaining = 0.0
    reload_item = ""
    reload_attempt = ""
    reload_zone = ""
    dash_time = 0.0
    current_fire_cooldown = 0.0
    intervention_cooldown = 0.0
    camera_impulse_080 = 0.0
    velocity = Vector3.ZERO
    nail_overheated = Game.has_attempt() and float(Game.state.get("weapon_state",{}).get("nail_heat",0.0)) >= 90.0
    var coords: Array=Game.state.get("player_pos",[-15.5,0.15,8.0])
    position=Vector3(float(coords[0]),float(coords[1]),float(coords[2]))
    rotation.y=float(Game.state.get("yaw",-1.570796))
    pitch=float(Game.state.get("pitch",0.0))
    camera.rotation.x=pitch
    if Game.has_attempt():
        Game.ensure_weapon_state()
        weapon_switched.emit(Game.equipped_weapon())
