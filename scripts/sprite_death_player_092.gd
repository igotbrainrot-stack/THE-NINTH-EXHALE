extends Sprite3D
## Plays a 09.2 death strip once (front facing for the viewer) and holds the
## last frame as remains. Silent by design.
const Rotation8 = preload("res://scripts/sprite_rotations_071.gd")
var anim_set: RefCounted
var clock: float = 0.0

func play(set_ref: RefCounted) -> void:
    anim_set = set_ref
    clock = 0.0
    _show()

func _process(delta: float) -> void:
    if anim_set == null: return
    clock += delta
    _show()
    if clock > anim_set.duration("death") + 0.1:
        set_process(false)

func _show() -> void:
    var facing: int = 1
    var cam: Camera3D = get_viewport().get_camera_3d() if is_inside_tree() else null
    if cam != null: facing = Rotation8.view_from_world(cam.global_position, global_transform)
    var tex: Texture2D = anim_set.frame("death", facing, clock)
    if tex != null: texture = tex
