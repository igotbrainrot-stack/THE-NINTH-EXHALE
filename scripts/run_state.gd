extends Node
## Authoritative, versioned campaign state. No scene or UI can create events by itself.
## Authored Build 06 slice rules, NOT the entire V6 mechanics or full Godot campaign.

signal state_changed
signal attempt_failed
signal level_changed(new_level: int)
const SAVE_DIR = "user://saves"
const SAVE_PATH = "user://saves/active_v1.json"
const PROFILE_PATH = "user://saves/profile_v1.json"
const PRESETS = {
    "Breaker": {"Force":6,"Reflex":3,"Insight":2,"Speech":1,"Tech":2,"Resolve":4},
    "Witness": {"Force":2,"Reflex":2,"Insight":5,"Speech":5,"Tech":1,"Resolve":3},
    "Mechanist": {"Force":2,"Reflex":2,"Insight":3,"Speech":2,"Tech":6,"Resolve":3},
    "Stalker": {"Force":4,"Reflex":5,"Insight":3,"Speech":2,"Tech":3,"Resolve":1}
}
const DISTRICTS = ["Ashmarket", "Sootworks", "Glass Orchard", "Flood Basilica", "Quiet Barracks"]
const XP_LEVELS = [0, 100, 230, 390, 580, 800, 1050]
const EnemyRoster068 = preload("res://scripts/enemy_roster_068.gd")
const RAIL_GROUPS_078: Dictionary = {
    "ward_patients":{"seats":10,"source":"Hearth Nine signed patient transport roster","name":"Hearth Nine patients with assigned support"},
    "guardian_families":{"seats":8,"source":"Hearth Nine signed infant-and-guardian register","name":"Infants travelling with their guardians"},
    "repair_crew":{"seats":8,"source":"Named staffed maintenance service roll","name":"Voluntary line and pump repair crew"},
    "claimant_residents":{"seats":10,"source":"Claimant Ward independent receiving roster","name":"Claimant Ward residents who request passage"}}
var state: Dictionary = {}
var profile: Dictionary = {"failed_deaths": [], "completed_endings": [], "blueprints": []}
var definitions: Dictionary = {}
var technical_ids: Dictionary = {}

func _ready() -> void:
    var id_text := FileAccess.get_file_as_string("res://data/master_ids.json")
    var raw_ids = JSON.parse_string(id_text)
    if raw_ids is Dictionary:
        technical_ids = raw_ids
    var catalogue = JSON.parse_string(FileAccess.get_file_as_string("res://data/v6_reference_catalogue.json"))
    if catalogue is Dictionary:
        definitions = catalogue
    load_profile()
    configure_inputs()

func has_attempt() -> bool:
    return not state.is_empty() and state.get("status", "") == "active"

func start_new(build: String, forced_seed: int = -1, continuing_failure_chain: bool = false) -> void:
    if not PRESETS.has(build):
        build = "Witness"
    var seed := forced_seed if forced_seed >= 0 else (randi() % 2000000000)
    var attrs: Dictionary = PRESETS[build].duplicate(true)
    var run_number := int(profile.get("run_number", 0)) + 1
    profile["run_number"] = run_number
    var plan := create_world_plan(seed)
    var inherited_failures: Array = state.get("nix_archived_failures",[]).duplicate(true) if continuing_failure_chain else []
    state = {
        "schema": 1, "status":"active", "attempt_id": "attempt-%06d" % run_number,
        "build": build, "attributes":attrs, "world_plan":plan,
        "nix_archived_failures": inherited_failures,
        "player_pos": [-24.0,0.15,14.2], "yaw": 0.0, "pitch": 0.0,
        "zone":"hearth", "zone_positions":{"hearth":[-24.0,0.15,14.2], "sootworks":[-19.0,0.15,8.0], "basilica":[-20.0,0.15,8.0]}, "slice_mode":true,
        "health": max(80, 100 + 6 * (int(attrs["Resolve"])-2) + 3 * (int(attrs["Force"])-3)),
        "breath": max(88, 100 + 4 * (int(attrs["Resolve"])-2)),
        "magazine":6, "spare_ammo":36,
        "inventory":{"weapons":[{"instance_id":"starter-%06d" % run_number,"definition_id":"wp_covenant_pistol"}],"consumables":{"Breath Ampoule":2},"vouchers":12,"salvage":3,"relics":[],"mod_rewards":[]},
        "events":[], "event_ids":{}, "xp_awards":{}, "xp":0, "level":1,"perks":[],
        "brin":{"alive":true,"stage":"unmet","payroll_seen":false,"decision":"","aftermath_seen":false},
        "labour":{"writ_id":"qobj_writ_of_labour","method":"","millwright_defeated":false,"regulator_isolated":false},
        "lung":{"acquired":false,"installed":false,"method":""},
        "flags":{"allocation_record_seen":false,"claimant_warned":false,"guard_defeated":false},
        "intro":{"stage":"unwoken","alarm_raised":false,"sentry_defeated":false,"valve_open":false},
        "resources":{"Energy":72,"Correction":62,"Biomass":64,"Air":54,"Labour":58},
        "ward_air":{"Hearth Nine":14,"Claimant Ward":30,"Reserve Capacity":10},
        "ledger":[], "relationships":{"Hearth Nine":0,"Claimant Ward":0},
        "hearing":{"passed":false,"attempts":0},
        "actors":{"sentry":{"hp":32,"hostile":false,"alive":true,"position":[-17.2,0.15,9.0]},
            "enforcer":{"hp":70,"hostile":false,"alive":true,"position":[18.0,0.15,0.0]},
            "millwright":{"hp":125,"hostile":false,"alive":true,"position":[14.0,0.15,-3.0]},
            "brin":{"hp":45,"alive":true}},
        "writs":[], "ending":null, "render_version":"v6-master-2026-11-17-build06"
    }
    state["world_plan"]["slice_featured"] = ["Sootworks", "Flood Basilica", "Ashmarket"]
    state["world_plan"]["slice_arcs"] = ["Brin Harker", "Sister Ossa"]
    state["world_plan"]["slice_hearing_district"] = "Flood Basilica"
    ensure_build06_state()
    # Seed selects circumstances, not Ninth's consent or dialogue decisions.
    # These placements are confined to the known walkable keeper arena.
    state["world_plan"]["slice_seed_version"] = 2
    if int(state["fun_slice"]["seed_variant"]) == 1:
        state["actors"]["millwright"]["position"] = [12.0,0.15,6.0]
    elif int(state["fun_slice"]["seed_variant"]) == 2:
        state["actors"]["cantor"]["position"] = [17.0,0.15,2.0]
    save_profile()
    save_attempt()
    state_changed.emit()

func create_world_plan(seed: int) -> Dictionary:
    var rng := RandomNumberGenerator.new()
    rng.seed = seed
    var choices := DISTRICTS.duplicate()
    for index in range(choices.size() - 1, 0, -1):
        var other := rng.randi_range(0, index)
        var temp = choices[index]
        choices[index] = choices[other]
        choices[other] = temp
    var custodians := ["Canon Edda", "Marshal Voss", "Archivist Latch"]
    var names := ["Iona Pell","Brin Harker","Kest-07","Sister Ossa","Dr Sela Vale","Venn-of-Glass","Old Perrin","The Pale Ledger"]
    for index in range(names.size()-1,0,-1):
        var other := rng.randi_range(0,index)
        var temp = names[index]
        names[index] = names[other]
        names[other] = temp
    var local_hooks: Dictionary = {}
    for district in choices.slice(0,3):
        var candidates: Array = []
        for entry in definitions.get("local_storylets", []):
            if str(entry.get("district","")) == district:
                candidates.append(str(entry.get("title","")))
        for index in range(candidates.size()-1,0,-1):
            var swap_index := rng.randi_range(0,index)
            var old = candidates[index]
            candidates[index] = candidates[swap_index]
            candidates[swap_index] = old
        local_hooks[district] = candidates.slice(0,2)
    return {"seed":seed,"generator_version":1,"featured":choices.slice(0,3),"optional":choices.slice(3,5),"custodian":custodians[rng.randi_range(0,2)],"npc_arcs":names.slice(0,3),"local_hooks":local_hooks,"hearing_district":choices[rng.randi_range(0,1)],"dawn_dossiers":["Deep Heat Survey","Orchard Root Seed","cipher"]}

func stat(stat_name: String) -> int:
    if not has_attempt(): return 1
    return int(state["attributes"].get(stat_name, 1))

func max_health() -> int:
    return maxi(80, 100 + 6 * (stat("Resolve")-2) + 3 * (stat("Force")-3))

func max_breath() -> int:
    return maxi(88, 100 + 4 * (stat("Resolve")-2)) + (10 if has_perk("V1") else 0)

func record_event(event_id: String, kind: String, details: Dictionary = {}) -> bool:
    if not has_attempt() or state["event_ids"].has(event_id):
        return false
    state["event_ids"][event_id] = true
    state["events"].append({"id":event_id,"kind":kind,"details":details.duplicate(true)})
    preload("res://scripts/district_record_095.gd").bump("records")
    state_changed.emit()
    return true

func record_evidence() -> bool:
    if not record_event("hearth.allocation_copy", "evidence", {"source":"public requisition archive"}):
        return false
    state["flags"]["allocation_record_seen"] = true
    save_attempt()
    return true

## Bible deterministic check (section 7.1): attribute + documented evidence bonus
## >= threshold, AND any required fact present. No dice. Returns the exact label the
## UI must show, e.g. "[Speech 5 + buyers' contracts 2 = 7 / 7]".
func check_attribute(attr: String, threshold: int, bonus: int = 0, bonus_label: String = "", fact_ok: bool = true, fact_label: String = "") -> Dictionary:
    var value: int = stat(attr)
    var perk_bonus: int = 1 if attr == "Speech" and fact_ok and bonus > 0 and perk_ready_in_district("S1") else 0
    var total: int = value + bonus + perk_bonus
    var text: String
    if perk_bonus > 0 and total >= threshold and value + bonus < threshold:
        return {"ok": has_attempt(), "text": "[%s %d + %s %d + Common Ground 1 = %d / %d]" % [attr, value, bonus_label, bonus, total, threshold], "perk":"S1"}
    if not fact_ok:
        text = "[%s %d; %s required]" % [attr, threshold, fact_label]
    elif bonus > 0:
        text = "[%s %d + %s %d = %d / %d]" % [attr, value, bonus_label, bonus, total, threshold]
    else:
        text = "[%s %d / %d]" % [attr, value, threshold]
    return {"ok": has_attempt() and fact_ok and total >= threshold, "text": text}

func bargain_check() -> Dictionary:
    var seen: bool = bool(state["flags"]["allocation_record_seen"])
    return check_attribute("Speech", 6, 1 if seen else 0, "allocation record", seen, "public allocation record")

func can_bargain() -> bool:
    return bool(bargain_check()["ok"])

## Ashmarket coalition: documented duplicate contracts + independent buyer testimony
## are a strong documented linkage (+2 under the bible rule), so Speech 5 qualifies.
func coalition_check() -> Dictionary:
    var documented: bool = bool(state.get("trade",{}).get("coalition_recorded",false))
    return check_attribute("Speech", 7, 2 if documented else 0, "buyers' contracts", documented, "buyers' contracts and testimony")

func abdication_check() -> Dictionary:
    var speech: int = stat("Speech"); var insight: int = stat("Insight")
    return {"ok": speech >= 5 or insight >= 5, "text": "[Speech %d / 5 or Insight %d / 5]" % [speech, insight]}

func claim_lung(method: String) -> bool:
    if not has_attempt() or bool(state["lung"]["acquired"]):return false
    if not ["fight","bargain","tech","steal"].has(method):return false
    var bargain_used: Dictionary = bargain_check() if method == "bargain" else {}
    if method == "bargain" and not bool(bargain_used.get("ok",false)):return false
    if method == "tech" and stat("Tech") < 5:return false
    if method == "fight" and not bool(state["flags"]["guard_defeated"]):return false
    if not record_event("hearth.lung_claim", "allocation_claim", {"method":method,"source":"contested reserve rack"}):return false
    state["lung"]["acquired"] = true
    state["lung"]["method"] = method
    if str(bargain_used.get("perk","")) == "S1": spend_district_perk("S1")
    if method in ["fight", "steal"]:
        adjust_trust_089("Claimant Ward", -1)
    if method == "bargain":
        adjust_trust_089("Hearth Nine", 1)
    save_attempt()
    return true

func install_lung() -> bool:
    if not has_attempt() or not bool(state["lung"]["acquired"]) or bool(state["lung"]["installed"]):return false
    if not record_event("hearth.lung_installed", "lung_install", {"method":str(state["lung"]["method"]),"ward":"Hearth Nine"}):return false
    # This is a finite reallocation of a real spare, not generated clean air.
    state["resources"]["Energy"] -= 1
    state["resources"]["Correction"] -= 1
    state["ward_air"]["Hearth Nine"] += 8
    state["ward_air"]["Claimant Ward"] -= 5
    state["ward_air"]["Reserve Capacity"] -= 3
    state["ledger"].append({"event":"hearth.lung_installed","source":"contested lung + powered grid","Energy":-1,"Correction":-1,"Hearth Nine air allotment":8,"Claimant Ward air allotment":-5,"reserve spare capacity":-3})
    state["lung"]["installed"] = true
    award_xp_once("hearth.lung_solution", 140)
    save_attempt()
    return true

func award_xp_once(challenge_id: String, amount: int) -> bool:
    if not has_attempt() or state["xp_awards"].has(challenge_id):return false
    var granted: int = amount
    # Bible 7.2: 165 XP for each of three unique Writ transfers, up to 495. A fourth
    # or fifth Writ is still recorded (no repeat) but pays nothing.
    if challenge_id.begins_with("writ."):
        var paid_writs: int = 0
        for key in state["xp_awards"].keys():
            if str(key).begins_with("writ.") and int(state["xp_awards"][key]) > 0: paid_writs += 1
        if paid_writs >= 3: granted = 0
    state["xp_awards"][challenge_id] = granted
    var level_before: int = int(state.get("level",1))
    var total: int = int(state["xp"]) + granted
    # Bible 7.2: XP cannot exceed the 1,050 threshold for advancement; the excess
    # is kept as run score only.
    var cap: int = int(XP_LEVELS.back())
    if total > cap:
        state["run_score_xp"] = int(state.get("run_score_xp",0)) + total - cap
        total = cap
    state["xp"] = total
    var computed_level := 1
    for threshold in XP_LEVELS:
        if int(state["xp"]) >= int(threshold):
            computed_level += 1
    state["level"] = mini(7, computed_level-1)
    sync_attribute_milestones_075()
    ensure_build076_state()
    state_changed.emit()
    if int(state["level"]) > level_before:
        level_changed.emit(int(state["level"]))
    return true

# ---- BUILD 08.9 / STANDARD PERKS (bible 7.2) ----
# Levels 2, 4 and 6 each grant one perk; level 7 grants +1 attribute OR a fourth
# perk. Only perks whose effect exists in the current game are offered; the rest of
# the bible's 18 need systems (recoil, breaching, mods, dissonance) not built yet.
const PERKS_089: Dictionary = {
    "F3": {"name":"Anchor Hands", "stat":"Force", "min":6, "effect":"The first heavy hit (15+) in each district loses 30 damage."},
    "R2": {"name":"Edge Runner", "stat":"Reflex", "min":5, "effect":"Dash costs 11 Breath instead of 14."},
    "R3": {"name":"Narrow Escape", "stat":"Reflex", "min":6, "effect":"Once per district, a lethal hit leaves 1 HP."},
    "S1": {"name":"Common Ground", "stat":"Speech", "min":3, "effect":"Once per district, +1 to a Speech check that already has documented evidence."},
    "T2": {"name":"Careful Isolation", "stat":"Tech", "min":5, "effect":"Each machine isolation refunds 1 of its Energy cost."},
    "V1": {"name":"Count Breath", "stat":"Resolve", "min":3, "effect":"+10 max Breath."},
}

