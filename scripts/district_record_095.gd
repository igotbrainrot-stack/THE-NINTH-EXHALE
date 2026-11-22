extends RefCounted
## Build 09.5 district record (after Doom's intermission tally and Dusk's
## kills/secrets screen): what Ninth did in a district, shown on its
## return-rail docket. It counts what the canon cares about (put down vs left
## standing, times spotted, the named witness, records written), not a score.
## Kept in Game.state["district_record_095"][zone]; survives saves.

const KEYS := ["seconds", "put_down", "spotted", "records"]
const WITNESS := {"sootworks": ["brin", "Brin Harker"], "basilica": ["ossa", "Sister Ossa"]}
const NAMES := {"sootworks": "SOOTWORKS", "basilica": "FLOOD BASILICA", "ashmarket": "ASHMARKET",
    "orchard": "GLASS ORCHARD", "barracks": "QUIET BARRACKS", "hearth": "HEARTH NINE"}

static func _entry(zone: String) -> Dictionary:
    if not Game.state.has("district_record_095"):
        Game.state["district_record_095"] = {}
    if not Game.state["district_record_095"].has(zone):
        Game.state["district_record_095"][zone] = {"seconds": 0.0, "put_down": 0, "spotted": 0, "records": 0}
    return Game.state["district_record_095"][zone]

## Add to a counter for the district Ninth is in now.
static func bump(key: String, amount: float = 1.0) -> void:
    if not Game.has_attempt(): return
    var zone: String = str(Game.state.get("zone", "hearth"))
    var e: Dictionary = _entry(zone)
    if key == "seconds":
        e["seconds"] = float(e.get("seconds", 0.0)) + amount
    else:
        e[key] = int(e.get(key, 0)) + int(amount)

static func get_entry(zone: String) -> Dictionary:
    if not Game.has_attempt(): return {}
    return _entry(zone)

## Enemies still standing in this district, split into office-holders and others.
static func standing(tree: SceneTree) -> Array:
    var keepers: int = 0
    var others: int = 0
    if tree == null: return [0, 0]
    for n in tree.get_nodes_in_group("hostile"):
        if not is_instance_valid(n) or int(n.get("hp")) <= 0: continue
        if float(n.get("wake_distance")) > 0.0: others += 1
        else: keepers += 1
    return [others, keepers]

static func _times(n: int) -> String:
    match n:
        0: return "never"
        1: return "once"
        2: return "twice"
        _: return "%d times" % n

## One paragraph for the return-rail docket.
static func text(zone: String, tree: SceneTree) -> String:
    if not Game.has_attempt(): return ""
    var e: Dictionary = _entry(zone)
    var left: Array = standing(tree)
    var minutes: int = int(round(float(e.get("seconds", 0.0)) / 60.0))
    var parts: Array = []
    parts.append("%d min here" % maxi(minutes, 1))
    parts.append("%d put down, %d still standing%s" % [int(e.get("put_down", 0)), int(left[0]), (" (%d office-holder%s)" % [left[1], "" if int(left[1]) == 1 else "s"]) if int(left[1]) > 0 else ""])
    parts.append("spotted %s" % _times(int(e.get("spotted", 0))))
    if WITNESS.has(zone):
        var key: String = WITNESS[zone][0]
        var who: String = WITNESS[zone][1]
        var person: Dictionary = Game.state.get(key, {})
        var status: String
        if not bool(person.get("alive", true)): status = "dead"
        elif bool(person.get("calmed_093", false)): status = "alive, calmed after a threat"
        elif Game.state.get("witness_093", {}).has(key): status = "alive, threatened"
        else: status = "alive"
        parts.append("%s %s" % [who, status])
    parts.append("%d record%s written" % [int(e.get("records", 0)), "" if int(e.get("records", 0)) == 1 else "s"])
    var line: String = "DISTRICT RECORD / %s: %s." % [str(NAMES.get(zone, zone.to_upper())), ", ".join(parts)]
    if int(e.get("spotted", 0)) == 0 and int(e.get("put_down", 0)) == 0:
        line += " No one here saw you coming, and no one fell."
    return line
