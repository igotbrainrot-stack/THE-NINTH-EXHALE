extends RefCounted
## Build 09.2 drop-in character animation sets (enemies and NPCs).
##
## Art lives in res://assets/sprites/anim_092/<stem>/ and is optional: an actor
## without a set keeps its 07.x/08.8 atlas. A set is:
##   <stem>.anim.json   {"cell":[w,h], "states":{"idle":{"frames":4,"fps":4,"loop":true}, ...}}
##   <stem>_<state>_<facing>.png   one horizontal strip per state and facing
## Facings use the 8-view convention (1 front ... 5 back, see
## sprite_rotations_071.gd); 0 is a universal strip used for every view. Any
## missing facing borrows the nearest painted one, so 4- or 5-facing deliveries
## work. PNGs that Godot has not imported yet are read from disk, so a delivery
## can be tested by copying files in. Spec: docs/handover/GPT_SPRITE_ANIMATION_HANDOVER_092.md

static var root_dir: String = "res://assets/sprites/anim_092/"
static var _cache: Dictionary = {}

var stem: String = ""
var cell: Vector2i = Vector2i(192, 256)
var states: Dictionary = {}        # state -> {"frames":int, "fps":float, "loop":bool, "facings":{int: Array[Texture2D]}}
var pixel_size: float = 0.0
var meta: Dictionary = {}          # the whole manifest (weapon events, notes)

static func clear_cache() -> void:
    _cache.clear()

## Returns a loaded set, or null when the actor has no 09.2 art.
static func load_set(sprite_stem: String, root: String = "") -> RefCounted:
    var base: String = root if root != "" else root_dir
    var key: String = base + sprite_stem
    if _cache.has(key):
        return _cache[key]
    var manifest_path: String = "%s%s/%s.anim.json" % [base, sprite_stem, sprite_stem]
    var result: RefCounted = null
    if FileAccess.file_exists(manifest_path):
        var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
        if parsed is Dictionary:
            var anim_set = load("res://scripts/sprite_anim_092.gd").new()
            if anim_set._build(sprite_stem, parsed, base):
                result = anim_set
    _cache[key] = result
    return result

static func _texture(path: String) -> Texture2D:
    if ResourceLoader.exists(path):
        return load(path) as Texture2D
    if FileAccess.file_exists(path):
        var img := Image.load_from_file(ProjectSettings.globalize_path(path))
        if img != null and not img.is_empty():
            return ImageTexture.create_from_image(img)
    return null

func _build(sprite_stem: String, data: Dictionary, base: String) -> bool:
    stem = sprite_stem
    meta = data
    var c: Array = data.get("cell", [192, 256])
    cell = Vector2i(int(c[0]), int(c[1]))
    pixel_size = float(data.get("pixel_size", 0.0))
    var declared: Dictionary = data.get("states", {})
    for state_name in declared.keys():
        var spec: Dictionary = declared[state_name]
        var frames: int = maxi(1, int(spec.get("frames", 1)))
        var facings: Dictionary = {}
        for facing in range(0, 9):
            var strip: Texture2D = _texture("%s%s/%s_%s_%d.png" % [base, stem, stem, state_name, facing])
            # Facing-less art (weapons, universal props) may omit the suffix.
            if strip == null and facing == 0:
                strip = _texture("%s%s/%s_%s.png" % [base, stem, stem, state_name])
            if strip == null: continue
            # Use the frames actually present if the strip is shorter than declared.
            var count: int = mini(frames, maxi(1, int(strip.get_width() / cell.x)))
            var cuts: Array[Texture2D] = []
            for i in range(count):
                var cut := AtlasTexture.new()
                cut.atlas = strip
                cut.region = Rect2(i * cell.x, 0, cell.x, cell.y)
                cuts.append(cut)
            facings[facing] = cuts
        if facings.is_empty(): continue
        states[str(state_name)] = {"frames": frames, "fps": maxf(0.1, float(spec.get("fps", 8.0))), "loop": bool(spec.get("loop", true)), "facings": facings}
    return not states.is_empty()

func has_state(state: String) -> bool:
    return states.has(state)

func duration(state: String) -> float:
    if not states.has(state): return 0.0
    var info: Dictionary = states[state]
    return float(info["frames"]) / float(info["fps"])

## The nearest painted facing to `facing` (cyclic 1..8); 0 means universal.
func resolve_facing(state: String, facing: int) -> int:
    var facings: Dictionary = states[state]["facings"]
    if facings.has(facing): return facing
    if facings.has(0): return 0
    var best: int = -1
    var best_gap: int = 99
    for f in facings.keys():
        if int(f) == 0: continue
        var gap: int = absi(int(f) - facing)
        gap = mini(gap, 8 - gap)
        # Ties prefer the view nearer the front (smaller index distance to 1).
        if gap < best_gap or (gap == best_gap and absi(int(f) - 1) < absi(best - 1)):
            best_gap = gap
            best = int(f)
    return best

## Texture for `state` seen from `facing`, `elapsed` seconds into the state.
## Looping states wrap; one-shot states hold their last frame.
func frame(state: String, facing: int, elapsed: float) -> Texture2D:
    if not states.has(state): return null
    var info: Dictionary = states[state]
    var f: int = resolve_facing(state, facing)
    if f < 0: return null
    var cuts: Array = info["facings"][f]
    var index: int = int(elapsed * float(info["fps"]))
    index = posmod(index, cuts.size()) if bool(info["loop"]) else mini(index, cuts.size() - 1)
    return cuts[index]

func frame_index(state: String, elapsed: float) -> int:
    if not states.has(state): return -1
    var info: Dictionary = states[state]
    var count: int = int(info["frames"])
    var index: int = int(elapsed * float(info["fps"]))
    return posmod(index, count) if bool(info["loop"]) else mini(index, count - 1)

## An NPC death plays where the actor stood and then stays as silent remains
## until the district unloads. Returns false (actor just vanishes, as before)
## when the stem has no death strip. Never plays a voice: dead NPCs are silent.
static func spawn_death(parent: Node, at: Vector3, sprite_stem: String, size: float) -> bool:
    var anim_set: RefCounted = load_set(sprite_stem)
    if anim_set == null or not anim_set.has_state("death") or not is_instance_valid(parent):
        return false
    var player_node := Sprite3D.new()
    player_node.name = "Remains_%s" % sprite_stem
    player_node.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    player_node.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
    player_node.shaded = false
    player_node.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
    player_node.pixel_size = anim_set.pixel_size if anim_set.pixel_size > 0.0 else size
    player_node.offset = Vector2(0, anim_set.cell.y * 0.5)
    player_node.set_script(load("res://scripts/sprite_death_player_092.gd"))
    parent.add_child(player_node)
    player_node.global_position = at
    player_node.call("play", anim_set)
    return true