## Office Trust is a signed score -3..+3 (bible 8). Actions adjust it; they never
## overwrite earlier witnessed history (previously the last action replaced it).
func adjust_trust_089(office: String, delta: int) -> void:
    state["relationships"][office] = clampi(int(state["relationships"].get(office,0)) + delta, -3, 3)

func has_perk(perk_id: String) -> bool:
    return has_attempt() and state.get("perks",[]).has(perk_id)

func perk_points_available() -> int:
    if not has_attempt(): return 0
    var level: int = int(state.get("level",1))
    var earned: int = 0
    for mark in [2,4,6]:
        if level >= mark: earned += 1
    if str(state.get("level7_bonus","")) == "perk": earned += 1
    return maxi(0, earned - state.get("perks",[]).size())

func level7_choice_pending() -> bool:
    return has_attempt() and int(state.get("level",1)) >= 7 and str(state.get("level7_bonus","")) == ""

func choose_level7_bonus(kind: String) -> bool:
    if not level7_choice_pending() or not kind in ["attribute","perk"]: return false
    if not record_event("rpg.level7_bonus", "level_bonus_choice", {"kind":kind}): return false
    state["level7_bonus"] = kind
    if kind == "attribute":
        state["unspent_attribute_points"] = int(state.get("unspent_attribute_points",0)) + 1
    state_changed.emit()
    save_attempt()
    return true

func perk_check(perk_id: String) -> Dictionary:
    var perk: Dictionary = PERKS_089[perk_id]
    var value: int = stat(str(perk["stat"]))
    var ok: bool = perk_points_available() > 0 and not has_perk(perk_id) and value >= int(perk["min"])
    return {"ok": ok, "text": "[%s %d / %d]" % [perk["stat"], value, int(perk["min"])]}

func choose_perk_089(perk_id: String) -> bool:
    if not PERKS_089.has(perk_id) or not bool(perk_check(perk_id)["ok"]): return false
    if not record_event("rpg.perk.%s" % perk_id, "perk_choice", {"perk":perk_id}): return false
    var breath_cap_before: int = max_breath()
    state["perks"].append(perk_id)
    state["breath"] = int(state["breath"]) + maxi(0, max_breath() - breath_cap_before)
    state_changed.emit()
    save_attempt()
    return true

func _perk_use_key(perk_id: String) -> String:
    return "%s:%s" % [perk_id, str(state.get("zone","hearth"))]

func perk_ready_in_district(perk_id: String) -> bool:
    return has_perk(perk_id) and not state.get("perk_uses_089",{}).has(_perk_use_key(perk_id))

func spend_district_perk(perk_id: String) -> void:
    if not state.has("perk_uses_089"): state["perk_uses_089"] = {}
    state["perk_uses_089"][_perk_use_key(perk_id)] = true

func dash_breath_cost() -> float:
    return 11.0 if has_perk("R2") else 14.0

## T2: refund recorded in the ledger so the finite-resource audit stays exact.
func _careful_isolation_refund_089(event_id: String) -> void:
    if not has_perk("T2"): return
    state["resources"]["Energy"] = int(state["resources"]["Energy"]) + 1
    state["ledger"].append({"event":"perk.T2." + event_id, "source":"Careful Isolation: staged shutdown kept one load online", "Energy":1})

# ---- BUILD 04 / FIRST LABOUR DISTRICT ----
# These are authored decisions on one physical Sootworks map. The full five-
# district procedural world and slice-only two-Writ lift are not yet complete.
func ensure_build04_state() -> void:
    if state.is_empty():
        return
    if not state.has("zone"):
        state["zone"] = "hearth"
    if not state.has("zone_positions"):
        state["zone_positions"] = {"hearth": state.get("player_pos",[-15.5,0.15,8.0]),"sootworks": [-19.0,0.15,8.0]}
    if not state.has("brin"):
        state["brin"] = {"alive":true,"stage":"unmet","payroll_seen":false,"decision":"","aftermath_seen":false}
    if not state.has("labour"):
        state["labour"] = {"writ_id":"qobj_writ_of_labour","method":"","millwright_defeated":false,"regulator_isolated":false}
    if not state["actors"].has("millwright"):
        state["actors"]["millwright"] = {"hp":125,"hostile":false,"alive":true,"position":[14.0,0.15,-3.0]}
    if not state["actors"].has("brin"):
        state["actors"]["brin"] = {"hp":45,"alive":bool(state["brin"].get("alive",true))}
    if not state["inventory"].has("relics"):
        state["inventory"]["relics"] = []
    if not state["inventory"].has("mod_rewards"):
        state["inventory"]["mod_rewards"] = []

func change_zone(zone_id: String) -> bool:
    if not has_attempt() or not bool(state["lung"]["installed"]):
        return false
    if zone_id not in ["hearth", "sootworks", "basilica", "ashmarket", "orchard", "barracks"]:
        return false
    state["zone"] = zone_id
    var default_position: Array = [-15.5,0.15,8.0] if zone_id == "hearth" else ([-19.0,0.15,8.0] if zone_id == "sootworks" else ([-21.0,0.15,9.0] if zone_id == "ashmarket" else [-20.0,0.15,8.0]))
    if zone_id == "orchard": default_position = [-22.0,0.15,8.0]
    if zone_id == "barracks": default_position = [-22.0,0.15,8.0]
    var known_position: Array = state["zone_positions"].get(zone_id,default_position)
    state["player_pos"] = known_position.duplicate()
    # Default spawns are authored for yaw 0. A remembered position is where Ninth
    # left the district, normally facing its transfer gate, so turn around to face
    # back into the district instead of a hard-coded world -Z (often a wall).
    var known_yaws: Dictionary = state.get("zone_yaws",{})
    if state["zone_positions"].has(zone_id) and known_yaws.has(zone_id):
        state["yaw"] = wrapf(float(known_yaws[zone_id]) + PI, -PI, PI)
    else:
        state["yaw"] = 0.0
    state["pitch"] = 0.0
    record_event("travel:%d" % state["events"].size(),"physical_district_transfer",{"to":zone_id})
    save_attempt()
    return true

func meet_brin() -> bool:
    if not has_attempt() or not bool(state["brin"]["alive"]) or str(state["brin"]["stage"])!="unmet":
        return false
    if not record_event("sootworks.brin.meet","npc_meet",{"actor":"Brin Harker", "witness":"Ninth"}):
        return false
    state["brin"]["stage"] = "encountered"
    save_attempt()
    return true

func record_payroll() -> bool:
    if not has_attempt() or bool(state["brin"]["payroll_seen"]):
        return false
    if not record_event("sootworks.payroll.original", "evidence", {"object_id":"qobj_payroll_cylinder","source":"physical freight payroll cylinder", "cleared_debt_years_ago":43}):
        return false
    state["brin"]["payroll_seen"] = true
    award_xp_once("sootworks.evidence.payroll",20)
    save_attempt()
    return true

func investigate_brin() -> bool:
    if not has_attempt() or not bool(state["brin"]["alive"]) or not bool(state["brin"]["payroll_seen"]):
        return false
    if str(state["brin"]["stage"]) != "encountered":
        return false
    if not record_event("sootworks.brin.investigated","npc_investigation",{"actor":"Brin Harker","source":"sootworks.payroll.original"}):
        return false
    state["brin"]["stage"] = "investigated"
    save_attempt()
    return true

func decide_brin(outcome: String) -> bool:
    if not has_attempt() or not bool(state["brin"]["alive"]) or str(state["brin"]["stage"]) != "investigated":
        return false
    if outcome not in ["help","compromise","exploit","abandon"]:
        return false
    if not record_event("sootworks.brin.decision","npc_decision",{"actor":"Brin Harker","decision":outcome, "source":"sootworks.payroll.original"}):
        return false
    state["brin"]["decision"] = outcome
    state["brin"]["stage"] = "decision"
    if outcome == "help":
        # Safe stoppage: neighbouring ward retains air, but time and energy are spent.
        state["resources"]["Labour"] -= 2
        state["resources"]["Energy"] -= 1
        state["ledger"].append({"event":"sootworks.brin.decision","source":"staffed safe strike and reserved heat buffer","Energy":-1,"Labour":-2,"Air":0})
        adjust_trust_089("Labour", 1)
        state["inventory"]["relics"].append("Brin's Torque")
    elif outcome == "compromise":
        state["resources"]["Labour"] -= 1
        state["ledger"].append({"event":"sootworks.brin.decision","source":"negotiated emergency crew shifts","Labour":-1})
        state["inventory"]["relics"].append("Union Rivet Kit")
    elif outcome == "exploit":
        state["resources"]["Energy"] = maxi(0,int(state["resources"]["Energy"])-3)
        state["resources"]["Air"] = maxi(0,int(state["resources"]["Air"])-2)
        state["ledger"].append({"event":"sootworks.brin.decision","source":"unsafe forced production/heat leak","Energy":-3,"Air":-2})
        adjust_trust_089("Labour", -2)
        state["inventory"]["vouchers"] = mini(99,int(state["inventory"]["vouchers"])+8)
        state["inventory"]["mod_rewards"].append("Chain of Wages")
    award_xp_once("npc.brin.arc",55)
    save_attempt()
    return true

func complete_brin_aftermath() -> bool:
    if not has_attempt() or not bool(state["brin"]["alive"]) or str(state["brin"]["stage"])!="decision":
        return false
    if not record_event("sootworks.brin.aftermath", "npc_aftermath", {"outcome":str(state["brin"]["decision"])}):
        return false
    state["brin"]["stage"] = "consequence"
    state["brin"]["aftermath_seen"] = true
    save_attempt()
    return true

func kill_brin() -> bool:
    if not has_attempt() or not bool(state["brin"]["alive"]):
        return false
    if not record_event("sootworks.brin.death", "npc_death", {"actor":"Brin Harker", "method":"player firearm", "witness":"workshop"}):
        return false
    state["brin"]["alive"] = false
    state["actors"]["brin"]["alive"] = false
    state["actors"]["brin"]["hp"] = 0
    state["brin"]["stage"] = "dead"
    state["brin"]["aftermath_seen"] = false
    state["relationships"]["Labour"] = maxi(-3,int(state["relationships"].get("Labour",0))-2)
    save_attempt()
    return true

func disable_sootworks_regulator() -> bool:
    if not has_attempt() or stat("Tech") < 5 or bool(state["labour"]["regulator_isolated"]):
        return false
    if not record_event("sootworks.regulator.isolated","infrastructure_sabotage",{"source":"isolated control bus", "impact":"temporary factory shutdown"}):
        return false
    state["labour"]["regulator_isolated"] = true
    state["resources"]["Energy"] = maxi(0,int(state["resources"]["Energy"])-3)
    state["resources"]["Labour"] = maxi(0,int(state["resources"]["Labour"])-2)
    state["ledger"].append({"event":"sootworks.regulator.isolated","source":"control bus isolation; factory stopped","Energy":-3,"Labour":-2})
    _careful_isolation_refund_089("sootworks.regulator.isolated")
    save_attempt()
    return true

func grant_labour_writ(method: String) -> bool:
    if not has_attempt() or not bool(state["lung"]["installed"]):
        return false
    if state["writs"].has("qobj_writ_of_labour"):
        return false
    if method == "council":
        if not bool(state["brin"]["alive"]) or not bool(state["brin"]["payroll_seen"]) or str(state["brin"]["decision"])!="help":
            return false
    elif method == "sabotage":
        if not bool(state["labour"]["regulator_isolated"]):
            return false
    elif method == "registry":
        if not bool(state["labour"]["millwright_defeated"]):
            return false
    else:
        return false
    if not record_event("sootworks.labour_writ.transferred","writ_transfer",{"office":"Labour", "method":method, "object_id":"qobj_writ_of_labour", "source":"public labour register"}):
        return false
    state["writs"].append("qobj_writ_of_labour")
    state["labour"]["method"] = method
    award_xp_once("writ.sootworks.labour",165)
    save_attempt()
    return true

func sootworks_supplies() -> bool:
    if not record_event("sootworks.emergency_supplies", "finite_pickup", {"source":"single staffed district issue"}):
        return false
    state["spare_ammo"] = mini(120,int(state["spare_ammo"])+24)
    state["inventory"]["consumables"]["Breath Ampoule"] = int(state["inventory"]["consumables"].get("Breath Ampoule",0))+2
    save_attempt()
    return true

# ---- BUILD 06 / FAITH DISTRICT + CIVIC INTERFERENCE HEARING ----
# Build 06 adds safe defaults in-place; old Build 04/05 snapshots are accepted
# without changing permanent event IDs or pretending the new district was visited.
func ensure_build06_state() -> void:
    if state.is_empty():
        return
    ensure_build04_state()
    if not state["zone_positions"].has("basilica"):
        state["zone_positions"]["basilica"] = [-20.0,0.15,8.0]
    # Old Build 04–06.4 saves resume beyond the new prologue; never trap
    # a returning character behind a newly introduced airlock.
    if not state.has("intro"):
        state["intro"] = {"stage":"stabilised","alarm_raised":false,"sentry_defeated":true,"valve_open":true}
    if not state["actors"].has("sentry"):
        state["actors"]["sentry"] = {"hp":32,"hostile":false,"alive":false,"position":[-17.2,0.15,9.0]}
    if not state.has("slice_finale"):
        state["slice_finale"] = {"entered":false,"petition_seen":false,"apparatus_defeated":false,"resolved":false,"outcome":""}
    if not state["actors"].has("edda_machine"):
        state["actors"]["edda_machine"] = {"hp":90,"hostile":false,"alive":true,"position":[7.0,0.15,3.0]}
    if not state["zone_positions"].has("lift"):
        state["zone_positions"]["lift"] = [-9.0,0.15,10.0]
    if not state.has("ossa"):
        state["ossa"] = {"alive":true,"stage":"unmet","hymn_seen":false,"decision":"","aftermath_seen":false}
    if not state.has("faith"):
        state["faith"] = {"writ_id":"qobj_writ_of_faith","method":"","cantor_defeated":false,"governor_isolated":false}
    if not state["actors"].has("cantor"):
        state["actors"]["cantor"] = {"hp":125,"hostile":false,"alive":true,"position":[14.0,0.15,5.0]}
    if not state["actors"].has("ossa"):
        state["actors"]["ossa"] = {"hp":45,"alive":bool(state["ossa"].get("alive",true))}
    if not state["relationships"].has("Faith"):
        state["relationships"]["Faith"] = 0
    if not state.has("hearing"):
        state["hearing"] = {"passed":false,"attempts":0}
    var hearing: Dictionary = state["hearing"]
    if not hearing.has("active"): hearing["active"] = false
    if not hearing.has("integrity"): hearing["integrity"] = 31
    if not hearing.has("strain_margin"): hearing["strain_margin"] = 46
    if not hearing.has("observed"): hearing["observed"] = false
    if not hearing.has("brace_guard"): hearing["brace_guard"] = 0
    if not hearing.has("turns"): hearing["turns"] = 0
    if not hearing.has("refusals"): hearing["refusals"] = 0
    if not hearing.has("accord_type"): hearing["accord_type"] = "loaner"
    if not hearing.has("participant"): hearing["participant"] = "Rootkin"
    if not hearing.has("opposition"): hearing["opposition"] = "Bell Wretch signal field"
    if not hearing.has("trust"): hearing["trust"] = 1
    if not hearing.has("familiarity"): hearing["familiarity"] = 0
    if not hearing.has("press_count"): hearing["press_count"] = 0
    if not hearing.has("transcript"): hearing["transcript"] = []
    if not hearing.has("phase_offset"): hearing["phase_offset"] = int(state["world_plan"].get("seed",0)) % 3
    if not hearing.has("last_phase"): hearing["last_phase"] = ""
    if not state.has("fun_slice"):
        var seed_variant: int = int(state["world_plan"].get("seed",0)) % 3
        state["fun_slice"] = {"seed_variant":seed_variant,"hearth_vent_used":false,"sootworks_service_open":seed_variant == 0,"basilica_side_open":seed_variant == 1,"sootworks_steam_used":false,"basilica_resonator_used":false}
    var fs: Dictionary = state["fun_slice"]
    for setting in ["hearth_vent_used","sootworks_service_open","basilica_side_open","sootworks_steam_used","basilica_resonator_used"]:
        if not fs.has(setting): fs[setting] = false
    # Build 06.7 optional physical fixtures retain one-use state in old saves.
    if not state.has("pressure_067"):
        state["pressure_067"] = {"sootworks_stack":false,"basilica_receiver":false,"lift_regulator":false}
    for key in ["sootworks_stack","basilica_receiver","lift_regulator"]:
        if not state["pressure_067"].has(key): state["pressure_067"][key] = false
    if not state.has("discovery_067"):
        state["discovery_067"] = {"sootworks_relief":false,"basilica_notes":false}
    for key in ["sootworks_relief","basilica_notes"]:
        if not state["discovery_067"].has(key): state["discovery_067"][key] = false
    if not state["world_plan"].has("slice_hearing_district"):
        state["world_plan"]["slice_hearing_district"] = "Flood Basilica"
    ensure_build075_state()
    ensure_build078_state()

