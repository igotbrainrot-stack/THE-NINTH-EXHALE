extends Node
## Runtime regression checks for the Build 08.5 code-fix pass.
## Unlike the PASS-line scenes, this one exits with code 1 when any check fails,
## so CI and scripts can rely on the process exit status.
## Run with an isolated HOME: it writes a temporary save.

var failures: Array[String] = []
var passes: int = 0
var scene: Node

func _ready() -> void:
    call_deferred("_run")

func check(ok: bool, label: String) -> void:
    if ok:
        passes += 1
        print("CODEFIX_PASS: ", label)
    else:
        failures.append(label)
        print("CODEFIX_FAIL: ", label)

func frames(n: int) -> void:
    for i in range(n):
        await get_tree().process_frame

func _run() -> void:
    scene = load("res://scenes/hearth_nine.tscn").instantiate()
    add_child(scene)
    await frames(1)
    scene.begin_attempt("Witness")
    await frames(6)
    scene.hud.close_modal(true)
    await frames(2)
    await _check_hud_layout("start")
    # Exercise the HUD states that previously overflowed.
    # Longest real objective must show both lines (not one line with an ellipsis).
    # Hold the 0.15 s HUD refresh so a slow frame cannot swap the text back.
    scene.hud.refresh_time = 99.0
    scene.hud.objective_label.text = "Track Brin, verify payroll, then recover the Labour Writ."
    await frames(1)
    check(scene.hud.objective_label.get_visible_line_count() == 2, "two-line objective is fully visible (lines %d visible %d, size %s)" % [scene.hud.objective_label.get_line_count(), scene.hud.objective_label.get_visible_line_count(), scene.hud.objective_label.size])
    # Longest real route label (with a 3-digit distance) must fit untrimmed.
    scene.hud.set_navigation("→  FIVE FOUNDING SERVICE RAILS · 112m")
    var nav: Label = scene.hud.navigation
    var nav_width: float = nav.get_theme_font("font").get_string_size(nav.text, HORIZONTAL_ALIGNMENT_LEFT, -1, nav.get_theme_font_size("font_size")).x
    check(nav_width <= nav.size.x, "longest route label fits without trimming (%d <= %d px)" % [nav_width, nav.size.x])
    for def_id in ["wp_coil_shotgun", "wp_nail_storm"]:
        Game.state["inventory"]["weapons"].append({"instance_id": "codefix-" + def_id, "definition_id": def_id})
    for weapon_id in ["nail", "coil", "covenant"]:
        check(Game.equip_weapon(weapon_id), "equip " + weapon_id)
        scene.hud.update_hud()
        await frames(2)
        await _check_hud_layout("weapon_" + weapon_id)
    await _check_combat_allocation()
    _check_hud_text()
    await _check_world_materials()
    await _check_spawn_facing()
    _check_attribute_top_up()
    await _check_quickload_never_rewinds()
    await _check_death_record_and_reconstruct()
    _finish()

