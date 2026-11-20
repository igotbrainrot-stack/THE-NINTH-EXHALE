extends Node
## Build 08.9 runtime checks: deterministic check labels and disabled options,
## XP caps, perks and their effects, Office Trust accumulation, True Dawn lockout
## warning, docket prerequisites, and hearing balance. Exits 1 on failure.
var failures: Array[String] = []
var passes: int = 0
var scene: Node
var levels_seen: Array[int] = []

func _ready() -> void:
    call_deferred("_run")

func check(ok: bool, label: String) -> void:
    if ok:
        passes += 1; print("RPG089_PASS: ", label)
    else:
        failures.append(label); print("RPG089_FAIL: ", label)

func frames(n: int) -> void:
    for i in range(n): await get_tree().process_frame

func fresh(build: String = "Witness") -> void:
    scene.begin_attempt(build)
    await frames(2)
    scene.hud.close_modal(true)
    Game.state["lung"]["installed"] = true

func _run() -> void:
    scene = load("res://scenes/hearth_nine.tscn").instantiate()
    add_child(scene)
    await frames(1)
    Game.level_changed.connect(func(l): levels_seen.append(l))
    await fresh()
    _checks_and_buttons()
    await _modal_disables_unmet_option()
    _xp_caps()
    _perks()
    _trust_accumulates()
    await _lockout_warning()
    _docket()
    await _hearing_balance()
    print("RPG089_SUMMARY: %d passed, %d failed" % [passes, failures.size()])
    await frames(1)
    Music.request_quit(1 if failures.size() > 0 else 0)

func _checks_and_buttons() -> void:
    Game.ensure_build075_state()
    var c: Dictionary = Game.coalition_check()
    check(not bool(c["ok"]) and str(c["text"]).contains("required"), "coalition needs documented contracts first: %s" % c["text"])
    Game.state["trade"]["coalition_recorded"] = true
    c = Game.coalition_check()
    check(bool(c["ok"]) and str(c["text"]) == "[Speech 5 + buyers' contracts 2 = 7 / 7]", "Witness Speech 5 + documented evidence passes Speech 7: %s" % c["text"])
    var t: Dictionary = Game.check_attribute("Tech", 5)
    check(not bool(t["ok"]) and str(t["text"]) == "[Tech 1 / 5]", "Tech check shows the real value: %s" % t["text"])
    var opt: Dictionary = scene.check_option("ISOLATE", "x", t)
    check(opt["enabled"] == false and str(opt["label"]).begins_with("[Tech 1 / 5]"), "check option is visible, labelled and disabled")

func _modal_disables_unmet_option() -> void:
    scene._on_interact("tech_panel")
    await frames(2)
    var buttons: Array = scene.hud.modal.find_children("*", "Button", true, false)
    var tech_button: Button = null
    for b in buttons:
        if str(b.text).contains("REROUTE"): tech_button = b
    check(tech_button != null and tech_button.disabled and str(tech_button.text).begins_with("[Tech 1 / 5]"), "unmet Tech option is shown greyed out in the modal")
    scene.hud.close_modal(true)

func _xp_caps() -> void:
    levels_seen.clear()
    var xp_before: int = int(Game.state["xp"])
    for office in ["sootworks.labour","basilica.faith","ashmarket.trade","orchard.growth","barracks.defence"]:
        Game.award_xp_once("writ." + office, 165)
    check(int(Game.state["xp"]) - xp_before == 495, "only three unique Writs pay 165 XP (got %d)" % (int(Game.state["xp"]) - xp_before))
    check(levels_seen.size() > 0, "level-up signal fires (%s)" % [levels_seen])
    for i in range(10): Game.award_xp_once("codefix.test.%d" % i, 100)
    check(int(Game.state["xp"]) == 1050 and int(Game.state["level"]) == 7 and int(Game.state.get("run_score_xp",0)) > 0, "XP stops at 1,050; excess is run score (%d)" % int(Game.state.get("run_score_xp",0)))