func vent_pressure_fixture(key: String) -> bool:
    # An authored physical pressure store discharges once. It consumes one
    # Energy unit; there is no unbacked air, health, ammunition or loot gain.
    if not has_attempt(): return false
    var zone_for: Dictionary = {"sootworks_stack":"sootworks","basilica_receiver":"basilica","lift_regulator":"lift"}
    if not zone_for.has(key) or str(state.get("zone","")) != str(zone_for[key]): return false
    if bool(state["pressure_067"].get(key,false)): return false
    var event_id: String = "%s.pressure_release_067" % str(zone_for[key])
    if not record_event(event_id,"finite_pressure_discharge",{"fixture":key,"source":"one stored pressure vessel","energy_units":1}): return false
    state["pressure_067"][key] = true
    var spent: int = mini(1,maxi(0,int(state["resources"].get("Energy",0))))
    state["resources"]["Energy"] = maxi(0,int(state["resources"].get("Energy",0))-spent)
    state["ledger"].append({"event":event_id,"source":"isolated air actuator with finite mechanical energy","Energy":-spent,"Air":0,"Correction":0})
    save_attempt()
    return true

func claim_discovery(key: String) -> bool:
    # Fixed, discoverable, once-only items placed in real side passages.
    if not has_attempt() or key not in ["sootworks_relief","basilica_notes"]: return false
    var expected_zone: String = "sootworks" if key == "sootworks_relief" else "basilica"
    if str(state.get("zone","")) != expected_zone: return false
    if bool(state["discovery_067"].get(key,false)): return false
    var event_id: String = "%s.discovery_%s_067" % [expected_zone,key]
    if not record_event(event_id,"physical_side_discovery",{"source":"finite public service store","kind":key}): return false
    state["discovery_067"][key] = true
    if key == "sootworks_relief":
        # A single pre-existing worker relief ampoule, not regenerated supplies.
        var stock: Dictionary = state["inventory"]["consumables"]
        stock["Breath Ampoule"] = int(stock.get("Breath Ampoule",0)) + 1
        state["ledger"].append({"event":event_id,"source":"sealed workers' relief box: one physical ampoule","new_health":0,"Energy":0,"Correction":0})
    else:
        # One source observation per public hearing attempt, NOT creature capture.
        state["hearing"]["familiarity"] = maxi(1,int(state["hearing"].get("familiarity",0)))
        state["ledger"].append({"event":event_id,"source":"original independent lay-choir acoustic notes","Energy":0,"Correction":0})
    save_attempt()
    return true

func meet_ossa() -> bool:
    ensure_build06_state()
    if not has_attempt() or not bool(state["ossa"]["alive"]) or str(state["ossa"]["stage"]) != "unmet":return false
    if not record_event("basilica.ossa.meet", "npc_meet", {"actor":"Sister Ossa", "source":"voluntary-maintenance choir", "witness":"Ninth"}):return false
    state["ossa"]["stage"] = "encountered"
    save_attempt()
    return true

func record_hymn_reel() -> bool:
    ensure_build06_state()
    if not has_attempt() or bool(state["ossa"]["hymn_seen"]):return false
    if not record_event("basilica.hymn.original", "evidence", {"source":"analogue governor timing reel", "content":"sixth note was a machine order"}):return false
    state["ossa"]["hymn_seen"] = true
    award_xp_once("basilica.evidence.hymn",20)
    save_attempt()
    return true

func investigate_ossa() -> bool:
    if not has_attempt() or not bool(state["ossa"]["alive"]) or not bool(state["ossa"]["hymn_seen"]):return false
    if str(state["ossa"]["stage"]) != "encountered":return false
    if not record_event("basilica.ossa.investigated", "npc_investigation", {"actor":"Sister Ossa", "source":"basilica.hymn.original"}):return false
    state["ossa"]["stage"] = "investigated"
    save_attempt()
    return true

func decide_ossa(outcome: String) -> bool:
    if not has_attempt() or not bool(state["ossa"]["alive"]) or str(state["ossa"]["stage"]) != "investigated":return false
    if outcome not in ["help", "compromise", "exploit", "abandon"]:return false
    if not record_event("basilica.ossa.decision", "npc_decision", {"actor":"Sister Ossa", "decision":outcome, "evidence":"basilica.hymn.original"}):return false
    state["ossa"]["decision"] = outcome
    state["ossa"]["stage"] = "decision"
    if outcome == "help":
        # Disconnect coercive command while the congregation retains its rituals.
        state["resources"]["Energy"] = maxi(0,int(state["resources"]["Energy"])-1)
        state["resources"]["Labour"] = maxi(0,int(state["resources"]["Labour"])-2)
        state["ledger"].append({"event":"basilica.ossa.decision", "source":"authorised lay council, signal isolation crew", "Energy":-1,"Labour":-2})
        adjust_trust_089("Faith", 1)
        ensure_weapon_state()
        state["inventory"]["weapons"].append({"instance_id":"quest-choirbreaker-"+str(state["attempt_id"]),"definition_id":"wp_choirbreaker"})
        state["weapon_state"]["magazines"]["choir"] = 12
        state["weapon_state"]["reserves"]["choir"] += 12
    elif outcome == "compromise":
        state["resources"]["Labour"] = maxi(0,int(state["resources"]["Labour"])-1)
        state["ledger"].append({"event":"basilica.ossa.decision", "source":"temporary staffed licence", "Labour":-1})
        state["inventory"]["relics"].append("Drowned Canticle")
    elif outcome == "exploit":
        state["resources"]["Correction"] = maxi(0,int(state["resources"]["Correction"])-3)
        state["ledger"].append({"event":"basilica.ossa.decision", "source":"amplified coercive choir signal", "Correction":-3})
        adjust_trust_089("Faith", -2)
    award_xp_once("npc.ossa.arc",55)
    save_attempt()
    return true

func complete_ossa_aftermath() -> bool:
    if not has_attempt() or not bool(state["ossa"]["alive"]) or str(state["ossa"]["stage"]) != "decision":return false
    if not record_event("basilica.ossa.aftermath", "npc_aftermath", {"outcome":str(state["ossa"]["decision"])}):return false
    state["ossa"]["stage"] = "consequence"
    state["ossa"]["aftermath_seen"] = true
    save_attempt()
    return true

func kill_ossa() -> bool:
    if not has_attempt() or not bool(state["ossa"]["alive"]):return false
    if not record_event("basilica.ossa.death", "npc_death", {"actor":"Sister Ossa", "witness":"Basilica nave", "method":"player firearm"}):return false
    state["ossa"]["alive"] = false
    state["ossa"]["stage"] = "dead"
    state["ossa"]["aftermath_seen"] = false
    state["actors"]["ossa"]["alive"] = false
    state["actors"]["ossa"]["hp"] = 0
    state["relationships"]["Faith"] = maxi(-3,int(state["relationships"].get("Faith",0))-2)
    save_attempt()
    return true

func disable_basilica_governor() -> bool:
    if not has_attempt() or stat("Tech") < 5 or bool(state["faith"]["governor_isolated"]):return false
    if not record_event("basilica.governor.isolated", "infrastructure_sabotage", {"source":"existing signal bus", "impact":"keeper machinery stands down"}):return false
    state["faith"]["governor_isolated"] = true
    state["resources"]["Energy"] = maxi(0,int(state["resources"]["Energy"])-2)
    state["resources"]["Labour"] = maxi(0,int(state["resources"]["Labour"])-1)
    state["ledger"].append({"event":"basilica.governor.isolated", "source":"isolated governor drive", "Energy":-2,"Labour":-1})
    _careful_isolation_refund_089("basilica.governor.isolated")
    save_attempt()
    return true

func grant_faith_writ(method: String) -> bool:
    if not has_attempt() or not bool(state["lung"]["installed"]):return false
    if state["writs"].has("qobj_writ_of_faith"):return false
    if method == "council":
        if not bool(state["ossa"]["alive"]) or not bool(state["ossa"]["hymn_seen"]) or str(state["ossa"]["decision"]) != "help":return false
    elif method == "sabotage":
        if not bool(state["faith"]["governor_isolated"]):return false
    elif method == "registry":
        if not bool(state["faith"]["cantor_defeated"]):return false
    else:
        return false
    if not record_event("basilica.faith_writ.transferred", "writ_transfer", {"office":"Faith","method":method,"object_id":"qobj_writ_of_faith","source":"durable public register"}):return false
    state["writs"].append("qobj_writ_of_faith")
    state["faith"]["method"] = method
    award_xp_once("writ.basilica.faith",165)
    save_attempt()
    return true

func basilica_supplies() -> bool:
    if not record_event("basilica.emergency_supplies", "finite_pickup", {"source":"one staffed defence ration, Flood Basilica"}):return false
    state["spare_ammo"] = mini(120,int(state["spare_ammo"])+24)
    state["inventory"]["consumables"]["Breath Ampoule"] = int(state["inventory"]["consumables"].get("Breath Ampoule",0))+2
    save_attempt()
    return true

func begin_public_hearing() -> bool:
    ensure_build06_state()
    if not has_attempt() or str(state.get("zone","")) != "basilica":return false
    if bool(state["hearing"]["passed"]) or bool(state["hearing"]["active"]):return false
    if not bool(state["lung"]["installed"]):return false
    var hearing: Dictionary = state["hearing"]
    hearing["attempts"] = int(hearing["attempts"])+1
    hearing["active"] = true
    hearing["integrity"] = 31
    hearing["strain_margin"] = 46
    # Hearing an optional original resonator reading grants ONE opening
    # observation; it never grants new organisms or free stamina.
    hearing["observed"] = bool(state.get("fun_slice",{}).get("basilica_resonator_used",false)) or bool(state.get("discovery_067",{}).get("basilica_notes",false)) or str(state.get("hazards_079",{}).get("basilica",{}).get("method","")) == "quiet"
    hearing["brace_guard"] = 0
    hearing["turns"] = 0
    hearing["press_count"] = 0
    hearing["phase_offset"] = (int(state["world_plan"].get("seed",0)) + int(hearing["attempts"]) - 1) % 3
    hearing["last_phase"] = ""
    hearing["last_command"] = ""
    hearing["participant"] = "Rootkin"
    hearing["accord_type"] = "loaner"
    hearing["opposition"] = "Bell Wretch signal field"
    if not record_event("basilica.hearing.start.%d" % int(hearing["attempts"]), "hearing_start", {"participant":"Rootkin", "status":"public loaner", "place":"Flood Basilica"}):return false
    hearing["transcript"].append({"attempt":hearing["attempts"],"command":"START","integrity":31,"strain_margin":46,"kind":"loaner"})
    save_attempt()
    return true

func hearing_phase() -> String:
    # Three publicly readable mechanical states. Seed changes opening phase,
    # not the player's choices; the phase can be re-derived after save/load.
    if not has_attempt(): return "rising"
    var h: Dictionary = state["hearing"]
    var index: int = (int(h.get("phase_offset",0)) + int(h.get("turns",0))) % 3
    return ["rising", "shielded", "exposed"][index]

func hearing_summary() -> String:
    if not has_attempt(): return "No active campaign."
    var h: Dictionary = state["hearing"]
    var phase: String = hearing_phase()
    var intent: String = "RISING PULSE / brace or align; an unguarded Press is risky"
    if phase == "shielded": intent = "SHIELDED SIGNAL / brute pressure is wasted; observe its rhythm"
    elif phase == "exposed": intent = "EXPOSED SHUTTER / a short window for decisive field action"
    return "FIELD %d / 31   ROOTKIN STRAIN %d / 46   ROUND %d / ATTEMPT %d\nOPPONENT: %s\nOBSERVATION %s    NEXT-PULSE GUARD %d\n\nPress: fast only when exposed. Attune: aligns across states. Brace: shields the NEXT response. Observe: records the next rhythm. Withdraw: free retry." % [int(h["integrity"]),int(h["strain_margin"]),int(h["turns"]),int(h["attempts"]),intent,"READY" if bool(h["observed"]) else "NONE",int(h["brace_guard"])]

