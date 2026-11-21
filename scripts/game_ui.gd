extends CanvasLayer
const WeaponCatalog = preload("res://scripts/weapon_catalog.gd")
## Pressure Docket: a diegetic industrial dossier overlay rather than a
## generic sci-fi visor. Build 06.9 focuses on clearer hierarchy and a more
## professional-looking UI while preserving the 640x400 retro presentation.

signal action_selected(action_id: String)

var modal_open := false
var overlay: Control
var modal: Panel
var modal_scrim: ColorRect

var reticle: TextureRect
var gun: TextureRect
var muzzle: TextureRect
var muzzle_frames_079x: Array[Texture2D] = []
var shell: ColorRect
var vignette: TextureRect

var objective_panel: Panel
var zone_label: Label
var objective_label: Label
var navigation_panel: Panel
var navigation: Label

var vitals_panel: Panel
var hp_bar: ProgressBar
var hp_text: Label
var breath_bar: ProgressBar
var breath_text: Label
var meta_text: Label
var med_text: Label

var weapon_panel: Panel
var weapon_name: Label
var ammo_text: Label
var hint_text: Label
var heat_bar: ProgressBar
var heat_text: Label
var heat_icon_087: TextureRect

var prompt_panel: Panel
var prompt_label: Label
var action_strip: Label

var banner_panel: Panel
var banner: Label
var banner_time := 0.0
var refresh_time := 0.0

var active_weapon: String = "covenant"
var anim_clock := 0.0
var recoil_strength := 0.0
var shot_flash := 0.0
var reload_duration := 0.0
var reload_clock := 0.0
var switch_duration := 0.0
var switch_clock := 0.0
var dry_kick := 0.0
var shell_life := 0.0
var current_prompt := ""
var damage_flash_079: ColorRect
var damage_time_079: float = 0.0
var reticle_hit_clock_079: float = 0.0

const HudFx090 = preload("res://scripts/hud_fx_090.gd")
var fx: Control                          # Build 09.0 stamp / slips / vignette layer
var prompt_keycap: Panel                 # "[E]" drawn as a key, not bracket text
var prompt_keycap_label: Label
var modal_buttons: Array[Button] = []    # number keys 1-9 pick these
var modal_actions: Array[String] = []
var modal_tabs: Array = []               # [{tab, text}] for the docket
var modal_tab_index: int = 0
var modal_tab_buttons: Array[Button] = []
var modal_story: RichTextLabel
var legend_clock: float = 0.0            # seconds of active play; legend fades at 45 s
## Build 09.2 drop-in weapon animation (assets/weapons/anim_092/<weapon>/).
## Spec: docs/handover/GPT_WEAPON_ANIMATION_HANDOVER_092.md
const SpriteAnim092 = preload("res://scripts/sprite_anim_092.gd")
const WEAPON_ANIM_ROOT_092: String = "res://assets/weapons/anim_092/"
var weapon_anim_092: RefCounted = null
var weapon_state_092: String = "idle"
var weapon_clock_092: float = 0.0
var weapon_speed_092: float = 1.0

func _ready() -> void:
    add_to_group("game_ui")
    build_base()

func _panel_style(bg: Color, border: Color, radius: int = 5, width: int = 2, pad_l: int = 10, pad_t: int = 8, pad_r: int = 10, pad_b: int = 8) -> StyleBoxFlat:
    var skin := StyleBoxFlat.new()
    skin.bg_color = bg
    skin.border_color = border
    skin.set_border_width_all(width)
    skin.set_corner_radius_all(radius)
    skin.content_margin_left = pad_l
    skin.content_margin_top = pad_t
    skin.content_margin_right = pad_r
    skin.content_margin_bottom = pad_b
    skin.shadow_color = Color(0,0,0,0.30)
    skin.shadow_size = 3
    return skin

# Build 08.6: approved Enamel Service Window art skin. Keep all game text, counters,
# controls and input in Godot; these textures are strictly visual and are not
# interaction or state snapshots. Nine-slice corners stay within the authored
# imported PNG margins, so long objective/weapon panels do not distort rivets.
const HUD_086_PATH: String = "res://assets/ui/hud_086/"
const HUD_086_STYLE: Dictionary = {
    "hud_frame_brass": [16, 14, 16, 14],
    "hud_frame_steel": [16, 14, 16, 14],
    "hud_prompt_tab": [13, 8, 13, 8],
    "hud_banner_alert": [18, 10, 18, 10],
    "hud_docket_modal": [26, 26, 26, 26],
    "hud_button_normal": [18, 12, 18, 12],
    "hud_button_hover": [18, 12, 18, 12],
    "hud_button_pressed": [18, 12, 18, 12],
    "hud_bar_track": [6, 3, 6, 3]
}

## Build 09.1 art override. Any PNG dropped into assets/ui/hud_091/ with a slot
## name (hud_frame_brass, icon_health, hud_keycap, ...) replaces that slot; the
## 08.6 set stays as the fallback. 9-slice margins for the new art come from
## assets/ui/hud_091/hud_091_slices.json ({"slot": [left, top, right, bottom]}).
## See docs/handover/GPT_HUD_UI_ART_HANDOVER_091.md.
const HUD_091_PATH: String = "res://assets/ui/hud_091/"
## 09.2: the override folder is a static setting so tests can point it at a
## scratch directory instead of writing over delivered art.
static var art_override_dir: String = HUD_091_PATH
var _hud091_slices: Dictionary = {}
var _hud091_slices_loaded: bool = false
var _hud_texture_cache: Dictionary = {}

func hud_art_path(name: String) -> String:
    var override: String = art_override_dir + name + ".png"
    if hud_art_has_override(name):
        return override
    return HUD_086_PATH + name + ".png"

## True for an imported PNG and for one just copied in before Godot has
## imported it (so new art shows on the next run without opening the editor).
func hud_art_has_override(name: String) -> bool:
    var path: String = art_override_dir + name + ".png"
    return ResourceLoader.exists(path) or FileAccess.file_exists(path)

func _load_hud_texture(path: String) -> Texture2D:
    if _hud_texture_cache.has(path):
        return _hud_texture_cache[path]
    var tex: Texture2D = null
    if ResourceLoader.exists(path):
        tex = load(path) as Texture2D
    elif FileAccess.file_exists(path):
        var img := Image.load_from_file(ProjectSettings.globalize_path(path))
        if img != null and not img.is_empty():
            tex = ImageTexture.create_from_image(img)
    _hud_texture_cache[path] = tex
    return tex

func _hud091_margins(name: String) -> Array:
    if not _hud091_slices_loaded:
        _hud091_slices_loaded = true
        var path: String = art_override_dir + "hud_091_slices.json"
        if FileAccess.file_exists(path):
            var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
            if parsed is Dictionary: _hud091_slices = parsed
    if hud_art_has_override(name) and _hud091_slices.has(name) and _hud091_slices[name] is Array and (_hud091_slices[name] as Array).size() == 4:
        return _hud091_slices[name]
    return HUD_086_STYLE.get(name, [0, 0, 0, 0])

func _hud086_texture(name: String) -> Texture2D:
    var tex: Texture2D = _load_hud_texture(hud_art_path(name))
    if tex == null:   # an unreadable override must never blank the HUD
        tex = _load_hud_texture(HUD_086_PATH + name + ".png")
    return tex

## Optional art slots for the procedural 09.0 pieces (notice slip, stamp frame,
## keycap, docket tabs). Without a hud_091 PNG the given flat style is used.
func hud_optional_skin(name: String, fallback: StyleBox) -> StyleBox:
    if not hud_art_has_override(name):
        return fallback
    var tex: Texture2D = _load_hud_texture(art_override_dir + name + ".png")
    if tex == null:
        return fallback
    var style := StyleBoxTexture.new()
    style.texture = tex
    var m: Array = _hud091_margins(name)
    style.texture_margin_left = float(m[0]); style.texture_margin_top = float(m[1])
    style.texture_margin_right = float(m[2]); style.texture_margin_bottom = float(m[3])
    style.content_margin_left = fallback.content_margin_left
    style.content_margin_top = fallback.content_margin_top
    style.content_margin_right = fallback.content_margin_right
    style.content_margin_bottom = fallback.content_margin_bottom
    return style

func _hud086_skin(name: String, padding: Vector4 = Vector4.ZERO) -> StyleBoxTexture:
    var style := StyleBoxTexture.new()
    style.texture = _hud086_texture(name)
    var margins: Array = _hud091_margins(name)
    style.texture_margin_left = float(margins[0])
    style.texture_margin_top = float(margins[1])
    style.texture_margin_right = float(margins[2])
    style.texture_margin_bottom = float(margins[3])
    style.content_margin_left = padding.x
    style.content_margin_top = padding.y
    style.content_margin_right = padding.z
    style.content_margin_bottom = padding.w
    return style

func _hud086_icon(parent: Control, name: String, xy: Vector2, dimensions: Vector2 = Vector2(16, 16)) -> TextureRect:
    var badge := TextureRect.new()
    badge.name = "HUD086Icon_" + name
    badge.texture = _hud086_texture(name)
    badge.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    badge.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    badge.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
    parent.add_child(badge)
    # Size last: with the default expand mode the 24 px texture is the minimum
    # size, so assigning 14-15 px first left every icon at 24 px over its label.
    badge.position = xy
    badge.size = dimensions
    return badge

