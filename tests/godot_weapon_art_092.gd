extends SceneTree
## Weapon art drop-in check (09.2, tightened in 09.3).
## Counts failures and exits 1: bare assert() can let headless runs exit 0.
const SpriteAnim = preload("res://scripts/sprite_anim_092.gd")
const WEAPONS := ["covenant", "coil", "nail", "choir"]
# Coil's fire strip is held back in 09.3 (the hand vanishes on every frame),
# so Coil fires on its idle frames with full procedural recoil.
const EXPECTED_FIRE_FRAMES := {"covenant": 4, "coil": 0, "nail": 2, "choir": 5}
const ANCHOR_REACH := 6  # px: a muzzle anchor must sit on or next to the weapon

var failures := 0
var checks := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, label: String) -> void:
    checks += 1
    if ok:
        print("WEAPON_092_PASS ", label)
    else:
        failures += 1
        print("WEAPON_092_FAIL ", label)

func _opaque_near(img: Image, at: Vector2i) -> bool:
    for dy in range(-ANCHOR_REACH, ANCHOR_REACH + 1):
        for dx in range(-ANCHOR_REACH, ANCHOR_REACH + 1):
            var p := at + Vector2i(dx, dy)
            if p.x < 0 or p.y < 0 or p.x >= 640 or p.y >= 400:
                continue
            if img.get_pixelv(p).a > 0.5:
                return true
    return false

func _run() -> void:
    SpriteAnim.clear_cache()
    for weapon in WEAPONS:
        var anim = SpriteAnim.load_set(weapon, "res://assets/weapons/anim_092/")
        check(anim != null, weapon + " set loads")
        if anim == null:
            continue
        check(anim.has_state("idle"), weapon + " has idle")
        var idle: Texture2D = anim.frame("idle", 0, 0.0)
        check(idle is AtlasTexture and (idle as AtlasTexture).region.size == Vector2(640, 400), weapon + " idle cell is 640x400")
        check(int(anim.states["idle"]["frames"]) == 4, weapon + " idle has 4 frames")
        var want: int = EXPECTED_FIRE_FRAMES[weapon]
        if want > 0:
            check(anim.has_state("fire") and int(anim.states["fire"]["frames"]) == want, weapon + " fire has %d frames" % want)
            check(anim.duration("fire") > 0.0, weapon + " fire has a duration")
        else:
            check(not anim.has_state("fire"), weapon + " fire held back (procedural recoil)")
        # The muzzle flash is centred on this anchor; it must touch the weapon.
        var muzzle: Array = anim.meta.get("anchors", {}).get("muzzle", [])
        check(muzzle.size() == 2, weapon + " declares a muzzle anchor")
        if muzzle.size() == 2 and idle is AtlasTexture:
            var at := Vector2i(int(muzzle[0]), int(muzzle[1]))
            var img: Image = (idle as AtlasTexture).atlas.get_image()
            if img.is_compressed():
                img.decompress()
            var frame0: Image = img.get_region(Rect2i((idle as AtlasTexture).region))
            check(_opaque_near(frame0, at), weapon + " muzzle anchor %s sits on the weapon" % str(at))
    print("WEAPON_092_SUMMARY %d checked, %d failed" % [checks, failures])
    quit(1 if failures > 0 else 0)
