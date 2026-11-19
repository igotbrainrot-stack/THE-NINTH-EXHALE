from pathlib import Path
p=Path(__file__).resolve().parents[2]/'scripts/run_state.gd'
s=p.read_text()
s=s.replace('const XP_LEVELS = [0, 100, 230, 390, 580, 800, 1050]\n','const XP_LEVELS = [0, 100, 230, 390, 580, 800, 1050]\nconst EnemyRoster068 = preload("res://scripts/enemy_roster_068.gd")\n')
s+='''
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
'''
p.write_text(s)
p=Path(__file__).resolve().parents[2]/'scripts/main.gd'
s=p.read_text()
s=s.replace('const OfficeEnforcer = preload("res://scripts/enemy.gd")\n','const OfficeEnforcer = preload("res://scripts/enemy.gd")\nconst EnemyRoster068 = preload("res://scripts/enemy_roster_068.gd")\n')
s=s.replace('var intro_sentry: CharacterBody3D\n','var intro_sentry: CharacterBody3D\nvar additional_enemies: Dictionary = {}\n')
s=s.replace('''    guard = null
    intro_sentry = null
''','''    guard = null
    intro_sentry = null
    additional_enemies.clear()
''')
s=s.replace('''    spawn_intro_sentry()
    _populate_living_wards()
''','''    spawn_intro_sentry()
    _populate_living_wards()
    _spawn_additional_enemies_068()
''')
start=s.index('func _populate_living_wards() -> void:')
s=s[:start]+'''func _spawn_additional_enemies_068() -> void:
    if not Game.has_attempt(): return
    var zone: String = str(Game.state.get("zone","hearth"))
    if zone == "hearth" and Game.intro_stage() in ["unwoken","alarm","cleared"]:
        # The opening combat remains a readable single-crawler tutorial.
        return
    for id in Game.selected_enemy_068(zone):
        var key: String = str(id)
        var spec: Dictionary = EnemyRoster068.spec(key)
        var saved: Dictionary = Game.state["actors"].get(key,{})
        if not bool(saved.get("alive",true)) or spec.is_empty(): continue
        var foe := OfficeEnforcer.new()
        foe.actor_key = key
        foe.name = str(spec["name"]).replace(" ","")
        foe.max_hp = int(spec["hp"])
        foe.hp = foe.max_hp
        foe.shot_interval = float(spec["interval"])
        foe.attack_timer = 1.25 + 0.38 * float(int(spec["rank"]) % 3)
        foe.position = Vector3(float(spec["pos"][0]),float(spec["pos"][1]),float(spec["pos"][2]))
        foe.player = player
        foe.defeated.connect(_additional_enemy_defeated.bind(key))
        foe.telegraph_started.connect(_enemy_telegraph)
        world.add_child(foe)
        additional_enemies[key] = foe

func _additional_enemy_defeated(key: String) -> void:
    if not Game.has_attempt() or not Game.state["actors"].has(key): return
    Game.state["actors"][key]["alive"] = false
    Game.state["actors"][key]["hp"] = 0
    Game.record_event("combat.068.%s" % key,"one_time_ambient_enemy_defeat",{"actor":key,"zone":str(Game.state.get("zone",""))})
    # No repeat XP, loot or Writ transfer from optional population.
    Game.save_attempt()
    additional_enemies.erase(key)
    hud.notify("SERVICE THREAT DISABLED / %s / NO REPEAT BOUNTY" % key.to_upper().replace("_"," "),2.5)

'''+s[start:]
p.write_text(s)
print('spawn + state edits complete')
