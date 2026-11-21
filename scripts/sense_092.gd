extends Node3D
## Build 09.2 sense component, one per enemy (immersive-sim Phase 1).
##
## Replaces the old "wake inside N metres" test for enemies that are not yet
## hostile. Hostile combat (telegraphs, two-attacker cap, staggers) is unchanged:
## reaching HOSTILE simply calls the owner's existing anger().
##
## Two temperaments:
##   patrol  optional district enemies: notice the player by sight and sound,
##           turn, walk to investigate, and fight when certain.
##   civic   office-holders (Millwright, Cantor, Collector...): ignore a citizen
##           standing at their counter, react to violence they perceive. They
##           turn hostile only after perceiving an assault on a person and then
##           seeing the attacker; gunfire alone makes them watchful.
## Readable feedback: a "?" over the head while suspicious or investigating, a
## "!" on turning hostile, and the 8-view sprite turns to face what it noticed.

const P = preload("res://scripts/perception_092.gd")

signal state_changed(state: String)

var owner_enemy: Node               # enemy.gd
var temperament: String = "patrol"  # or "civic"
var awareness: float = 0.0
var state: String = "UNAWARE"
var last_known: Vector3 = Vector3.ZERO
var has_lead: bool = false
var since_stimulus: float = 99.0
var assault_alert: float = 0.0     # civic: seconds left to spot an attacker
var assault_victim: String = ""
var assault_channel: String = ""
var home: Vector3 = Vector3.ZERO
var base_yaw: float = 0.0
var scan_clock: float = 0.0
var indicator: Label3D
var debug_label: Label3D
var hostile_flash: float = 0.0
var stuck_clock: float = 0.0
var last_step_pos: Vector3 = Vector3.ZERO

func setup(enemy: Node, mode: String) -> void:
    owner_enemy = enemy
    temperament = mode
    name = "Sense092"
    add_to_group(P.GROUP_PERCEIVERS)
    home = enemy.global_position if enemy.is_inside_tree() else enemy.position
    # Face the room's centre by default (districts are built around the origin);
    # authored facings can override base_yaw later.
    var to_centre: Vector3 = -Vector3(home.x, 0.0, home.z)
    base_yaw = atan2(-to_centre.x, -to_centre.z) if to_centre.length() > 0.5 else 0.0
    enemy.rotation.y = base_yaw
    indicator = Label3D.new()
    indicator.name = "AwarenessMark"
    indicator.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    indicator.no_depth_test = true
    indicator.fixed_size = false
    indicator.pixel_size = 0.012
    indicator.font_size = 56
    indicator.outline_size = 10
    indicator.outline_modulate = Color("#171918")
    indicator.position = Vector3(0, 2.45, 0)
    indicator.visible = false
    add_child(indicator)
    debug_label = Label3D.new()
    debug_label.name = "SenseDebug"
    debug_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    debug_label.no_depth_test = true
    debug_label.pixel_size = 0.005
    debug_label.font_size = 28
    debug_label.outline_size = 6
    debug_label.position = Vector3(0, 2.9, 0)
    debug_label.visible = false
    add_child(debug_label)

func facing() -> Vector3:
    return -owner_enemy.global_transform.basis.z

func eye() -> Vector3:
    return owner_enemy.global_position + Vector3(0, P.EYE_HEIGHT, 0)

## True when this NPC can currently see the player (cones + walls).
func sees_player() -> bool:
    var player: Node3D = owner_enemy.get("player")
    if not is_instance_valid(player): return false
    var view_range: float = P.CIVIC_RANGE if temperament == "civic" else P.MAIN_RANGE
    var target: Vector3 = player.global_position + Vector3(0, 1.2, 0)
    if not P.in_cones(eye(), facing(), target, view_range): return false
    return P.clear_line(owner_enemy.get_world_3d().direct_space_state, eye(), target, [owner_enemy.get_rid(), player.get_rid()])

func _player_motion() -> float:
    var player: CharacterBody3D = owner_enemy.get("player")
    var speed: float = Vector2(player.velocity.x, player.velocity.z).length()
    if speed > 6.0: return P.MOTION_SPRINT
    if speed > 0.5: return P.MOTION_WALK
    return P.MOTION_STILL

