extends Sprite3D
## Rootkin and Bell Wretch use the same fixed-frame atlas system as hostile actors,
## but their civic hearing is NOT an FPS combat encounter or a creature prize.
const Rotation8 = preload("res://scripts/sprite_rotations_071.gd")
const Grounding074 = preload("res://scripts/sprite_grounding_074.gd")
@export var echoform_id: String = "bell_wretch"
@export_range(0,8,1) var rotation_mode: int = 8
var animations: Dictionary = {}
var clock: float = 0.0

func _ready() -> void:
    for face in range(1,9):
        var file_path: String = "res://assets/sprites/enemies_074/%s_%d.png" % [echoform_id,face]
        if not ResourceLoader.exists(file_path):
            file_path = "res://assets/sprites/enemies_073/%s_%d.png" % [echoform_id,face]
        if not ResourceLoader.exists(file_path):
            file_path = "res://assets/sprites/enemies_071/%s_%d.png" % [echoform_id,face]
        if not ResourceLoader.exists(file_path):
            var legacy: String = "front" if face == 1 else ("left" if face in [2,3] else ("back" if face in [4,5,6] else "right"))
            file_path = "res://assets/sprites/enemies_068/%s_%s.png" % [echoform_id,legacy]
        if not ResourceLoader.exists(file_path): continue
        var atlas: Texture2D = load(file_path)
        var frames: Array[Texture2D] = []
        for idx in range(12):
            var frame := AtlasTexture.new()
            frame.atlas = atlas
            frame.region = Rect2((idx % 4)*192,int(idx/4)*256,192,256)
            frames.append(frame)
        animations[face] = frames
    if animations.has(1): texture = animations[1][0]
    texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
    alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
    alpha_scissor_threshold = 0.26
    billboard = BaseMaterial3D.BILLBOARD_ENABLED
    shaded = false
    if get_parent() is Node3D:
        Grounding074.add_contact_shadow(get_parent() as Node3D, 0.95, 0.55)

func _process(delta: float) -> void:
    if animations.is_empty(): return
    clock += delta
    var idx: int = int(clock * 2.5) % 4
    if Game.has_attempt():
        var hearing: Dictionary = Game.state.get("hearing",{})
        if bool(hearing.get("active",false)):
            var phase: String = str(hearing.get("last_phase",""))
            if echoform_id == "bell_wretch":
                if phase == "rising": idx = 4 + int(clock * 6.0) % 2
                elif phase == "shielded": idx = 6 + int(clock * 4.0) % 2
                elif phase == "exposed": idx = int(clock * 3.0) % 4
            elif phase == "exposed": idx = 4 + int(clock * 4.0) % 2
    var index: int = 1
    var view_camera: Camera3D = get_viewport().get_camera_3d()
    if rotation_mode != 0 and view_camera != null:
        # Sprite is parented directly to district; use its own natural world-facing frame.
        var origin: Transform3D = global_transform
        index = Rotation8.view_from_world(view_camera.global_position,origin)
    if not animations.has(index): index = 1
    if animations.has(index): texture = animations[index][idx]