func _apply_button_style(button: Button, emphasis: bool = false) -> void:
    var base: Color = Color("#2a312e")
    var hover: Color = Color("#39413d")
    var pressed: Color = Color("#4f4735")
    var border: Color = Color("#b38a4f") if emphasis else Color("#6c7468")
    var normal := _hud086_skin("hud_button_normal", Vector4(12, 8, 12, 8))
    var hover_skin := _hud086_skin("hud_button_hover", Vector4(12, 8, 12, 8))
    var pressed_skin := _hud086_skin("hud_button_pressed", Vector4(12, 8, 12, 8))
    button.add_theme_stylebox_override("normal", normal)
    button.add_theme_stylebox_override("hover", hover_skin)
    button.add_theme_stylebox_override("pressed", pressed_skin)
    button.add_theme_stylebox_override("focus", hover_skin)
    button.add_theme_stylebox_override("disabled", normal)
    button.add_theme_color_override("font_color", Color("#171918"))
    button.add_theme_color_override("font_hover_color", Color("#171918"))
    button.add_theme_color_override("font_pressed_color", Color("#171918"))
    button.add_theme_color_override("font_focus_color", Color("#171918"))
    button.add_theme_font_size_override("font_size", 15 if emphasis else 14)
    button.focus_mode = Control.FOCUS_ALL
    button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func _apply_progress_style(bar: ProgressBar, fill: Color) -> void:
    bar.show_percentage = false
    bar.max_value = 100.0
    bar.add_theme_stylebox_override("background", _hud086_skin("hud_bar_track"))
    var fill_name: String = "hud_bar_fill_health"
    if fill == Color("#6e9780"):
        fill_name = "hud_bar_fill_breath"
    elif fill == Color("#c88c4e"):
        fill_name = "hud_bar_fill_heat"
    var fill_skin := StyleBoxTexture.new()
    fill_skin.texture = _hud086_texture(fill_name)
    bar.add_theme_stylebox_override("fill", fill_skin)

