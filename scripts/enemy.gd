extends CharacterBody3D
## 06.6: distinct, readable attack commitments. Collision and the original
## actor keys / death events remain authoritative in Game.run_state.
signal defeated
signal became_hostile
signal telegraph_started(message: String)
const EnemyRoster068 = preload("res://scripts/enemy_roster_068.gd")
const Rotation8 = preload("res://scripts/sprite_rotations_071.gd")
const Grounding074 = preload("res://scripts/sprite_grounding_074.gd")
const CombatTracer079X = preload("res://scripts/combat_tracer_079x.gd")
const CombatCorpse080 = preload("res://scripts/combat_corpse_080.gd")
var actor_key: String = "enforcer"
var max_hp: int = 70
const PAIN_GUARD_095: float = 0.7
var pain_damage_095: float = 0.0
var pain_guard_095: float = 0.0
var flinches_095: int = 0          # tests and the district record read this
var hp: int = 70
var hostile: bool = false
var player: CharacterBody3D
var shot_interval: float = 2.25
var attack_timer: float = 1.0
var frame_timer: float = 0.0
var sprite_frames: Array[Texture2D] = []
var sprite: Sprite3D
var warning: MeshInstance3D
var warning_material: StandardMaterial3D
var warning_audio: AudioStreamPlayer3D
var impact_audio: AudioStreamPlayer3D
var voice_083: Node
var windup: float = 0.0
var recovery: float = 0.0
var rush_time: float = 0.0
var rush_hit_ready: bool = false
var rush_direction: Vector3 = Vector3.ZERO
var attack_sequence: int = 0
var stagger_time: float = 0.0
var flash_time: float = 0.0
# 06.8 deterministic directional animation: fixed cell dimensions and baseline.
var animated_textures: Dictionary = {}
var animation_state: String = "idle"
var sprite_rotation_mode: int = 8 # 0 universal / 8 directional, default 8
var animation_timer: float = 0.0
var death_time: float = 0.0
var corpse_spawned_080: bool = false
var wounded_count: int = 0
var alert_time_079x: float = 0.0
var displayed_animation_state_079y: String = ""
var aim_lane_079z: MeshInstance3D
var aim_lane_mat_079z: StandardMaterial3D
var role: Dictionary = {}
var role_speed: float = 2.1
var role_reach: float = 10.5
var role_damage: int = 9
var role_attack: String = "line"
var role_move: String = "guard"
var wake_distance: float = 0.0
var last_seen_position: Vector3 = Vector3.ZERO
var time_since_sighted: float = 100.0
var positional_memory: float = 4.0
# 08.4: bounded navigation fallback for colliding with scenery. No new AI goals,
# teleportation, phantom projectiles, or expensive per-frame path searches.
var obstacle_dodge_time_084: float = 0.0
## Build 09.2 perception (immersive-sim Phase 1): replaces the distance wake.
const Sense092 = preload("res://scripts/sense_092.gd")
const Perception093 = preload("res://scripts/perception_092.gd")
const Callouts095 = preload("res://scripts/callouts_095.gd")
var sense_092: Node = null
## Build 09.2 drop-in animation (assets/sprites/anim_092/<actor_key>/). Any
## state it lacks falls back to the 12-cell atlas below.
const SpriteAnim092 = preload("res://scripts/sprite_anim_092.gd")
var anim_092: RefCounted = null
var obstacle_dodge_side_084: float = 1.0
var obstacle_dodge_direction_084: Vector3 = Vector3.ZERO
var obstacle_dodge_cooldown_084: float = 0.0
const DIRECTIONS: Array = [1,2,3,4,5,6,7,8]
const ATLAS_W: int = 192
const ATLAS_H: int = 256

