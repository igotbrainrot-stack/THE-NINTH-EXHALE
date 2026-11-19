extends RefCounted
## Build 06.8 enemy catalogue. The JSON file is the canonical authoring source.
## No enemy kill produces farmable XP. Writ holders retain their original keys.
const FILE_PATH = "res://data/enemy_roster_068.json"
static var _entries: Dictionary = {}
static func _init_catalog() -> void:
    if not _entries.is_empty(): return
    var file: FileAccess = FileAccess.open(FILE_PATH, FileAccess.READ)
    if file == null: return
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY: return
    for spec in parsed.get("combat_enemies", []):
        _entries[str(spec.get("id", ""))] = spec
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
