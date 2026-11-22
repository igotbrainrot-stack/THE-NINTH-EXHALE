extends Node
## Build 09.0 scripted play session (a QA tool, not part of the game).
## Drives the real game through input: yaw/pitch like a mouse, WASD through
## Input.action_press, E/fire/reload/number keys through parsed InputEvents. It
## walks with a physics-sampled A* grid, follows the game's own advisory route,
## fights only hostiles in line of sight, reads the hearing phase, and picks the
## first docket option that moves the story on. It logs every notice, prompt,
## stamp and docket and saves a frame every 4 s plus each new docket.
## Run: tools/playbot_090/run_playbot.sh <out_dir> [seconds]
## A full critical path (title to ending) took about 6 minutes of bot time.
var cap_dir: String = OS.get_environment("CAP_DIR") if OS.get_environment("CAP_DIR") != "" else "user://playbot"
var t0: int
var game: Node
var shot_clock: float = 0.0
var shots: int = 0
var last_banner: String = ""
var last_prompt: String = ""
var last_modal: String = ""
var modal_seen: Dictionary = {}
var stuck_clock: float = 0.0
var last_pos: Vector3
var strafe: String = ""
var strafe_time: float = 0.0
var fps_samples: Array[float] = []
var max_time: float = float(OS.get_environment("BOT_SECONDS")) if OS.get_environment("BOT_SECONDS") != "" else 150.0
var acted_clock: float = 0.0
var target_label: String = ""
var target_since: float = 0.0
var hit_count: int = 0
## 09.2 (immersive-sim Phase 0): BOT_POLICY=combat (default, shoots any visible
## enemy) or pacifist (fires only at enemies already HOSTILE). The bot logs
## every awareness change and checks the witness invariants at the end.
var policy: String = OS.get_environment("BOT_POLICY") if OS.get_environment("BOT_POLICY") != "" else "combat"
var watched_senses: Dictionary = {}
var ending_seen: String = ""
var sense_transitions: int = 0
var hostile_transitions: int = 0
var astar: AStarGrid2D
var grid_zone: String = ""
var path: PackedVector2Array = PackedVector2Array()
var path_goal: Vector3 = Vector3.INF
var grid_img: Image
var dumped: int = 0
var heal_clock: float = 0.0
const CELL := 0.5
const HALF := 70

func _cell(p: Vector3) -> Vector2i:
    return Vector2i(clampi(roundi(p.x / CELL), -HALF, HALF - 1), clampi(roundi(p.z / CELL), -HALF, HALF - 1))

func _build_grid() -> void:
    astar = AStarGrid2D.new()
    astar.region = Rect2i(-HALF, -HALF, HALF * 2, HALF * 2)
    astar.cell_size = Vector2(CELL, CELL)
    astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
    astar.update()
    var space: PhysicsDirectSpaceState3D = game.player.get_world_3d().direct_space_state
    var shape := SphereShape3D.new(); shape.radius = 0.5
    var q := PhysicsShapeQueryParameters3D.new()
    q.shape = shape; q.collision_mask = 1; q.exclude = [game.player.get_rid()]
    var floor_q := PhysicsRayQueryParameters3D.new(); floor_q.collision_mask = 1
    var solid := 0
    for x in range(-HALF, HALF):
        for z in range(-HALF, HALF):
            var w := Vector3(x * CELL, 0.95, z * CELL)
            q.transform = Transform3D(Basis(), w)
            var blocked: bool = not space.intersect_shape(q, 1).is_empty()
            if not blocked:
                # Knee-height sweep catches low consoles, crates and kerbs.
                q.transform = Transform3D(Basis(), Vector3(w.x, 0.55, w.z))
                blocked = not space.intersect_shape(q, 1).is_empty()
            if not blocked:
                floor_q.from = w; floor_q.to = w - Vector3(0, 3, 0)
                blocked = space.intersect_ray(floor_q).is_empty()
            if blocked:
                astar.set_point_solid(Vector2i(x, z)); solid += 1
    grid_zone = str(Game.state.get("zone", ""))
    var img := Image.create(HALF * 2, HALF * 2, false, Image.FORMAT_RGB8)
    for x in range(-HALF, HALF):
        for z in range(-HALF, HALF):
            img.set_pixel(x + HALF, z + HALF, Color(0.15, 0.1, 0.1) if astar.is_point_solid(Vector2i(x, z)) else Color(0.8, 0.8, 0.75))
    grid_img = img
    log_line("GRID built for %s: %d/%d cells blocked" % [grid_zone, solid, (HALF * 2) * (HALF * 2)])