func hearing_command(command: String) -> Dictionary:
    if not has_attempt(): return {"ok":false,"message":"No active campaign"}
    var h: Dictionary = state["hearing"]
    if not bool(h.get("active",false)) or bool(h.get("passed",false)):
        return {"ok":false,"message":"No active hearing; begin or retry at the station."}
    if command not in ["Press", "Attune", "Brace", "Observe", "Withdraw"]:
        return {"ok":false,"message":"Unknown field command."}
    var phase: String = hearing_phase()
    var integrity_loss: int = 0
    var strain_loss: int = 0
    var note: String = ""
    if command == "Withdraw":
        h["active"] = false
        note = "Authorised withdrawal: Rootkin returns to public care. A fresh loaner and a free attempt remain available."
    else:
        h["turns"] = int(h["turns"]) + 1
        match command:
            "Press":
                h["press_count"] = int(h["press_count"]) + 1
                strain_loss = 5
                if str(h["accord_type"]) == "coerced" and int(h["press_count"]) % 3 == 0:
                    h["refusals"] = int(h["refusals"]) + 1
                    note = "The participant refuses a compelled unsafe instruction."
                elif phase == "exposed":
                    integrity_loss = 13
                    note = "The exposed shutter is displaced cleanly."
                elif phase == "shielded":
                    integrity_loss = 1
                    strain_loss += 4
                    note = "Pressure rebounds off the shielded signal."
                else:
                    integrity_loss = 1
                    strain_loss += 2
                    note = "The rising field pushes back against raw pressure."
            "Attune":
                # Build 08.9 balance: Attune is the steady tool in rising/shielded
                # phases; Press owns the exposed phase; repeating the same interval
                # tires the participant. Repeating any single command now fails.
                integrity_loss = 5 if phase == "exposed" else (5 if phase == "shielded" else 6)
                integrity_loss += 3 if bool(h["observed"]) else 0
                strain_loss = 4 + (2 if str(h.get("last_command","")) == "Attune" else 0)
                h["observed"] = false
                note = "Rootkin aligns a recorded interval, preserving agency and field control."
            "Brace":
                strain_loss = 2
                note = "Rootkin braces for the NEXT opponent response."
            "Observe":
                strain_loss = 2
                if not bool(h["observed"]):
                    integrity_loss = 3
                    h["observed"] = true
                    note = "Ninth records the signal rhythm for one subsequent Attune."
                else:
                    note = "The rhythm is already documented; no second evidence bonus is minted."
        var guard_before: int = int(h["brace_guard"])
        h["integrity"] = maxi(0,int(h["integrity"])-integrity_loss)
        var backlash: int = 6 if phase == "rising" else (6 if phase == "shielded" else 1)
        if command == "Brace":
            h["brace_guard"] = 8
        else:
            h["brace_guard"] = 0
        backlash = maxi(0,backlash-guard_before)
        h["strain_margin"] = maxi(0,int(h["strain_margin"])-strain_loss-backlash)
        h["last_phase"] = phase
        h["last_command"] = command
        if int(h["integrity"]) <= 0:
            h["passed"] = true
            h["active"] = false
            note += " Field interference safely cleared; no ownership changes."
        elif int(h["strain_margin"]) <= 0:
            h["active"] = false
            note += " Rootkin is exhausted. Withdraw, then retry with a fresh voluntary public loaner."
    var event_id: String = "basilica.hearing.%d.%d.%s" % [int(h["attempts"]),int(h["turns"]),command.to_lower()]
    if not record_event(event_id,"hearing_command",{"command":command,"phase":phase,"integrity":int(h["integrity"]),"strain_margin":int(h["strain_margin"]),"participant":"Rootkin"}):
        return {"ok":false,"message":"Command already recorded."}
    h["transcript"].append({"attempt":h["attempts"],"command":command,"phase":phase,"integrity":h["integrity"],"strain_margin":h["strain_margin"],"note":note})
    if bool(h["passed"]): award_xp_once("basilica.civic_hearing",110)
    save_attempt()
    return {"ok":true,"message":note,"phase":phase,"passed":bool(h["passed"]),"active":bool(h["active"])}

func take_damage(amount: int) -> void:
    if not has_attempt():return
    if amount >= 15 and perk_ready_in_district("F3"):
        spend_district_perk("F3")
        amount = maxi(0, amount - 30)
    if int(state["health"]) - amount <= 0 and perk_ready_in_district("R3"):
        spend_district_perk("R3")
        amount = int(state["health"]) - 1
    state["health"] = maxi(0, int(state["health"])-amount)
    state_changed.emit()
    if int(state["health"]) <= 0:
        fail_attempt("Combat injury in " + str(state.get("zone","hearth")), true)

func heal_ampoule() -> bool:
    if not has_attempt():return false
    var inv: Dictionary = state["inventory"]
    var available := int(inv["consumables"].get("Breath Ampoule",0))
    if available <= 0:return false
    inv["consumables"]["Breath Ampoule"] = available-1
    state["health"] = mini(max_health(),int(state["health"])+35)
    state["breath"] = mini(max_breath(),int(state["breath"])+24)
    state_changed.emit()
    return true

func ammo_pickup() -> bool:
    if not record_event("hearth.mandatory_ammo", "finite_pickup", {"source":"emergency locker"}):return false
    state["spare_ammo"] = mini(120, int(state["spare_ammo"])+24)
    state["inventory"]["consumables"]["Breath Ampoule"] = int(state["inventory"]["consumables"].get("Breath Ampoule",0))+2
    save_attempt()
    return true

# Weapon visuals and finite ammunition added in graphics build 06.4.
# Existing attempts retain the original Covenant magazine/reserve values.
func ensure_weapon_state() -> void:
    if not has_attempt():return
    if not state.has("weapon_state") or not (state["weapon_state"] is Dictionary):
        var legacy_choir: bool = weapon_owned("choir")
        state["weapon_state"] = {"equipped":"covenant", "magazines":{"coil":0,"nail":0,"choir":12 if legacy_choir else 0}, "reserves":{"coil":0,"nail":0,"choir":12 if legacy_choir else 0}, "nail_heat":0.0}
    var info: Dictionary = state["weapon_state"]
    if not info.has("magazines") or not (info["magazines"] is Dictionary):info["magazines"]={"coil":0,"nail":0,"choir":0}
    if not info.has("reserves") or not (info["reserves"] is Dictionary):info["reserves"]={"coil":0,"nail":0,"choir":0}
    if not info.has("nail_heat"):info["nail_heat"]=0.0
    if not info.has("equipped"):info["equipped"]="covenant"

func weapon_owned(id: String) -> bool:
    if not has_attempt():return false
    var labels := {"covenant":"wp_covenant_pistol","coil":"wp_coil_shotgun","nail":"wp_nail_storm","choir":"wp_choirbreaker"}
    if not labels.has(id):return false
    for entry in state["inventory"].get("weapons",[]):
        if str(entry.get("definition_id",""))==str(labels[id]):return true
    return false

func equipped_weapon() -> String:
    if not has_attempt():return "covenant"
    ensure_weapon_state()
    var id: String = str(state["weapon_state"].get("equipped","covenant"))
    return id if weapon_owned(id) else "covenant"

func equip_weapon(id: String) -> bool:
    if not weapon_owned(id):return false
    ensure_weapon_state()
    state["weapon_state"]["equipped"]=id
    state_changed.emit()
    return true

func weapon_mag(id: String) -> int:
    ensure_weapon_state()
    if not has_attempt():return 0
    return int(state["magazine"]) if id=="covenant" else int(state["weapon_state"]["magazines"].get(id,0))

func weapon_reserve(id: String) -> int:
    ensure_weapon_state()
    if not has_attempt():return 0
    return int(state["spare_ammo"]) if id=="covenant" else int(state["weapon_state"]["reserves"].get(id,0))

func consume_weapon_round(id: String) -> bool:
    if not has_attempt() or not weapon_owned(id):return false
    ensure_weapon_state()
    if id=="covenant":return fire_ammo()
    if weapon_mag(id)<=0:return false
    state["weapon_state"]["magazines"][id]=weapon_mag(id)-1
    state_changed.emit()
    return true

func refill_weapon_mag(id: String, max_mag: int) -> bool:
    if not has_attempt() or not weapon_owned(id):return false
    ensure_weapon_state()
    if id=="covenant":return reload_pistol()
    var amount: int = mini(max_mag-weapon_mag(id), weapon_reserve(id))
    if amount<=0:return false
    state["weapon_state"]["magazines"][id]=weapon_mag(id)+amount
    state["weapon_state"]["reserves"][id]=weapon_reserve(id)-amount
    state_changed.emit()
    return true

func issue_sootworks_tool(id: String) -> bool:
    if id not in ["coil","nail"] or not has_attempt() or str(state.get("zone",""))!="sootworks":return false
    if not bool(state.get("lung",{}).get("installed",false)):return false
    if state["event_ids"].has("sootworks.worker_tool_issue"):return false
    if not record_event("sootworks.worker_tool_issue", "finite_weapon_issue",{"selection":id,"source":"staffed worker tools register"}):return false
    ensure_weapon_state()
    var item: String = "wp_coil_shotgun" if id=="coil" else "wp_nail_storm"
    state["inventory"]["weapons"].append({"instance_id":"sootworks-tool-"+str(state["attempt_id"]),"definition_id":item})
    state["weapon_state"]["magazines"][id]=2 if id=="coil" else 60
    state["weapon_state"]["reserves"][id]=8 if id=="coil" else 60
    state["weapon_state"]["equipped"]=id
    save_attempt()
    state_changed.emit()
    return true

func fire_ammo() -> bool:
    if not has_attempt() or int(state["magazine"])<=0:return false
    state["magazine"] = int(state["magazine"])-1
    state_changed.emit()
    return true

func reload_pistol() -> bool:
    if not has_attempt():return false
    var amount := mini(6-int(state["magazine"]), int(state["spare_ammo"]))
    if amount<=0:return false
    state["magazine"] = int(state["magazine"])+amount
    state["spare_ammo"] = int(state["spare_ammo"])-amount
    state_changed.emit()
    return true

func fail_attempt(cause: String, witnessed: bool) -> void:
    if not has_attempt():return
    var event_id := "death:%s" % str(state["attempt_id"])
    record_event(event_id,"actual_death",{"cause":cause,"witnessed":witnessed})
    state["status"] = "failed"
    if witnessed:
        var zone_name: String = "Vesper"
        match str(state.get("zone","hearth")):
            "hearth": zone_name = "Hearth Nine requisitions"
            "sootworks": zone_name = "Sootworks"
            "basilica": zone_name = "Flood Basilica"
            "ashmarket": zone_name = "Ashmarket"
            "orchard": zone_name = "Glass Orchard"
            "barracks": zone_name = "Quiet Barracks"
            "core": zone_name = "the Central Archives"
            "assembly": zone_name = "the Public Assembly"
            "lift": zone_name = "the Freight Lift"
        var death_record := {"attempt_id":str(state["attempt_id"]),"site":zone_name, "cause":cause}
        profile["failed_deaths"].append(death_record)
        state["nix_archived_failures"].append(death_record)
    save_profile()
    save_attempt()
    attempt_failed.emit()
    state_changed.emit()

func have_recorded_death() -> bool:
    return has_attempt() and not state.get("nix_archived_failures",[]).is_empty()

func intro_text() -> String:
    if have_recorded_death():
        var last: Dictionary = state["nix_archived_failures"].back()
        return "NIX / ARCHIVE SPOOL: I have a witnessed record of your failure at %s. That was a previous attempt. This one is new." % str(last.get("site", "the ward"))
    return "NIX / ARCHIVE SPOOL: I have the printer number. It does not tell me whom you used to be."

func save_profile() -> bool:
    return write_validated_json(PROFILE_PATH,profile)

func load_profile() -> void:
    var loaded = read_json(PROFILE_PATH)
    if loaded is Dictionary and loaded.has("failed_deaths") and loaded["failed_deaths"] is Array:
        profile = loaded

func save_attempt() -> bool:
    if state.is_empty():return false
    return write_validated_json(SAVE_PATH,state)

func has_saved_active() -> bool:
    var loaded = read_json(SAVE_PATH)
    return loaded is Dictionary and int(loaded.get("schema",0)) == 1 and loaded.get("status","") == "active"

## The last attempt on disk, if it ended in a committed, witnessed death that has
## not yet been reconstructed (starting any other attempt overwrites it).
func failed_attempt_awaiting_reprint() -> Dictionary:
    var loaded = read_json(SAVE_PATH)
    if not (loaded is Dictionary): return {}
    if int(loaded.get("schema",0)) != 1 or str(loaded.get("status","")) != "failed": return {}
    var record = loaded.get("nix_archived_failures",[])
    if not (record is Array) or record.is_empty(): return {}
    return loaded

## Loads that failed attempt so start_new(..., true) inherits Nix's witnessed record.
func load_failed_chain_for_reprint() -> bool:
    var loaded: Dictionary = failed_attempt_awaiting_reprint()
    if loaded.is_empty(): return false
    state = loaded
    return true

func load_attempt() -> bool:
    var loaded = read_json(SAVE_PATH)
    if not (loaded is Dictionary):return false
    if int(loaded.get("schema",0))!=1 or loaded.get("status","")!="active":return false
    if not loaded.has("world_plan") or not loaded.has("event_ids") or not loaded.has("attributes"):return false
    state = loaded
    ensure_build06_state()
    state_changed.emit()
    return true

func read_json(path: String):
    if not FileAccess.file_exists(path):return null
    return JSON.parse_string(FileAccess.get_file_as_string(path))

func write_validated_json(path: String, payload: Dictionary) -> bool:
    var directory := ProjectSettings.globalize_path(SAVE_DIR)
    if not DirAccess.dir_exists_absolute(directory):
        if DirAccess.make_dir_recursive_absolute(directory)!=OK:return false
    var tmp := path + ".tmp"
    var file := FileAccess.open(tmp, FileAccess.WRITE)
    if file==null:return false
    var serialized := JSON.stringify(payload,"\t")
    file.store_string(serialized)
    file.flush()
    file.close()
    var parsed = read_json(tmp)
    if not (parsed is Dictionary):return false
    if parsed.size()!=payload.size():return false
    var destination := ProjectSettings.globalize_path(path)
    var candidate := ProjectSettings.globalize_path(tmp)
    return DirAccess.rename_absolute(candidate,destination)==OK

func configure_inputs() -> void:
    # Runtime defaults; future remapping work should persist user overrides.
    var keys := {"move_forward":KEY_W,"move_back":KEY_S,"move_left":KEY_A,"move_right":KEY_D,
        "interact":KEY_E,"sprint":KEY_SHIFT,"dash":KEY_SPACE,"reload":KEY_R,"intervene":KEY_F,
        "view_docket":KEY_TAB,"quick_save":KEY_F5,"quick_load":KEY_F9}
    for action in keys:
        if not InputMap.has_action(action):InputMap.add_action(action)
        InputMap.action_erase_events(action)
        var ev := InputEventKey.new()
        ev.physical_keycode = int(keys[action])
        InputMap.action_add_event(action,ev)
    if not InputMap.has_action("fire"):InputMap.add_action("fire")
    InputMap.action_erase_events("fire")
    var click := InputEventMouseButton.new()
    click.button_index=MOUSE_BUTTON_LEFT
    InputMap.action_add_event("fire",click)
    var right_click := InputEventMouseButton.new()
    right_click.button_index = MOUSE_BUTTON_RIGHT
    InputMap.action_add_event("intervene",right_click)

# ---- BUILD 06.5 / HEARTH NINE SHORT OPENING ----
func intro_stage() -> String:
    if not has_attempt(): return "stabilised"
    return str(state.get("intro",{}).get("stage","stabilised"))

func wake_reprint_relay() -> bool:
    if not has_attempt() or str(state.get("zone","")) != "hearth" or intro_stage() != "unwoken":return false
    if not record_event("hearth.reprint_relay_woken","opening_alarm",{"source":"intake pressure relay","witness":"Nix receiver"}):return false
    state["intro"]["stage"] = "alarm"
    state["intro"]["alarm_raised"] = true
    state["actors"]["sentry"]["hostile"] = true
    save_attempt()
    return true

func record_intake_sentry_defeat() -> bool:
    if not has_attempt() or intro_stage() != "alarm":return false
    if not record_event("hearth.intake_sentry_stopped","small_combat",{"actor":"filter crawler","witness":"Nix receiver"}):return false
    state["intro"]["stage"] = "cleared"
    state["intro"]["sentry_defeated"] = true
    state["actors"]["sentry"]["hp"] = 0
    state["actors"]["sentry"]["alive"] = false
    award_xp_once("hearth.intake_crawler",12)
    save_attempt()
    return true