func _ready() -> void:
    collision_layer = 4
    collision_mask = 1
    role = EnemyRoster068.spec(actor_key)
    if not role.is_empty():
        role_speed = float(role.get("speed",2.1))
        if actor_key == "sentry" or str(role.get("zone","")) == "hearth" and str(role.get("attack","")) == "rush":
            role_speed *= 1.16
        role_reach = float(role.get("reach",10.5))
        role_damage = int(role.get("damage",9))
        role_attack = str(role.get("attack","line"))
        role_move = str(role.get("move","guard"))
        wake_distance = float(role.get("wake",0.0))
        shot_interval = float(role.get("interval",shot_interval))
        # Role/zone authored tempo survives _ready() and respects old saves.
        var area: String = str(role.get("zone",""))
        if area == "hearth" and role_attack == "rush": shot_interval *= 0.85
        elif area == "sootworks" and role_attack in ["line","heavy"]: shot_interval *= 0.87
        elif area == "basilica" and role_attack in ["signal","pull"]: shot_interval *= 0.88
        max_hp = int(role.get("hp",max_hp))
        if hp != max_hp: hp = max_hp
    if actor_key == "core_actuator":
        role_move = "boss"
        role_attack = "heavy"
        role_speed = 1.75
        role_reach = 15.0
        role_damage = 12
        shot_interval = 1.65
    if actor_key == "collector":
        # Collector is an office-holder, not another optional roaming type.
        # The distinct Trade frame uses the enforcer animation rig until its
        # original eight-view painting is completed.
        role_move = "skirmish"
        role_attack = "line"
        role_speed = 1.95
        role_reach = 11.0
        role_damage = 10
    var short_body: bool = actor_key in ["sentry","pressure_mite","vent_whistler","rivet_courier","choir_reed"]
    var shape := CapsuleShape3D.new()
    shape.height = 0.95 if short_body else 1.75
    shape.radius = 0.30 if short_body else 0.38
    var collision := CollisionShape3D.new()
    collision.position.y = 0.475 if short_body else 0.875
    collision.shape = shape
    add_child(collision)
    sprite = Sprite3D.new()
    sprite.position.y = 0.54 if short_body else 1.03
    sprite.pixel_size = 0.0052 if short_body else 0.0082
    sprite.shaded = false
    sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
    sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
    sprite.alpha_scissor_threshold = 0.26
    var texture_path: String = "res://assets/sprites/%s_front.png" % actor_key
    if actor_key == "edda_machine": texture_path = "res://assets/sprites/millwright_front.png"
    if actor_key == "collector": texture_path = "res://assets/sprites/enforcer_front.png"
    if actor_key == "core_actuator": texture_path = "res://assets/sprites/edda_machine_front.png"
    if actor_key == "gardener": texture_path = "res://assets/sprites/sentry_front.png"
    if actor_key == "commandant": texture_path = "res://assets/sprites/millwright_front.png"
    if not ResourceLoader.exists(texture_path):
        texture_path = "res://assets/sprites/sentry_front.png"
    var standing_texture: Texture2D = load(texture_path)
    for i in range(4): sprite_frames.append(standing_texture)
    sprite.texture = sprite_frames[0]
    add_child(sprite)
    Grounding074.add_contact_shadow(self, 1.30 if short_body else 0.98, 0.82 if short_body else 0.57)
    _load_directional_animation()
    warning = MeshInstance3D.new()
    warning.name = "Visible pressure attack telegraph"
    warning.position = Vector3(0,2.05,0)
    var mesh := CylinderMesh.new()
    mesh.top_radius = 0.30
    mesh.bottom_radius = 0.30
    mesh.height = 0.07
    warning.mesh = mesh
    warning_material = StandardMaterial3D.new()
    warning_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    warning_material.albedo_color = Color("#eab75c")
    warning.material_override = warning_material
    warning.visible = false
    add_child(warning)
    # A faint projected threat line gives a player a directional dodge cue.
    # Visual only; it cannot alter the authoritative attack ray or hitbox.
    aim_lane_079z = MeshInstance3D.new()
    aim_lane_079z.name = "Attack windup / projected line of fire"
    var lane_mesh := BoxMesh.new()
    lane_mesh.size = Vector3(0.045,0.045,1.0)
    aim_lane_079z.mesh = lane_mesh
    aim_lane_mat_079z = StandardMaterial3D.new()
    aim_lane_mat_079z.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    aim_lane_mat_079z.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    aim_lane_mat_079z.albedo_color = Color(1.0,0.55,0.18,0.38)
    aim_lane_079z.material_override = aim_lane_mat_079z
    aim_lane_079z.visible = false
    add_child(aim_lane_079z)
    warning_audio = AudioStreamPlayer3D.new()
    warning_audio.stream = load("res://assets/audio/pressure_warning.wav")
    warning_audio.max_distance = 15.0
    add_child(warning_audio)
    impact_audio = AudioStreamPlayer3D.new()
    impact_audio.stream = load("res://assets/audio/metal_hit.wav")
    impact_audio.max_distance = 15.0
    add_child(impact_audio)
    voice_083 = preload("res://scripts/actor_voice_083.gd").new()
    voice_083.name = "Voice083"
    voice_083.set("kind", "organic" if actor_key in ["sentry", "cantor", "choir_reed", "bell_wretch", "rootkin", "pressure_mite", "vent_whistler", "saltbound_porter", "gardener"] else "mechanical")
    add_child(voice_083)
    add_to_group("hostile")
    if Game.has_attempt():
        var saved: Dictionary = Game.state["actors"].get(actor_key,{})
        hp = int(saved.get("hp",max_hp))
        hostile = bool(saved.get("hostile",false))
        # Older saves may omit a position. Keep this enemy's authored spawn
        # rather than silently stacking every unrecorded actor at one point.
        var location: Array = saved.get("position",[position.x,position.y,position.z])
        position = Vector3(float(location[0]),float(location[1]),float(location[2]))
        if hostile:
            # 09.3: a reloaded hostile has no fresh sighting; if it cannot
            # see the player it searches where it stands, not at the origin.
            last_seen_position = position
            time_since_sighted = 0.0
    # Optional enemies (wake > 0) perceive the player; office-holders and the
    # Edda machine (wake 0) react to perceived violence instead (sense_092.gd).
    # Set up after the saved position is restored, so home and facing are true.
    sense_092 = Sense092.new()
    add_child(sense_092)
    sense_092.setup(self, "patrol" if wake_distance > 0.0 else "civic")