func _plan(goal: Vector3) -> void:
    var from: Vector2i = _cell(game.player.global_position)
    var to: Vector2i = _cell(goal)
    if astar.is_point_solid(from): astar.set_point_solid(from, false)
    if astar.is_point_solid(to):
        # The goal is a machine or a person: aim for the nearest open cell.
        var best: Vector2i = to; var best_d: float = 1e9
        for dx in range(-6, 7):
            for dz in range(-6, 7):
                var c: Vector2i = to + Vector2i(dx, dz)
                if astar.region.has_point(c) and not astar.is_point_solid(c):
                    var d: float = float(dx * dx + dz * dz)
                    if d < best_d: best_d = d; best = c
        to = best
    path = astar.get_point_path(from, to)
    path_goal = goal
    if path.is_empty():
        if not modal_seen.has("nopath:" + target_label):
            modal_seen["nopath:" + target_label] = 1
            log_line("NO PATH to %s (from %s)" % [target_label, game.player.global_position])
        # Head straight for it; the stuck handler will back off if needed.
        path = PackedVector2Array([Vector2(goal.x, goal.z)])

func log_line(s: String) -> void:
    print("[%6.1f] %s" % [(Time.get_ticks_msec() - t0) / 1000.0, s])

func _ready() -> void:
    t0 = Time.get_ticks_msec()
    DirAccess.make_dir_recursive_absolute(cap_dir)
    call_deferred("_run")

func snap(name: String) -> void:
    await RenderingServer.frame_post_draw
    shots += 1
    get_viewport().get_texture().get_image().save_png("%s/%03d_%s.png" % [cap_dir, shots, name])

func key(code: Key) -> void:
    var ev := InputEventKey.new(); ev.keycode = code; ev.physical_keycode = code; ev.pressed = true
    Input.parse_input_event(ev)
    await get_tree().process_frame
    var up := InputEventKey.new(); up.keycode = code; up.physical_keycode = code; up.pressed = false
    Input.parse_input_event(up)
    await get_tree().process_frame

func action(name: String) -> void:
    var ev := InputEventAction.new(); ev.action = name; ev.pressed = true
    Input.parse_input_event(ev)
    await get_tree().process_frame
    var up := InputEventAction.new(); up.action = name; up.pressed = false
    Input.parse_input_event(up)
    await get_tree().process_frame

func _run() -> void:
    var start: Node = load("res://scenes/main.tscn").instantiate()
    add_child(start)
    await get_tree().create_timer(1.0).timeout
    await snap("title")
    start.queue_free()
    game = load("res://scenes/hearth_nine.tscn").instantiate()
    add_child(game)
    await get_tree().create_timer(1.5).timeout
    await snap("new_ninth_docket")
    _log_modal()
    await key(KEY_1)
    await get_tree().create_timer(1.0).timeout
    _log_modal()
    await snap("after_start")
    game.player.hit_confirmed_090.connect(func(k): hit_count += 1; if k: log_line("KILL CONFIRMED"))
    var elapsed: float = 0.0
    while elapsed < max_time:
        await get_tree().physics_frame
        var dt: float = get_physics_process_delta_time()
        elapsed += dt
        fps_samples.append(Engine.get_frames_per_second())
        _watch_text()
        _watch_senses()
        shot_clock += dt
        if shot_clock > 4.0:
            shot_clock = 0.0
            await snap("play_%s" % str(Game.state.get("zone","")))
        if game.hud.modal_open:
            _release_moves()
            await _handle_modal()
            if ending_seen != "": break
            continue
        if not Game.has_attempt(): break
        await _drive(dt)
    _release_moves()
    var avg: float = 0.0
    for f in fps_samples: avg += f
    log_line("SUMMARY ending=%s policy=%s fps_avg=%.1f min=%.1f writs=%s zone=%s level=%s hp=%s hits=%d sense_changes=%d hostile=%d %s" % [ending_seen if ending_seen != "" else "none", policy, avg / maxf(1, fps_samples.size()), fps_samples.min() if not fps_samples.is_empty() else 0.0, str(Game.state.get("writs",[])), str(Game.state.get("zone","")), str(Game.state.get("level",0)), str(Game.state.get("health",0)), hit_count, sense_transitions, hostile_transitions, _witness_invariants()])
    await snap("end")
    get_tree().quit()