func _perks() -> void:
    check(Game.perk_points_available() == 3, "levels 2, 4, 6 grant three perk choices (%d)" % Game.perk_points_available())
    check(not bool(Game.perk_check("F3")["ok"]), "Force 2 Witness cannot take Anchor Hands (Force 6)")
    check(not Game.choose_perk_089("F3"), "requirement enforced on choose")
    var breath_cap: int = Game.max_breath()
    check(Game.choose_perk_089("V1") and Game.max_breath() == breath_cap + 10, "Count Breath adds +10 max Breath")
    check(not Game.choose_perk_089("V1"), "a perk cannot be taken twice")
    check(Game.level7_choice_pending(), "level 7 offers attribute or fourth perk")
    check(Game.choose_level7_bonus("perk") and Game.perk_points_available() == 3, "level 7 fourth-perk choice adds a perk slot")
    # Effects that need stats the Witness lacks: grant directly to test behaviour.
    Game.state["perks"].append_array(["F3","R3","R2","T2"])
    Game.state["zone"] = "sootworks"
    Game.state["health"] = 50
    Game.take_damage(40)
    check(int(Game.state["health"]) == 40, "Anchor Hands absorbs 30 of the first heavy hit (HP %d)" % int(Game.state["health"]))
    Game.take_damage(40)
    check(int(Game.state["health"]) == 1 and Game.has_attempt(), "Narrow Escape leaves 1 HP once per district")
    Game.state["health"] = 60
    check(Game.dash_breath_cost() == 11.0, "Edge Runner dash costs 11 Breath")
    var energy: int = int(Game.state["resources"]["Energy"])
    Game.state["attributes"]["Tech"] = 5
    check(Game.disable_sootworks_regulator() and int(Game.state["resources"]["Energy"]) == energy - 2 and str(Game.state["ledger"].back()["event"]).begins_with("perk.T2"), "Careful Isolation refunds 1 Energy, recorded in the ledger")
    Game.state["attributes"]["Tech"] = 1

func _trust_accumulates() -> void:
    Game.state["relationships"]["Growth"] = 0
    Game.adjust_trust_089("Growth", 1)
    Game.adjust_trust_089("Growth", -1)
    check(int(Game.state["relationships"]["Growth"]) == 0, "trust adds up instead of the last action overwriting it")
    for i in range(6): Game.adjust_trust_089("Growth", -1)
    check(int(Game.state["relationships"]["Growth"]) == -3, "trust is clamped to -3..+3")
    Game.state["relationships"]["Growth"] = 0

func _lockout_warning() -> void:
    Game.ensure_build078_state()
    # Close three constituencies, leaving exactly three possible (incl. growth).
    Game.state["brin"]["alive"] = false
    Game.state["ossa"]["alive"] = false
    Game.state["relationships"]["Trade"] = -2
    check(Game.constituencies_possible_089() == 3, "three constituencies still possible (%d)" % Game.constituencies_possible_089())
    var warning: String = Game.true_dawn_lockout_warning_089("orchard:writ:isolation")
    check(warning.contains("True Dawn would become impossible"), "isolating the Growth Writ without a vote warns first")
    scene._on_action("orchard:writ:isolation")
    await frames(2)
    var title_ok: bool = false
    for l in scene.hud.modal.find_children("*", "Label", true, false):
        if str(l.text) == "TRUE DAWN WOULD CLOSE": title_ok = true
    check(title_ok, "the warning is shown as a confirmation before the action runs")
    scene.hud.close_modal(true)
    check(Game.true_dawn_lockout_warning_089("barracks:roster") == "", "harmless actions never warn")

func _docket() -> void:
    var text: String = scene.hud.dossier_text()
    check(text.contains("KNOWN FINAL PREREQUISITES") and text.contains("OFFICE TRUST") and text.contains("CLOSED: BRIN IS DEAD"), "docket lists prerequisites, closed constituencies with reasons, and trust")
    check(text.contains("PERKS: V1 Count Breath"), "docket lists chosen perks")

func _hearing_balance() -> void:
    for strategy in ["spam_attune", "spam_press", "phase_aware"]:
        var passed_all: bool = true
        var failed_all: bool = true
        for offset in range(3):
            await fresh()
            Game.state["zone"] = "basilica"
            check(Game.begin_public_hearing(), "hearing starts (%s %d)" % [strategy, offset]) if offset == 0 else Game.begin_public_hearing()
            Game.state["hearing"]["phase_offset"] = offset
            Game.state["hearing"]["observed"] = false
            for i in range(20):
                if not bool(Game.state["hearing"]["active"]): break
                var cmd: String = "Attune"
                if strategy == "spam_press": cmd = "Press"
                elif strategy == "phase_aware":
                    var ph: String = Game.hearing_phase()
                    cmd = "Press" if ph == "exposed" else ("Attune" if ph == "rising" else ("Observe" if not bool(Game.state["hearing"]["observed"]) else "Brace"))
                Game.hearing_command(cmd)
            var passed: bool = bool(Game.state["hearing"]["passed"])
            passed_all = passed_all and passed
            failed_all = failed_all and not passed
        if strategy == "phase_aware": check(passed_all, "reading the phases passes the hearing on every seed")
        else: check(failed_all, "%s fails on every seed (no single-command exploit)" % strategy)