func anger() -> void:
    if not hostile:
        hostile = true
        alert_time_079x = 0.36
        # 09.3: turning hostile means knowing where the attacker is now; the
        # search memory starts from here, not from a stale default.
        if is_instance_valid(player):
            last_seen_position = player.global_position
        time_since_sighted = 0.0
        if Game.has_attempt(): Game.state["actors"][actor_key]["hostile"] = true
        if is_instance_valid(voice_083): voice_083.call("play_enemy", "alert")
        became_hostile.emit()

## 09.6: a weapon hit carries the bible's stagger value (§8 weapon table:
## Covenant 8, Coil 35 a shot, Nail Storm 3, Choirbreaker 17). Other hits
## (intervention, hazards, scripted damage) build pain from their damage.
var _incoming_stagger_096: float = -1.0

func take_weapon_hit_096(damage: int, stagger: float) -> void:
    _incoming_stagger_096 = stagger
    take_hit(damage)
    _incoming_stagger_096 = -1.0

func take_hit(damage: int) -> void:
    if hp <= 0: return
    anger()
    var applied_damage: int = damage
    # Service screens reduce damage while braced; their recovery window is exposed.
    if role_move == "shield" and windup <= 0.0 and recovery <= 0.0:
        applied_damage = maxi(1,roundi(damage * 0.45))
    hp -= applied_damage
    wounded_count += 1
    # 09.5: Doom's pain chance, made deterministic (no dice: bible L699).
    # Stagger (09.6: the weapon's bible stagger value, else damage) builds
    # toward a role threshold; crossing it flinches the enemy
    # (and cancels its attack), then it cannot flinch again for PAIN_GUARD s.
    # A wind-up takes twice the damage to interrupt. Before this every hit
    # staggered, so the Nail Storm (one shot per 0.09 s) stun-locked anything.
    pain_damage_095 += _incoming_stagger_096 if _incoming_stagger_096 >= 0.0 else float(applied_damage)
    var pain_needed: float = pain_threshold_095() * (2.0 if windup > 0.0 else 1.0)
    if pain_guard_095 <= 0.0 and pain_damage_095 >= pain_needed:
        stagger_time = maxf(stagger_time,0.24 if actor_key != "millwright" else 0.11)
        pain_damage_095 = 0.0
        pain_guard_095 = PAIN_GUARD_095
        flinches_095 += 1
        if hp > 0:
            Callouts095.say(self, "PAIN")
    flash_time = 0.22
    if is_instance_valid(voice_083): voice_083.call("play_enemy", "death" if hp <= 0 else "hurt")
    impact_audio.play()
    if Game.has_attempt(): Game.state["actors"][actor_key]["hp"] = maxi(0,hp)
    if hp <= 0:
        hp = 0
        hostile = false
        preload("res://scripts/district_record_095.gd").bump("put_down")
        Callouts095.man_down(self)
        death_time = 0.84
        if anim_092 != null and anim_092.has_state("death"):
            death_time = maxf(0.84, anim_092.duration("death") + 0.12)
        animation_timer = 0.0
        animation_state = "death"
        velocity = Vector3.ZERO
        warning.visible = false
        aim_lane_079z.visible = false
        # Death is a visible short animation, not an instant disappearing sprite.
        defeated.emit()