func _watch_senses() -> void:
    for sense in get_tree().get_nodes_in_group("perceivers_092"):
        if watched_senses.has(sense.get_instance_id()): continue
        watched_senses[sense.get_instance_id()] = true
        var who: String = str(sense.owner_enemy.get("actor_key")) if is_instance_valid(sense.owner_enemy) else "?"
        sense.state_changed.connect(func(st: String):
            sense_transitions += 1
            if st == "HOSTILE": hostile_transitions += 1
            log_line("SENSE %s -> %s" % [who, st]))

## Canon invariants as log checks (plan section "the playbot needs three changes").
func _witness_invariants() -> String:
    var records: int = 0
    var without_witness: int = 0
    for e in Game.state.get("events", []):
        var eid: String = str(e.get("id", ""))
        if eid.begins_with("witness.092.") or eid.begins_with("witness.093."):
            records += 1
            var details: Dictionary = e.get("details", {})
            if str(details.get("witness_id", "")) == "": without_witness += 1
            # 09.3 reports must have been written by a witness alive at the time.
            elif eid.contains(".reported_to_") and not bool(details.get("witness_alive_at_record", false)): without_witness += 1
    return "witness_records=%d records_without_living_witness=%d" % [records, without_witness]

func _watch_text() -> void:
    var hud = game.hud
    var newest: String = ""
    if is_instance_valid(hud.fx) and not hud.fx.slips.is_empty() and is_instance_valid(hud.fx.slips[0]):
        newest = (hud.fx.slips[0].get_child(0) as Label).text
    elif hud.banner_panel.visible:
        newest = hud.banner.text
    if newest != "" and newest != last_banner:
        last_banner = newest
        log_line("NOTICE: " + newest)
    if hud.current_prompt != last_prompt:
        last_prompt = hud.current_prompt
        if last_prompt != "": log_line("PROMPT: " + last_prompt)
    if is_instance_valid(hud.fx) and is_instance_valid(hud.fx.stamp_node):
        var head: String = (hud.fx.stamp_node.get_child(1) as Label).text
        if not modal_seen.has("stamp:" + head + str(Game.state.get("writs",[]).size())):
            modal_seen["stamp:" + head + str(Game.state.get("writs",[]).size())] = 1
            log_line("STAMP: " + head)
            await snap("stamp")

func _log_modal() -> void:
    var hud = game.hud
    if not hud.modal_open or not is_instance_valid(hud.modal): return
    var title: String = ""
    for c in hud.modal.get_children():
        if c is Label and c.position == Vector2(39, 10): title = c.text
    var opts: Array[String] = []
    for b in hud.modal_buttons:
        opts.append(("x " if b.disabled else "") + b.text)
    var sig: String = title + "|" + "|".join(opts)
    if sig != last_modal:
        last_modal = sig
        log_line("DOCKET: %s  -> %s" % [title, opts])

