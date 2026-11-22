extends Panel
## Build 09.3 HUD cue: how visible the player is, and the most alarmed guard
## nearby (immersive-sim Phase 1b; Gloomwood-style three colours).
##
## Left: a five-pip "lamp" meter from the same light and motion factors the
## guards use (perception_092.player_visibility). Right: one word for the most
## alarmed perceiver within CUE_REACH metres. It never covers the vitals,
## ammo or hazard tells (bible L1350-1368); it sits just above the vitals.

const P = preload("res://scripts/perception_092.gd")
const CUE_REACH := 30.0
const PIPS := 5
const WORDS := {
    "UNAWARE": ["UNNOTICED", Color("#9aa39a")],
    "HIGH_ALERT": ["HIGH ALERT", Color("#d9c27a")],
    "SUSPICIOUS": ["NOTICED ?", Color("#e0b46d")],
    "SEARCH": ["SEARCHING ?!", Color("#f08a4b")],
    "INVESTIGATE": ["CLOSING IN ?!", Color("#f08a4b")],
    "HOSTILE": ["SPOTTED !", Color("#e0573f")],
}

var hud: Node
var pips: Array = []
var word: Label
var clock: float = 0.0
var visibility: float = 0.0     # last computed, 0..1 (tests read it)
var alarm: String = "UNAWARE"   # last computed state (tests read it)

func build(owner_hud: Node, skin: StyleBox) -> void:
    hud = owner_hud
    name = "AwarenessCue093"
    # 24 px tall so its text (14 px at size 10) keeps a 5 px inset from the
    # frame. It ends at y 333, clear of the vitals frame, whose file-card tab
    # is drawn 5 px above the vitals panel (09.6), from y 335.
    position = Vector2(8, 309)
    size = Vector2(204, 24)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    if skin != null:
        add_theme_stylebox_override("panel", skin)
    for i in PIPS:
        var pip := ColorRect.new()
        pip.position = Vector2(8 + i * 9, 9)
        pip.size = Vector2(7, 6)
        pip.mouse_filter = Control.MOUSE_FILTER_IGNORE
        add_child(pip)
        pips.append(pip)
    # Font first, size last: a Label's size is clamped to its minimum when
    # set, and never shrinks back, so sizing it under the default 16 px font
    # left both labels 23 px tall and spilling onto the vitals panel.
    var lamp := Label.new()
    lamp.text = "LIT"
    lamp.add_theme_font_size_override("font_size", 9)
    lamp.add_theme_color_override("font_color", Color("#bda77e"))
    add_child(lamp)
    lamp.position = Vector2(56, 5)
    lamp.size = Vector2(22, 14)
    word = Label.new()
    word.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    word.add_theme_font_size_override("font_size", 10)
    word.clip_text = true
    add_child(word)
    word.position = Vector2(84, 5)
    word.size = Vector2(112, 14)
    visible = false

func _process(delta: float) -> void:
    clock -= delta
    if clock > 0.0: return
    clock = 0.15
    refresh()

func refresh() -> void:
    var player: Node3D = get_tree().get_first_node_in_group("player_controller") as Node3D
    var modal: bool = is_instance_valid(hud) and bool(hud.get("modal_open"))
    visible = Game.has_attempt() and is_instance_valid(player) and not modal
    if not visible: return
    var speed: float = 0.0
    if player is CharacterBody3D:
        var v: Vector3 = (player as CharacterBody3D).velocity
        speed = Vector2(v.x, v.z).length()
    # Same light the guards use: the district's lamps (not the player's own
    # flash lamp), raised by a recent muzzle flash.
    var main_scene: Node = player.get_parent()
    var world_root: Node = main_scene.get("world") if main_scene != null and main_scene.get("world") != null else main_scene
    var light: float = P.player_light(world_root, player.global_position + Vector3(0, 0.2, 0))
    visibility = P.player_visibility(light, speed)
    var lit: int = clampi(int(ceil(visibility * PIPS)), 1, PIPS)
    for i in PIPS:
        (pips[i] as ColorRect).color = Color("#e8d8a8") if i < lit else Color("#3a3f3a")
    alarm = str(P.most_alarmed(get_tree(), player.global_position, CUE_REACH)[0])
    var entry: Array = WORDS.get(alarm, WORDS["UNAWARE"])
    word.text = str(entry[0])
    word.add_theme_color_override("font_color", entry[1])
