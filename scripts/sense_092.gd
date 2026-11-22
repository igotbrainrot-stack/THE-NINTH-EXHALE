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
##
## 09.3 (Phase 1b): patrols that lose a hostile target SEARCH the last known
## position, then stay on HIGH ALERT (wider, quicker sight) instead of
## forgetting. Every change speaks a deterministic bark naming its cause.
## Movement follows walk_grid_093 paths, so guards go round walls. Keepers
## accept reports from a fleeing witness (TOLD channel).

const P = preload("res://scripts/perception_092.gd")
const PathFollower = preload("res://scripts/path_follower_093.gd")

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
var high_alert: bool = false        # 09.3: stays on after a search, for this visit and saves
var search_clock: float = 0.0
var last_cause: String = "SIGHT"
var bark_label: Label3D
var bark_time: float = 0.0
var bark_text: String = ""          # last spoken line (tests and playbot read it)
var walker = PathFollower.new()

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
    bark_label = Label3D.new()
    bark_label.name = "Bark093"
    bark_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    bark_label.no_depth_test = true
    # Constant on-screen size: a bark must be readable at 15 m, not only up close.
    bark_label.fixed_size = true
    bark_label.pixel_size = 0.0012
    bark_label.font_size = 22
    bark_label.outline_size = 8
    bark_label.outline_modulate = Color("#171918")
    bark_label.modulate = Color("#efe2c0")
    bark_label.position = Vector3(0, 2.12, 0)
    bark_label.visible = false
    add_child(bark_label)
    if bool(enemy.get("hostile")):
        # Loaded already fighting: not a new sighting for the district record.
        state = "HOSTILE"
    if Game.has_attempt():
        var saved: Dictionary = Game.state.get("actors", {}).get(str(enemy.get("actor_key")), {})
        high_alert = bool(saved.get("high_alert_093", false))
        if high_alert and state != "HOSTILE":
            state = "HIGH_ALERT"

func facing() -> Vector3:
    return -owner_enemy.global_transform.basis.z

func eye() -> Vector3:
    return owner_enemy.global_position + Vector3(0, P.EYE_HEIGHT, 0)

## True when this NPC can currently see the player (cones + walls).
func sees_player() -> bool:
    var player: Node3D = owner_enemy.get("player")
    if not is_instance_valid(player): return false
    var view_range: float = _view_range()
    var target: Vector3 = player.global_position + Vector3(0, 1.2, 0)
    if not P.in_cones(eye(), facing(), target, view_range): return false
    return P.clear_line(owner_enemy.get_world_3d().direct_space_state, eye(), target, [owner_enemy.get_rid(), player.get_rid()])

func _view_range() -> float:
    if temperament == "civic": return P.CIVIC_RANGE
    return P.MAIN_RANGE * (P.HIGH_ALERT_RANGE_SCALE if high_alert else 1.0)

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
        var light: float = P.player_light(world_root, player.global_position + Vector3(0, 0.2, 0))
        var view_range: float = _view_range()
        var rate: float = P.sight_rate(distance, view_range, light, _player_motion())
        if state == "SEARCH": rate *= P.SEARCH_RISE_SCALE
        elif high_alert: rate *= P.HIGH_ALERT_RISE_SCALE
        if temperament == "civic":
            # A citizen at the counter is not a threat. Only a perceived
            # assault makes the office-holder study the person responsible.
            rate = rate * 1.5 if assault_alert > 0.0 else 0.0
        if rate > 0.0:
            last_cause = "SIGHT"
            awareness += rate * delta
            last_known = player.global_position
            has_lead = true
            since_stimulus = 0.0
    bark_time = maxf(0.0, bark_time - delta)
    if state == "SEARCH":
        # Searching holds attention just below INVESTIGATE: a glimpse is enough.
        search_clock += delta
        awareness = maxf(awareness, P.INVESTIGATE - 0.01)
        if awareness >= P.HOSTILE:
            _become_hostile(seen)
            return
        if search_clock >= P.SEARCH_SECONDS:
            _end_search()
        else:
            _behave(delta)
            _refresh_marks()
            return
    if since_stimulus > P.DECAY_DELAY:
        awareness = maxf(0.0, awareness - P.DECAY_PER_SECOND * delta)
        if awareness < P.SUSPICIOUS: has_lead = false
    if temperament == "civic" and assault_alert <= 0.0:
        awareness = minf(awareness, P.INVESTIGATE - 0.01)
    if awareness >= P.HOSTILE:
        _become_hostile(seen)
        return
    _set_state(_calm_state())
    _behave(delta)
    _refresh_marks()