func _handle_modal() -> void:
    var hud = game.hud
    _log_modal()
    var title_sig: String = last_modal.get_slice("|", 0)
    # 09.2: the run is complete at the first ending card. Stop there instead
    # of starting a counterfactual campaign with stale docket counters.
    if title_sig.begins_with("VESPER /") and "NEW COUNTERFACTUAL CAMPAIGN" in last_modal:
        ending_seen = title_sig
        log_line("ENDING REACHED: %s" % title_sig)
        await snap("ending")
        return
    modal_seen[title_sig] = int(modal_seen.get(title_sig, 0)) + 1
    if int(modal_seen[title_sig]) == 1:
        await snap("docket")
    await get_tree().create_timer(0.4).timeout
    # Policy: first enabled option that moves things forward; avoid close/save/
    # reprint unless the same docket keeps coming back.
    var pick: int = -1
    var fallback: int = -1
    for i in range(hud.modal_buttons.size()):
        var b: Button = hud.modal_buttons[i]
        if b.disabled: continue
        var a: String = hud.modal_actions[i]
        var text: String = b.text.to_upper()
        var passive: bool = a in ["close", "save_and_close", "menu"] or text.begins_with("CLOSE") or text.begins_with("RETURN TO") or text.begins_with("COMMIT SAVE")
        if passive:
            if fallback < 0: fallback = i
            continue
        if pick < 0: pick = i
    if int(modal_seen[title_sig]) > 3 and fallback >= 0: pick = fallback
    if title_sig.begins_with("PUBLIC HEARING"):
        # Read the phase the docket shows and answer it, as a player would.
        var phase: String = Game.hearing_phase()
        var last: String = str(Game.state["hearing"].get("last_command", ""))
        if phase == "exposed": pick = 0
        elif phase == "rising": pick = 2 if last == "Attune" else 1
        else: pick = 3
        log_line("HEARING phase=%s field=%s strain=%s" % [phase, str(Game.state["hearing"].get("integrity")), str(Game.state["hearing"].get("strain_margin"))])
    if pick < 0: pick = fallback
    if pick < 0:
        await key(KEY_ESCAPE); return
    log_line("CHOOSE %d: %s" % [pick + 1, hud.modal_buttons[pick].text])
    if pick < 9:
        await key(KEY_1 + pick)
    else:
        hud._button_pressed(hud.modal_actions[pick])
    await get_tree().create_timer(0.5).timeout

func _release_moves() -> void:
    for a in ["move_forward", "move_back", "move_left", "move_right", "sprint"]:
        Input.action_release(a)

func _face(goal: Vector3, dt: float, height: float = 1.1) -> float:
    var p: CharacterBody3D = game.player
    var to: Vector3 = goal - p.global_position
    to.y = 0
    if to.length() < 0.05: return 0.0
    var want: float = atan2(-to.x, -to.z)
    var diff: float = wrapf(want - p.rotation.y, -PI, PI)
    p.rotation.y += clampf(diff, -4.0 * dt, 4.0 * dt)   # mouse-like turn rate
    var cam_y: float = p.camera.global_position.y
    var want_pitch: float = atan2(goal.y + height - cam_y, to.length())
    p.pitch = lerpf(p.pitch, clampf(want_pitch, -0.9, 0.9), 0.15)
    p.camera.rotation.x = p.pitch
    return absf(diff)

func _nearest_hostile() -> Node3D:
    var best: Node3D = null
    var best_d: float = 18.0
    for h in get_tree().get_nodes_in_group("hostile"):
        if not (h is Node3D) or not h.visible: continue
        if "hp" in h and int(h.hp) <= 0: continue
        if policy == "pacifist" and "hostile" in h and not bool(h.hostile): continue
        var d: float = h.global_position.distance_to(game.player.global_position)
        # Only fight what can be seen, as a player would.
        var los := PhysicsRayQueryParameters3D.create(game.player.camera.global_position, h.global_position + Vector3(0, 0.9, 0))
        los.collision_mask = 1
        los.exclude = [game.player.get_rid(), h.get_rid()] if h is CollisionObject3D else [game.player.get_rid()]
        var blocker: Dictionary = game.player.get_world_3d().direct_space_state.intersect_ray(los)
        if not blocker.is_empty() and blocker.get("collider") != h: continue
        if d < best_d:
            best_d = d; best = h
    return best