## Called by enemy.gd every physics frame while not hostile.
func tick(delta: float) -> void:
    if not is_instance_valid(owner_enemy) or int(owner_enemy.get("hp")) <= 0: return
    var player: Node3D = owner_enemy.get("player")
    if not is_instance_valid(player): return
    since_stimulus += delta
    assault_alert = maxf(0.0, assault_alert - delta)
    hostile_flash = maxf(0.0, hostile_flash - delta)
    var seen: bool = sees_player()
    if seen:
        var distance: float = owner_enemy.global_position.distance_to(player.global_position)
        var world_root: Node = owner_enemy.get_parent()
        var light: float = P.light_at(world_root, player.global_position + Vector3(0, 0.2, 0))
        var view_range: float = P.CIVIC_RANGE if temperament == "civic" else P.MAIN_RANGE
        var rate: float = P.sight_rate(distance, view_range, light, _player_motion())
        if temperament == "civic":
            # A citizen at the counter is not a threat. Only a perceived
            # assault makes the office-holder study the person responsible.
            rate = rate * 1.5 if assault_alert > 0.0 else 0.0
        if rate > 0.0:
            awareness += rate * delta
            last_known = player.global_position
            has_lead = true
            since_stimulus = 0.0
    if since_stimulus > P.DECAY_DELAY:
        awareness = maxf(0.0, awareness - P.DECAY_PER_SECOND * delta)
        if awareness < P.SUSPICIOUS: has_lead = false
    if temperament == "civic" and assault_alert <= 0.0:
        awareness = minf(awareness, P.INVESTIGATE - 0.01)
    if awareness >= P.HOSTILE:
        _become_hostile(seen)
        return
    _set_state(P.state_name(awareness, false))
    _behave(delta)
    _refresh_marks()

func _behave(delta: float) -> void:
    var enemy: CharacterBody3D = owner_enemy
    enemy.velocity.x = 0.0
    enemy.velocity.z = 0.0
    if state == "UNAWARE":
        # A slow, deterministic look-around so the sprite shows where it looks.
        scan_clock += delta
        enemy.rotation.y = lerp_angle(enemy.rotation.y, base_yaw + sin(scan_clock * 0.55) * deg_to_rad(42.0), clampf(delta * 2.0, 0.0, 1.0))
        if temperament == "patrol" and enemy.global_position.distance_to(home) > 0.6:
            _walk_toward(home, 0.45, delta)
        return
    if has_lead:
        _turn_toward(last_known, delta)
    if state == "INVESTIGATE" and temperament == "patrol" and has_lead:
        _walk_toward(last_known, 0.55, delta)

func _turn_toward(point: Vector3, delta: float) -> void:
    var enemy: Node3D = owner_enemy
    var to: Vector3 = point - enemy.global_position
    if Vector2(to.x, to.z).length() < 0.2: return
    var yaw: float = atan2(-to.x, -to.z)
    enemy.rotation.y = lerp_angle(enemy.rotation.y, yaw, clampf(delta * 5.0, 0.0, 1.0))

func _walk_toward(point: Vector3, speed_scale: float, delta: float) -> void:
    var enemy: CharacterBody3D = owner_enemy
    var to: Vector3 = point - enemy.global_position
    to.y = 0.0
    if to.length() < 0.8:
        return
    var speed: float = float(enemy.get("role_speed")) * speed_scale
    enemy.velocity.x = to.normalized().x * speed
    enemy.velocity.z = to.normalized().z * speed
    _turn_toward(point, delta)
    # Give up on a lead that a wall keeps blocking; no navmesh yet (Phase 2).
    stuck_clock += delta
    if stuck_clock > 1.5:
        if enemy.global_position.distance_to(last_step_pos) < 0.3 and point != home:
            has_lead = false
            awareness = minf(awareness, P.INVESTIGATE - 0.05)
        last_step_pos = enemy.global_position
        stuck_clock = 0.0