func build_base() -> void:
    # Label/ProgressBar sizes are assigned after add_child(): Godot clamps a
    # Control to its minimum size, and font/style overrides only take effect
    # in the tree. Sizing earlier inflated every label to 23 px and every bar
    # to 27 px, which caused the 640x400 HUD overlaps.
    overlay = Control.new()
    overlay.name = "PressureDocket"
    overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(overlay)

    vignette = TextureRect.new()
    vignette.texture = load("res://assets/ui/vignette_069.png")
    vignette.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    vignette.stretch_mode = TextureRect.STRETCH_SCALE
    vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
    overlay.add_child(vignette)

    objective_panel = Panel.new()
    # Build 09.0 compaction: the HUD used 35% of the 640x400 view. Panels are
    # now sized to their content (about 15%) and the view stays open.
    objective_panel.position = Vector2(8, 6)
    objective_panel.size = Vector2(300, 60)
    objective_panel.add_theme_stylebox_override("panel", _hud086_skin("hud_frame_brass", Vector4(10, 7, 10, 8)))
    overlay.add_child(objective_panel)

    _hud086_icon(objective_panel, "icon_writ", Vector2(9, 7), Vector2(12, 12))
    zone_label = Label.new()
    zone_label.position = Vector2(25, 5)
    zone_label.add_theme_font_size_override("font_size", 10)
    zone_label.add_theme_color_override("font_color", Color("#bda77e"))
    zone_label.text = "PRESSURE DOCKET / OBJECTIVE"
    objective_panel.add_child(zone_label)
    zone_label.size = Vector2(268, 15)
    zone_label.clip_text = true
    zone_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS

    objective_label = Label.new()
    objective_label.position = Vector2(10, 20)
    objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    objective_label.add_theme_font_size_override("font_size", 11)
    objective_label.add_theme_constant_override("line_spacing", -1)
    objective_label.add_theme_color_override("font_color", Color("#e6dcc5"))
    objective_label.max_lines_visible = 2
    objective_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
    objective_panel.add_child(objective_label)
    objective_label.size = Vector2(282, 34)

    navigation_panel = Panel.new()
    navigation_panel.position = Vector2(384, 6)
    navigation_panel.size = Vector2(248, 28)
    navigation_panel.tooltip_text = "ADVISORY ROUTE: points at the next machine, never a gate"
    # The 28 px compass may get its own thin frame (hud_091/hud_frame_route.png);
    # the shared steel frame's 14+14 px corners fill its whole height.
    navigation_panel.add_theme_stylebox_override("panel", _hud086_skin("hud_frame_route" if hud_art_has_override("hud_frame_route") else "hud_frame_steel", Vector4(10, 7, 10, 7)))
    overlay.add_child(navigation_panel)

    var nav_title := Label.new()
    _hud086_icon(navigation_panel, "icon_route_arrow", Vector2(8, 8), Vector2(12, 12))
    nav_title.position = Vector2(24, 6)
    nav_title.visible = false   # the compass line itself says where to go
    nav_title.add_theme_font_size_override("font_size", 10)
    nav_title.add_theme_color_override("font_color", Color("#93b1a0"))
    nav_title.text = "ADVISORY ROUTE"
    navigation_panel.add_child(nav_title)
    nav_title.size = Vector2(170, 16)

    navigation = Label.new()
    navigation.position = Vector2(22, 6)
    navigation.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
    navigation.add_theme_font_size_override("font_size", 11)
    navigation.add_theme_color_override("font_color", Color("#d9ead2"))
    navigation.mouse_filter=Control.MOUSE_FILTER_IGNORE
    navigation.clip_text = true
    navigation.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
    navigation_panel.add_child(navigation)
    navigation.size = Vector2(220, 16)

    reticle = TextureRect.new()
    reticle.texture = _hud086_texture("hud_reticle")
    reticle.position = Vector2(304, 184)
    reticle.size = Vector2(32, 32)
    reticle.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    reticle.mouse_filter = Control.MOUSE_FILTER_IGNORE
    overlay.add_child(reticle)

    gun = TextureRect.new()
    gun.texture=load("res://assets/weapons/covenant_idle.png")
    gun.position = Vector2.ZERO
    gun.size = Vector2(640, 400)
    gun.pivot_offset = Vector2(580, 394)
    gun.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    gun.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    gun.mouse_filter = Control.MOUSE_FILTER_IGNORE
    overlay.add_child(gun)

    muzzle = TextureRect.new()
    var blast: Texture2D = load("res://assets/fx/civic_muzzle_burst_079x.png")
    for frame_index in range(4):
        var frame := AtlasTexture.new()
        frame.atlas = blast
        frame.region = Rect2(frame_index * 128,0,128,128)
        muzzle_frames_079x.append(frame)
    muzzle.texture = muzzle_frames_079x[0]
    muzzle.position = Vector2(300, 70)
    muzzle.size = Vector2(124, 124)
    muzzle.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    muzzle.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    muzzle.mouse_filter = Control.MOUSE_FILTER_IGNORE
    muzzle.visible = false
    overlay.add_child(muzzle)

    shell = ColorRect.new()
    shell.color = Color("#e8b56c")
    shell.position = Vector2(470, 208)
    shell.size = Vector2(7, 13)
    shell.visible = false
    shell.mouse_filter = Control.MOUSE_FILTER_IGNORE
    overlay.add_child(shell)

    prompt_panel = Panel.new()
    prompt_panel.position = Vector2(186, 236)
    prompt_panel.size = Vector2(268, 26)
    prompt_panel.visible = false
    prompt_panel.add_theme_stylebox_override("panel", _hud086_skin("hud_prompt_tab", Vector4(8, 4, 8, 4)))
    overlay.add_child(prompt_panel)

    prompt_label = Label.new()
    _hud086_icon(prompt_panel, "icon_interact", Vector2(8, 5), Vector2(15, 15))
    prompt_label.position = Vector2(24, 4)
    prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    prompt_label.add_theme_font_size_override("font_size", 11)
    prompt_label.add_theme_color_override("font_color", Color("#e7dec8"))
    prompt_panel.add_child(prompt_label)
    prompt_label.size = Vector2(236, 16)
    prompt_keycap = Panel.new()
    prompt_keycap.name = "PromptKeycap"
    prompt_keycap.mouse_filter = Control.MOUSE_FILTER_IGNORE
    prompt_keycap.add_theme_stylebox_override("panel", _keycap_style())
    prompt_keycap.visible = false
    prompt_panel.add_child(prompt_keycap)
    prompt_keycap.position = Vector2(7, 5)
    prompt_keycap.size = Vector2(17, 16)
    prompt_keycap_label = _keycap_label(prompt_keycap, "E")

    vitals_panel = Panel.new()
    vitals_panel.position = Vector2(8, 340)
    vitals_panel.size = Vector2(204, 54)
    vitals_panel.add_theme_stylebox_override("panel", _hud086_skin("hud_frame_steel", Vector4(10, 8, 10, 8)))
    overlay.add_child(vitals_panel)

    var vitals_title := Label.new()
    _hud086_icon(vitals_panel, "icon_health", Vector2(8, 7), Vector2(12, 12))
    vitals_title.position = Vector2(27, 6)
    vitals_title.visible = false
    vitals_title.add_theme_font_size_override("font_size", 10)
    vitals_title.add_theme_color_override("font_color", Color("#9fb7a4"))
    vitals_title.text = "VITALS"
    vitals_panel.add_child(vitals_title)
    vitals_title.size = Vector2(100, 14)

    hp_text = Label.new()
    hp_text.position = Vector2(136, 5)
    hp_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    hp_text.add_theme_font_size_override("font_size", 11)
    hp_text.add_theme_color_override("font_color", Color("#f2d5bd"))
    vitals_panel.add_child(hp_text)
    hp_text.size = Vector2(60, 15)

    hp_bar = ProgressBar.new()
    hp_bar.position = Vector2(24, 9)
    _apply_progress_style(hp_bar, Color("#b66c5a"))
    vitals_panel.add_child(hp_bar)
    hp_bar.size = Vector2(108, 9)

    # 08.7: Breath icon is a live HUD element, not an unused packaged variant.
    _hud086_icon(vitals_panel, "icon_breath", Vector2(8, 22), Vector2(12, 12))
    breath_text = Label.new()
    breath_text.position = Vector2(136, 20)
    breath_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    breath_text.add_theme_font_size_override("font_size", 11)
    breath_text.add_theme_color_override("font_color", Color("#d5e6d3"))
    vitals_panel.add_child(breath_text)
    breath_text.size = Vector2(60, 15)

    breath_bar = ProgressBar.new()
    breath_bar.position = Vector2(24, 24)
    _apply_progress_style(breath_bar, Color("#6e9780"))
    vitals_panel.add_child(breath_bar)
    breath_bar.size = Vector2(108, 9)

    meta_text = Label.new()
    meta_text.position = Vector2(8, 35)
    meta_text.add_theme_font_size_override("font_size", 9)
    meta_text.add_theme_color_override("font_color", Color("#cbbfa6"))
    vitals_panel.add_child(meta_text)
    meta_text.size = Vector2(110, 13)

    # 08.7: Consumable indicator follows the existing ampoule counter.
    _hud086_icon(vitals_panel, "icon_ampoule", Vector2(124, 36), Vector2(11, 11))
    med_text = Label.new()
    med_text.position = Vector2(136, 35)
    med_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    med_text.add_theme_font_size_override("font_size", 9)
    med_text.add_theme_color_override("font_color", Color("#d0ddb7"))
    vitals_panel.add_child(med_text)
    med_text.size = Vector2(60, 13)

    weapon_panel = Panel.new()
    weapon_panel.position = Vector2(428, 340)
    weapon_panel.size = Vector2(204, 54)
    weapon_panel.add_theme_stylebox_override("panel", _hud086_skin("hud_frame_brass", Vector4(10, 8, 10, 8)))
    overlay.add_child(weapon_panel)

    var weapon_title := Label.new()
    _hud086_icon(weapon_panel, "icon_ammo", Vector2(8, 7), Vector2(12, 12))
    weapon_title.position = Vector2(27, 6)
    weapon_title.visible = false
    weapon_title.add_theme_font_size_override("font_size", 10)
    weapon_title.add_theme_color_override("font_color", Color("#bda77e"))
    weapon_title.text = "EQUIPMENT"
    weapon_panel.add_child(weapon_title)
    weapon_title.size = Vector2(100, 14)

    weapon_name = Label.new()
    weapon_name.position = Vector2(24, 5)
    weapon_name.add_theme_font_size_override("font_size", 10)
    weapon_name.add_theme_color_override("font_color", Color("#bda77e"))
    weapon_name.clip_text = true
    weapon_panel.add_child(weapon_name)
    weapon_name.size = Vector2(172, 15)

    ammo_text = Label.new()
    # Ammunition is the number read mid-fight, so it is the biggest type here.
    ammo_text.position = Vector2(8, 19)
    ammo_text.add_theme_font_size_override("font_size", 19)
    ammo_text.add_theme_color_override("font_color", Color("#efe2c7"))
    ammo_text.add_theme_color_override("font_outline_color", Color("#171918"))
    ammo_text.add_theme_constant_override("outline_size", 2)
    weapon_panel.add_child(ammo_text)
    ammo_text.size = Vector2(104, 28)

    # 08.7: Heat icon is only visible when a heat-using weapon is equipped.
    heat_icon_087 = _hud086_icon(weapon_panel, "icon_heat", Vector2(118, 35), Vector2(11, 11))
    heat_text = Label.new()
    heat_text.position = Vector2(118, 20)
    heat_text.add_theme_font_size_override("font_size", 10)
    heat_text.add_theme_color_override("font_color", Color("#d2bc90"))
    weapon_panel.add_child(heat_text)
    heat_text.size = Vector2(76, 13)
    heat_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

    heat_bar = ProgressBar.new()
    heat_bar.position = Vector2(132, 37)
    _apply_progress_style(heat_bar, Color("#c88c4e"))
    weapon_panel.add_child(heat_bar)
    heat_bar.size = Vector2(62, 8)

    hint_text = Label.new()
    hint_text.position = Vector2(118, 33)
    hint_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    hint_text.add_theme_font_size_override("font_size", 10)
    hint_text.add_theme_color_override("font_color", Color("#9eb79f"))
    weapon_panel.add_child(hint_text)
    hint_text.size = Vector2(76, 14)

    action_strip = Label.new()
    # The old 272px-wide strip overlapped VITALS and EQUIPMENT at native 640x400.
    # Keep controls in the intentional 143px gap between the two lower panels.
    # 09.0: a one-line control reminder between the panels. It fades once the
    # player has been in control for a while (legend_clock) and is never shown
    # over an interaction prompt.
    action_strip.position = Vector2(214, 362)
    action_strip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    action_strip.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    action_strip.add_theme_font_size_override("font_size", 9)
    action_strip.add_theme_color_override("font_color", Color("#c8c7ae"))
    action_strip.add_theme_color_override("font_outline_color", Color("#171918"))
    action_strip.add_theme_constant_override("outline_size", 3)
    action_strip.text = "TAB dossier · F intervene · R reload\nSHIFT sprint · 1 ampoule · 2–5 weapons"
    overlay.add_child(action_strip)
    action_strip.size = Vector2(208, 28)

    banner_panel = Panel.new()
    banner_panel.position = Vector2(148, 88)
    banner_panel.size = Vector2(344, 38)
    banner_panel.visible = false
    banner_panel.add_theme_stylebox_override("panel", _hud086_skin("hud_banner_alert", Vector4(10, 6, 10, 6)))
    overlay.add_child(banner_panel)

    banner = Label.new()
    banner.position = Vector2(12, 6)
    banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    banner.add_theme_font_size_override("font_size", 13)
    banner.add_theme_color_override("font_color", Color("#2a312e"))
    banner_panel.add_child(banner)
    banner.size = Vector2(320, 24)

    # Legacy regression references retained for source tests:
    # overlay.move_child(gun,0)
    # overlay.move_child(muzzle,1)
    # overlay.move_child(shell,2)
    # Damage feedback is brief and nonblocking, not a second HUD menu.
    damage_flash_079 = ColorRect.new()
    damage_flash_079.color = Color(0.72,0.12,0.08,0.0)
    damage_flash_079.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    damage_flash_079.mouse_filter = Control.MOUSE_FILTER_IGNORE
    overlay.add_child(damage_flash_079)
    overlay.move_child(vignette, 0)
    overlay.move_child(gun, 1)
    overlay.move_child(muzzle, 2)
    overlay.move_child(shell, 3)
    # Build 09.0 feedback layer sits above the viewmodel and under every panel,
    # so the red pressure edge never tints the readouts.
    fx = HudFx090.new()
    overlay.add_child(fx)
    overlay.move_child(fx, 4)
    fx.setup(self)
    update_hud()

