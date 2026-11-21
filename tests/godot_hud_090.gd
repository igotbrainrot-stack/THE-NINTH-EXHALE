extends Node
## Build 09.0 HUD/UI runtime checks: stacked notice slips, civic stamps for
## recorded milestones, keycap prompt, numbered modal choices with number-key
## shortcuts, the tabbed docket, damage vignette, bar damage trail and the
## reticle hit/kill marker. Exits 1 on failure.
var failures: Array[String] = []
var passes: int = 0
var scene: Node
var picked: Array[String] = []

func _ready() -> void:
    call_deferred("_run")

func check(ok: bool, label: String) -> void:
    if ok:
        passes += 1; print("HUD090_PASS: ", label)
    else:
        failures.append(label); print("HUD090_FAIL: ", label)

func frames(n: int) -> void:
    for i in range(n): await get_tree().process_frame

func key(code: Key) -> void:
    var ev := InputEventKey.new()
    ev.keycode = code
    ev.pressed = true
    Input.parse_input_event(ev)
    await frames(2)
    var up := ev.duplicate()
    up.pressed = false
    Input.parse_input_event(up)
    await frames(1)

func _run() -> void:
    scene = load("res://scenes/hearth_nine.tscn").instantiate()
    add_child(scene)
    await frames(1)
    scene.begin_attempt("Witness")
    await frames(2)
    scene.hud.close_modal(true)
    var hud = scene.hud
    check(is_instance_valid(hud.fx) and hud.fx.get_parent() == hud.overlay, "fx layer lives in the overlay")
    check(hud.fx.get_index() == hud.shell.get_index() + 1 and hud.fx.get_index() < hud.objective_panel.get_index(), "fx layer draws above the viewmodel, under every panel")
    await _slips(hud)
    await _prompt(hud)
    await _modal_keys(hud)
    await _docket_tabs(hud)
    await _stamps(hud)
    await _feedback(hud)
    print("HUD090_SUMMARY: %d passed, %d failed" % [passes, failures.size()])
    await frames(1)
    Music.request_quit(1 if failures.size() > 0 else 0)

func _slips(hud) -> void:
    for s in hud.fx.slips.duplicate(): s.queue_free()
    hud.fx.slips.clear()
    await frames(1)
    hud.notify("FIRST NOTICE", 4.0)
    hud.notify("SECOND NOTICE", 4.0)
    await frames(12)
    check(hud.fx.slips.size() == 2, "two notices stack instead of overwriting")
    check(not hud.banner_panel.visible, "legacy banner stays hidden when slips are available")
    var newest: Control = hud.fx.slips[0]
    var older: Control = hud.fx.slips[1]
    check((newest.get_child(0) as Label).text == "SECOND NOTICE", "newest notice is on top")
    check(older.position.y > newest.position.y, "older notice moves down")
    for i in range(4): hud.notify("BULK %d" % i, 4.0)
    await get_tree().create_timer(0.35).timeout
    check(hud.fx.slips.size() == 3, "at most three slips")
    var view := Rect2(Vector2.ZERO, Vector2(640, 400))
    var clash: Array[String] = []
    for s in hud.fx.slips:
        var r: Rect2 = s.get_global_rect()
        if not view.encloses(r): clash.append("offscreen %s" % r)
        for p in [hud.objective_panel, hud.navigation_panel, hud.vitals_panel, hud.weapon_panel]:
            if r.intersects(p.get_global_rect()): clash.append("%s x %s" % [r, p.name])
    check(clash.is_empty(), "slips sit clear of HUD panels %s" % [clash])
    hud.notify("PRESSURE CRAWLER STOPPED / FIND THE MANUAL VALVE AT THE NORTH DOOR", 4.0)
    hud.notify("ENFORCER DOWN / WITNESS RECORDED. Ask clerk for the reserve.", 4.0)
    await get_tree().create_timer(0.35).timeout
    var stacked: Array[String] = []
    for i in range(hud.fx.slips.size()):
        for j in range(i + 1, hud.fx.slips.size()):
            var ra: Rect2 = hud.fx.slips[i].get_global_rect()
            var rb: Rect2 = hud.fx.slips[j].get_global_rect()
            if ra.intersects(rb): stacked.append("%s x %s" % [ra, rb])
        var lab: Label = hud.fx.slips[i].get_child(0)
        if lab.get_line_count() > lab.get_visible_line_count() or lab.get_global_rect().end.y > hud.fx.slips[i].get_global_rect().end.y + 0.5:
            stacked.append("text overflows slip %d (%s in %s)" % [i, lab.get_global_rect(), hud.fx.slips[i].get_global_rect()])
    check(stacked.is_empty(), "wrapped slips never overlap or overflow %s" % [stacked])
    var before: int = hud.fx.slips.size()
    hud.notify("PISTOL EMPTY", 4.0)
    hud.notify("PISTOL EMPTY", 4.0)
    hud.notify("PISTOL EMPTY", 4.0)
    await frames(2)
    var copies: int = 0
    for s in hud.fx.slips:
        if str(s.get_meta("message", "")) == "PISTOL EMPTY": copies += 1
    check(copies == 1, "repeated notice merges into one slip")
    check(hud.fx.slips[0].get_child(0).text.ends_with("×3"), "merged slip shows its count")
    hud.notify("SHORT", 0.05)
    await get_tree().create_timer(0.6).timeout
    var still := false
    for s in hud.fx.slips:
        if is_instance_valid(s) and (s.get_child(0) as Label).text == "SHORT": still = true
    check(not still, "expired slip is removed")