## Every HUD text label and bar must sit inside the 640x400 viewport, and must not
## overlap any other HUD text, bar or panel it does not belong to.
func _check_hud_layout(tag: String) -> void:
    # 09.5: the stealth cue sizes its text on refresh; measure it after one,
    # so the check does not depend on whether a refresh has happened yet.
    var cue = scene.hud.get("awareness_cue_093")
    if cue != null and cue.has_method("refresh"):
        cue.refresh()
        await get_tree().process_frame
    var view := Rect2(Vector2.ZERO, Vector2(640, 400))
    var leaves: Array[Control] = []
    var panels: Array[Control] = []
    for node in scene.hud.overlay.get_children():
        if not (node is Control) or not node.visible: continue
        if node is Panel:
            if node == scene.hud.banner_panel or node == scene.hud.prompt_panel: continue
            panels.append(node)
            for child in node.get_children():
                if child is Control and child.visible and (child is Label or child is ProgressBar or (child is TextureRect and str(child.name).begins_with("HUD086Icon_"))):
                    leaves.append(child)
        elif node is Label or node is ProgressBar:
            leaves.append(node)
    var off_screen: Array[String] = []
    for leaf in leaves:
        var r: Rect2 = leaf.get_global_rect()
        if not view.encloses(r):
            off_screen.append("%s %s" % [_label_of(leaf), r])
    check(off_screen.is_empty(), "%s: all HUD text inside 640x400 %s" % [tag, off_screen])
    var overlaps: Array[String] = []
    for i in range(leaves.size()):
        for j in range(i + 1, leaves.size()):
            var a: Rect2 = leaves[i].get_global_rect().grow(-0.5)
            var b: Rect2 = leaves[j].get_global_rect().grow(-0.5)
            if a.intersects(b):
                overlaps.append("%s x %s" % [_label_of(leaves[i]), _label_of(leaves[j])])
        for panel in panels:
            if leaves[i].get_parent() == panel: continue
            if leaves[i].get_global_rect().grow(-0.5).intersects(panel.get_global_rect()):
                overlaps.append("%s x panel %s" % [_label_of(leaves[i]), panel.name])
    check(overlaps.is_empty(), "%s: no HUD overlaps %s" % [tag, overlaps])
    # Text, bars and icons must stay off the panel frame border (5 px inset).
    var on_border: Array[String] = []
    for leaf in leaves:
        var parent := leaf.get_parent() as Control
        if parent is Panel and not parent.get_global_rect().grow(-5.0).encloses(leaf.get_global_rect()):
            on_border.append("%s in %s" % [_label_of(leaf), parent.name])
    check(on_border.is_empty(), "%s: HUD content clear of panel borders %s" % [tag, on_border])
    # 09.6: frames as drawn (a frame's tab is drawn above its panel) must not
    # overlap each other either.
    var drawn: Array = []
    for panel in panels:
        var r: Rect2 = panel.get_global_rect()
        var sb = panel.get_theme_stylebox("panel")
        if sb is StyleBoxTexture:
            r = r.grow_individual(sb.expand_margin_left, sb.expand_margin_top, sb.expand_margin_right, sb.expand_margin_bottom)
        drawn.append([panel, r])
    var frame_clash: Array[String] = []
    for i in range(drawn.size()):
        for j in range(i + 1, drawn.size()):
            if (drawn[i][1] as Rect2).grow(-0.5).intersects(drawn[j][1]):
                frame_clash.append("%s x %s" % [drawn[i][0].name, drawn[j][0].name])
    check(frame_clash.is_empty(), "%s: drawn HUD frames do not overlap %s" % [tag, frame_clash])

## Firing must not allocate fresh meshes/materials/audio players per pellet, and
## vertical tracers must not trigger the colinear look_at warning.
func _check_combat_allocation() -> void:
    var player = scene.player
    check(Game.equip_weapon("coil"), "equip coil for allocation test")
    Game.state["weapon_state"]["magazines"]["coil"] = 2
    player.reloading = false
    player.current_fire_cooldown = 0.0
    player.fire_equipped()   # warm-up: creates the shared resources and voice pool once
    await frames(30)
    Game.state["weapon_state"]["magazines"]["coil"] = 2
    player.current_fire_cooldown = 0.0
    var nodes_before: int = int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
    var objects_before: int = int(Performance.get_monitor(Performance.OBJECT_COUNT))
    player.fire_equipped()
    var nodes_added: int = int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)) - nodes_before
    var objects_added: int = int(Performance.get_monitor(Performance.OBJECT_COUNT)) - objects_before
    print("CODEFIX_INFO: coil blast added %d nodes, %d objects (was 113 nodes, 308 objects)" % [nodes_added, objects_added])
    check(objects_added <= nodes_added + 4, "coil blast allocates no per-pellet meshes/materials (%d objects for %d nodes)" % [objects_added, nodes_added])
    var voices_before: int = player.get_child_count()
    for i in range(12):
        player._play_action_audio("covenant_fire.wav", -40.0)
    check(player.get_child_count() == voices_before, "action audio reuses a fixed voice pool")
    var tracer = preload("res://scripts/combat_tracer_079x.gd").new()
    add_child(tracer)
    tracer.configure(Vector3(0, 1, 0), Vector3(0, 6, 0), Color.WHITE)  # straight up
    check(tracer.beam != null and is_equal_approx(tracer.beam.scale.z, 5.0), "vertical tracer is built with correct length")
    await frames(12)

func _check_hud_text() -> void:
    Game.ensure_build078_state()
    Game.state["civic"]["staged_groups"] = {"Ward children": true, "Clinic patients": false}
    var docket: String = scene.hud.dossier_text()
    check(docket.contains("STAGED ROSTERS: Ward children") and not docket.contains("Clinic patients"), "released cohorts are not listed as staged")
    Game.state["civic"]["staged_groups"] = {}
    Game.state["zone"] = "sootworks"
    Game.state["lung"]["installed"] = true
    Game.state["writs"].append("qobj_writ_of_labour")
    scene.hud.update_hud()
    check(not scene.hud.objective_label.text.contains("Return to Flood Basilica"), "Sootworks objective after Labour Writ is the run-wide one")
    Game.state["writs"].erase("qobj_writ_of_labour")
    Game.state["zone"] = "hearth"