func update_hud() -> void:
    if not Game.has_attempt():
        zone_label.text = "THE NINTH EXHALE / BUILD 08.7"
        objective_label.text = "Enter Hearth Nine and open the civic pressure docket."
        navigation.text = "NO ACTIVE ROUTE"
        hp_text.text = "--"
        breath_text.text = "--"
        meta_text.text = "LEVEL --"
        med_text.text = "× --"
        weapon_name.text = "COVENANT PISTOL"
        ammo_text.text = "-- / --"
        hint_text.text = ""
        heat_text.text = ""
        heat_bar.value = 0.0
        heat_bar.visible = false
        if is_instance_valid(heat_icon_087):
            heat_icon_087.visible = false
        return
    var inventory: Dictionary = Game.state["inventory"]
    var id: String = Game.equipped_weapon()
    var spec: Dictionary = WeaponCatalog.spec(id)
    var zone: String = str(Game.state.get("zone", "hearth"))
    var zone_name: String = "HEARTH NINE"
    if zone == "sootworks": zone_name = "SOOTWORKS"
    elif zone == "basilica": zone_name = "FLOOD BASILICA"
    elif zone == "ashmarket": zone_name = "ASHMARKET"
    elif zone == "orchard": zone_name = "GLASS ORCHARD"
    elif zone == "barracks": zone_name = "QUIET BARRACKS"
    elif zone == "assembly": zone_name = "PUBLIC ASSEMBLY / LAST SIGNATURE"
    elif zone == "core": zone_name = "FREIGHT LIFT / CENTRAL ARCHIVES"
    elif zone == "lift": zone_name = "FREIGHT LIFT TRIAL"
    zone_label.text = zone_name   # the panel itself is the objective; the suffix overflowed

    var objective_text := "Bring the Cinder Lung to Dr Sela and install it." if bool(Game.state["lung"]["acquired"]) else "Contest the withheld Cinder Lung at the reserve requisitions desk."
    if zone == "hearth" and Game.intro_stage() != "stabilised":
        var intro_phase: String = Game.intro_stage()
        if intro_phase == "unwoken":
            objective_text = "Reach the reprint relay and wake the intake systems."
        elif intro_phase == "alarm":
            objective_text = "Survive the filter crawler and keep moving during its rush."
        elif intro_phase == "cleared":
            objective_text = "Turn the manual pressure valve and open the shutter."
    if bool(Game.state["lung"]["installed"]):
        var writ_count: int = Game.founding_writs_recorded_077().size()
        if writ_count >= 3 and bool(Game.state.get("hearing",{}).get("passed",false)):
            objective_text = "Authenticate any three founding Writs at Hearth Nine's public desk."
            if bool(Game.state.get("trade",{}).get("quorum_audit",false)):
                objective_text = "Three-Writ Quorum certified. Enter the full Freight Lift."
        elif not bool(Game.state.get("hearing",{}).get("passed",false)):
            objective_text = "Complete the Rootkin public hearing, then obtain three distinct Writs."
        else:
            objective_text = "Secure %d more founding Writ(s) from five reachable offices." % maxi(0, 3-writ_count)
    if zone == "sootworks":
        # Once the Labour Writ is held, keep the run-wide objective computed above
        # (five offices are reachable; the old "Return to Flood Basilica" was stale).
        if not Game.state["writs"].has("qobj_writ_of_labour"):
            objective_text = "Track Brin, verify payroll, then recover the Labour Writ."
    elif zone == "ashmarket":
        var trade: Dictionary = Game.state.get("trade",{})
        if Game.state["writs"].has("qobj_writ_of_trade"):
            objective_text = "Trade Writ secured. Return to Hearth Nine for the Quorum audit."
        elif not bool(trade.get("duplicate_contracts",false)):
            objective_text = "Locate the original duplicate contracts in the Trade archive."
        elif not bool(trade.get("buyer_testimony",false)):
            objective_text = "Gather independent testimony; test the contract claim."
        else:
            objective_text = "Challenge the Collector or bypass the counting locks."
    elif zone == "orchard":
        var growth: Dictionary = Game.state.get("growth",{})
        if not bool(growth.get("sample_separated",false)):
            objective_text = "Separate the nursery control fruit from its forced-memory feed."
        elif not Game.state["writs"].has("qobj_writ_of_growth"):
            objective_text = "Secure the Growth Writ via research vote, Tech or apparatus."
        else:
            objective_text = "Growth Writ held. Find the independent Orchard Root Seed."
    elif zone == "barracks":
        var defence: Dictionary = Game.state.get("defence",{})
        if not bool(defence.get("casualty_roll",false)):
            objective_text = "Copy the original casualty roll without erasing names."
        elif not Game.state["writs"].has("qobj_writ_of_defence"):
            objective_text = "Secure the Defence Writ; keep independent guards on duty."
        else:
            objective_text = "Defence Writ held. Copy the Deep Heat Survey."
    elif zone == "core":
        var core: Dictionary = Game.state.get("core",{})
        if not bool(core.get("order_read",false)):
            objective_text = "Find the architect's signed order in the west archive."
        elif not bool(core.get("objection_heard",false)):
            objective_text = "Play the second signature: original recorded objection."
        elif not bool(core.get("rail_read",false)):
            objective_text = "Copy the emergency rail route and its finite capacity."
        elif str(core.get("custodian_method","")) == "":
            objective_text = "Confront %s using counterevidence, safety or combat." % str(Game.core_custodian())
        else:
            objective_text = "Custodian resolved. Enter the Public Assembly Gate in this archive."
    elif zone == "assembly":
        var civic: Dictionary = Game.state.get("civic",{})
        if not bool(civic.get("risk_disclosed",false)):
            objective_text = "Disclose the original risks before asking for a public vote."
        elif int(civic.get("staged_seats",0)) == 0:
            objective_text = "Inspect the finite rail rosters; stage voluntary cohorts."
        elif Game.dawn_technical_prerequisites_078() and not bool(civic.get("mandate",false)):
            objective_text = "Count independent constituencies for a revocable trial."
        else:
            objective_text = "Review the final civic docket. This decision is terminal."
    elif zone == "lift":
        objective_text = "Record the petition, weigh the evidence, and decide Edda's trial."
    elif zone == "basilica":
        var faith_ready: bool = Game.state["writs"].has("qobj_writ_of_faith")
        var hearing_done: bool = bool(Game.state.get("hearing", {}).get("passed", false))
        if faith_ready and hearing_done:
            objective_text = "Faith Writ and hearing recorded. Secure the remaining office record."
        elif faith_ready:
            objective_text = "The Writ is recorded. Complete the Rootkin public hearing."
        elif hearing_done:
            objective_text = "Hearing passed. Meet Ossa and file the Faith Writ."
        else:
            objective_text = "Meet Ossa, examine the reel, and survive the public hearing."
    objective_label.text = objective_text

    var health_now: int = int(Game.state["health"])
    var health_max: int = Game.max_health()
    var breath_now: int = int(Game.state["breath"])
    var breath_max: int = Game.max_breath()
    hp_text.text = "%d/%d" % [health_now, health_max]
    breath_text.text = "%d/%d" % [breath_now, breath_max]
    hp_text.add_theme_color_override("font_color", Color("#ff9b80") if health_now * 10 < health_max * 3 else Color("#f2d5bd"))
    hp_bar.value = 100.0 * float(health_now) / maxf(1.0, float(health_max))
    breath_bar.value = 100.0 * float(breath_now) / maxf(1.0, float(breath_max))
    if is_instance_valid(fx):
        fx.track_bar(hp_bar, hp_bar.value)
        fx.track_bar(breath_bar, breath_bar.value)
        fx.watch_state()
    # Unspent level-up choices stay visible until spent in the docket.
    var pending: int = int(Game.state.get("unspent_attribute_points", 0)) + Game.perk_points_available() + (1 if Game.level7_choice_pending() else 0)
    if pending > 0:
        meta_text.text = "LV %d · %d TO SPEND · TAB" % [int(Game.state["level"]), pending]
        meta_text.add_theme_color_override("font_color", Color("#e0b46d"))
    else:
        meta_text.text = "LEVEL %d · %d XP" % [int(Game.state["level"]), int(Game.state["xp"])]
        meta_text.add_theme_color_override("font_color", Color("#cbbfa6"))
    med_text.text = "× %d  [1]" % int(inventory["consumables"].get("Breath Ampoule", 0))

    weapon_name.text = str(spec.get("name", "SERVICE TOOL")).to_upper()
    var mag_now: int = Game.weapon_mag(id)
    var mag_size: int = int(spec.get("mag", 1))
    ammo_text.text = "%d / %d" % [mag_now, Game.weapon_reserve(id)]
    ammo_text.add_theme_color_override("font_color", Color("#ff9b80") if mag_now * 4 <= mag_size else Color("#efe2c7"))
    # The reload reminder appears only when it is useful.
    hint_text.text = "R  RELOAD" if mag_now * 4 <= mag_size and Game.weapon_reserve(id) > 0 else ""
    hint_text.add_theme_color_override("font_color", Color("#ff9b80"))
    if id == "nail":
        if is_instance_valid(heat_icon_087):
            heat_icon_087.visible = true
        heat_bar.visible = true
        heat_text.text = "HEAT"
        hint_text.visible = false
        heat_bar.value = clampf(100.0 * float(Game.state["weapon_state"].get("nail_heat", 0.0)) / 90.0, 0.0, 100.0)
    else:
        if is_instance_valid(heat_icon_087):
            heat_icon_087.visible = false
        heat_bar.visible = false
        heat_text.text = ""
        hint_text.visible = true
    if current_prompt == "":
        prompt_panel.visible = false

func set_navigation(label_text: String) -> void:
    if is_instance_valid(navigation):
        navigation.text = label_text if Game.has_attempt() else "NO ACTIVE ROUTE"