## Stagger that makes this enemy flinch, by role (fraction of max HP, 8..45).
## 09.6: who can speak. People, and frames worked by a named office-holder,
## speak; automata only make sounds (shown as bracketed captions). Roster
## enemies carry "voice" in data/enemy_roster_068.json; the district keepers
## below are not in the roster.
const KEEPER_VOICE_096 := {"collector": "speech", "commandant": "speech", "core_actuator": "machine", "gardener": "machine"}

func voice_kind() -> String:
    var spec: Dictionary = EnemyRoster068.spec(actor_key)
    if spec.has("voice"): return str(spec["voice"])
    return str(KEEPER_VOICE_096.get(actor_key, "speech"))

func pain_threshold_095() -> float:
    var fraction: float = 0.15
    if role_attack == "rush": fraction = 0.10
    elif role_move in ["boss", "shield", "siege"]: fraction = 0.30
    elif role_attack in ["heavy", "pull"]: fraction = 0.24
    elif role_attack == "signal": fraction = 0.18
    return clampf(float(max_hp) * fraction, 8.0, 45.0)

func apply_environmental_stagger(seconds: float) -> void:
    if hp <= 0: return
    stagger_time = maxf(stagger_time, seconds)
    windup = 0.0
    rush_time = 0.0
    warning.visible = false
    aim_lane_079z.visible = false
    attack_timer = maxf(attack_timer,seconds + 0.65)
    flash_time = 0.4

func _attack_label() -> String:
    if not role.is_empty() and int(role.get("rank",0)) > 0:
        return "%s / %s — WATCH THE AMBER WINDUP" % [str(role.get("name","SERVICE HOSTILE")).to_upper(),str(role_attack).to_upper()]
    match actor_key:
        "sentry": return "CRAWLER / INTAKE RUSH — MOVE SIDEWAYS OR USE COVER"
        "millwright": return "MILLWRIGHT / PRESSURE CYCLE — BREAK LINE OF SIGHT"
        "cantor": return "CANTOR / SIGNAL PULSE — TAKE COVER"
        "edda_machine": return "TRIAGE REGULATOR / LOAD SPIKE — FIND SHELTER"
        "core_actuator": return "CENTRAL EXECUTIVE ACTUATOR / PRESSURE PULSE — FIND COVER"
        "collector": return "COLLECTOR / BONDED SECURITY — AVOID THE COUNTING SHUTTER"
        "gardener": return "GARDENER / ROOT MOTOR PULSE — BREAK SIGHTLINES"
        "commandant": return "COMMANDANT / HEAVY ARMOUR FRAME — SEEK COVER"
        _: return "ENFORCER / RAISING SERVICE CARBINE"

func _has_clear_shot() -> bool:
    if not is_instance_valid(player): return false
    var origin: Vector3 = global_position + Vector3(0,1.15,0)
    var destination: Vector3 = player.global_position + Vector3(0,1.15,0)
    var query := PhysicsRayQueryParameters3D.create(origin,destination)
    query.exclude = [get_rid()]
    query.collision_mask = 3
    var result: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
    return not result.is_empty() and result.get("collider") == player

func _ally_winding_up() -> bool:
    # Small groups alternate their commitments. Telegraph overlap is harder
    # to read and often creates unavoidable burst damage for low-Reflex builds.
    for member in get_tree().get_nodes_in_group("hostile"):
        if member == self or not is_instance_valid(member): continue
        if not (member is Node3D): continue
        if global_position.distance_to(member.global_position) > 11.0: continue
        if float(member.get("windup")) > 0.0 and bool(member.get("hostile")):
            return true
    return false

func _begin_windup() -> void:
    windup = 0.56 if role_attack == "rush" else (0.78 if role_attack == "heavy" else (0.71 if role_attack == "pull" else 0.64))
    warning.visible = true
    animation_timer = 0.0
    warning_audio.play()
    if is_instance_valid(voice_083): voice_083.call("play_enemy", "windup")
    Callouts095.say(self, "WINDUP_" + role_attack)
    _update_aim_lane_079z()
    telegraph_started.emit(_attack_label())

