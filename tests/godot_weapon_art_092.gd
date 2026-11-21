extends SceneTree
const Anim = preload("res://scripts/sprite_anim_092.gd")
const WEAPONS := ["covenant", "coil", "nail", "choir"]
func _initialize() -> void:
    call_deferred("_run")
func _run() -> void:
    for weapon in WEAPONS:
        var data: Dictionary = Anim.load_set(weapon, "res://assets/weapons/anim_092/")
        assert(not data.is_empty(), "Missing animation set: " + weapon)
        assert(Anim.has_state(data, "idle"), "Missing idle: " + weapon)
        assert(Anim.has_state(data, "fire"), "Missing fire: " + weapon)
        var idle: Texture2D = Anim.frame(data, "idle", 0, 0.0)
        var fire: Texture2D = Anim.frame(data, "fire", 0, 0.0)
        assert(idle is AtlasTexture and fire is AtlasTexture, "Expected atlas frames: " + weapon)
        assert((idle as AtlasTexture).region.size == Vector2(640, 400), "Bad idle cell: " + weapon)
        assert((fire as AtlasTexture).region.size == Vector2(640, 400), "Bad fire cell: " + weapon)
        var states: Dictionary = data.get("states", {})
        print("WEAPON_092_GODOT_OK %s idle=%d fire=%d" % [weapon, int(states["idle"]["frames"]), int(states["fire"]["frames"])])
    print("WEAPON_092_GODOT_ALL_OK")
    quit(0)