func stabilise_intake_valve() -> bool:
    if not has_attempt() or str(state.get("zone","")) != "hearth" or intro_stage() != "cleared":return false
    if not record_event("hearth.intake_seal_stable","opening_repair",{"source":"manual airlock wheel","witness":"Nix receiver"}):return false
    state["intro"]["stage"] = "stabilised"
    state["intro"]["valve_open"] = true
    award_xp_once("hearth.intake_repair",8)
    save_attempt()
    return true

# ---- LEVEL 3 AND 5 ATTRIBUTE CHOICES / V6 CONTRACT ----
# This preview does not implement the entire 18-perk tree. It does implement
# the attribute choices needed for an honest Speech 7 Ashmarket route.
func sync_attribute_milestones_075() -> void:
    if state.is_empty(): return
    if not state.has("unspent_attribute_points"):
        state["unspent_attribute_points"] = 0
    if not state.has("attribute_milestones_075"):
        state["attribute_milestones_075"] = []
    for level_mark in [3,5]:
        if int(state.get("level",1)) >= level_mark and not state["attribute_milestones_075"].has(level_mark):
            state["attribute_milestones_075"].append(level_mark)
            state["unspent_attribute_points"] = int(state["unspent_attribute_points"])+1

func choose_attribute_075(stat_name: String) -> bool:
    if not has_attempt() or not PRESETS["Witness"].has(stat_name): return false
    sync_attribute_milestones_075()
    if int(state["unspent_attribute_points"]) <= 0 or int(state["attributes"].get(stat_name,0)) >= 10: return false
    # The source is the finite level-up point, not extra XP or a resource.
    var next_index: int = int(state["attribute_milestones_075"].size())-int(state["unspent_attribute_points"])+1
    if not record_event("rpg.attribute_choice_075.%s" % next_index, "level_attribute_allocation", {"stat":stat_name,"value":int(state["attributes"][stat_name])+1}): return false
    var health_cap_before: int = max_health()
    var breath_cap_before: int = max_breath()
    state["attributes"][stat_name] = int(state["attributes"][stat_name])+1
    state["unspent_attribute_points"] = int(state["unspent_attribute_points"])-1
    # A higher cap also raises current HP/Breath by the same amount.
    state["health"] = int(state["health"]) + maxi(0, max_health() - health_cap_before)
    state["breath"] = int(state["breath"]) + maxi(0, max_breath() - breath_cap_before)
    state_changed.emit()
    save_attempt()
    return true

# ---- BUILD 07.5 / ASHMARKET TRADE OFFICE ----
# A third *physically playable* Writ. Does NOT imply finished campaign endings.
# Migration is additive to schema 1; older active saves remain valid.
func ensure_build075_state() -> void:
    if state.is_empty(): return
    if not state["zone_positions"].has("ashmarket"):
        state["zone_positions"]["ashmarket"] = [-21.0,0.15,9.0]
    if not state.has("trade"):
        state["trade"] = {}
    var trade: Dictionary = state["trade"]
    var trade_defaults: Dictionary = {"method":"", "duplicate_contracts":false, "buyer_testimony":false,
        "coalition_recorded":false, "counting_lock_isolated":false, "collector_defeated":false,
        "intimidation_recorded":false, "rain_claim":"", "rain_records_seen":false,
        "supplies_claimed":false, "quorum_audit":false}
    for key in trade_defaults.keys():
        if not trade.has(key): trade[key] = trade_defaults[key]
    if not state["actors"].has("collector"):
        state["actors"]["collector"] = {"hp":95,"hostile":false,"alive":true,"position":[16.0,0.15,-2.5]}
    if not state["relationships"].has("Trade"):
        state["relationships"]["Trade"] = 0
    if not state["world_plan"].has("expansion_district"):
        state["world_plan"]["expansion_district"] = "Ashmarket"
    state["world_plan"]["slice_featured"] = ["Sootworks", "Flood Basilica", "Ashmarket"]
    sync_attribute_milestones_075()

func _in_ashmarket() -> bool:
    return has_attempt() and str(state.get("zone","")) == "ashmarket" and bool(state["lung"].get("installed",false))

func record_market_contracts() -> bool:
    if not _in_ashmarket() or bool(state["trade"]["duplicate_contracts"]): return false
    if not record_event("ashmarket.duplicate_contracts", "original_evidence", {"source":"two physical bonded contracts", "claim":"same identity was sold twice"}): return false
    state["trade"]["duplicate_contracts"] = true
    award_xp_once("ashmarket.contract_evidence",25)
    save_attempt()
    return true

func record_market_testimony() -> bool:
    if not _in_ashmarket() or bool(state["trade"]["buyer_testimony"]): return false
    if not record_event("ashmarket.independent_buyers", "witness_statement", {"source":"independent buyer and porter testimony"}): return false
    state["trade"]["buyer_testimony"] = true
    award_xp_once("ashmarket.buyer_testimony",20)
    save_attempt()
    return true

func convene_market_coalition() -> bool:
    if not _in_ashmarket() or bool(state["trade"]["coalition_recorded"]): return false
    if not bool(state["trade"]["duplicate_contracts"]) or not bool(state["trade"]["buyer_testimony"]): return false
    if not record_event("ashmarket.buyers_coalition", "public_coalition", {"source":"duplicate originals + independent public witnesses","scope":"buyer power, not automatic market abolition"}): return false
    state["trade"]["coalition_recorded"] = true
    award_xp_once("ashmarket.coalition",35)
    save_attempt()
    return true

func isolate_market_counting_lock() -> bool:
    if not _in_ashmarket() or stat("Tech") < 5 or bool(state["trade"]["counting_lock_isolated"]): return false
    if int(state["resources"].get("Energy",0)) < 2 or int(state["resources"].get("Labour",0)) < 1: return false
    if not record_event("ashmarket.counting_lock_isolated", "finite_machine_isolation", {"source":"bonded token press", "doors":"released without deleting contracts"}): return false
    state["trade"]["counting_lock_isolated"] = true
    state["resources"]["Energy"] = int(state["resources"]["Energy"])-2
    state["resources"]["Labour"] = int(state["resources"]["Labour"])-1
    state["ledger"].append({"event":"ashmarket.counting_lock_isolated", "source":"physical counting actuator / public crew", "Energy":-2, "Labour":-1})
    _careful_isolation_refund_089("ashmarket.counting_lock")
    award_xp_once("ashmarket.counting_lock",35)
    save_attempt()
    return true

func intimidate_market_collector() -> bool:
    if not _in_ashmarket() or stat("Force") < 6 or bool(state["trade"]["intimidation_recorded"]): return false
    if not bool(state["actors"]["collector"].get("alive",true)): return false
    if not record_event("ashmarket.collector_intimidated", "public_threat", {"source":"witnessed coercion","consequence":"office security retaliates"}): return false
    state["trade"]["intimidation_recorded"] = true
    state["relationships"]["Trade"] = maxi(-3,int(state["relationships"].get("Trade",0))-2)
    save_attempt()
    return true

func grant_trade_writ(method: String) -> bool:
    if not _in_ashmarket() or state["writs"].has("qobj_writ_of_trade"): return false
    match method:
        "coalition":
            var coalition: Dictionary = coalition_check()
            if not bool(coalition["ok"]) or not bool(state["actors"]["collector"].get("alive",true)): return false
            if str(coalition.get("perk","")) == "S1": spend_district_perk("S1")
        "sabotage":
            if not bool(state["trade"]["counting_lock_isolated"]): return false
        "intimidation":
            if not bool(state["trade"]["intimidation_recorded"]): return false
        "registry":
            if not bool(state["trade"]["collector_defeated"]): return false
        _:
            return false
    if not record_event("ashmarket.trade_writ.transferred", "writ_transfer", {"office":"Trade","method":method,"object_id":"qobj_writ_of_trade","source":"public emergency registry"}): return false
    state["writs"].append("qobj_writ_of_trade")
    state["trade"]["method"] = method
    if method == "coalition": state["relationships"]["Trade"] = maxi(1,int(state["relationships"].get("Trade",0)))
    award_xp_once("writ.ashmarket.trade",165)
    save_attempt()
    return true

func record_market_rain_reading() -> bool:
    if not _in_ashmarket() or bool(state["trade"]["rain_records_seen"]): return false
    if not record_event("ashmarket.rain_claim_original", "original_evidence", {"source":"physical water allotment dial + signed tariff"}): return false
    state["trade"]["rain_records_seen"] = true
    save_attempt()
    return true

func resolve_market_rain(outcome: String) -> bool:
    if not _in_ashmarket() or str(state["trade"]["rain_claim"]) != "" or not bool(state["trade"]["rain_records_seen"]): return false
    if outcome not in ["open_tank","take_cut"]: return false
    # The cistern is already full; no clean water is conjured. Public release
    # consumes a crew shift and valve power. Taking a fee does not mint money.
    if outcome == "open_tank" and (int(state["resources"].get("Labour",0)) < 2 or int(state["resources"].get("Energy",0)) < 1): return false
    if not record_event("ashmarket.price_of_rain", "side_quest_decision", {"outcome":outcome,"source":"one existing water cistern"}): return false
    state["trade"]["rain_claim"] = outcome
    if outcome == "open_tank":
        state["resources"]["Labour"] = int(state["resources"]["Labour"])-2
        state["resources"]["Energy"] = int(state["resources"]["Energy"])-1
        state["ledger"].append({"event":"ashmarket.price_of_rain","source":"public valve crew + existing clean water", "Labour":-2,"Energy":-1})
        state["relationships"]["Trade"] = maxi(1,int(state["relationships"].get("Trade",0)))
    else:
        state["relationships"]["Trade"] = maxi(-2,int(state["relationships"].get("Trade",0))-1)
        state["ledger"].append({"event":"ashmarket.price_of_rain", "source":"private brokerage of unchanged water stock", "Energy":0,"Air":0})
    award_xp_once("ashmarket.price_of_rain",25)
    save_attempt()
    return true

func claim_market_emergency_lot() -> bool:
    if not _in_ashmarket() or bool(state["trade"]["supplies_claimed"]): return false
    if not record_event("ashmarket.one_public_defence_lot", "finite_pickup", {"source":"one sealed market emergency store"}): return false
    state["trade"]["supplies_claimed"] = true
    state["spare_ammo"] = mini(120,int(state["spare_ammo"])+18)
    state["inventory"]["consumables"]["Breath Ampoule"] = int(state["inventory"]["consumables"].get("Breath Ampoule",0))+1
    state["ledger"].append({"event":"ashmarket.one_public_defence_lot","source":"18 physical Ledger Slugs and one sealed Breath Ampoule"})
    save_attempt()
    return true

const FOUNDING_WRIT_IDS: Array = ["qobj_writ_of_labour", "qobj_writ_of_faith", "qobj_writ_of_trade", "qobj_writ_of_growth", "qobj_writ_of_defence"]

func founding_writs_recorded_077() -> Array:
    if not has_attempt(): return []
    var originals: Array = []
    for id in FOUNDING_WRIT_IDS:
        if state["writs"].has(id) and not originals.has(id): originals.append(id)
    return originals

func can_register_three_writ_quorum() -> bool:
    return has_attempt() and bool(state["lung"].get("installed",false)) and bool(state["hearing"].get("passed",false)) and founding_writs_recorded_077().size() >= 3

func register_three_writ_quorum() -> bool:
    if not can_register_three_writ_quorum() or bool(state["trade"].get("quorum_audit",false)) or str(state.get("zone","")) != "hearth": return false
    var originals: Array = founding_writs_recorded_077()
    if not record_event("quorum.three_writs_verified_075", "quorum_verification", {"physical_writs":originals.slice(0,3), "campaign_complete":false, "unique_offices_required":3}): return false
    state["trade"]["quorum_audit"] = true
    award_xp_once("quorum.three_writs_verified",35)
    save_attempt()
    return true

# ---- TWO-WRIT VERTICAL SLICE / NO CANON FINALE REPLACEMENT ----
func can_enter_slice_lift() -> bool:
    return has_attempt() and bool(state["lung"]["installed"]) and state["writs"].has("qobj_writ_of_labour") and state["writs"].has("qobj_writ_of_faith") and bool(state["hearing"].get("passed",false))

func visit_slice_lift() -> bool:
    if not can_enter_slice_lift():return false
    if not state["slice_finale"]["entered"]:
        record_event("slice.freight_lift_entered","slice_access",{"writs":2,"not_full_game":true})
        state["slice_finale"]["entered"] = true
    state["zone"]="lift"
    state["player_pos"]=[-9.0,0.15,10.0]
    state["zone_positions"]["lift"] = state["player_pos"].duplicate()
    save_attempt()
    return true

func record_eddas_petition() -> bool:
    if not has_attempt() or str(state.get("zone","")) != "lift":return false
    if bool(state["slice_finale"]["petition_seen"]):return false
    if not record_event("slice.edda.original_petition","evidence",{"source":"voluntary-risk petition","custodian":"Canon Edda"}):return false
    state["slice_finale"]["petition_seen"] = true
    award_xp_once("slice.petition_evidence",20)
    save_attempt()
    return true

func resolve_slice(outcome: String) -> bool:
    if not can_enter_slice_lift() or str(state.get("zone","")) != "lift" or bool(state["slice_finale"]["resolved"]):return false
    var evidence: bool = bool(state["slice_finale"]["petition_seen"])
    if outcome == "public_mandate" and not evidence:return false
    if outcome == "apparatus_shutdown" and not bool(state["slice_finale"]["apparatus_defeated"]):return false
    if outcome not in ["public_mandate","apparatus_shutdown","coercive_continuity"]:return false
    # Every trial resolution has a finite technical and staffing price.
    var delta: Dictionary = {"Energy":-1,"Labour":-2} if outcome == "public_mandate" else ({"Energy":-2,"Labour":-3} if outcome == "apparatus_shutdown" else {"Correction":-2,"Labour":-1})
    for resource_name in delta.keys():
        if int(state["resources"].get(resource_name,0)) < -int(delta[resource_name]):return false
    if not record_event("slice.edda_resolution","slice_card",{"outcome":outcome,"development_slice":true}):return false
    for resource_name in delta.keys():
        state["resources"][resource_name] = int(state["resources"].get(resource_name,0)) + int(delta[resource_name])
    var record: Dictionary = {"event":"slice.edda_resolution","source":"finite triage handover staffing and machine pressure"}
    for resource_name in delta.keys():record[resource_name] = delta[resource_name]
    state["ledger"].append(record)
    state["slice_finale"]["resolved"] = true
    state["slice_finale"]["outcome"] = outcome
    award_xp_once("slice.edda_resolution",35)
    save_attempt()
    return true

# ---- BUILD 06.8 NEW ENEMIES / SAVE MIGRATION ----
func ensure_enemy_roster_068_state() -> void:
    if not has_attempt(): return
    if not state.has("enemy_068"):
        state["enemy_068"] = {"version":1,"zone_selection":{}}
    if not state["enemy_068"].has("zone_selection"):
        state["enemy_068"]["zone_selection"] = {}
    for id in EnemyRoster068.combat_types():
        var spec: Dictionary = EnemyRoster068.spec(str(id))
        if int(spec.get("rank",0)) <= 0: continue
        if not state["actors"].has(id):
            state["actors"][id] = {"hp":int(spec["hp"]),"alive":true,"hostile":false,"position":spec["pos"].duplicate()}
        else:
            var saved: Dictionary = state["actors"][id]
            if not saved.has("hp"): saved["hp"] = int(spec["hp"])
            if not saved.has("alive"): saved["alive"] = true
            if not saved.has("hostile"): saved["hostile"] = false
            if not saved.has("position"): saved["position"] = spec["pos"].duplicate()