func _update_aim_lane_079z() -> void:
    if not is_instance_valid(aim_lane_079z) or not is_instance_valid(player): return
    if role_attack == "rush" or windup <= 0.0:
        aim_lane_079z.visible = false
        return
    var source: Vector3 = global_position + Vector3(0,1.25,0)
    var goal: Vector3 = player.global_position + Vector3(0,1.25,0)
    var path: Vector3 = goal-source
    if path.length_squared() < 0.16:
        aim_lane_079z.visible = false
        return
    # A wall clips the projected beam, just as it blocks the actual projectile.
    var query := PhysicsRayQueryParameters3D.create(source,goal)
    query.exclude = [get_rid()]
    query.collision_mask = 1
    var obstruction: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
    if not obstruction.is_empty(): goal = obstruction["position"]
    var segment: Vector3 = goal-source
    if segment.length_squared() < 0.16:
        aim_lane_079z.visible = false
        return
    aim_lane_079z.visible = true
    aim_lane_079z.global_position = (source+goal)*0.5
    aim_lane_079z.look_at(goal, preload("res://scripts/combat_tracer_079x.gd").safe_up(segment))
    aim_lane_079z.scale = Vector3(1.0,1.0,segment.length())
    var cue_color: Color = aim_lane_mat_079z.albedo_color
    cue_color.a = 0.30 + 0.14 * absf(sin(frame_timer*19.0))
    aim_lane_mat_079z.albedo_color = cue_color

func _draw_attack_streak_079y(origin: Vector3, destination: Vector3) -> void:
    # Every committed shot has a spatially honest visible path, including misses
    # stopped by cover. Purely cosmetic; the physics ray remains authoritative.
    var streak := CombatTracer079X.new()
    get_tree().current_scene.add_child(streak)
    var tone := Color("#e7a84a")
    if role_attack in ["signal", "pull"]: tone = Color("#6eefd3")
    elif role_attack == "heavy": tone = Color("#f46c48")
    streak.configure(origin,destination,tone)

func _line_attack(damage: int) -> bool:
    if not is_instance_valid(player): return false
    var origin: Vector3 = global_position + Vector3(0,1.25,0)
    var destination: Vector3 = player.global_position + Vector3(0,1.25,0)
    var query := PhysicsRayQueryParameters3D.create(origin,destination)
    query.exclude = [get_rid()]
    query.collision_mask = 3
    var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
    var endpoint: Vector3 = hit.get("position",destination)
    _draw_attack_streak_079y(origin,endpoint)
    if not hit.is_empty() and hit.get("collider") == player:
        Game.take_damage(damage)
        return true
    return false

func _commit_attack() -> void:
    warning.visible = false
    aim_lane_079z.visible = false
    attack_sequence += 1
    if is_instance_valid(voice_083): voice_083.call("play_enemy", "attack")
    if role_attack == "rush":
        # Never commit a tracking rush through closed geometry.
        if not _has_clear_shot():
            recovery = 0.35
            return
        rush_time = 0.38 if actor_key == "sentry" else (0.46 if actor_key == "saltbound_porter" else 0.34)
        rush_hit_ready = true
        # Lock a direction on the telegraph. This makes sideways dodging fair;
        # the crawler does not home into the player after commitment.
        rush_direction = (player.global_position-global_position).normalized() if is_instance_valid(player) else Vector3.ZERO
        rush_direction.y = 0.0
        rush_direction = rush_direction.normalized()
    elif role_attack == "signal":
        _line_attack(role_damage)
        recovery = 0.48
    elif role_attack == "heavy":
        _line_attack(role_damage)
        recovery = 0.85
    elif role_attack == "pull":
        # A finite breath-pressure interruption, not a teleport or a stun lock.
        if is_instance_valid(player) and global_position.distance_to(player.global_position) < role_reach:
            # The pressure may only cost Breath when the same authoritative
            # collision ray actually connects. Cover must block both effects.
            if _line_attack(role_damage):
                Game.state["breath"] = maxf(0.0,float(Game.state.get("breath",0.0))-4.0)
                Game.state_changed.emit()
        recovery = 0.84
    else:
        _line_attack(role_damage)
        recovery = 0.32
    attack_timer = maxf(0.90,shot_interval * 0.78)

