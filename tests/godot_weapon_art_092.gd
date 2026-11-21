extends SceneTree
const SpriteAnim = preload("res://scripts/sprite_anim_092.gd")
const WEAPONS := ["covenant", "coil", "nail", "choir"]
const EXPECTED_FIRE_FRAMES := {"covenant": 4, "coil": 6, "nail": 2, "choir": 5}

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    for weapon in WEAPONS:
        var anim = SpriteAnim.load_set(weapon, "res://assets/weapons/anim_092/")
        assert(anim != null, "Missing animation set: " + weapon)
        assert(anim.has_state("idle"), "Missing idle: " + weapon)
        assert(anim.has_state("fire"), "Missing fire: " + weapon)
        var idle: Texture2D = anim.frame("idle", 0, 0.0)
        var fire: Texture2D = anim.frame("fire", 0, 0.0)
        assert(idle is AtlasTexture and fire is AtlasTexture, "Expected atlas frames: " + weapon)
        assert((idle as AtlasTexture).region.size == Vector2(640, 400), "Bad idle cell: " + weapon)
        assert((fire as AtlasTexture).region.size == Vector2(640, 400), "Bad fire cell: " + weapon)
        assert(int(anim.states["idle"]["frames"]) == 4, "Bad idle frame count: " + weapon)
        assert(int(anim.states["fire"]["frames"]) == EXPECTED_FIRE_FRAMES[weapon], "Bad fire frame count: " + weapon)
        assert(anim.duration("idle") > 0.0 and anim.duration("fire") > 0.0, "Invalid animation duration: " + weapon)
        print("WEAPON_092_GODOT_OK %s idle=%d fire=%d" % [weapon, int(anim.states["idle"]["frames"]), int(anim.states["fire"]["frames"])])
    print("WEAPON_092_GODOT_ALL_OK")
    quit(0)