func selected_enemy_068(zone: String) -> Array:
    # Fixed for this attempt, stable across transfers and save/reload. Max 2
    # optional enemies per district so first-person spaces remain readable.
    ensure_enemy_roster_068_state()
    if not has_attempt(): return []
    var saved: Dictionary = state["enemy_068"]["zone_selection"]
    if saved.has(zone): return saved[zone]
    var candidates: Array = EnemyRoster068.optional_types(zone)
    var selected: Array = []
    if zone == "lift":
        selected = candidates.duplicate()
    elif not candidates.is_empty():
        var seed: int = int(state.get("world_plan",{}).get("seed",0))
        var offset: int = abs(seed) % candidates.size()
        selected.append(candidates[offset])
        if candidates.size() > 1:
            selected.append(candidates[(offset+1)%candidates.size()])
    saved[zone] = selected.duplicate()
    return selected

# ---- BUILD 07.6 / FULL THREE-WRIT CORE ARCHIVES ----
# Not the two-Writ development-slice Edda room. The core stores independent
# architect records and respects the one WorldPlan-selected Custodian.
# All new values are additive for schema-1 active saves.
func ensure_build076_state() -> void:
    if state.is_empty(): return
    if not state["zone_positions"].has("core"):
        state["zone_positions"]["core"] = [-24.0,0.15,17.0]
    if not state.has("core"): state["core"] = {}
    var core: Dictionary = state["core"]
    var defaults: Dictionary = {"entered":false,"order_read":false,"objection_heard":false,
        "rail_read":false,"excluded_wards":false,"voluntary_petition":false,
        "independent_radio":false,"safety_bus_prepared":false,"cipher_copied":false,
        "actuator_disabled":false,"custodian_method":"","custodian_fate":"",
        "rail_repaired":false,"rail_capacity":24,"boarding_policy":""}
    for key in defaults:
        if not core.has(key): core[key] = defaults[key]
    if not state["actors"].has("core_actuator"):
        state["actors"]["core_actuator"] = {"hp":210,"hostile":false,"alive":true,"position":[8.0,0.15,-11.0]}
    if not state["relationships"].has("Central Archive"):
        state["relationships"]["Central Archive"] = 0

func core_custodian() -> String:
    if not has_attempt(): return ""
    return str(state["world_plan"].get("custodian","Canon Edda"))

func can_enter_core_076() -> bool:
    # One three-office legal quorum; the two-Writ test mode is never counted.
    return has_attempt() and bool(state.get("trade",{}).get("quorum_audit",false)) and can_register_three_writ_quorum()

func visit_core_076() -> bool:
    if not can_enter_core_076(): return false
    if not bool(state["core"].get("entered",false)):
        if not record_event("core.freight_lift_opened_076", "physical_three_writ_lift", {"writ_count":3,"hearing":"passed","architect_records":"not yet inspected"}): return false
        state["core"]["entered"] = true
    state["zone"] = "core"
    state["player_pos"] = [-24.0,0.15,17.0]
    state["zone_positions"]["core"] = state["player_pos"].duplicate()
    state["yaw"] = 0.0
    state["pitch"] = 0.0
    save_attempt()
    return true

func record_core_document_076(document: String) -> bool:
    if not has_attempt() or str(state.get("zone","")) != "core": return false
    var index: Dictionary = {
        "order":{"key":"order_read","source":"original physically signed conscription order"},
        "objection":{"key":"objection_heard","source":"mechanically preserved architect objection spool"},
        "rail":{"key":"rail_read","source":"emergency rail charter with real, insufficient carriage capacity"},
        "excluded":{"key":"excluded_wards","source":"individually named unregistered casualty figures"},
        "petition":{"key":"voluntary_petition","source":"real, revocable patient-risk petition"},
        "radio":{"key":"independent_radio","source":"unused independent gate radio plan"}}
    if not index.has(document): return false
    var spec: Dictionary = index[document]
    var flag: String = str(spec["key"])
    if bool(state["core"].get(flag,false)): return false
    # The targeted Custodian proof is not a substitute for the two core
    # architect signatures; none is forged from Nix's limited knowledge.
    if not record_event("core.source_%s_076" % document,"independent_analogue_evidence",{"source":spec["source"],"custodian":core_custodian()}): return false
    state["core"][flag] = true
    award_xp_once("core.document.%s" % document,15 if document in ["order","objection","rail"] else 10)
    save_attempt()
    return true

func core_main_records_complete() -> bool:
    if not has_attempt(): return false
    var core: Dictionary = state.get("core",{})
    return bool(core.get("order_read",false)) and bool(core.get("objection_heard",false)) and bool(core.get("rail_read",false))

func core_target_evidence() -> String:
    match core_custodian():
        "Canon Edda": return "voluntary_petition"
        "Marshal Voss": return "independent_radio"
        "Archivist Latch": return "excluded_wards"
    return ""

func prepare_core_safety_bus_076() -> bool:
    # Supplies a real containment alternative, no hidden stat/XP grind.
    if not has_attempt() or str(state.get("zone","")) != "core": return false
    if bool(state["core"].get("safety_bus_prepared",false)) or stat("Tech") < 5: return false
    if not core_main_records_complete(): return false
    if int(state["resources"].get("Energy",0)) < 3 or int(state["resources"].get("Labour",0)) < 2: return false
    if not record_event("core.staffed_safety_bus_076","finite_safety_retrofit",{"source":"existing control cables and staffed manual pump crew","Energy":-3,"Labour":-2}): return false
    state["core"]["safety_bus_prepared"] = true
    state["resources"]["Energy"] = int(state["resources"]["Energy"])-3
    state["resources"]["Labour"] = int(state["resources"]["Labour"])-2
    state["ledger"].append({"event":"core.staffed_safety_bus_076","source":"wired manual fallback and scheduled technicians","Energy":-3,"Labour":-2,"Correction":0})
    _careful_isolation_refund_089("core.safety_bus")
    award_xp_once("core.safety_bus",30)
    save_attempt()
    return true

func claim_core_cipher_076() -> bool:
    # Only ONE cipher object; Founders' Cipher is an alias, not a second item.
    if not has_attempt() or str(state.get("zone","")) != "core": return false
    if not core_main_records_complete() or bool(state["core"].get("cipher_copied",false)): return false
    if not record_event("core.governor_maintenance_cipher_076","unique_quest_item",{"object_id":"cipher","name":"Governor's Maintenance Cipher","consent_field":"blank","dawn":"not unlocked"}): return false
    state["core"]["cipher_copied"] = true
    if not state["inventory"]["relics"].has("cipher"):
        state["inventory"]["relics"].append("cipher")
    save_attempt()
    return true

func record_core_actuator_defeat_076() -> bool:
    if not has_attempt() or str(state.get("zone","")) != "core": return false
    if bool(state["core"].get("actuator_disabled",false)): return false
    if not record_event("core.executive_actuator_shutdown_076","physical_executive_equipment_disabled",{"equipment":"central actuator","custodian":core_custodian(),"person_killed":false}): return false
    state["core"]["actuator_disabled"] = true
    state["actors"]["core_actuator"]["alive"] = false
    state["actors"]["core_actuator"]["hp"] = 0
    award_xp_once("core.actuator_shutdown",35)
    save_attempt()
    return true

func resolve_core_custodian_076(method: String) -> bool:
    if not has_attempt() or str(state.get("zone","")) != "core": return false
    if str(state["core"].get("custodian_method","")) != "" or not core_main_records_complete(): return false
    var custodian: String = core_custodian()
    var evidence: String = core_target_evidence()
    var fate: String = ""
    match method:
        "tribunal":
            if evidence == "" or not bool(state["core"].get(evidence,false)): return false
            # Three independently verified offices plus mandatory public
            # hearing authorise a review; not a True Dawn assembly mandate.
            fate = "tribunal_removed"
        "abdication":
            if evidence == "" or not bool(state["core"].get(evidence,false)): return false
            if not bool(abdication_check()["ok"]): return false
            fate = "abdicated_alive"
        "containment":
            if not bool(state["core"].get("safety_bus_prepared",false)): return false
            fate = "contained_alive"
        "apparatus_shutdown":
            if not bool(state["core"].get("actuator_disabled",false)): return false
            fate = "executive_actuator_disabled"
        _:
            return false
    if not record_event("core.custodian_resolved_076","custodian_authority_resolution",{"custodian":custodian,"method":method,"fate":fate,"person_killed":false,"endings_offered":false}): return false
    state["core"]["custodian_method"] = method
    state["core"]["custodian_fate"] = fate
    # All lawful resolutions physically revoke the executive actuator's
    # command line. The machine must not continue shooting after abdication.
    state["actors"]["core_actuator"]["alive"] = false
    state["actors"]["core_actuator"]["hostile"] = false
    state["actors"]["core_actuator"]["hp"] = 0
    state["core"]["actuator_disabled"] = true
    adjust_trust_089("Central Archive", 1 if method in ["tribunal","abdication"] else 0)
    award_xp_once("core.custodian_resolved",75)
    save_attempt()
    return true

func repair_rail_carriage_076() -> bool:
    # Provisional local inspection count: 24 seats, +12 after a finite physical
    # repair. This never implies all of Vesper can be evacuated.
    if not has_attempt() or str(state.get("zone","")) != "core": return false
    if not bool(state["core"].get("rail_read",false)) or bool(state["core"].get("rail_repaired",false)): return false
    if int(state["resources"].get("Energy",0)) < 2 or int(state["resources"].get("Labour",0)) < 3: return false
    if int(state["inventory"].get("salvage",0)) < 2: return false
    if not record_event("core.spare_carriage_repair_076","finite_rail_repair",{"source":"one existing carriage chassis, 2 salvage, 3 crew shifts, 2 Energy", "seats_before":24,"seats_after":36,"passengers_boarded":0}): return false
    state["core"]["rail_repaired"] = true
    state["core"]["rail_capacity"] = 36
    state["resources"]["Energy"] = int(state["resources"]["Energy"])-2
    state["resources"]["Labour"] = int(state["resources"]["Labour"])-3
    state["inventory"]["salvage"] = int(state["inventory"]["salvage"])-2
    state["ledger"].append({"event":"core.spare_carriage_repair_076","source":"stored parts, real labour and power","Energy":-2,"Labour":-3,"Salvage":-2,"extra_rail_seats":12,"passengers_boarded":0})
    award_xp_once("core.carriage_repair",30)
    save_attempt()
    return true

func record_rail_boarding_policy_076(policy: String) -> bool:
    if not has_attempt() or str(state.get("zone","")) != "core": return false
    if not bool(state["core"].get("rail_read",false)) or str(state["core"].get("boarding_policy","")) != "": return false
    if policy not in ["patients_first","repair_crews_first","defer_public_vote"]: return false
    if not record_event("core.rail_boarding_plan_076","draft_priority_not_boarding",{"policy":policy,"available_seats":int(state["core"].get("rail_capacity",24)),"boarded":0,"cannot_override_civilian_consent":true}): return false
    state["core"]["boarding_policy"] = policy
    save_attempt()
    return true


# ---- BUILD 07.7 / GLASS ORCHARD AND QUIET BARRACKS ----
# The two optional offices have real Writ paths; any three different founding
# offices can now authenticate the core, as the Master Bible requires.
# Technical isolates and ethically costly routes never generate free resources.
func ensure_build077_state() -> void:
    if state.is_empty(): return
    ensure_build076_state()
    for entry in [{"zone":"orchard","pos":[-22.0,0.15,8.0]}, {"zone":"barracks","pos":[-22.0,0.15,8.0]}]:
        if not state["zone_positions"].has(entry["zone"]): state["zone_positions"][entry["zone"]] = entry["pos"].duplicate()
    if not state.has("growth"): state["growth"] = {}
    for key in {"method":"","sample_separated":false,"feed_line_isolated":false,"researcher_vote":false,"gardener_defeated":false,"root_seed_found":false,"supplies_claimed":false}.keys():
        if not state["growth"].has(key):
            state["growth"][key] = "" if key == "method" else false
    if not state.has("defence"): state["defence"] = {}
    for key in {"method":"","casualty_roll":false,"guard_roster":false,"platoon_vote":false,"signal_isolated":false,"commandant_defeated":false,"heat_survey_found":false,"supplies_claimed":false}.keys():
        if not state["defence"].has(key):
            state["defence"][key] = "" if key == "method" else false
    for key in ["venn","kest"]:
        if not state.has(key): state[key] = {}
        var arc: Dictionary = state[key]
        for field in ["met","evidence","investigated","aftermath"]:
            if not arc.has(field): arc[field] = false
        if not arc.has("decision"): arc["decision"] = ""
        if not arc.has("alive"): arc["alive"] = true
    for key in ["gardener","commandant"]:
        if not state["actors"].has(key):
            state["actors"][key] = {"hp":150 if key == "gardener" else 165,"alive":true,"hostile":false,"position":[15.0,0.15,0.0] if key == "gardener" else [16.0,0.15,0.0]}
    for key in ["Growth", "Defence"]:
        if not state["relationships"].has(key): state["relationships"][key] = 0
    if not state["inventory"].has("quest_items"): state["inventory"]["quest_items"] = []

func _in_office_077(office: String) -> bool:
    return has_attempt() and str(state.get("zone","")) == office and bool(state["lung"].get("installed",false))

func record_orchard_sample_077() -> bool:
    if not _in_office_077("orchard") or bool(state["growth"]["sample_separated"]): return false
    if not record_event("orchard.sample_separated_077","independent_pattern_control",{"source":"isolated fruit and control culture","forced_memory_feed":"disconnected for test"}): return false
    state["growth"]["sample_separated"] = true
    award_xp_once("orchard.sample_test",20)
    save_attempt()
    return true

func vote_orchard_researchers_077() -> bool:
    if not _in_office_077("orchard") or not bool(state["growth"]["sample_separated"]) or bool(state["growth"]["researcher_vote"]): return false
    if not record_event("orchard.researcher_vote_077","witnessed_communal_decision",{"source":"living horticultural researchers","consent":"independent and recorded"}): return false
    state["growth"]["researcher_vote"] = true
    award_xp_once("orchard.researchers",20)
    save_attempt()
    return true

func isolate_orchard_feed_077() -> bool:
    if not _in_office_077("orchard") or stat("Tech") < 5 or bool(state["growth"]["feed_line_isolated"]): return false
    if int(state["resources"].get("Energy",0)) < 2 or int(state["resources"].get("Labour",0)) < 1: return false
    if not record_event("orchard.feed_line_isolation_077","finite_machine_intervention",{"source":"salt wash and staffed irrigation isolation","Energy":-2,"Labour":-1,"Correction":0}): return false
    state["growth"]["feed_line_isolated"] = true
    state["resources"]["Energy"] = int(state["resources"]["Energy"])-2
    state["resources"]["Labour"] = int(state["resources"]["Labour"])-1
    state["ledger"].append({"event":"orchard.feed_line_isolation_077","source":"real crew and pump energy","Energy":-2,"Labour":-1,"Air":0,"Correction":0})
    _careful_isolation_refund_089("orchard.feed_isolate")
    award_xp_once("orchard.feed_isolate",25)
    save_attempt()
    return true