func _physics_process(delta: float) -> void:
    if hp <= 0 or not Game.has_attempt(): return
    if (actor_key == "millwright" and bool(Game.state.get("labour",{}).get("regulator_isolated",false))) or (actor_key == "cantor" and bool(Game.state.get("faith",{}).get("governor_isolated",false))):
        hostile = false
        velocity = Vector3.ZERO
        warning.visible = false
        aim_lane_079z.visible = false
        sprite.modulate = Color("#78807b")
        return
    if not is_instance_valid(player) or not player.active: return
    if not is_on_floor(): velocity.y -= 17.0 * delta
    else: velocity.y = -0.2
    flash_time = maxf(0.0,flash_time-delta)
    alert_time_079x = maxf(0.0,alert_time_079x-delta)
    pain_guard_095 = maxf(0.0, pain_guard_095 - delta)
    # Chip damage spread thinly over time does not add up to a flinch.
    pain_damage_095 = maxf(0.0, pain_damage_095 - pain_threshold_095() * 0.5 * delta)
    sprite.modulate = Color("#fff0ab") if flash_time > 0.0 else Color.WHITE
    if not hostile:
        velocity.x = 0.0
        velocity.z = 0.0
        # 09.2: sight, sound and witnessed violence decide when an enemy turns
        # hostile (sense_092.gd); the old "inside N metres" wake is gone.
        if is_instance_valid(sense_092):
            sense_092.tick(delta)
        if not hostile:
            animation_state = "walk" if Vector2(velocity.x, velocity.z).length() > 0.2 else "idle"
        move_and_slide()
        return
    if is_instance_valid(sense_092):
        sense_092.hostile_tick(delta)
    # Hostile actors face their target so the eight-view sprite reads true.
    var face_to: Vector3 = player.global_position - global_position
    if Vector2(face_to.x, face_to.z).length() > 0.3:
        rotation.y = lerp_angle(rotation.y, atan2(-face_to.x, -face_to.z), clampf(delta * 6.0, 0.0, 1.0))
    var toward: Vector3 = player.global_position-global_position
    toward.y = 0.0
    var distance: float = toward.length()
    # An enemy remembers an actually seen player briefly, rather than firing
    # and strafing through a wall indefinitely. Doors provide fair recovery.
    var sees_player: bool = _has_clear_shot() if distance < 24.0 else false
    if sees_player:
        last_seen_position = player.global_position
        time_since_sighted = 0.0
    else:
        time_since_sighted += delta
    # 09.3: a patrol that has lost its target searches, then stays on high
    # alert (sense_092.gd). Keepers hold their post and stay in combat.
    if not sees_player and time_since_sighted >= Perception093.LOSE_TRACK_SECONDS and windup <= 0.0 and rush_time <= 0.0 and is_instance_valid(sense_092) and sense_092.temperament == "patrol":
        warning.visible = false
        aim_lane_079z.visible = false
        sense_092.lose_track(last_seen_position)
        velocity.x = 0.0
        velocity.z = 0.0
        move_and_slide()
        return
    frame_timer += delta
    var hold: bool = windup > 0.0 or recovery > 0.0 or stagger_time > 0.0
    if stagger_time > 0.0:
        stagger_time = maxf(0.0,stagger_time-delta)
        warning.visible = false
        aim_lane_079z.visible = false
        windup = 0.0
    elif windup > 0.0:
        windup -= delta
        warning_material.albedo_color = Color("#ee7043") if int(frame_timer * 12.0) % 2 == 0 else Color("#ffe5a2")
        _update_aim_lane_079z()
        if windup <= 0.0: _commit_attack()
    elif recovery > 0.0:
        recovery = maxf(0.0,recovery-delta)
    if rush_time > 0.0:
        rush_time = maxf(0.0,rush_time-delta)
        if rush_hit_ready and distance < role_reach and _has_clear_shot():
            Game.take_damage(role_damage)
            rush_hit_ready = false
        if rush_time <= 0.0: recovery = 0.45
    var move_speed: float = role_speed
    if rush_time > 0.0: move_speed = 8.2 if actor_key == "sentry" else maxf(6.0,role_speed*2.25)
    var approach: bool = rush_time > 0.0 or (not hold and role_move != "turret" and distance > (3.4 if role_move in ["boss","shield","siege"] else 2.6) and distance < 19.0)
    var travel: Vector3 = toward.normalized() * move_speed if approach and distance > 0.01 else Vector3.ZERO
    obstacle_dodge_time_084 = maxf(0.0, obstacle_dodge_time_084-delta)
    obstacle_dodge_cooldown_084 = maxf(0.0, obstacle_dodge_cooldown_084-delta)
    if rush_time > 0.0:
        travel = rush_direction * move_speed
    elif not sees_player and time_since_sighted < positional_memory and role_move != "turret" and not hold:
        var search: Vector3 = last_seen_position - global_position
        search.y = 0.0
        travel = search.normalized() * move_speed if search.length() > 1.0 else Vector3.ZERO
    elif not sees_player and time_since_sighted >= positional_memory:
        travel = Vector3.ZERO
    elif not hold and role_move in ["boss","skirmish","flanker"] and distance < 10.0 and distance > 3.3:
        # Distinct lateral repositioning. Millwright slowly presses a lane;
        # Cantor changes acoustic sightlines. Seed and attack count decide side.
        var tangent := Vector3(-toward.z,0.0,toward.x).normalized()
        var side: float = 1.0 if (attack_sequence + int(Game.state["world_plan"].get("seed",0))) % 2 == 0 else -1.0
        var step_speed: float = 0.60 if actor_key == "millwright" else (1.55 if role_move == "skirmish" else 1.25)
        travel = tangent * side * step_speed
    # A short lateral slide around solid furniture. The floor collision normal
    # is ignored; only near-vertical scenery can initiate obstacle recovery.
    # Rush attacks never steer after the committed telegraph direction.
    if obstacle_dodge_time_084 > 0.0 and rush_time <= 0.0 and not hold and sees_player:
        travel = obstacle_dodge_direction_084 * move_speed * 0.88
    velocity.x = travel.x
    velocity.z = travel.z
    move_and_slide()
    if rush_time <= 0.0 and not hold and sees_player and role_move != "turret" and travel.length_squared() > 0.20 and obstacle_dodge_time_084 <= 0.0 and obstacle_dodge_cooldown_084 <= 0.0:
        for collision_index in range(get_slide_collision_count()):
            var obstruction: KinematicCollision3D = get_slide_collision(collision_index)
            var normal: Vector3 = obstruction.get_normal()
            if absf(normal.y) > 0.30:
                continue
            var sideways: Vector3 = Vector3(-normal.z,0.0,normal.x).normalized()
            if sideways.length_squared() <= 0.1:
                continue
            var toward_flat: Vector3 = toward.normalized()
            var option_a: Vector3 = sideways
            var option_b: Vector3 = -sideways
            # Prefer progress toward the target, but alternate when symmetric
            # so agents do not permanently grind against the same wall corner.
            var preference: float = option_a.dot(toward_flat) - option_b.dot(toward_flat)
            if absf(preference) < 0.15:
                sideways *= obstacle_dodge_side_084
                obstacle_dodge_side_084 *= -1.0
            elif preference < 0.0:
                sideways *= -1.0
            obstacle_dodge_direction_084 = sideways
            obstacle_dodge_time_084 = 0.56
            obstacle_dodge_cooldown_084 = 0.80
            break
    if stagger_time > 0.0: animation_state = "hurt"
    elif alert_time_079x > 0.0: animation_state = "alert"
    elif rush_time > 0.0: animation_state = "rush"
    elif windup > 0.0: animation_state = "windup"
    elif recovery > 0.0: animation_state = "attack"
    elif travel.length_squared() > 0.09: animation_state = "walk"
    else: animation_state = "idle"
    if animated_textures.is_empty():
        sprite.texture = sprite_frames[int(frame_timer*5.0)%4] if approach else sprite_frames[0]
    if Game.has_attempt(): Game.state["actors"][actor_key]["position"] = [position.x,position.y,position.z]
    attack_timer -= delta
    if attack_timer <= 0.0 and windup <= 0.0 and recovery <= 0.0 and stagger_time <= 0.0 and rush_time <= 0.0 and distance < role_reach:
        if not sees_player:
            attack_timer = 0.35  # seek a real line of sight, no wall-hacking
        elif _ally_winding_up():
            attack_timer = 0.40  # alternate incoming pressure; not synchronized bursts
        else:
            attack_timer = maxf(0.90,shot_interval * 0.78)
            _begin_windup()

