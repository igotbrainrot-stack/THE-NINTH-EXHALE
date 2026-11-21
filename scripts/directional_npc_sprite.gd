extends Sprite3D
## BUILD 07.1: 1..8 directional selection with 0 universal fallback.
## Billboard applies to the *plane*, never to static world furniture.
## Asymmetric left and right views are distinct assets.
const Rotation8 = preload("res://scripts/sprite_rotations_071.gd")
const Grounding074 = preload("res://scripts/sprite_grounding_074.gd")
@export var sprite_stem: String = ""
@export_range(0, 8, 1) var rotation_mode: int = 8
var face_textures: Dictionary = {}
var ambient_frames: Dictionary = {}
var idle_clock: float = 0.0
var current_face: int = -1
var talk_time_079x: float = 0.0
var listen_time_080: float = 0.0
var pose_clock_080: float = 0.0
var hurt_flash_079z: float = 0.0
var threatened_085: bool = false
## Build 09.2 drop-in animation (assets/sprites/anim_092/<stem>/): idle, talk,
## listen, threatened and hurt strips replace the stretched breathing cells.
const SpriteAnim092 = preload("res://scripts/sprite_anim_092.gd")
var anim_092: RefCounted = null
var anim_state_092: String = ""
var anim_clock_092: float = 0.0

func set_threatened_085(value: bool) -> void:
    threatened_085 = value
    talk_time_079x = 0.0
    listen_time_080 = 0.0

func talk_079x() -> void:
    # Playback follows actual dialogue selection, never dead/absent witnesses.
    talk_time_079x = 1.5
    listen_time_080 = 0.0
    pose_clock_080 = 0.0

func listen_080() -> void:
    listen_time_080 = 0.8
    talk_time_079x = 0.0
    pose_clock_080 = 0.0

func hurt_079z() -> void:
    # No sprite scale/pivot movement: avoid foot sliding and silhouette jitter.
    hurt_flash_079z = 0.30

func _ready() -> void:
    billboard = BaseMaterial3D.BILLBOARD_ENABLED
    texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
    alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
    alpha_scissor_threshold = 0.26
    shaded = false
    # Build 08.8: Runway turnaround art (tools/import_art_088.py) takes priority.
    # Its idle strips are generated from the same art, so never mix it with the
    # 07.2 idle strips of the older sprite.
    var art_088: bool = ResourceLoader.exists("res://assets/sprites/npc_088/%s_1.png" % sprite_stem)
    var face_dir: String = "npc_088" if art_088 else "directional8"
    var idle_dir: String = "npc_idle_088" if art_088 else "npc_idle_072"
    for index in range(1,9):
        var path: String = "res://assets/sprites/%s/%s_%d.png" % [face_dir,sprite_stem,index]
        if ResourceLoader.exists(path):
            face_textures[index] = load(path)
    # A0: same graphic every angle only for explicitly universal assets.
    var all_path: String = "res://assets/sprites/directional8/%s_0.png" % sprite_stem
    if ResourceLoader.exists(all_path): face_textures[0] = load(all_path)
    # 09.1: the legacy 4-view folder was removed; directional8 covers every NPC.
    # Four uniquely shifted upper-body idle poses per view. Constant foot pivot.
    for index in range(1,9):
        var idle_path: String = "res://assets/sprites/%s/%s_%d.png" % [idle_dir,sprite_stem,index]
        if ResourceLoader.exists(idle_path):
            var strip: Texture2D = load(idle_path)
            var cells: Array[Texture2D] = []
            for part in range(4):
                var cut := AtlasTexture.new()
                cut.atlas = strip
                cut.region = Rect2(part*192,0,192,280)
                cells.append(cut)
            ambient_frames[index] = cells
    if face_textures.has(1):
        texture = face_textures[1]
        pixel_size = 0.0072
        position.y = 1.03
        current_face = 1
    if get_parent() is Node3D:
        Grounding074.add_contact_shadow(get_parent() as Node3D, 0.82, 0.50)
    anim_092 = SpriteAnim092.load_set(sprite_stem)
    if anim_092 != null and anim_092.pixel_size > 0.0:
        pixel_size = anim_092.pixel_size
    set_process(face_textures.size() > 1 or not ambient_frames.is_empty() or anim_092 != null)

func _process(delta: float) -> void:
    idle_clock += delta
    talk_time_079x = maxf(0.0,talk_time_079x-delta)
    listen_time_080 = maxf(0.0,listen_time_080-delta)
    pose_clock_080 += delta
    hurt_flash_079z = maxf(0.0,hurt_flash_079z-delta)
    # Persistent low-health civilian fear is distinct from the short hit flash.
    modulate = Color("#ed8b74") if hurt_flash_079z > 0.0 else (Color("#c9a79d") if threatened_085 else Color.WHITE)
    var view_camera: Camera3D = get_viewport().get_camera_3d()
    if view_camera == null: return
    var actor: Node3D = get_parent() as Node3D
    if actor == null: return
    var selected: int = 0 if rotation_mode == 0 else Rotation8.view_from_world(view_camera.global_position, actor.global_transform)
    if anim_092 != null:
        var wanted: String = "hurt" if hurt_flash_079z > 0.0 else ("talk" if talk_time_079x > 0.0 else ("listen" if listen_time_080 > 0.0 else ("threatened" if threatened_085 else "idle")))
        if not anim_092.has_state(wanted) and wanted != "idle": wanted = "threatened" if threatened_085 and anim_092.has_state("threatened") else "idle"
        if anim_092.has_state(wanted):
            if wanted != anim_state_092:
                anim_state_092 = wanted
                anim_clock_092 = 0.0
            anim_clock_092 += delta
            var tex: Texture2D = anim_092.frame(wanted, selected if selected > 0 else 1, anim_clock_092)
            if tex != null:
                texture = tex
                current_face = selected
                return
    if not face_textures.has(selected):
        # Legacy fallback if a production cell is accidentally missing.
        selected = [1,1,3,3,5,5,7,7][selected-1] if selected > 0 else 1
    if face_textures.has(selected):
        var next_texture: Texture2D = face_textures[selected]
        if ambient_frames.has(selected):
            var pose: int = int(idle_clock*(3.5 if threatened_085 else 1.6))%4
            if talk_time_079x > 0.0:
                pose = 2 + int(pose_clock_080*8.0)%2
            elif listen_time_080 > 0.0:
                pose = 1 if int(pose_clock_080*2.0)%2 == 0 else 0
            next_texture = ambient_frames[selected][pose]
        if selected != current_face or texture != next_texture:
            texture = next_texture
            current_face = selected