func mark_office_defeat_077(office: String) -> bool:
    if not _in_office_077(office) or office not in ["orchard","barracks"]: return false
    var key: String = "gardener" if office == "orchard" else "commandant"
    var field: String = "gardener_defeated" if office == "orchard" else "commandant_defeated"
    var group: String = "growth" if office == "orchard" else "defence"
    if bool(state[group].get(field,false)): return false
    if not record_event("%s.%s_actuator_defeated_077" % [office,key],"regional_security_shutdown",{"machine":key,"regional_keeper_person_killed":false}): return false
    state[group][field] = true
    state["actors"][key]["alive"] = false
    state["actors"][key]["hp"] = 0
    award_xp_once("%s.actuator_defeat" % office,35)
    save_attempt()
    return true

func grant_growth_writ_077(method: String) -> bool:
    if not _in_office_077("orchard") or state["writs"].has("qobj_writ_of_growth"): return false
    match method:
        "researchers":
            if not bool(state["growth"]["sample_separated"]) or not bool(state["growth"]["researcher_vote"]): return false
        "isolation":
            if not bool(state["growth"]["feed_line_isolated"]): return false
        "registry":
            if not bool(state["growth"]["gardener_defeated"]): return false
        _: return false
    if not record_event("orchard.growth_writ_transferred_077","writ_transfer",{"office":"Growth","object_id":"qobj_writ_of_growth","method":method,"source":"public nursery registry"}): return false
    state["writs"].append("qobj_writ_of_growth")
    state["growth"]["method"] = method
    adjust_trust_089("Growth", 1 if method == "researchers" else (0 if method == "isolation" else -1))
    award_xp_once("writ.orchard.growth",165)
    save_attempt()
    return true

func record_barracks_roll_077() -> bool:
    if not _in_office_077("barracks") or bool(state["defence"]["casualty_roll"]): return false
    if not record_event("barracks.original_casualty_roll_077","original_analogue_testimony",{"source":"named soldiers written before identity erasure"}): return false
    state["defence"]["casualty_roll"] = true
    award_xp_once("barracks.casualty_roll",20)
    save_attempt()
    return true

func record_guard_roster_077() -> bool:
    if not _in_office_077("barracks") or bool(state["defence"]["guard_roster"]): return false
    if not record_event("barracks.staffed_safety_roster_077","finite_guard_plan",{"source":"real independent watch officers and fixed shift coverage"}): return false
    state["defence"]["guard_roster"] = true
    award_xp_once("barracks.guard_plan",15)
    save_attempt()
    return true

func convene_barracks_platoon_077() -> bool:
    if not _in_office_077("barracks") or bool(state["defence"]["platoon_vote"]): return false
    if not bool(state["defence"]["casualty_roll"]) or not bool(state["defence"]["guard_roster"]): return false
    if not record_event("barracks.named_platoon_witness_077","public_soldiers_assembly",{"source":"analogue casualty names and real staffed gate rota"}): return false
    state["defence"]["platoon_vote"] = true
    award_xp_once("barracks.platoon_vote",25)
    save_attempt()
    return true

func isolate_barracks_signal_077() -> bool:
    if not _in_office_077("barracks") or stat("Tech") < 5 or not bool(state["defence"]["guard_roster"]) or bool(state["defence"]["signal_isolated"]): return false
    if int(state["resources"].get("Energy",0)) < 2 or int(state["resources"].get("Labour",0)) < 2: return false
    if not record_event("barracks.signal_zero_isolation_077","finite_signal_intervention",{"source":"staffed watch and obsolete order cabinet","Energy":-2,"Labour":-2}): return false
    state["defence"]["signal_isolated"] = true
    state["resources"]["Energy"] = int(state["resources"]["Energy"])-2
    state["resources"]["Labour"] = int(state["resources"]["Labour"])-2
    state["ledger"].append({"event":"barracks.signal_zero_isolation_077","source":"human guard detail and conventional electricity","Energy":-2,"Labour":-2,"Correction":0})
    _careful_isolation_refund_089("barracks.signal_isolate")
    award_xp_once("barracks.signal_isolate",25)
    save_attempt()
    return true

func grant_defence_writ_077(method: String) -> bool:
    if not _in_office_077("barracks") or state["writs"].has("qobj_writ_of_defence"): return false
    match method:
        "platoon":
            if not bool(state["defence"]["platoon_vote"]): return false
        "isolation":
            if not bool(state["defence"]["signal_isolated"]): return false
        "registry":
            if not bool(state["defence"]["commandant_defeated"]): return false
        _: return false
    if not record_event("barracks.defence_writ_transferred_077","writ_transfer",{"office":"Defence","object_id":"qobj_writ_of_defence","method":method,"source":"public command-office succession"}): return false
    state["writs"].append("qobj_writ_of_defence")
    state["defence"]["method"] = method
    adjust_trust_089("Defence", 1 if method == "platoon" else (0 if method == "isolation" else -1))
    award_xp_once("writ.barracks.defence",165)
    save_attempt()
    return true

func arc_event_077(person: String, step: String, choice: String = "") -> bool:
    # Four beats: meet -> original evidence -> investigation -> decision ->
    # witnessed aftermath. No prior-run murder is invented for Kest.
    if not has_attempt() or person not in ["venn","kest"]: return false
    var office: String = "orchard" if person == "venn" else "barracks"
    if not _in_office_077(office): return false
    var arc: Dictionary = state[person]
    if not bool(arc["alive"]): return false
    match step:
        "meet":
            if bool(arc["met"]): return false
            if not record_event("%s.meet_077" % person,"npc_meet",{"source":"living witness","no_omniscience":true}): return false
            arc["met"] = true
        "evidence":
            if not bool(arc["met"]) or bool(arc["evidence"]): return false
            if not record_event("%s.original_evidence_077" % person,"analogue_evidence",{"source":"remote staple authorisation" if person == "venn" else "original forged warrant; no prior player killing asserted"}): return false
            arc["evidence"] = true
        "investigate":
            if not bool(arc["evidence"]) or bool(arc["investigated"]): return false
            if not record_event("%s.investigation_077" % person,"independent_investigation",{"source":"nursery consent records" if person == "venn" else "consecutive historical soldier printing orders"}): return false
            arc["investigated"] = true
        "decide":
            if not bool(arc["investigated"]) or str(arc["decision"]) != "" or choice not in ["help","compromise","exploit","abandon"]: return false
            if not record_event("%s.decision_077" % person,"npc_arc_decision",{"choice":choice,"consent":"recorded with consequences"}): return false
            arc["decision"] = choice
            adjust_trust_089("Growth" if person == "venn" else "Defence", 1 if choice == "help" else (-1 if choice == "exploit" else 0))
        "aftermath":
            if str(arc["decision"]) == "" or bool(arc["aftermath"]): return false
            if not record_event("%s.aftermath_077" % person,"npc_arc_aftermath",{"decision":arc["decision"],"rewards_repeatable":false}): return false
            arc["aftermath"] = true
        _: return false
    award_xp_once("%s.%s" % [person,step],15 if step != "decide" else 25)
    save_attempt()
    return true

func claim_restoration_clue_077(item: String) -> bool:
    # Guaranteed discoverability regardless of build, NOT a free True Dawn.
    var office: String = "orchard" if item == "orchard_root_seed" else "barracks"
    var flag: String = "root_seed_found" if item == "orchard_root_seed" else "heat_survey_found"
    var group: String = "growth" if item == "orchard_root_seed" else "defence"
    if item not in ["orchard_root_seed","deep_heat_survey"] or not _in_office_077(office): return false
    if bool(state[group][flag]): return false
    if item == "orchard_root_seed" and not bool(state["growth"]["sample_separated"]): return false
    if item == "deep_heat_survey" and not bool(state["defence"]["casualty_roll"]): return false
    if not record_event("clue.%s_077" % item,"unique_physical_restoration_dossier",{"source":"autonomous botanical experiment" if item == "orchard_root_seed" else "analogue geological heat survey","not_public_mandate":true}): return false
    state[group][flag] = true
    var quest_id: String = "qobj_orchard_root_seed" if item == "orchard_root_seed" else "qobj_deep_heat_survey"
    if not state["inventory"]["quest_items"].has(quest_id): state["inventory"]["quest_items"].append(quest_id)
    award_xp_once("clue.%s" % item,20)
    save_attempt()
    return true

func claim_office_supplies_077(office: String) -> bool:
    if office not in ["orchard","barracks"] or not _in_office_077(office): return false
    var group: String = "growth" if office == "orchard" else "defence"
    if bool(state[group]["supplies_claimed"]): return false
    if not record_event("%s.one_sealed_lot_077" % office,"finite_public_supply",{"physical_stock":true,"not_repeatable":true}): return false
    state[group]["supplies_claimed"] = true
    state["inventory"]["consumables"]["Breath Ampoule"] = int(state["inventory"]["consumables"].get("Breath Ampoule",0))+1
    state["ledger"].append({"event":"%s.one_sealed_lot_077" % office,"source":"one physical ampoule, not manufactured on revisit"})
    save_attempt()
    return true



# ---- BUILD 07.8 / CIVIC ASSEMBLY, FINITE RAIL, AND TERMINAL ENDINGS ----
# A full-game assembly is NOT the existing two-Writ development trial.
# No passenger exists merely because a policy was drafted, and neither
# energy nor correction patterns are conjured by the rail launch.


func ensure_build078_state() -> void:
    if state.is_empty(): return
    ensure_build077_state()
    if not state["zone_positions"].has("assembly"):
        state["zone_positions"]["assembly"] = [-20.0,0.15,17.0]
    if not state.has("civic") or not (state["civic"] is Dictionary): state["civic"] = {}
    var c: Dictionary = state["civic"]
    var defaults: Dictionary = {"entered":false,"risk_disclosed":false,
        "petition_read":false,"votes":{},"mandate":false,"mandate_revoked":false,
        "staged_groups":{},"staged_seats":0,"seats_used":0,"passenger_manifest":[],
        "rail_state":"closed","emergency_battery_used":false,"trial_cost_paid":false,
        "ending":"","epilogue":"","finalized":false}
    for key in defaults:
        if not c.has(key): c[key] = defaults[key].duplicate(true) if defaults[key] is Dictionary or defaults[key] is Array else defaults[key]
    # Reconcile derived values rather than trusting manually edited save totals.
    var staged_total: int = 0
    for key in c["staged_groups"].keys():
        if RAIL_GROUPS_078.has(key) and bool(c["staged_groups"][key]):
            staged_total += int(RAIL_GROUPS_078[key]["seats"])
    c["staged_seats"] = mini(staged_total, int(state["core"].get("rail_capacity",24)))

func can_enter_assembly_078() -> bool:
    return has_attempt() and can_enter_core_076() and core_main_records_complete() and str(state["core"].get("custodian_method","")) != ""

func visit_assembly_078() -> bool:
    if not can_enter_assembly_078(): return false
    if not bool(state["civic"]["entered"]):
        if not record_event("assembly.public_chamber_entered_078","three_writ_civic_chamber",{"custodian_removed":true,"automatic_ending":false}): return false
        state["civic"]["entered"] = true
    state["zone"] = "assembly"
    state["player_pos"] = [-20.0,0.15,17.0]
    state["zone_positions"]["assembly"] = state["player_pos"].duplicate()
    state["yaw"] = 0.0
    state["pitch"] = 0.0
    save_attempt()
    return true

func _in_assembly_078() -> bool:
    return has_attempt() and str(state.get("zone","")) == "assembly" and bool(state.get("civic",{}).get("entered",false))

func disclose_assembly_risk_078() -> bool:
    if not _in_assembly_078() or bool(state["civic"]["risk_disclosed"]): return false
    if not core_main_records_complete(): return false
    if not record_event("assembly.full_risk_disclosure_078","independent_public_disclosure",{"false_sun":"scheduled blackouts","health":"care hours must be cut","trial":"slow and uncertain","consent":"reversible public mandate","rail":"finite passenger seats"}): return false
    state["civic"]["risk_disclosed"] = true
    save_attempt()
    return true

func verify_assembly_petition_078() -> bool:
    if not _in_assembly_078() or bool(state["civic"]["petition_read"]): return false
    if not bool(state["core"].get("voluntary_petition",false)): return false
    if not record_event("assembly.voluntary_petition_presented_078","original_patient_petition_in_public",{"source":"signed original from core archives","consent":"revoke before committing","not_unanimity":true}): return false
    state["civic"]["petition_read"] = true
    save_attempt()
    return true

func assembly_support_078(group: String) -> bool:
    if not has_attempt(): return false
    var rel: Dictionary = state["relationships"]
    match group:
        "clinic":
            return bool(state["lung"]["installed"]) and bool(state["flags"].get("allocation_record_seen",false)) and int(rel.get("Hearth Nine",0)) >= 0
        "labour":
            return state["writs"].has("qobj_writ_of_labour") and bool(state["brin"].get("alive",true)) and str(state["brin"].get("decision","")) in ["help","compromise"]
        "choir":
            return state["writs"].has("qobj_writ_of_faith") and bool(state["ossa"].get("alive",true)) and str(state["ossa"].get("decision","")) in ["help","compromise"]
        "market":
            return state["writs"].has("qobj_writ_of_trade") and bool(state.get("trade",{}).get("coalition_recorded",false)) and int(rel.get("Trade",0)) >= 0
        "growth":
            return state["writs"].has("qobj_writ_of_growth") and bool(state.get("growth",{}).get("researcher_vote",false)) and int(rel.get("Growth",0)) >= 0
        "defence":
            return state["writs"].has("qobj_writ_of_defence") and bool(state.get("defence",{}).get("platoon_vote",false)) and int(rel.get("Defence",0)) >= 0
    return false

# ---- BUILD 08.9 / KNOWN FINAL PREREQUISITES (bible 13: docket) ----
const CONSTITUENCY_NAMES_089: Dictionary = {"clinic":"Clinic (Hearth Nine)","labour":"Labour (Brin's workers)","choir":"Choir (Ossa's congregation)","market":"Market (Ashmarket buyers)","growth":"Growth (Orchard researchers)","defence":"Defence (Barracks platoon)"}

## "verified" | "open" | "closed: <reason Ninth knows>"
func constituency_status_089(group: String) -> String:
    if not has_attempt(): return "open"
    if assembly_support_078(group): return "verified"
    var rel: Dictionary = state["relationships"]
    match group:
        "clinic":
            if int(rel.get("Hearth Nine",0)) < 0: return "closed: Hearth Nine trust %d" % int(rel.get("Hearth Nine",0))
        "labour", "choir":
            var who: String = "brin" if group == "labour" else "ossa"
            var actor: Dictionary = state.get(who,{})
            var display: String = "Brin" if who == "brin" else "Ossa"
            if not bool(actor.get("alive",true)): return "closed: %s is dead" % display
            var decision: String = str(actor.get("decision",""))
            if decision != "" and not decision in ["help","compromise"]: return "closed: %s's cause was %s" % [display, "abandoned" if decision == "abandon" else "exploited"]
        "market":
            if int(rel.get("Trade",0)) < 0: return "closed: Trade trust %d" % int(rel.get("Trade",0))
            if state["writs"].has("qobj_writ_of_trade") and not bool(state.get("trade",{}).get("coalition_recorded",false)): return "closed: Trade Writ taken without the buyers' coalition"
        "growth":
            if int(rel.get("Growth",0)) < 0: return "closed: Growth trust %d" % int(rel.get("Growth",0))
            if state["writs"].has("qobj_writ_of_growth") and not bool(state.get("growth",{}).get("researcher_vote",false)): return "closed: Growth Writ taken without the researchers' vote"
        "defence":
            if int(rel.get("Defence",0)) < 0: return "closed: Defence trust %d" % int(rel.get("Defence",0))
            if state["writs"].has("qobj_writ_of_defence") and not bool(state.get("defence",{}).get("platoon_vote",false)): return "closed: Defence Writ taken without the platoon's vote"
    return "open"