func _prompt(hud) -> void:
    hud.set_interact_prompt("[E] SPEAK TO BRIN HARKER")
    check(hud.prompt_keycap.visible and hud.prompt_keycap_label.text == "E", "prompt key shown as keycap")
    check(hud.prompt_label.text == "SPEAK TO BRIN HARKER", "prompt verb phrase without brackets")
    var icon = hud.prompt_panel.get_node("HUD086Icon_icon_interact")
    check(not icon.visible, "interact icon yields to the keycap")
    check(hud.prompt_panel.get_global_rect().grow(-4.0).encloses(hud.prompt_keycap.get_global_rect()), "keycap inside the prompt tab")
    hud.set_interact_prompt("LOOK AT THE VALVE")
    check(not hud.prompt_keycap.visible and icon.visible, "plain prompt keeps the icon")
    hud.set_interact_prompt("")

func _modal_keys(hud) -> void:
    if not hud.action_selected.is_connected(_on_pick): hud.action_selected.connect(_on_pick)
    picked.clear()
    hud.open_modal("TEST", "Body", [
        {"label":"FIRST", "action":"a1"},
        {"label":"[Tech 9 / 9] LOCKED", "action":"a2", "enabled": false},
        {"label":"THIRD", "action":"a3"}])
    await frames(2)
    var keys := 0
    for b in hud.modal_buttons:
        if b.get_node_or_null("ChoiceKey") != null: keys += 1
    check(keys == 3, "every choice carries a number keycap")
    check(hud.modal_buttons[1].text.begins_with("[Tech 9 / 9]"), "button text is unchanged by numbering")
    var b0: Button = hud.modal_buttons[0]
    check(b0.get_theme_stylebox("normal").content_margin_left >= 30.0, "label clears the keycap")
    await key(KEY_2)
    check(picked.is_empty(), "number key ignores a disabled choice")
    await key(KEY_3)
    check(picked == ["a3"], "number key 3 picks the third choice %s" % [picked])
    hud.close_modal(true)
    await frames(1)
    picked.clear()
    await key(KEY_1)
    check(picked.is_empty(), "number keys do nothing with no docket open")
    hud.action_selected.disconnect(_on_pick)

func _on_pick(id: String) -> void:
    picked.append(id)

func _docket_tabs(hud) -> void:
    var sections: Array = hud.dossier_sections()
    var names: Array[String] = []
    for s in sections: names.append(str(s["tab"]))
    check(names == ["Goals", "The Ninth", "Records", "Endgame"], "docket has four tabs %s" % [names])
    var whole: String = hud.dossier_text()
    check(whole.contains("KNOWN FINAL PREREQUISITES") and whole.contains("STAGED ROSTERS"), "dossier_text still holds the whole record")
    check(str(sections[0]["text"]).contains("KNOWN FINAL PREREQUISITES") and str(sections[0]["text"]).contains("OFFICE TRUST"), "Goals tab leads with prerequisites and trust")
    scene._show_dossier()
    await frames(3)
    check(hud.modal_tab_buttons.size() == 4 and hud.modal_tab_buttons[0].button_pressed, "docket opens on the Goals tab")
    check(hud.modal_story.text == str(sections[0]["text"]), "story shows the Goals section")
    await key(KEY_RIGHT)
    check(hud.modal_tab_index == 1 and hud.modal_story.text.contains("ATTRIBUTES"), "Right arrow moves to The Ninth")
    await key(KEY_Q)
    await key(KEY_Q)
    check(hud.modal_tab_index == 3, "Q wraps back to Endgame")
    hud.modal_tab_buttons[2].emit_signal("pressed")
    await frames(1)
    check(hud.modal_tab_index == 2 and hud.modal_story.text.contains("RELATIONSHIPS"), "clicking a tab selects it")
    var view := Rect2(Vector2.ZERO, Vector2(640, 400))
    var bad: Array[String] = []
    for n in [hud.modal_story] + hud.modal_tab_buttons:
        if not view.encloses(n.get_global_rect()): bad.append(str(n.name))
        if not hud.modal.get_global_rect().encloses(n.get_global_rect()): bad.append("outside docket " + str(n.name))
    check(bad.is_empty(), "tabs and story stay inside the docket %s" % [bad])
    check(hud.modal_story.get_global_rect().end.y <= hud.modal_buttons[0].get_parent().get_parent().get_global_rect().position.y, "story does not run under the choices")
    scene.resume_controls()
    await frames(1)