## No lit world material may be strongly metallic: with no sky or reflection
## probe they render near-black on the Compatibility renderer.
func _check_world_materials() -> void:
    var worst: Array[String] = []
    for zone_name in ["hearth","sootworks","basilica","ashmarket","orchard","barracks","core","assembly"]:
        Game.state["zone"] = zone_name
        scene.reload_district_world()
        await frames(2)
        for node in scene.world.find_children("*", "MeshInstance3D", true, false):
            var mats: Array = [node.material_override]
            if node.mesh != null:
                for i in range(node.mesh.get_surface_count()): mats.append(node.mesh.surface_get_material(i))
            for m in mats:
                if m is StandardMaterial3D and m.shading_mode != BaseMaterial3D.SHADING_MODE_UNSHADED and m.metallic > 0.2001:
                    worst.append("%s:%s=%.2f" % [zone_name, node.name, m.metallic])
    check(worst.is_empty(), "no lit world material above metallic 0.2 %s" % [worst.slice(0, 6)])
    Game.state["zone"] = "hearth"
    scene.reload_district_world()
    scene.player.restore_position()
    await frames(2)

func _check_spawn_facing() -> void:
    Game.state["lung"]["installed"] = true
    scene.player.rotation.y = 1.0
    scene._on_action("travel:sootworks")
    await frames(3)
    scene.hud.close_modal(true)
    check(str(Game.state["zone"]) == "sootworks" and is_equal_approx(scene.player.rotation.y, 0.0), "first arrival in Sootworks uses the authored facing")
    scene.player.rotation.y = -2.0
    scene._on_action("travel:hearth")
    await frames(3)
    scene.hud.close_modal(true)
    check(is_equal_approx(scene.player.rotation.y, wrapf(1.0 + PI, -PI, PI)), "returning to Hearth faces away from the gate Ninth left by")
    scene._on_action("travel:sootworks")
    await frames(3)
    scene.hud.close_modal(true)
    check(is_equal_approx(scene.player.rotation.y, wrapf(-2.0 + PI, -PI, PI)), "returning to Sootworks faces back into the district")

func _check_attribute_top_up() -> void:
    Game.state["level"] = 3
    Game.state["health"] = Game.max_health()
    var cap_before: int = Game.max_health()
    check(Game.choose_attribute_075("Force"), "attribute point can be spent")
    check(Game.max_health() > cap_before and int(Game.state["health"]) == Game.max_health(), "raising Force raises current HP with the cap")

func _check_quickload_never_rewinds() -> void:
    Music.active_combat = false
    Game.state["health"] = Game.max_health()
    Game.save_attempt()
    Game.take_damage(30)
    var hurt: int = int(Game.state["health"])
    scene._load_now()
    await frames(2)
    check(int(Game.state["health"]) == hurt, "F9 does not refill HP lost since the last autosave")
    Music.active_combat = true
    var zone_before: String = str(Game.state["zone"])
    scene.player.global_position += Vector3(0.5, 0, 0)
    var pos_before: Vector3 = scene.player.global_position
    scene._load_now()
    check(scene.player.global_position.is_equal_approx(pos_before) and str(Game.state["zone"]) == zone_before, "F9 is refused while hostiles are engaged")
    Music.active_combat = false
    scene.hud.close_modal(true)

func _check_death_record_and_reconstruct() -> void:
    Game.state["zone"] = "orchard"
    Game.take_damage(99999)
    await frames(2)
    var record: Array = Game.state.get("nix_archived_failures", [])
    check(not record.is_empty() and str(record.back().get("site", "")) == "Glass Orchard", "Orchard death is recorded at Glass Orchard, not Vesper")
    # Simulate an app restart: nothing in memory, only the failed save on disk.
    Game.state = {}
    check(not Game.has_saved_active(), "a failed attempt is not offered as RESUME")
    check(not Game.failed_attempt_awaiting_reprint().is_empty(), "the failed attempt is offered for reconstruction")
    scene.hud.close_modal(true)
    scene._on_action("reprint_saved")
    await frames(3)
    check(Game.has_attempt() and Game.intro_text().contains("failure at Glass Orchard"), "reconstructing after restart keeps Nix's witnessed record")
    check(Game.failed_attempt_awaiting_reprint().is_empty(), "the death is consumed once reconstructed")
    scene.hud.close_modal(true)

func _label_of(c: Control) -> String:
    if c is Label: return "'%s'" % str(c.text).replace("\n", "/").left(24)
    if c is TextureRect: return "icon %s %s" % [str(c.name).trim_prefix("HUD086Icon_"), c.size]
    return "bar@%s" % c.get_global_rect().position

func _finish() -> void:
    print("CODEFIX_SUMMARY: %d passed, %d failed" % [passes, failures.size()])
    for f in failures: print("  FAILED: ", f)
    await frames(2)
    Music.request_quit(1 if failures.size() > 0 else 0)
