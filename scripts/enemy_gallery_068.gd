extends Control
## Non-canonical preview: inspect all 15 combat enemies + Rootkin/Bell Wretch.
## It reads asset atlases and never changes Game.state or grants loot/XP.
const EnemyRoster068 = preload("res://scripts/enemy_roster_068.gd")
const Rotation8 = preload("res://scripts/sprite_rotations_071.gd")
var ids: Array = []
var at: int = 0
var face: int = 1
var index: int = 0
var clock: float = 0.0
var attack_mode: bool = false
var compare_legacy: bool = false
var display: TextureRect
var active_atlas: Texture2D
var heading: Label
var description: Label
var footer: Label
const FACES: Array = ["BILLBOARD","FRONT","FRONT LEFT","LEFT","BACK LEFT","BACK","BACK RIGHT","RIGHT","FRONT RIGHT"]

func _ready() -> void:
    ids = EnemyRoster068.combat_types()
    ids.sort()
    ids.append("bell_wretch")
    ids.append("rootkin")
    var background := ColorRect.new()
    background.color = Color("#1b2424")
    background.size = Vector2(640,400)
    background.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(background)
    var panel := ColorRect.new()
    panel.color = Color("#303633")
    panel.position = Vector2(205,66)
    panel.size = Vector2(230,265)
    add_child(panel)
    display = TextureRect.new()
    display.position = Vector2(222,70)
    display.size = Vector2(192,256)
    display.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    display.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    display.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(display)
    heading = Label.new()
    heading.position = Vector2(15,10)
    heading.size = Vector2(625,54)
    heading.add_theme_color_override("font_color",Color("#f1d4a0"))
    heading.add_theme_font_size_override("font_size",17)
    add_child(heading)
    description = Label.new()
    description.position = Vector2(445,76)
    description.size = Vector2(181,270)
    description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    description.add_theme_color_override("font_color",Color("#d6d6c7"))
    description.add_theme_font_size_override("font_size",12)
    add_child(description)
    footer = Label.new()
    footer.position = Vector2(15,350)
    footer.size = Vector2(620,42)
    footer.add_theme_color_override("font_color",Color("#c9af86"))
    footer.add_theme_font_size_override("font_size",12)
    footer.text = "LEFT/RIGHT: enemy   UP/DOWN: views 0–8   SPACE: animation   T: old/new   ESC: title\nPreview only — no battle, rewards or save changes"
    add_child(footer)
    var prev := Button.new()
    prev.text = "<"
    prev.position = Vector2(17,274)
    prev.size = Vector2(45,31)
    prev.pressed.connect(_prev)
    add_child(prev)
    var next := Button.new()
    next.text = ">"
    next.position = Vector2(150,274)
    next.size = Vector2(45,31)
    next.pressed.connect(_next)
    add_child(next)
    var back := Button.new()
    back.text = "TITLE"
    back.position = Vector2(536,14)
    back.size = Vector2(92,34)
    back.pressed.connect(_return_title)
    add_child(back)
    _refresh()

func _prev() -> void:
    at = posmod(at-1,ids.size())
    _refresh()
func _next() -> void:
    at = posmod(at+1,ids.size())
    _refresh()
func _return_title() -> void:
    get_tree().change_scene_to_file("res://scenes/main.tscn")
func _unhandled_input(event: InputEvent) -> void:
    if not event is InputEventKey: return
    var key: InputEventKey = event as InputEventKey
    if not key.pressed or key.echo: return
    match key.keycode:
        KEY_LEFT: _prev()
        KEY_RIGHT: _next()
        KEY_UP:
            face = posmod(face+1,9)
            _refresh()
        KEY_DOWN:
            face = posmod(face-1,9)
            _refresh()
        KEY_SPACE:
            attack_mode = not attack_mode
            clock = 0.0
            _refresh()
        KEY_T:
            compare_legacy = not compare_legacy
            _refresh()
        KEY_ESCAPE: _return_title()

func _refresh() -> void:
    if ids.is_empty(): return
    var id: String = str(ids[at])
    var spec: Dictionary = EnemyRoster068.spec(id)
    var caption: String = id.replace("_"," ").to_upper() if spec.is_empty() else str(spec.get("name",id)).to_upper()
    heading.text = "ENEMY ECOLOGY / %s    %02d / %02d\n%s" % ["ORIGINAL 07.3" if compare_legacy else "POLISHED 07.4",at+1,ids.size(),caption]
    var detail: String = "HEARING-ONLY\nNOT an FPS enemy\nVoluntary public-loaner or opposition field" if spec.is_empty() else "ZONE: %s\nHEALTH: %d\nROLE: %s\nATTACK: %s\nDAMAGE: %d\nREACH: %.1fm\n\nEight genuinely rotated views, with improved material texture and silhouette readability. These remain 3D maquette derivatives, not the external Runway paintings." % [str(spec["zone"]).to_upper(),int(spec["hp"]),str(spec["move"]).to_upper(),str(spec["attack"]).to_upper(),int(spec["damage"]),float(spec["reach"])]
    description.text = detail + "\n\nVIEW %d: " % face + str(FACES[face]).to_upper() + ("\nATTACK CYCLE" if attack_mode else "\nWALK CYCLE")
    var file_view: int = 1 if face == 0 else face
    var source_dir: String = "enemies_073" if compare_legacy else "enemies_074"
    var path: String = "res://assets/sprites/%s/%s_%d.png" % [source_dir,id,file_view]
    active_atlas = load(path) if ResourceLoader.exists(path) else null
    clock = 0.0
    _update_sprite()

func _update_sprite() -> void:
    if ids.is_empty() or active_atlas == null: return
    var pose: int = (4+int(clock*5.0)%4) if attack_mode else int(clock*5.0)%4
    var sub := AtlasTexture.new()
    sub.atlas = active_atlas
    sub.region = Rect2((pose%4)*192,int(pose/4)*256,192,256)
    display.texture = sub

func _process(delta: float) -> void:
    clock += delta
    _update_sprite()