## Noise heard. Returns true if this NPC registered it.
func hear_092(at: Vector3, radius: float, kind: String, violent: bool) -> bool:
    if not is_instance_valid(owner_enemy) or int(owner_enemy.get("hp")) <= 0: return false
    if bool(owner_enemy.get("hostile")): return false
    var space: PhysicsDirectSpaceState3D = owner_enemy.get_world_3d().direct_space_state
    var player: Node3D = owner_enemy.get("player")
    var exclude: Array = [owner_enemy.get_rid()]
    if is_instance_valid(player): exclude.append(player.get_rid())
    var travelled: float = P.heard_distance(space, at, owner_enemy.global_position, exclude)
    if travelled > radius: return false
    last_known = at
    has_lead = true
    since_stimulus = 0.0
    if temperament == "civic":
        # Office-holders turn and watch; they do not leave their post.
        awareness = maxf(awareness, P.SUSPICIOUS + 0.05 if not violent else P.INVESTIGATE - 0.02)
    else:
        awareness = maxf(awareness, P.INVESTIGATE + 0.02 if violent else P.SUSPICIOUS + 0.08)
    _set_state(P.state_name(awareness, false))
    _refresh_marks()
    return true

## A person was assaulted. Returns the channel ("SIGHT"/"SOUND") through which
## this NPC perceived it, or "" if it did not. Only civic perceivers act on it.
func witness_assault_092(victim: String, at: Vector3, attacker_pos: Vector3) -> String:
    if temperament != "civic" or not is_instance_valid(owner_enemy) or int(owner_enemy.get("hp")) <= 0: return ""
    if bool(owner_enemy.get("hostile")): return ""
    var channel: String = ""
    var space: PhysicsDirectSpaceState3D = owner_enemy.get_world_3d().direct_space_state
    var player: Node3D = owner_enemy.get("player")
    var exclude: Array = [owner_enemy.get_rid()]
    if is_instance_valid(player): exclude.append(player.get_rid())
    if sees_player() or (P.in_cones(eye(), facing(), at + Vector3(0, 1.0, 0), P.CIVIC_RANGE) and P.clear_line(space, eye(), at + Vector3(0, 1.0, 0), exclude)):
        channel = "SIGHT"
    elif P.heard_distance(space, at, owner_enemy.global_position, exclude) <= P.NOISE_CRY:
        channel = "SOUND"
    if channel == "": return ""
    assault_alert = 9.0
    assault_victim = victim
    assault_channel = channel
    last_known = attacker_pos
    has_lead = true
    since_stimulus = 0.0
    awareness = maxf(awareness, P.INVESTIGATE + (0.3 if channel == "SIGHT" else 0.02))
    _set_state(P.state_name(awareness, false))
    _refresh_marks()
    return channel

func _become_hostile(seen: bool) -> void:
    hostile_flash = 1.1
    _set_state("HOSTILE")
    if temperament == "civic" and assault_victim != "" and Game.has_attempt():
        # The office-holder is a living witness who saw the attacker: record it.
        var key: String = str(owner_enemy.get("actor_key"))
        Game.record_event("witness.092.%s.assault_on_%s" % [key, assault_victim.to_snake_case()], "witnessed_assault", {
            "witness_id": key, "victim": assault_victim, "channel": assault_channel,
            "confirmed_by": "SIGHT" if seen else assault_channel, "zone": str(Game.state.get("zone", ""))})
    owner_enemy.call("anger")
    _refresh_marks()

func _set_state(next: String) -> void:
    if next != state:
        state = next
        state_changed.emit(state)

func _refresh_marks() -> void:
    if not is_instance_valid(indicator): return
    var alive: bool = int(owner_enemy.get("hp")) > 0
    if hostile_flash > 0.0 and alive:
        indicator.text = "!"
        indicator.modulate = Color("#e0573f")
        indicator.visible = true
    elif alive and state in ["SUSPICIOUS", "INVESTIGATE"]:
        indicator.text = "?" if state == "SUSPICIOUS" else "?!"
        indicator.modulate = Color("#e0b46d") if state == "SUSPICIOUS" else Color("#f08a4b")
        indicator.visible = true
    else:
        indicator.visible = false
    debug_label.visible = P.debug and alive
    if debug_label.visible:
        debug_label.text = "%s %.2f%s" % [state, awareness, " A%.0f" % assault_alert if assault_alert > 0.0 else ""]

## Hostile enemies still show the "!" briefly and keep the overlay current.
func hostile_tick(delta: float) -> void:
    hostile_flash = maxf(0.0, hostile_flash - delta)
    _set_state("HOSTILE")
    _refresh_marks()
