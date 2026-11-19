extends Control
## QA-only preview of full 0/1..8 sprite convention for existing civilians.
## Does not instantiate encounter actors or change attempt state.
const Rotation8 = preload("res://scripts/sprite_rotations_071.gd")
const PERSONS: Array = ["sela", "brin", "ossa", "oren", "clerk"]
var character_index: int = 0
var angle_index: int = 1
var sprite_view: TextureRect
var title_label: Label
var detail_label: Label
var idle_atlas: Texture2D
var idle_clock: float = 0.0
var animated: bool = true

func _ready() -> void:
    var background := ColorRect.new()
    background.color = Color("#1c2825")
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(background)
    var frame := Panel.new()
    frame.position = Vector2(190,46)
    frame.size = Vector2(260,304)
    var style := StyleBoxFlat.new()
    style.bg_color = Color("#293431")
    style.border_color = Color("#a8814e")
    style.set_border_width_all(2)
    frame.add_theme_stylebox_override("panel",style)
    add_child(frame)
    sprite_view = TextureRect.new()
    sprite_view.position = Vector2(224,52)
    sprite_view.size = Vector2(192,280)
    sprite_view.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    sprite_view.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    add_child(sprite_view)
    title_label = Label.new()
    title_label.position = Vector2(20,12)
    title_label.size = Vector2(605,32)
    title_label.add_theme_color_override("font_color",Color("#f0dbc0"))
    title_label.add_theme_font_size_override("font_size",19)
    add_child(title_label)
    detail_label = Label.new()
    detail_label.position = Vector2(458,88)
    detail_label.size = Vector2(172,220)
    detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    detail_label.add_theme_color_override("font_color",Color("#dbd9c8"))
    detail_label.add_theme_font_size_override("font_size",13)
    add_child(detail_label)
    var footer := Label.new()
    footer.position = Vector2(16,356)
    footer.size = Vector2(616,38)
    footer.text = "LEFT/RIGHT NPC  •  UP/DOWN 45°  •  SPACE idle on/off  •  0 universal  •  ESC title"
    footer.add_theme_color_override("font_color",Color("#c9af86"))
    footer.add_theme_font_size_override("font_size",12)
    add_child(footer)
    var back := Button.new()
    back.text = "TITLE"
    back.position = Vector2(528,16)
    back.size = Vector2(95,31)
    back.pressed.connect(_return_title)
    add_child(back)
    _refresh()

func _return_title() -> void:
    get_tree().change_scene_to_file("res://scenes/main.tscn")

func _unhandled_input(event: InputEvent) -> void:
    if not (event is InputEventKey):return
    var k: InputEventKey = event as InputEventKey
    if not k.pressed or k.echo:return
    match k.keycode:
        KEY_LEFT:
            character_index = posmod(character_index-1,PERSONS.size())
        KEY_RIGHT:
            character_index = posmod(character_index+1,PERSONS.size())
        KEY_UP:
            angle_index = posmod(angle_index,8)+1
        KEY_DOWN:
            angle_index = posmod(angle_index-2,8)+1
        KEY_0:
            angle_index = 0
        KEY_SPACE:
            animated = not animated
        KEY_ESCAPE:
            _return_title()
            return
        _:
            return
    _refresh()

func _refresh() -> void:
    var name: String = str(PERSONS[character_index])
    var display: String = "Brin Harker" if name == "brin" else ("Sister Ossa" if name == "ossa" else ("Dr Sela Vale" if name == "sela" else ("Oren" if name == "oren" else "Requisition Clerk")))
    var shown_angle: int = 1 if angle_index == 0 else angle_index
    var path: String = "res://assets/sprites/directional8/%s_%d.png" % [name,shown_angle]
    sprite_view.texture = load(path) if ResourceLoader.exists(path) else null
    var atlas_path: String = "res://assets/sprites/npc_idle_072/%s_%d.png" % [name,shown_angle]
    idle_atlas = load(atlas_path) if ResourceLoader.exists(atlas_path) else null
    idle_clock = 0.0
    title_label.text = "CIVILIAN SPRITE ROTATIONS / 07.2   %d / %d" % [character_index+1,PERSONS.size()]
    var art_note: String = "Eight separately illustrated directions" if name == "brin" else "Cardinals original / intermediate diagonals are provisional synthesis"
    detail_label.text = "%s\n\nVIEW %s\n\n%s\n\n%s\n\nRunway 8-view regeneration complete but exports are external.\n\nIdle: %s" % [display,str(angle_index),Rotation8.label_for(angle_index),art_note,"ON" if animated else "OFF"]

func _process(delta: float) -> void:
    if idle_atlas == null: return
    idle_clock += delta
    var frame: int = int(idle_clock*1.6)%4 if animated else 0
    var clip := AtlasTexture.new()
    clip.atlas = idle_atlas
    clip.region = Rect2(frame*192,0,192,280)
    sprite_view.texture = clip