# ---- BUILD 06.8 FRAME-ATLAS ANIMATION ----
func _load_directional_animation() -> void:
    anim_092 = SpriteAnim092.load_set(actor_key)
    if anim_092 != null and anim_092.pixel_size > 0.0 and is_instance_valid(sprite):
        sprite.pixel_size = anim_092.pixel_size
    for face in DIRECTIONS:
        # Build 08.8 Runway turnaround atlases first, then the 07.x procedural ones.
        var atlas_path: String = "res://assets/sprites/enemies_088/%s_%d.png" % [actor_key,face]
        if not ResourceLoader.exists(atlas_path):
            atlas_path = "res://assets/sprites/enemies_077/%s_%d.png" % [actor_key,face] if actor_key in ["gardener","commandant"] else ("res://assets/sprites/enemies_076/core_actuator_%d.png" % face if actor_key == "core_actuator" else ("res://assets/sprites/enemies_075/collector_%d.png" % face if actor_key == "collector" else "res://assets/sprites/enemies_074/%s_%d.png" % [actor_key,face]))
        # 09.1: the 06.8/07.1/07.3 generations were removed; every actor has an
        # 07.4-07.7 atlas (see art/BUILD_091_REMOVED_SUPERSEDED.json).
        if not ResourceLoader.exists(atlas_path): continue
        var atlas: Texture2D = load(atlas_path)
        var frames: Array[Texture2D] = []
        for idx in range(12):
            var sub := AtlasTexture.new()
            sub.atlas = atlas
            sub.region = Rect2((idx % 4) * ATLAS_W,int(idx / 4) * ATLAS_H,ATLAS_W,ATLAS_H)
            frames.append(sub)
        animated_textures[face] = frames