func set_interact_prompt(message: String) -> void:
    current_prompt = message
    if not is_instance_valid(prompt_panel) or not is_instance_valid(prompt_label): return
    # "[E] SPEAK TO BRIN" renders as a keycap plus the verb phrase.
    var key: String = ""
    var text: String = message
    var m := RegEx.create_from_string("^\\[([A-Z0-9]{1,3})\\]\\s*(.*)$").search(message)
    if m != null:
        key = m.get_string(1)
        text = m.get_string(2)
    prompt_label.text = text
    var icon: Node = prompt_panel.get_node_or_null("HUD086Icon_icon_interact")
    if is_instance_valid(prompt_keycap):
        prompt_keycap.visible = key != ""
        prompt_keycap_label.text = key
    if icon is CanvasItem: (icon as CanvasItem).visible = key == ""
    prompt_panel.visible = message != "" and not modal_open

func _keycap_style() -> StyleBox:
    return hud_optional_skin("hud_keycap", _keycap_flat())

func _keycap_flat() -> StyleBoxFlat:
    var key := StyleBoxFlat.new()
    key.bg_color = Color("#e6dcc5")
    key.border_color = Color("#6b5530")
    key.border_width_left = 1
    key.border_width_right = 1
    key.border_width_top = 1
    key.border_width_bottom = 3
    key.set_corner_radius_all(2)
    return key

func _keycap_label(cap: Control, text: String) -> Label:
    var label := Label.new()
    label.name = "KeyLegend"
    label.text = text
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    label.add_theme_font_size_override("font_size", 10)
    label.add_theme_color_override("font_color", Color("#171918"))
    cap.add_child(label)
    label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    label.offset_bottom = -2
    return label

## Notices are filed as stacked slips (newest on top, three at most) so a new
## message no longer overwrites the one the player was still reading. The
## legacy banner keeps the last text for captures and saves.
func notify(message: String, seconds: float = 4.0) -> void:
    banner.text = message
    banner_time = 0.0
    if is_instance_valid(fx):
        fx.slip(message, seconds)
    else:
        banner_panel.visible = true
        banner_time = seconds

## Big milestones get the civic stamp instead of a slip.
func stamp(title: String, detail: String = "") -> void:
    if is_instance_valid(fx): fx.stamp(title, detail)

func hit_confirmed_090(killed: bool) -> void:
    if is_instance_valid(fx): fx.shot_result(true, killed)

func _process(delta: float) -> void:
    banner_time -= delta
    if Game.has_attempt() and not modal_open:
        legend_clock += delta
    if is_instance_valid(action_strip):
        action_strip.modulate.a = clampf((45.0 - legend_clock) / 5.0, 0.0, 1.0)
        action_strip.visible = action_strip.modulate.a > 0.01
    refresh_time -= delta
    _advance_viewmodel(delta)
    damage_time_079 = maxf(0.0,damage_time_079-delta)
    reticle_hit_clock_079 = maxf(0.0,reticle_hit_clock_079-delta)
    if is_instance_valid(damage_flash_079):
        damage_flash_079.color.a = 0.17 * clampf(damage_time_079/0.22,0.0,1.0)
    if is_instance_valid(reticle):
        reticle.texture = _hud086_texture("hud_reticle_hit") if reticle_hit_clock_079 > 0.0 else _hud086_texture("hud_reticle")
    if banner_time < 0.0:
        banner_panel.visible = false
    if refresh_time <= 0.0:
        refresh_time = 0.15
        update_hud()

func set_weapon(id: String) -> void:
    if not WeaponCatalog.ARSENAL.has(id):
        id = "covenant"
    active_weapon = id
    var path: String = "res://assets/weapons/%s_idle.png" % id
    if ResourceLoader.exists(path):
        gun.texture = load(path)
    weapon_anim_092 = SpriteAnim092.load_set(id, WEAPON_ANIM_ROOT_092)
    _weapon_play_092("draw" if weapon_anim_092 != null and weapon_anim_092.has_state("draw") else "idle", 1.0)
    recoil_strength = 0.0
    shot_flash = 0.0
    reload_clock = 0.0
    dry_kick = 0.0
    muzzle.visible = false
    shell.visible = false
    update_hud()

## Painted weapon state, scaled to fit `fit_seconds` when given (reloads follow
## the catalog reload time, whatever the frame count).
func _weapon_play_092(state: String, fit_seconds: float = 0.0) -> void:
    if weapon_anim_092 == null or not weapon_anim_092.has_state(state):
        return
    weapon_state_092 = state
    weapon_clock_092 = 0.0
    var natural: float = weapon_anim_092.duration(state)
    weapon_speed_092 = natural / fit_seconds if fit_seconds > 0.05 and natural > 0.0 else 1.0

func weapon_anchor_092(name: String, fallback: Vector2) -> Vector2:
    if weapon_anim_092 == null: return fallback
    var anchors: Dictionary = weapon_anim_092.meta.get("anchors", {})
    var a: Array = anchors.get(name, [])
    return Vector2(float(a[0]), float(a[1])) if a.size() == 2 else fallback

func weapon_event(kind: String, duration: float) -> void:
    if weapon_anim_092 != null:
        match kind:
            "fire": _weapon_play_092("fire")
            "reload": _weapon_play_092("reload", duration)
            "reload_complete": _weapon_play_092("idle")
            "switch": _weapon_play_092("draw", duration)
            "dry": _weapon_play_092("dry")
            "intervene": _weapon_play_092("intervene")
    if kind == "intervene":
        kind = "dry"
    if kind == "reload":
        reload_duration = maxf(0.01, duration)
        reload_clock = reload_duration
        shot_flash = 0.0
    elif kind == "reload_complete":
        reload_clock = 0.0
    elif kind == "switch":
        switch_duration = maxf(0.01, duration)
        switch_clock = switch_duration
    elif kind == "fire":
        recoil_strength = minf(2.0,recoil_strength+0.9)
        shot_flash = maxf(shot_flash,0.075)
    elif kind == "dry":
        dry_kick = 0.14

func _advance_viewmodel(delta: float) -> void:
    if not is_instance_valid(gun) or modal_open:
        return
    anim_clock += delta
    shot_flash = maxf(0.0, shot_flash - delta)
    recoil_strength=move_toward(recoil_strength, 0.0, delta * 8.2)
    dry_kick = maxf(0.0, dry_kick - delta)
    var walking: bool = Input.is_action_pressed("move_forward") or Input.is_action_pressed("move_back") or Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")
    var sway: float = sin(anim_clock * 9.0) * 2.3 if walking else sin(anim_clock * 1.45) * 0.65
    var bounce: float = absf(sin(anim_clock * 9.0)) * 2.5 if walking else sin(anim_clock * 1.8) * 0.65
    var recoil_px: float = 15.0 if active_weapon == "coil" else (3.2 if active_weapon == "nail" else 9.0)
    var painted: bool = weapon_anim_092 != null
    if painted:
        # Painted frames carry their own recoil and reload; keep only sway and
        # the share of procedural kick the weapon's manifest asks for.
        var procedural: Dictionary = weapon_anim_092.meta.get("procedural", {})
        recoil_px *= float(procedural.get("recoil", 0.35 if weapon_anim_092.has_state("fire") else 1.0))
        _advance_weapon_frames_092(delta)
    var kick: Vector2 = Vector2(-0.30 * recoil_px * recoil_strength, recoil_px * recoil_strength)
    var reload_dip: float = 0.0
    if reload_clock > 0.0:
        reload_clock = maxf(0.0, reload_clock - delta)
        var progress: float = 1.0 - reload_clock / maxf(0.01, reload_duration)
        reload_dip = pow(sin(PI * progress), 0.85)
        if painted and weapon_anim_092.has_state("reload") and not bool(weapon_anim_092.meta.get("procedural", {}).get("reload_dip", false)):
            reload_dip = 0.0
    var switch_dip: float = 0.0
    if switch_clock > 0.0:
        switch_clock = maxf(0.0, switch_clock - delta)
        switch_dip = sin(PI * (1.0 - switch_clock / maxf(0.01, switch_duration)))
    gun.position=Vector2(sway - 20.0 * reload_dip, bounce + 105.0 * reload_dip + 85.0 * switch_dip) + kick + Vector2(1.5 * sin(anim_clock * 43.0) * dry_kick / 0.14, 0)
    gun.rotation = -0.11 * reload_dip + 0.015 * recoil_strength
    # The muzzle anchor is the flash centre in 640x400 viewmodel space.
    muzzle.position = weapon_anchor_092("muzzle", Vector2(372, 153)) - muzzle.size * 0.5 + Vector2(sway, bounce) + kick
    if shot_flash > 0.0 and not muzzle_frames_079x.is_empty():
        var pulse_index: int = clampi(int((1.0-shot_flash/0.075)*4.0),0,3)
        muzzle.texture = muzzle_frames_079x[pulse_index]
    muzzle.visible=shot_flash>0.0 and not modal_open
    muzzle.modulate.a = clampf(shot_flash / 0.06, 0.0, 1.0)
    if shell_life > 0.0:
        shell_life = maxf(0.0, shell_life - delta)
        var flight: float = 1.0 - shell_life / 0.42
        var port: Vector2 = weapon_anchor_092("shell_port", Vector2(454, 173))
        shell.position = Vector2(port.x + 65 * flight, port.y + 130 * flight * flight)
        shell.rotation = flight * 5.0
        shell.visible = not modal_open
    else:
        shell.visible = false