func constituencies_possible_089() -> int:
    var n: int = 0
    for group in CONSTITUENCY_NAMES_089.keys():
        if not constituency_status_089(group).begins_with("closed"): n += 1
    return n

## Constituencies an action would definitely close (only those still possible).
func constituencies_closed_by_089(action: String) -> Array[String]:
    var closes: Array[String] = []
    match action:
        "brin:abandon", "brin:exploit": closes.append("labour")
        "ossa:abandon", "ossa:exploit": closes.append("choir")
        "market:intimidate", "trade:intimidation": closes.append("market")
        "trade:sabotage", "trade:registry":
            if not bool(state.get("trade",{}).get("coalition_recorded",false)): closes.append("market")
        "orchard:writ:isolation", "orchard:writ:registry":
            if not bool(state.get("growth",{}).get("researcher_vote",false)): closes.append("growth")
        "barracks:writ:isolation", "barracks:writ:registry":
            if not bool(state.get("defence",{}).get("platoon_vote",false)): closes.append("defence")
    var still_open: Array[String] = []
    for group in closes:
        if not constituency_status_089(group).begins_with("closed"): still_open.append(group)
    return still_open

## Non-empty when an action would leave fewer than the three constituencies the
## True Dawn mandate needs. Ninth is told before committing, never after.
func true_dawn_lockout_warning_089(action: String) -> String:
    if not has_attempt() or bool(state.get("civic",{}).get("mandate_revoked",false)): return ""
    var closes: Array[String] = constituencies_closed_by_089(action)
    if closes.is_empty(): return ""
    var after: int = constituencies_possible_089() - closes.size()
    if after >= 3: return ""
    var names: Array[String] = []
    for group in closes: names.append(str(CONSTITUENCY_NAMES_089[group]))
    return "This closes the %s constituency. Only %d constituenc%s could still vote for a public mandate, and True Dawn needs three. True Dawn would become impossible in this attempt. Liberation, Dominion and Crown remain open." % [", ".join(names), maxi(0, after), "y" if after == 1 else "ies"]

func record_assembly_support_078(group: String) -> bool:
    if not _in_assembly_078() or not bool(state["civic"]["risk_disclosed"]): return false
    if group not in ["clinic","labour","choir","market","growth","defence"]: return false
    if state["civic"]["votes"].has(group) or not assembly_support_078(group): return false
    if not record_event("assembly.support.%s_078" % group,"independent_consented_constituency",{"witness":group,"verified_prior_event":true,"not_proxy_by_high_speech":true}): return false
    state["civic"]["votes"][group] = true
    save_attempt()
    return true

func assembly_vote_count_078() -> int:
    if not has_attempt(): return 0
    var count: int = 0
    for key in state["civic"]["votes"].keys():
        if bool(state["civic"]["votes"][key]) and assembly_support_078(str(key)):
            count += 1
    return count

func grant_public_mandate_078() -> bool:
    if not _in_assembly_078(): return false
    if bool(state["civic"]["mandate"]) or bool(state["civic"]["mandate_revoked"]): return false
    if not bool(state["civic"]["risk_disclosed"]) or not bool(state["civic"]["petition_read"]): return false
    if assembly_vote_count_078() < 3: return false
    if not record_event("assembly.revocable_public_mandate_078","public_vote_to_authorise_trial",{"affirmative_constituencies":state["civic"]["votes"].keys().duplicate(),"minimum":3,"revoke_before_trial":true,"unanimous":false}): return false
    state["civic"]["mandate"] = true
    save_attempt()
    return true

func revoke_public_mandate_078() -> bool:
    if not _in_assembly_078() or not bool(state["civic"]["mandate"]): return false
    if not record_event("assembly.public_revocation_078","public_withdrawal_of_consent",{"no_trial_authorised":true,"mandate_prior":true}): return false
    state["civic"]["mandate"] = false
    state["civic"]["mandate_revoked"] = true
    save_attempt()
    return true

func rail_group_078(group: String) -> Dictionary:
    return RAIL_GROUPS_078.get(group,{})

func stage_rail_group_078(group: String) -> bool:
    if not _in_assembly_078() or not RAIL_GROUPS_078.has(group): return false
    if not bool(state["core"].get("rail_read",false)): return false
    if bool(state["civic"]["staged_groups"].get(group,false)): return false
    var places: int = int(RAIL_GROUPS_078[group]["seats"])
    if int(state["civic"]["staged_seats"]) + places > int(state["core"].get("rail_capacity",24)): return false
    if not record_event("rail.staged.%s.%d_078" % [group,state["events"].size()],"named_cohort_voluntary_muster_not_departure",{"count":places,"source":RAIL_GROUPS_078[group]["source"],"boarded":0,"seat_limit":int(state["core"]["rail_capacity"])}): return false
    state["civic"]["staged_groups"][group] = true
    state["civic"]["staged_seats"] = int(state["civic"]["staged_seats"]) + places
    save_attempt()
    return true


func release_rail_group_078(group: String) -> bool:
    # A group can withdraw its request before the train actually departs.
    # The occupied seats become available to another signed roster; neither
    # the rail nor the number of people in the city changes magically.
    if not _in_assembly_078() or not RAIL_GROUPS_078.has(group): return false
    if not bool(state["civic"]["staged_groups"].get(group,false)): return false
    var places: int = int(RAIL_GROUPS_078[group]["seats"])
    if not record_event("rail.withdrawal.%s.%d_078" % [group,state["events"].size()],"cohort_withdrew_before_departure",{"group":group,"released_seats":places,"boarded":0}): return false
    state["civic"]["staged_groups"][group] = false
    state["civic"]["staged_seats"] = maxi(0,int(state["civic"]["staged_seats"])-places)
    save_attempt()
    return true

func dawn_technical_prerequisites_078() -> bool:
    if not has_attempt(): return false
    return bool(state.get("growth",{}).get("root_seed_found",false)) and bool(state.get("defence",{}).get("heat_survey_found",false)) and bool(state.get("core",{}).get("cipher_copied",false)) and state["inventory"].get("relics",[]).has("cipher")

func ending_eligibility_078() -> Dictionary:
    var offered: Dictionary = {"liberation":false,"dominion":false,"crown":false,"true_dawn":false}
    var common: bool = _in_assembly_078() and can_enter_assembly_078()
    if not common: return offered
    for label in ["liberation","dominion","crown"]:
        offered[label] = true
    offered["true_dawn"] = dawn_technical_prerequisites_078() and bool(state["civic"]["mandate"]) and not bool(state["civic"]["mandate_revoked"]) and int(state["civic"]["staged_seats"]) > 0 and int(state["resources"].get("Energy",0)) >= 3 and int(state["resources"].get("Labour",0)) >= 2
    return offered

func _local_epilogue_078() -> String:
    var lines: Array[String] = []
    var npc_records: Dictionary = {"brin":"Brin Harker","ossa":"Sister Ossa","venn":"Venn-of-Glass","kest":"Kest-07"}
    for key in npc_records:
        var actor: Dictionary = state.get(key,{})
        if not bool(actor.get("alive",true)):
            lines.append("%s does not speak after their recorded death." % npc_records[key])
        elif str(actor.get("decision","")) == "help":
            lines.append("%s's recorded act of mutual aid remains in force." % npc_records[key])
        elif str(actor.get("decision","")) == "exploit":
            lines.append("The exploitation recorded in %s's case has not been erased." % npc_records[key])
    var trade: Dictionary = state.get("trade",{})
    if str(trade.get("rain_claim","")) != "":
        lines.append("Ashmarket rain allocation remains recorded as %s; the market does not reset its cistern." % str(trade["rain_claim"]))
    lines.append("Hearth Nine holds %d ward-air units; Claimant Ward holds %d. The Lung transfer did not erase that unequal distribution." % [int(state["ward_air"]["Hearth Nine"]),int(state["ward_air"]["Claimant Ward"])])
    lines.append("Conventional Energy %d and correction integrity %d remain separate limited channels." % [int(state["resources"]["Energy"]),int(state["resources"]["Correction"])])
    return "\n".join(lines)

func ending_epilogue_078() -> String:
    if str(state.get("status","")) != "completed": return ""
    return str(state.get("civic",{}).get("epilogue",""))

func complete_ending_078(kind: String) -> bool:
    if not ending_eligibility_078().get(kind,false): return false
    if bool(state["civic"]["finalized"]) or state.get("ending",null) != null: return false
    var boarded: Array = []
    var seats: int = 0
    if kind in ["liberation","true_dawn"]:
        for group in ["ward_patients","guardian_families","repair_crew","claimant_residents"]:
            if bool(state["civic"]["staged_groups"].get(group,false)):
                var count: int = int(RAIL_GROUPS_078[group]["seats"])
                seats += count
                boarded.append({"group":group,"count":count,"source":RAIL_GROUPS_078[group]["source"]})
        if seats > int(state["core"].get("rail_capacity",24)): return false
    var rail_status: String = "closed"
    var summary: String = ""
    match kind:
        "liberation":
            rail_status = "departure_open"
            summary = "LIBERATION / Gates open for the authenticated %d of %d local seats. The Engine disconnects, the false sun falls, and the unboarded residents still need shelter. The railway does not rescue all of Vesper." % [seats,int(state["core"]["rail_capacity"])]
        "dominion":
            summary = "DOMINION / Exits remain closed. Hospitals and pumps hold for now by an institutional memory tax. No rail passenger has left; comfort is real and the stolen names are not returned."
        "crown":
            summary = "THE CROWN / Ninth takes personal command and seals the exits. Each promised exception chooses another debtor as fuel. The prior Custodian's fate remains exactly as recorded."
        "true_dawn":
            rail_status = "limited_trial_departure"
            summary = "TRUE DAWN / A revocable public mandate begins a slow, uncertain boundary transition. The Heat Survey powers conventional pumps; the Root Seed supplies alternate correction patterns; one cipher guides calibration. %d local passengers depart on the limited rail. Some sectors darken and clinic schedules contract; future public oversight can still withdraw consent." % seats
        _:
            return false
    var custodian_name: String = core_custodian()
    if not record_event("campaign.ending.%s_078" % kind,"terminal_civic_settlement",{"ending":kind,"custodian":custodian_name,"custodian_method":state["core"]["custodian_method"],"custodian_fate":state["core"]["custodian_fate"],"rail_state":rail_status,"passengers":boarded.duplicate(true),"seats_used":seats,"seats_capacity":int(state["core"]["rail_capacity"]),"revocable_mandate":bool(state["civic"]["mandate"]),"terminal":true}): return false
    if kind == "true_dawn":
        state["resources"]["Energy"] = int(state["resources"]["Energy"])-3
        state["resources"]["Labour"] = int(state["resources"]["Labour"])-2
        state["ledger"].append({"event":"campaign.dawn_operating_cost_078","source":"initial trial staff and finite conventional electricity","Energy":-3,"Labour":-2,"Correction":0,"Biomass":0})
        state["civic"]["trial_cost_paid"] = true
    if kind in ["liberation","true_dawn"]:
        state["civic"]["emergency_battery_used"] = true
        state["ledger"].append({"event":"rail.emergency_launch_reserve_078","source":"one pre-existing sealed launch battery","launches":-1,"passengers_boarded":seats})
    state["civic"]["rail_state"] = rail_status
    state["civic"]["passenger_manifest"] = boarded.duplicate(true)
    state["civic"]["seats_used"] = seats
    state["civic"]["ending"] = kind
    state["civic"]["finalized"] = true
    state["ending"] = kind
    var local_report: String = _local_epilogue_078()
    state["civic"]["epilogue"] = summary + "\n\nCustodian: %s; resolution %s; fate %s.\n\n%s" % [custodian_name, str(state["core"]["custodian_method"]),str(state["core"]["custodian_fate"]),local_report]
    state["status"] = "completed"
    var entry: Dictionary = {"attempt_id":str(state["attempt_id"]),"ending":kind,"rail_seats":seats,"custodian":custodian_name,"method":str(state["core"]["custodian_method"]),"mandate":bool(state["civic"]["mandate"]),"separate_campaign":true}
    if not profile.has("completed_endings"): profile["completed_endings"] = []
    # One and only one terminal record for a completed attempt.
    var already_recorded: bool = false
    for earlier in profile["completed_endings"]:
        if str(earlier.get("attempt_id","")) == str(state["attempt_id"]): already_recorded = true
    if not already_recorded: profile["completed_endings"].append(entry)
    save_profile()
    save_attempt()
    state_changed.emit()
    return true

# --- BUILD 07.9 / PHYSICAL SERVICE HAZARDS ---
# Opt-in, one-use safety interventions; neither dialogue nor combat is gated.
# Stored in old and new attempts without reformatting the saved schema.
func ensure_build079_state() -> void:
    if state.is_empty(): return
    if not state.has("hazards_079"): state["hazards_079"] = {}
    for id in ["hearth","sootworks","basilica"]:
        if not state["hazards_079"].has(id):
            state["hazards_079"][id] = {"disabled":false,"method":""}
        else:
            var entry: Dictionary = state["hazards_079"][id]
            if not entry.has("disabled"): entry["disabled"] = false
            if not entry.has("method"): entry["method"] = ""

func shut_down_hazard_079(id: String, method: String) -> bool:
    if not has_attempt() or str(state.get("status","")) != "active": return false
    ensure_build079_state()
    if id not in ["hearth","sootworks","basilica"] or method not in ["quiet","rupture"]: return false
    if str(state.get("zone","")) != id: return false
    var entry: Dictionary = state["hazards_079"][id]
    if bool(entry.get("disabled",false)): return false
    # A planned, staffed isolation requires one safe technician shift and
    # one conventional power allocation. A destructive rupture loses two
    # power units and cannot yield the Basilica's acoustic testimony.
    var energy_cost: int = 2 if method == "rupture" else 1
    var labour_cost: int = 0 if method == "rupture" else 1
    if int(state["resources"].get("Energy",0)) < energy_cost: return false
    if int(state["resources"].get("Labour",0)) < labour_cost: return false
    var event_id: String = id + ".079.service_" + method
    if not record_event(event_id,"finite_hazard_intervention",{"zone":id,"method":method,"Energy":-energy_cost,"Labour":-labour_cost}): return false
    entry["disabled"] = true
    entry["method"] = method
    state["resources"]["Energy"] = int(state["resources"]["Energy"])-energy_cost
    state["resources"]["Labour"] = int(state["resources"]["Labour"])-labour_cost
    state["ledger"].append({"event":event_id,"source":"physical service isolation or irreversible rupture", "Energy":-energy_cost,"Labour":-labour_cost,"Correction":0})
    # Quiet Basilica signal calibration gives one useful factual observation
    # for a later free Rootkin hearing, not an owned Echoform or auto-win.
    if id == "basilica" and method == "quiet" and state.has("hearing"):
        state["hearing"]["familiarity"] = maxi(1,int(state["hearing"].get("familiarity",0)))
        if bool(state["hearing"].get("active",false)):
            state["hearing"]["observed"] = true
    state_changed.emit()
    save_attempt()
    return true