## 09.2 art path. Returns false to let the legacy atlas handle this frame.
func _play_anim_092(delta: float) -> bool:
    var wanted: String = "death" if hp <= 0 else animation_state
    if wanted == "rush" and not anim_092.has_state("rush"): wanted = "walk"
    if not anim_092.has_state(wanted): return false
    animation_timer += delta
    var facing: int = 1
    var view_camera: Camera3D = get_viewport().get_camera_3d()
    if sprite_rotation_mode != 0 and view_camera != null:
        facing = Rotation8.view_from_world(view_camera.global_position, global_transform)
    var speed: float = 1.7 if animation_state == "rush" and wanted == "walk" else 1.0
    var tex: Texture2D = anim_092.frame(wanted, facing, animation_timer * speed)
    if tex != null: sprite.texture = tex
    if hp <= 0:
        death_time -= delta
        if death_time <= 0.0: _finish_death_080()
    return true

func _finish_death_080() -> void:
    # Final pose remains in the same district and evaporates on zone unload.
    # Gameplay state was already committed by the defeated signal.
    if corpse_spawned_080: return
    corpse_spawned_080 = true
    if is_instance_valid(sprite) and is_instance_valid(get_parent()) and sprite.texture != null:
        var remains := CombatCorpse080.new()
        get_parent().add_child(remains)
        remains.global_position = sprite.global_position
        remains.configure(sprite.texture, sprite.pixel_size)
    queue_free()

func _process(delta: float) -> void:
    if animation_state != displayed_animation_state_079y:
        animation_timer = 0.0
        displayed_animation_state_079y = animation_state
    if anim_092 != null and _play_anim_092(delta):
        return
    if animated_textures.is_empty():
        if hp <= 0:
            death_time -= delta
            if death_time <= 0.0: _finish_death_080()
        return
    animation_timer += delta
    var selected: int = 1
    var view_camera: Camera3D = get_viewport().get_camera_3d()
    if sprite_rotation_mode != 0 and view_camera != null:
        selected = Rotation8.view_from_world(view_camera.global_position,global_transform)
    if not animated_textures.has(selected): selected = 1
    if not animated_textures.has(selected): return
    var index: int = 0
    if hp <= 0:
        death_time -= delta
        index = 9 + mini(2,maxi(0,int((0.84-death_time)/0.28)))
        if death_time <= 0.0:
            sprite.texture = animated_textures[selected][11]
            _finish_death_080()
    elif animation_state in ["walk","rush"]:
        index = int(animation_timer*(9.5 if animation_state == "rush" else 5.5)) % 4
    elif animation_state == "alert": index = 4 + (int(animation_timer * 11.0) % 2)
    elif animation_state == "windup": index = 4 + (int(animation_timer * 11.0) % 2)
    elif animation_state == "attack": index = 6 + (int(animation_timer * 12.0) % 2)
    elif animation_state == "hurt": index = 8
    sprite.texture = animated_textures[selected][index]