func _advance_weapon_frames_092(delta: float) -> void:
    if not weapon_anim_092.has_state(weapon_state_092):
        weapon_state_092 = "idle"
        if not weapon_anim_092.has_state("idle"): return
    weapon_clock_092 += delta * weapon_speed_092
    var state_len: float = weapon_anim_092.duration(weapon_state_092)
    var looping: bool = bool(weapon_anim_092.states[weapon_state_092]["loop"])
    if not looping and weapon_clock_092 >= state_len:
        _weapon_play_092("idle")
    var tex: Texture2D = weapon_anim_092.frame(weapon_state_092, 0, weapon_clock_092)
    if tex != null: gun.texture = tex

func open_modal(heading: String, description: String, choices: Array, tabs: Array = []) -> void:
    close_modal(false)
    modal_open = true
    reticle.visible = false
    gun.visible = false
    muzzle.visible = false
    shell.visible = false
    prompt_panel.visible = false
    modal_buttons.clear()
    modal_actions.clear()
    modal_tab_buttons.clear()
    modal_tabs = tabs
    modal_tab_index = 0
    var tabbed: bool = tabs.size() > 1
    var many: bool = choices.size() >= 4

    modal_scrim = ColorRect.new()
    modal_scrim.color = Color(0, 0, 0, 0.48)
    modal_scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    modal_scrim.mouse_filter = Control.MOUSE_FILTER_STOP
    overlay.add_child(modal_scrim)

    modal = Panel.new()
    modal.position = Vector2(42, 26)
    modal.size = Vector2(556, 328)
    modal.add_theme_stylebox_override("panel", _hud086_skin("hud_docket_modal", Vector4(14, 12, 14, 12)))
    overlay.add_child(modal)

    var title := Label.new()
    _hud086_icon(modal, "icon_evidence_tab", Vector2(15, 9), Vector2(18, 18))
    title.text = heading
    title.position = Vector2(39, 10)
    title.size = Vector2(378, 28)
    title.clip_text = true
    title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
    # Long headings shrink to fit rather than lose their end to an ellipsis.
    var title_size: int = 20
    var title_font: Font = title.get_theme_font("font")
    while title_size > 14 and title_font.get_string_size(heading, HORIZONTAL_ALIGNMENT_LEFT, -1, title_size).x > title.size.x:
        title_size -= 1
    title.add_theme_font_size_override("font_size", title_size)
    title.add_theme_color_override("font_color", Color("#efe2c7"))
    title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.55))
    title.add_theme_constant_override("shadow_offset_y", 1)
    modal.add_child(title)

    var subtitle := Label.new()
    subtitle.text = "CIVIC RECORD"
    subtitle.position = Vector2(382, 14)
    subtitle.size = Vector2(156, 18)
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    subtitle.add_theme_font_size_override("font_size", 10)
    subtitle.add_theme_color_override("font_color", Color("#9fb7a4"))
    modal.add_child(subtitle)

    var line := ColorRect.new()
    line.position = Vector2(16, 40)
    line.size = Vector2(524, 2)
    line.color = Color("#8f6f3d")
    modal.add_child(line)

    var story_top: float = 46.0
    if tabbed:
        _build_modal_tabs(tabs)
        story_top = 66.0
    var story_bottom: float = 162.0 if many else 212.0
    # The tabbed docket trades one visible choice row for more record text.
    if tabbed and many: story_bottom = 196.0
    var options_y: float = story_bottom + 5.0 if many else 214.0
    if tabbed and many: options_y = story_bottom - 16.0   # no "AVAILABLE ACTIONS" caption

    var story_backing := ColorRect.new()
    story_backing.position = Vector2(12, story_top)
    story_backing.size = Vector2(532, story_bottom - story_top)
    story_backing.color = Color("#171918")
    story_backing.color.a = 0.91
    story_backing.mouse_filter = Control.MOUSE_FILTER_IGNORE
    modal.add_child(story_backing)

    var story := RichTextLabel.new()
    story.name = "ModalStory"
    story.bbcode_enabled = true
    story.fit_content = false
    story.scroll_active = true
    story.position = Vector2(16, story_top + 6.0)
    # Significant final choices should not all be hidden below a tiny
    # 74-pixel scroll viewport, so four or more choices shorten the story.
    story.size = Vector2(524, story_bottom - story_top - 12.0) if not many else Vector2(524, story_bottom - story_top - 6.0)
    story.add_theme_font_size_override("normal_font_size", 13 if tabbed else 14)
    story.add_theme_font_size_override("bold_font_size", 13 if tabbed else 14)
    story.add_theme_color_override("default_color", Color("#d8d6c7"))
    story.text = str(tabs[0]["text"]) if tabbed else description
    modal.add_child(story)
    modal_story = story

    var options_title := Label.new()
    options_title.position = Vector2(16, options_y)
    options_title.size = Vector2(200, 18)
    options_title.text = "AVAILABLE ACTIONS"
    options_title.visible = not (tabbed and many)
    options_title.add_theme_font_size_override("font_size", 10)
    options_title.add_theme_color_override("font_color", Color("#2a312e"))
    modal.add_child(options_title)

    var scroll := ScrollContainer.new()
    scroll.position = Vector2(16, options_y + 20.0)
    # 09.2: the 09.1 docket art has a ~16 px bottom border; choices and the
    # shortcut footer end above it instead of being drawn over the frame.
    scroll.size = Vector2(524, 300.0 - options_y - 20.0)
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    modal.add_child(scroll)

    var options := VBoxContainer.new()
    options.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    options.custom_minimum_size = Vector2(500, 0)
    options.add_theme_constant_override("separation", 6)
    scroll.add_child(options)
    var focus_taken: bool = false
    for i in range(choices.size()):
        var choice = choices[i]
        var button := Button.new()
        button.text = str(choice.get("label", "Continue"))
        button.custom_minimum_size = Vector2(500, 32)
        # Long labels (check sums, perk effects) wrap inside the 500 px column
        # instead of widening it and forcing a sideways scroll.
        button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        _apply_button_style(button, i == 0)
        # Bible 7.1: a check-gated option stays visible with its exact sum, but can
        # only be attempted once it is met.
        button.disabled = not bool(choice.get("enabled", true))
        if button.disabled:
            button.add_theme_color_override("font_disabled_color", Color("#3b362c"))
            button.modulate = Color(1, 1, 1, 0.62)
            button.tooltip_text = "Requirement not met yet"
        var action_id: String = str(choice.get("action", "close"))
        button.pressed.connect(_button_pressed.bind(action_id))
        options.add_child(button)
        modal_buttons.append(button)
        modal_actions.append(action_id)
        if i < 9:
            _add_choice_key(button, str(i + 1))
        if not button.disabled and not focus_taken:
            button.grab_focus()
            focus_taken = true

    var footer := Label.new()
    footer.position = Vector2(16, 300)
    footer.size = Vector2(524, 12)
    footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    var hint: String = "1-%d choose" % mini(9, choices.size()) if choices.size() > 1 else "1 or ENTER continues"
    if tabbed: hint += " • ←/→ or Q/E switch tabs"
    footer.text = hint + " • TAB or ESC returns here during play"
    footer.add_theme_font_size_override("font_size", 9)
    footer.add_theme_color_override("font_color", Color("#90a190"))
    modal.add_child(footer)
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

    # Opening transition: the scrim and the docket fade in quickly so the
    # change of mode reads, without delaying input.
    modal_scrim.modulate.a = 0.0
    modal.modulate.a = 0.0
    var t := modal.create_tween().set_parallel(true)
    t.tween_property(modal_scrim, "modulate:a", 1.0, 0.12)
    t.tween_property(modal, "modulate:a", 1.0, 0.10)

## Number keycap at the left of each choice; the style's left content margin is
## widened so the label never runs under it.
func _add_choice_key(button: Button, number: String) -> void:
    for state in ["normal", "hover", "pressed", "focus", "disabled"]:
        var box: StyleBox = button.get_theme_stylebox(state)
        if box != null:
            box = box.duplicate()
            box.content_margin_left = 34.0
            box.content_margin_right = 14.0
            button.add_theme_stylebox_override(state, box)
    var cap := Panel.new()
    cap.name = "ChoiceKey"
    cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
    cap.add_theme_stylebox_override("panel", _keycap_style())
    button.add_child(cap)
    cap.anchor_top = 0.5
    cap.anchor_bottom = 0.5
    cap.offset_left = 10
    cap.offset_right = 27
    cap.offset_top = -8
    cap.offset_bottom = 8
    _keycap_label(cap, number)

func _build_modal_tabs(tabs: Array) -> void:
    var row := HBoxContainer.new()
    row.name = "DocketTabs"
    row.add_theme_constant_override("separation", 3)
    modal.add_child(row)
    row.position = Vector2(14, 45)
    for i in range(tabs.size()):
        var tab := Button.new()
        tab.name = "DocketTab%d" % i
        tab.text = str(tabs[i]["tab"])
        tab.focus_mode = Control.FOCUS_NONE
        tab.toggle_mode = true
        tab.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
        tab.add_theme_font_size_override("font_size", 11)
        tab.pressed.connect(select_modal_tab.bind(i))
        row.add_child(tab)
        tab.custom_minimum_size = Vector2(86, 18)
        modal_tab_buttons.append(tab)
    _style_modal_tabs()