func _drive(dt: float) -> void:
    var p: CharacterBody3D = game.player
    var foe: Node3D = _nearest_hostile()
    if foe != null:
        _release_moves()
        var off: float = _face(foe.global_position, dt, 0.8)
        acted_clock -= dt
        if off < 0.08 and acted_clock <= 0.0:
            acted_clock = 0.35
            var wid: String = Game.equipped_weapon()
            if Game.weapon_mag(wid) <= 0:
                if Game.weapon_reserve(wid) > 0:
                    log_line("RELOAD")
                    await action("reload")
                    acted_clock = 1.4
                else:
                    await action("intervene")
            else:
                await action("fire")
        var d: float = foe.global_position.distance_to(p.global_position)
        if d > 9.0: Input.action_press("move_forward")
        elif d < 4.0: Input.action_press("move_back")
        return
    var wid2: String = Game.equipped_weapon()
    if Game.weapon_mag(wid2) <= 1 and Game.weapon_reserve(wid2) > 0 and not game.player.reloading:
        await action("reload")
    heal_clock -= dt
    if float(Game.state.get("health", 100)) < Game.max_health() * 0.4 and heal_clock <= 0.0:
        heal_clock = 3.0
        log_line("HEAL (key 1)")
        await key(KEY_1)
    var target: Dictionary = game._nav_target()
    if target.is_empty(): return
    if str(target["label"]) != target_label:
        target_label = str(target["label"]); target_since = 0.0
        log_line("ROUTE -> %s" % target_label)
        # Doors and shutters open on progress: wait for them, then re-map.
        _release_moves()
        await get_tree().create_timer(2.0).timeout
        _build_grid(); _plan(target["pos"])
    target_since += dt
    var goal: Vector3 = target["pos"]
    var flat: Vector3 = goal - p.global_position; flat.y = 0
    var dist: float = flat.length()
    if grid_zone != str(Game.state.get("zone", "")) or astar == null:
        _build_grid(); path_goal = Vector3.INF
    if strafe_time > 0.0:
        strafe_time -= dt
        Input.action_release("move_forward")
        Input.action_press("move_back")
        Input.action_press(strafe)
        if strafe_time <= 0.0:
            Input.action_release(strafe); Input.action_release("move_back")
        return
    if dist > 2.2:
        if path_goal.distance_to(goal) > 0.5 or path.is_empty():
            _plan(goal)
        while path.size() > 1 and Vector2(p.global_position.x, p.global_position.z).distance_to(path[0]) < 0.45:
            path.remove_at(0)
        var wp: Vector3 = Vector3(path[0].x, 0, path[0].y) if not path.is_empty() else goal
        var off: float = _face(wp, dt)
        if off < 0.5: Input.action_press("move_forward")
        else: Input.action_release("move_forward")
        if dist > 8.0 and float(Game.state.get("breath", 0)) > 30.0 and off < 0.3: Input.action_press("sprint")
        else: Input.action_release("sprint")
        stuck_clock += dt
        if stuck_clock > 1.5:
            if p.global_position.distance_to(last_pos) < 0.5:
                log_line("STUCK near %s at %s; path %d pts" % [target_label, p.global_position, path.size()])
                if dumped < 0:
                    dumped += 1
                    var img: Image = grid_img.duplicate()
                    for q in astar.get_point_path(_cell(p.global_position), _cell(goal)):
                        img.set_pixel(int(q.x / CELL) + HALF, int(q.y / CELL) + HALF, Color(0.2, 0.4, 1))
                    var c := _cell(p.global_position); img.set_pixel(c.x + HALF, c.y + HALF, Color(1, 0, 0))
                    var g := _cell(goal); img.set_pixel(g.x + HALF, g.y + HALF, Color(0, 0.8, 0))
                    img.resize(HALF * 8, HALF * 8, Image.INTERPOLATE_NEAREST)
                    img.save_png(cap_dir + "/grid_stuck.png")
                    await snap("stuck_view")
                # Back off and sidestep the way a player would, then replan.
                strafe = "move_left" if randf() < 0.5 else "move_right"
                strafe_time = 0.6
                _plan(goal)
            last_pos = p.global_position
            stuck_clock = 0.0
        return
    _face(goal, dt)
    _release_moves()
    acted_clock -= dt
    if acted_clock > 0.0: return
    acted_clock = 1.2
    if game.hud.current_prompt != "":
        await action("interact")
    else:
        # Sweep the aim a little: the prompt needs the ray on the object.
        p.pitch = clampf(p.pitch + randf_range(-0.25, 0.1), -0.8, 0.6)
        p.rotation.y += randf_range(-0.3, 0.3)
        await action("interact")
    if target_since > 40.0:
        log_line("GAVE UP on %s after 40s" % target_label)
        target_since = 0.0
