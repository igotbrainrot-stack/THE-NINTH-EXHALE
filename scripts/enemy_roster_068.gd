extends RefCounted
## Build 06.8 enemy catalogue. The JSON file is the canonical authoring source.
## No enemy kill produces farmable XP. Writ holders retain their original keys.
const FILE_PATH = "res://data/enemy_roster_068.json"
static var _entries: Dictionary = {}
static var _residents: Array = []
static func _init_catalog() -> void:
    if not _entries.is_empty(): return
    var file: FileAccess = FileAccess.open(FILE_PATH, FileAccess.READ)
    if file == null: return
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY: return
    for spec in parsed.get("combat_enemies", []):
        _entries[str(spec.get("id", ""))] = spec
    # 09.6: guaranteed residents (the Unsaid), outside the optional rotation.
    for spec in parsed.get("residents_096", []):
        _entries[str(spec.get("id", ""))] = spec
        _residents.append(spec)
static func spec(id: String) -> Dictionary:
    _init_catalog()
    return _entries.get(id,{})
static func combat_types() -> Array:
    _init_catalog()
    return _entries.keys()
static func optional_types(zone: String) -> Array:
    _init_catalog()
    var matches: Array = []
    for entry in _entries.values():
        if str(entry.get("zone", "")) == zone and int(entry.get("rank",0)) > 0:
            matches.append(str(entry["id"]))
    matches.sort()
    return matches

## 09.6: enemies that always live in a district (not one of its two optional
## slots). Each is spawned once per attempt and never respawns.
static func residents(zone: String) -> Array:
    _init_catalog()
    var out: Array = []
    for entry in _residents:
        if str(entry.get("zone", "")) == zone:
            out.append(str(entry["id"]))
    return out