func _style_modal_tabs() -> void:
    for i in range(modal_tab_buttons.size()):
        var tab: Button = modal_tab_buttons[i]
        var active: bool = i == modal_tab_index
        var box := StyleBoxFlat.new()
        box.bg_color = Color("#b38a4f") if active else Color("#2a312e", 0.92)
        box.border_color = Color("#e1d1a6") if active else Color("#6c7468")
        box.set_border_width_all(1)
        box.border_width_bottom = 0 if active else 1
        box.corner_radius_top_left = 3
        box.corner_radius_top_right = 3
        box.content_margin_left = 8
        box.content_margin_right = 8
        var skin: StyleBox = hud_optional_skin("hud_tab_active" if active else "hud_tab_idle", box)
        for state in ["normal", "hover", "pressed", "focus", "hover_pressed"]:
            tab.add_theme_stylebox_override(state, skin)
        var ink: Color = Color("#171918") if active else Color("#d8d6c7")
        for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
            tab.add_theme_color_override(c, ink)
        tab.set_pressed_no_signal(active)

func select_modal_tab(index: int) -> void:
    if modal_tabs.size() <= 1 or not is_instance_valid(modal_story): return
    modal_tab_index = posmod(index, modal_tabs.size())
    modal_story.text = str(modal_tabs[modal_tab_index]["text"])
    modal_story.scroll_to_line(0)
    _style_modal_tabs()

## Keyboard shortcuts while a docket is open: 1-9 pick the numbered choice
## (disabled ones are ignored), Left/Right or Q/E change docket tab.
func _input(event: InputEvent) -> void:
    if not modal_open or not (event is InputEventKey) or not event.pressed or event.echo:
        return
    var key: int = (event as InputEventKey).keycode
    if key >= KEY_1 and key <= KEY_9:
        var index: int = key - KEY_1
        if index < modal_buttons.size() and is_instance_valid(modal_buttons[index]) and not modal_buttons[index].disabled:
            get_viewport().set_input_as_handled()
            modal_buttons[index].grab_focus()
            _button_pressed(modal_actions[index])
        return
    if modal_tabs.size() > 1 and key in [KEY_LEFT, KEY_Q]:
        select_modal_tab(modal_tab_index - 1)
        get_viewport().set_input_as_handled()
    elif modal_tabs.size() > 1 and key in [KEY_RIGHT, KEY_E]:
        select_modal_tab(modal_tab_index + 1)
        get_viewport().set_input_as_handled()

func _button_pressed(action_id: String) -> void:
    action_selected.emit(action_id)

func close_modal(show_game: bool = true) -> void:
    modal_open = false
    modal_buttons.clear()
    modal_actions.clear()
    modal_tab_buttons.clear()
    modal_tabs = []
    modal_story = null
    if is_instance_valid(modal_scrim):
        modal_scrim.queue_free()
        modal_scrim = null
    if is_instance_valid(modal):
        modal.queue_free()
        modal = null
    if is_instance_valid(reticle):
        reticle.visible = show_game
    if is_instance_valid(gun):
        gun.visible = show_game
    if is_instance_valid(prompt_panel):
        prompt_panel.visible = show_game and current_prompt != ""

func impact_damage_079(amount: int) -> void:
    damage_time_079 = 0.22 + minf(0.13,float(amount)*0.004)
    if is_instance_valid(fx): fx.damage_taken(amount)

func animate_shot(hit: bool) -> void:
    if hit: reticle_hit_clock_079 = 0.12
    if not is_instance_valid(gun):
        return
    recoil_strength = minf(1.75, recoil_strength + 1.0)
    shot_flash=0.065 if active_weapon != "nail" else 0.036
    shell_life = 0.42 if active_weapon in ["covenant", "nail"] else 0.0
    # Hits are confirmed by the reticle marker (hit_confirmed_090), not a banner.

## Build 09.0: the docket is read in four tabs. dossier_text() still returns
## the whole record (save files, tests and the plain fallback use it).
func dossier_text() -> String:
    if not Game.has_attempt():
        return "[b]No active reconstruction.[/b]"
    var parts: Array[String] = []
    for section in dossier_sections():
        parts.append(str(section["text"]))
    return "\n\n".join(parts)