## The state for the current awareness when not hostile or searching.
func _calm_state() -> String:
    var st: String = P.state_name(awareness, false)
    if st == "UNAWARE" and high_alert: return "HIGH_ALERT"
    return st

func _behave(delta: float) -> void:
    var enemy: CharacterBody3D = owner_enemy
    enemy.velocity.x = 0.0
    enemy.velocity.z = 0.0
    if state == "SEARCH":
        # Walk to where the target was last seen, then sweep a wide arc there.
        if not walker.arrived(enemy.global_position) and not walker.failed:
            _walk_toward(last_known, 0.7, delta)
        else:
            scan_clock += delta
            enemy.rotation.y = lerp_angle(enemy.rotation.y, base_yaw + sin(scan_clock * 1.1) * deg_to_rad(75.0), clampf(delta * 3.0, 0.0, 1.0))
        return
    if state in ["UNAWARE", "HIGH_ALERT"]:
        # A slow, deterministic look-around so the sprite shows where it looks.
        # High alert sweeps faster and wider.
        scan_clock += delta
        var sweep: float = 70.0 if high_alert else 42.0
        enemy.rotation.y = lerp_angle(enemy.rotation.y, base_yaw + sin(scan_clock * (0.85 if high_alert else 0.55)) * deg_to_rad(sweep), clampf(delta * 2.0, 0.0, 1.0))
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
    var flat: Vector3 = point - enemy.global_position
    flat.y = 0.0
    if flat.length() < 0.8:
        return
    # 09.3: follow a grid path round walls (walk_grid_093) instead of a
    # straight line; give up the lead only when no route exists at all.
    var world: Node3D = enemy.get_parent() as Node3D
    walker.set_goal(world, enemy.global_position, point)
    if walker.failed:
        if point != home:
            has_lead = false
            awareness = minf(awareness, P.INVESTIGATE - 0.05)
        return
    var dir: Vector3 = walker.direction(world, enemy.global_position, delta)
    if dir == Vector3.ZERO:
        return
    var speed: float = float(enemy.get("role_speed")) * speed_scale
    enemy.velocity.x = dir.x * speed
    enemy.velocity.z = dir.z * speed
    _turn_toward(enemy.global_position + dir, delta)

## Noise heard. Returns true if this NPC registered it.
func hear_092(at: Vector3, radius: float, kind: String, violent: bool) -> bool:
    if not is_instance_valid(owner_enemy) or int(owner_enemy.get("hp")) <= 0: return false
    if bool(owner_enemy.get("hostile")): return false
    var space: PhysicsDirectSpaceState3D = owner_enemy.get_world_3d().direct_space_state
    var player: Node3D = owner_enemy.get("player")
    var exclude: Array = [owner_enemy.get_rid()]
    if is_instance_valid(player): exclude.append(player.get_rid())
    var travelled: float = P.heard_distance(space, at, owner_enemy.global_position, exclude, owner_enemy.get_parent() as Node3D, radius)
    if travelled > radius: return false
    last_known = at
    has_lead = true
    since_stimulus = 0.0
    last_cause = "CRY" if kind == "cry_for_help" else ("VIOLENT" if violent else "SOUND")
    if temperament == "civic":
        # Office-holders turn and watch; they do not leave their post.
        awareness = maxf(awareness, P.SUSPICIOUS + 0.05 if not violent else P.INVESTIGATE - 0.02)
    else:
        awareness = maxf(awareness, P.INVESTIGATE + 0.02 if violent else P.SUSPICIOUS + 0.08)
    if state != "SEARCH":
        _set_state(_calm_state())
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
    elif P.heard_distance(space, at, owner_enemy.global_position, exclude, owner_enemy.get_parent() as Node3D, P.NOISE_CRY) <= P.NOISE_CRY:
        channel = "SOUND"
    if channel == "": return ""
    assault_alert = 9.0
    assault_victim = victim
    assault_channel = channel
    last_known = attacker_pos
    has_lead = true
    since_stimulus = 0.0
    awareness = maxf(awareness, P.INVESTIGATE + (0.3 if channel == "SIGHT" else 0.02))
    last_cause = "CRY" if channel == "SOUND" else "SIGHT"
    _set_state(_calm_state())
    _refresh_marks()
    return channel