func _stamps(hud) -> void:
    hud.fx.stamp_queue.clear()
    if is_instance_valid(hud.fx.stamp_node): hud.fx.stamp_node.queue_free()
    hud.fx.stamp_node = null
    hud.fx.watch_state()
    Game.state["writs"].append("qobj_writ_of_labour")
    Game.state["hearing"]["passed"] = true
    hud.fx.watch_state()
    await frames(2)
    check(is_instance_valid(hud.fx.stamp_node) and hud.fx.stamp_node.name.begins_with("CivicStamp"), "a recorded Writ is stamped on screen")
    var head: Label = hud.fx.stamp_node.get_child(1)
    check(head.text == "WRIT RECORDED", "first stamp is the Writ %s" % head.text)
    check(hud.fx.stamp_queue.size() == 1, "hearing stamp waits its turn")
    hud.fx.watch_state()
    check(hud.fx.stamp_queue.size() == 1, "a milestone is stamped once")
    var r: Rect2 = hud.fx.stamp_node.get_global_rect()
    check(Rect2(Vector2.ZERO, Vector2(640, 400)).encloses(r), "stamp inside the viewport %s" % r)
    await get_tree().create_timer(2.4).timeout
    var head2: Label = hud.fx.stamp_node.get_child(1) if is_instance_valid(hud.fx.stamp_node) else null
    check(head2 != null and head2.text == "HEARING PASSED", "queued hearing stamp follows")
    Game.state["level"] = int(Game.state["level"]) + 1
    hud.fx.watch_state()
    check(hud.fx.stamp_queue.size() >= 1 and str(hud.fx.stamp_queue.back()[0]).begins_with("Level"), "level-up is stamped")
    Game.state["writs"].erase("qobj_writ_of_labour")
    Game.state["hearing"]["passed"] = false

func _feedback(hud) -> void:
    hud.fx.low_health = 0.0
    hud.fx.damage_pulse = 0.0
    hud.impact_damage_079(20)
    check(hud.fx.damage_pulse > 0.5, "damage raises the pressure vignette")
    await frames(30)
    var mat: ShaderMaterial = hud.fx.vignette.material
    check(float(mat.get_shader_parameter("intensity")) < 0.5, "vignette fades after the hit")
    var max_hp: int = Game.max_health()
    Game.state["health"] = int(max_hp * 0.15)
    hud.update_hud()
    await get_tree().create_timer(0.5).timeout
    check(hud.fx.low_health > 0.2, "low health keeps a pulsing edge")
    hud.open_modal("PAUSE", "Body", [{"label":"OK", "action":"close"}])
    await frames(2)
    check(float(mat.get_shader_parameter("intensity")) == 0.0, "vignette is off while a docket is open")
    hud.close_modal(true)
    Game.state["health"] = max_hp
    hud.update_hud()
    Game.state["health"] = int(max_hp * 0.5)
    hud.update_hud()
    var trail: ColorRect = hud.fx.trails[hud.hp_bar]["rect"]
    check(trail.visible and trail.size.x > 10.0, "lost health leaves a trail on the bar")
    await get_tree().create_timer(1.4).timeout
    check(not trail.visible or trail.size.x < 2.0, "trail drains to the new value")
    Game.state["health"] = max_hp
    hud.update_hud()
    hud.hit_confirmed_090(false)
    check(hud.fx.marker_time > 0.0 and not hud.fx.marker_kill, "hit marker on a hit")
    hud.hit_confirmed_090(true)
    check(hud.fx.marker_kill and hud.fx.marker_time > 0.2, "kill marker lasts longer")
    Game.state["unspent_attribute_points"] = 3
    hud.update_hud()
    var meta: Label = hud.meta_text
    var mw: float = meta.get_theme_font("font").get_string_size(meta.text, HORIZONTAL_ALIGNMENT_LEFT, -1, meta.get_theme_font_size("font_size")).x
    check(meta.text.contains("TO SPEND") and mw <= meta.size.x, "pending level-up points shown and fit (%s, %d px)" % [meta.text, mw])
    Game.state["unspent_attribute_points"] = 0
    Game.state["level"] = 1
    hud.update_hud()
    check(not hud.meta_text.text.contains("TO SPEND"), "reminder clears once spent (%s)" % hud.meta_text.text)
    scene.hearing_choices("Flavour text about the hearing.")
    await frames(2)
    check(hud.modal_story.text.begins_with("FIELD"), "hearing docket leads with the live field state")
    check(hud.modal_story.text.contains("[color=#e0b46d][b]OPPONENT:"), "opponent phase is highlighted")
    var t_label: Label = null
    for c in hud.modal.get_children():
        if c is Label and c.position == Vector2(39, 10): t_label = c
    var tw: float = t_label.get_theme_font("font").get_string_size(t_label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, t_label.get_theme_font_size("font_size")).x
    check(tw <= t_label.size.x, "long docket title shrinks to fit (%d px at %d)" % [tw, t_label.get_theme_font_size("font_size")])
    hud.close_modal(true)
    var notices_before: int = hud.fx.slips.size()
    hud.animate_shot(true)
    check(hud.fx.slips.size() == notices_before, "a hit no longer spams a notice")