func dossier_sections() -> Array:
    if not Game.has_attempt():
        return [{"tab": "Goals", "text": "[b]No active reconstruction.[/b]"}]
    var sections: Array = []
    var attrs: Dictionary = Game.state["attributes"]
    var resources: Dictionary = Game.state["resources"]
    var plan: Dictionary = Game.state["world_plan"]
    var lung: Dictionary = Game.state["lung"]
    var lines: Array[String] = []
    lines.append("[color=#e9dcc0][b]NINTH / %s[/b][/color]    [color=#9fb7a4]ATTEMPT %s[/color]" % [str(Game.state["build"]), str(Game.state["attempt_id"])])
    lines.append("")
    lines.append_array(_final_prerequisites_lines_089())
    sections.append({"tab": "Goals", "text": "\n".join(lines)})
    lines = []
    lines.append("[color=#bda77e][b]ATTRIBUTES[/b][/color]")
    lines.append("FORCE %s   REFLEX %s   INSIGHT %s   SPEECH %s   TECH %s   RESOLVE %s" % [attrs["Force"], attrs["Reflex"], attrs["Insight"], attrs["Speech"], attrs["Tech"], attrs["Resolve"]])
    lines.append("")
    lines.append("[color=#bda77e][b]RESOURCES[/b][/color]")
    lines.append("LEVEL %s   XP %s   VOUCHERS %s" % [Game.state["level"], Game.state["xp"], Game.state["inventory"]["vouchers"]])
    lines.append("ATTRIBUTE POINTS TO SPEND: %d  /  PERK CHOICES: %d" % [int(Game.state.get("unspent_attribute_points",0)), Game.perk_points_available()])
    var perk_names: Array[String] = []
    for perk_id in Game.state.get("perks",[]):
        if Game.PERKS_089.has(perk_id): perk_names.append("%s %s" % [perk_id, Game.PERKS_089[perk_id]["name"]])
    lines.append("PERKS: %s" % (", ".join(perk_names) if not perk_names.is_empty() else "none yet (levels 2, 4, 6)"))
    if int(Game.state.get("run_score_xp",0)) > 0:
        lines.append("RUN SCORE BEYOND THE 1,050 XP CAP: %d" % int(Game.state["run_score_xp"]))
    lines.append("ENERGY %s / CORRECTION %s / BIOMASS %s / AIR %s / LABOUR %s" % [resources["Energy"], resources["Correction"], resources["Biomass"], resources["Air"], resources["Labour"]])
    lines.append("WARD ALLOCATION: HEARTH %s / CLAIMANT %s / IDLE %s" % [Game.state["ward_air"]["Hearth Nine"], Game.state["ward_air"]["Claimant Ward"], Game.state["ward_air"]["Reserve Capacity"]])
    lines.append("CINDER LUNG: %s    METHOD: %s" % ["INSTALLED" if bool(lung["installed"]) else "PENDING", str(lung["method"])])
    lines.append("")
    lines.append("[color=#bda77e][b]ATTEMPT PLAN[/b][/color]")
    lines.append("SEED %s / FIVE PLAYABLE FOUNDING OFFICES" % plan["seed"])
    lines.append("WORLDPLAN FEATURED: %s / CENTRAL CUSTODIAN: %s" % [", ".join(plan["featured"]), plan["custodian"]])
    var zone: String = str(Game.state.get("zone", "hearth"))
    var zone_name: String = "Hearth Nine"
    if zone == "sootworks": zone_name = "Sootworks"
    elif zone == "basilica": zone_name = "Flood Basilica"
    elif zone == "ashmarket": zone_name = "Ashmarket"
    elif zone == "orchard": zone_name = "Glass Orchard"
    elif zone == "barracks": zone_name = "Quiet Barracks"
    elif zone == "assembly": zone_name = "Public Assembly / Emergency Rail"
    elif zone == "core": zone_name = "Full Freight Lift / Central Archives"
    elif zone == "lift": zone_name = "Freight Lift (Two-Writ Trial)"
    lines.append("CURRENT DISTRICT: %s" % zone_name)
    lines.append("FOUNDING WRITS: %d / 3 REQUIRED (FIVE OFFICES) • %s" % [Game.founding_writs_recorded_077().size(), ", ".join(Game.founding_writs_recorded_077())])
    sections.append({"tab": "The Ninth", "text": "\n".join(lines)})
    lines = []
    var brin: Dictionary = Game.state.get("brin", {})
    var ossa: Dictionary = Game.state.get("ossa", {})
    var hearing: Dictionary = Game.state.get("hearing", {})
    lines.append("[color=#bda77e][b]RELATIONSHIPS + RECORDS[/b][/color]")
    lines.append("BRIN: %s / %s / ALIVE %s" % [str(brin.get("stage", "unmet")), str(brin.get("decision", "")), str(brin.get("alive", true))])
    lines.append("OSSA: %s / %s / ALIVE %s" % [str(ossa.get("stage", "unmet")), str(ossa.get("decision", "")), str(ossa.get("alive", true))])
    lines.append("RELICS: %s" % ", ".join(Game.state["inventory"].get("relics", [])))
    lines.append("MOD REWARDS: %s" % ", ".join(Game.state["inventory"].get("mod_rewards", [])))
    lines.append("GROWTH WRIT: %s / VENN: %s" % [str(Game.state["writs"].has("qobj_writ_of_growth")),str(Game.state.get("venn",{}).get("decision",""))])
    lines.append("DEFENCE WRIT: %s / KEST: %s" % [str(Game.state["writs"].has("qobj_writ_of_defence")),str(Game.state.get("kest",{}).get("decision",""))])
    lines.append("RESTORATION CLUES: %s" % ", ".join(Game.state["inventory"].get("quest_items",[])))
    lines.append("FAITH WRIT: %s / METHOD: %s" % [str(Game.state["writs"].has("qobj_writ_of_faith")), str(Game.state.get("faith", {}).get("method", ""))])
    var trade: Dictionary = Game.state.get("trade",{})
    lines.append("TRADE WRIT: %s / METHOD: %s" % [str(Game.state["writs"].has("qobj_writ_of_trade")), str(trade.get("method", ""))])
    lines.append("ASHMARKET EVIDENCE: CONTRACTS %s / BUYER TESTIMONY %s / COALITION %s" % [str(trade.get("duplicate_contracts",false)), str(trade.get("buyer_testimony",false)), str(trade.get("coalition_recorded",false))])
    lines.append("THREE-WRIT QUORUM: %s / HEARING %s" % ["VERIFIED" if bool(trade.get("quorum_audit",false)) else "NOT YET VERIFIED", "PASSED" if bool(Game.state.get("hearing",{}).get("passed",false)) else "PENDING"])
    lines.append("ECHOFORM HEARING: %s / ROOTKIN LOANER / %s ATTEMPTS" % ["PASSED" if bool(hearing.get("passed", false)) else "NOT PASSED", str(hearing.get("attempts", 0))])
    var recent: Array = hearing.get("transcript", [])
    if not recent.is_empty():
        var recent_lines: Array[String] = []
        for command_record in recent.slice(maxi(0, recent.size() - 6), recent.size()):
            recent_lines.append("%s (integrity %s, strain %s)" % [str(command_record.get("command", "?")), str(command_record.get("integrity", "?")), str(command_record.get("strain_margin", "?"))])
        lines.append("TRANSCRIPT: " + "; ".join(recent_lines))
    var discovered: Dictionary = Game.state.get("discovery_067", {})
    lines.append("")
    lines.append("[color=#bda77e][b]OPTIONAL DISCOVERIES[/b][/color]")
    lines.append("WORKERS' RELIEF %s / INDEPENDENT CHOIR NOTES %s" % ["COPIED" if bool(discovered.get("sootworks_relief", false)) else "UNFOUND", "COPIED" if bool(discovered.get("basilica_notes", false)) else "UNFOUND"])
    lines.append("")
    lines.append("[color=#90a190]The transcript is preserved in the saved attempt, not a creature-ownership record.[/color]")
    sections.append({"tab": "Records", "text": "\n".join(lines)})
    lines = []
    var core: Dictionary = Game.state.get("core",{})
    lines.append("[color=#bda77e][b]FULL FREIGHT LIFT / CENTRAL CORE[/b][/color]")
    lines.append("THREE-WRIT QUORUM %s / SIGNED ORDER %s / OBJECTION %s / RAIL CHARTER %s" % [str(Game.state.get("trade",{}).get("quorum_audit",false)),str(core.get("order_read",false)),str(core.get("objection_heard",false)),str(core.get("rail_read",false))])
    lines.append("CUSTODIAN %s / METHOD %s / FATE %s" % [str(Game.core_custodian()),str(core.get("custodian_method","")),str(core.get("custodian_fate",""))])
    lines.append("RAIL SEATS %s (PROVISIONAL LOCAL CAPACITY) / BOARDING PLAN %s / PASSENGERS BOARDED 0" % [str(core.get("rail_capacity",24)),str(core.get("boarding_policy",""))])
    lines.append("UNIQUE MAINTENANCE CIPHER %s" % str(core.get("cipher_copied",false)))
    var civic: Dictionary = Game.state.get("civic",{})
    lines.append("")
    lines.append("[color=#bda77e][b]CIVIC ASSEMBLY / LIVE FINITE RAIL REGISTER[/b][/color]")
    lines.append("RISKS DISCLOSED %s / ORIGINAL PETITION %s / ASSENT %d OF 3" % [str(civic.get("risk_disclosed",false)),str(civic.get("petition_read",false)),Game.assembly_vote_count_078()])
    lines.append("MANDATE %s / REVOKED %s / TRUE DAWN TECHNICAL CLUES %s" % [str(civic.get("mandate",false)),str(civic.get("mandate_revoked",false)),str(Game.dawn_technical_prerequisites_078())])
    lines.append("RAIL STAGED %s / CAPACITY %s / BOARDING %s / GATE %s" % [str(civic.get("staged_seats",0)),str(core.get("rail_capacity",24)),str(civic.get("seats_used",0)),str(civic.get("rail_state","closed"))])
    # Released cohorts stay in the dictionary as false; list only staged ones.
    var staged_now: Array[String] = []
    for group in civic.get("staged_groups",{}).keys():
        if bool(civic["staged_groups"][group]): staged_now.append(str(group))
    lines.append("STAGED ROSTERS: %s" % (", ".join(staged_now) if not staged_now.is_empty() else "none"))
    lines.append("[color=#90a190]Any three Writs, signed original archives and the Custodian resolution precede the public assembly. Liberation, Dominion and The Crown are never blocked by goodwill points. True Dawn requires three separate clues and explicit revocable consent.[/color]")
    sections.append({"tab": "Endgame", "text": "\n".join(lines)})
    return sections

## Bible 13 docket: "known final prerequisites" and Office Trust -3..+3.
func _final_prerequisites_lines_089() -> Array[String]:
    var out: Array[String] = []
    var ok := func(v: bool) -> String: return "[color=#9fd18b]DONE[/color]" if v else "[color=#d9a05b]TODO[/color]"
    var writs: int = Game.founding_writs_recorded_077().size()
    var civic: Dictionary = Game.state.get("civic",{})
    out.append("[color=#bda77e][b]KNOWN FINAL PREREQUISITES[/b][/color]")
    out.append("%s  Three unique Writs from different offices (%d / 3)" % [ok.call(writs >= 3), mini(writs,3)])
    out.append("%s  Public Echoform hearing passed" % ok.call(bool(Game.state.get("hearing",{}).get("passed",false))))
    out.append("[color=#9fb7a4]TRUE DAWN ALSO NEEDS:[/color]")
    out.append("%s  Orchard root seed   %s  Deep heat survey   %s  Governor's cipher" % [ok.call(bool(Game.state.get("growth",{}).get("root_seed_found",false))), ok.call(bool(Game.state.get("defence",{}).get("heat_survey_found",false))), ok.call(bool(Game.state.get("core",{}).get("cipher_copied",false)))])
    if bool(civic.get("mandate_revoked",false)):
        out.append("[color=#e07a63]CLOSED  The public mandate was revoked. True Dawn is no longer possible this attempt.[/color]")
    else:
        out.append("%s  Public mandate: 3 constituencies (%d still possible)" % [ok.call(bool(civic.get("mandate",false))), Game.constituencies_possible_089()])
        for group in Game.CONSTITUENCY_NAMES_089.keys():
            var status: String = Game.constituency_status_089(group)
            var colour: String = "#9fd18b" if status == "verified" else ("#e07a63" if status.begins_with("closed") else "#d8d6c7")
            out.append("      [color=%s]%s: %s[/color]" % [colour, Game.CONSTITUENCY_NAMES_089[group], status.to_upper()])
        if Game.constituencies_possible_089() < 3:
            out.append("[color=#e07a63]True Dawn is no longer possible: fewer than three constituencies can vote.[/color]")
    out.append("%s  At least one cohort staged on the emergency rail   %s  Energy 3+ and Labour 2+ held back" % [ok.call(int(civic.get("staged_seats",0)) > 0), ok.call(int(Game.state["resources"].get("Energy",0)) >= 3 and int(Game.state["resources"].get("Labour",0)) >= 2)])
    out.append("")
    out.append("[color=#bda77e][b]OFFICE TRUST (-3 TO +3; NOT A MORALITY SCORE)[/b][/color]")
    var trust: Array[String] = []
    for office in ["Hearth Nine","Claimant Ward","Labour","Faith","Trade","Growth","Defence","Central Archive"]:
        trust.append("%s %+d" % [office.to_upper(), int(Game.state["relationships"].get(office,0))])
    out.append("   ".join(trust))
    return out