## 09.3: a fleeing witness reached this keeper and told what happened (TOLD).
## The keeper now watches for the attacker; seeing them makes it hostile, and
## that is when the witnessed record is written, as for SIGHT and SOUND.
func receive_report_093(victim: String, attacker_pos: Vector3) -> bool:
    if temperament != "civic" or not is_instance_valid(owner_enemy) or int(owner_enemy.get("hp")) <= 0: return false
    if bool(owner_enemy.get("hostile")): return false
    assault_alert = 20.0
    assault_victim = victim
    assault_channel = "TOLD"
    last_known = attacker_pos
    has_lead = true
    since_stimulus = 0.0
    last_cause = "TOLD"
    awareness = maxf(awareness, P.INVESTIGATE + 0.05)
    _set_state(_calm_state())
    _refresh_marks()
    return true

## 09.3: called by enemy.gd when a hostile patrol has not seen its target for
## LOSE_TRACK_SECONDS. Drops out of combat into SEARCH at the last known spot.
func lose_track(last_seen: Vector3) -> void:
    if temperament != "patrol" or not is_instance_valid(owner_enemy): return
    owner_enemy.set("hostile", false)
    last_known = last_seen
    has_lead = true
    search_clock = 0.0
    scan_clock = 0.0
    awareness = P.INVESTIGATE - 0.01
    walker = PathFollower.new()
    var key: String = str(owner_enemy.get("actor_key"))
    if Game.has_attempt() and Game.state.get("actors", {}).has(key):
        Game.state["actors"][key]["hostile"] = false
        Game.state["actors"][key]["high_alert_093"] = true
    last_cause = "LOST"
    _set_state("SEARCH")
    _refresh_marks()

func _end_search() -> void:
    high_alert = true
    awareness = 0.0
    has_lead = false
    walker = PathFollower.new()
    last_cause = "END"
    _set_state("HIGH_ALERT")

func _become_hostile(seen: bool) -> void:
    hostile_flash = 1.1
    last_cause = "WITNESS" if temperament == "civic" and assault_victim != "" else "SIGHT"
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
        var previous: String = state
        state = next
        if next == "HOSTILE":
            preload("res://scripts/district_record_095.gd").bump("spotted")
        var line: String = P.bark_for(next, last_cause)
        if next in ["UNAWARE"] and previous in ["SUSPICIOUS", "INVESTIGATE"]:
            line = P.bark_for("UNAWARE", "CALM")
        elif next == "INVESTIGATE" and line == "":
            line = P.bark_for("INVESTIGATE", "SOUND")
        elif next == "SUSPICIOUS" and line == "":
            line = P.bark_for("SUSPICIOUS", "SOUND")
        if line != "":
            _say(line)
        state_changed.emit(state)

func _say(line: String) -> void:
    bark_text = line
    bark_time = 2.4
    if is_instance_valid(bark_label):
        bark_label.text = line
        bark_label.visible = int(owner_enemy.get("hp")) > 0

func _refresh_marks() -> void:
    if not is_instance_valid(indicator): return
    var alive: bool = int(owner_enemy.get("hp")) > 0
    if hostile_flash > 0.0 and alive:
        indicator.text = "!"
        indicator.modulate = Color("#e0573f")
        indicator.visible = true
    elif alive and state in ["SUSPICIOUS", "INVESTIGATE", "SEARCH"]:
        indicator.text = "?" if state == "SUSPICIOUS" else "?!"
        indicator.modulate = Color("#e0b46d") if state == "SUSPICIOUS" else Color("#f08a4b")
        indicator.visible = true
    else:
        indicator.visible = false
    if is_instance_valid(bark_label):
        bark_label.visible = alive and bark_time > 0.0
    debug_label.visible = P.debug and alive
    if debug_label.visible:
        debug_label.text = "%s %.2f%s" % [state, awareness, " A%.0f" % assault_alert if assault_alert > 0.0 else ""]

## Hostile enemies still show the "!" briefly and keep the overlay current.
func hostile_tick(delta: float) -> void:
    hostile_flash = maxf(0.0, hostile_flash - delta)
    bark_time = maxf(0.0, bark_time - delta)
    _set_state("HOSTILE")
    _refresh_marks()
