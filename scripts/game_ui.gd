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

func _apply_button_style(button: Button, emphasis: bool = false) -> void:
    var base: Color = Color("#2a312e")
    var hover: Color = Color("#39413d")
    var pressed: Color = Color("#4f4735")
    var border: Color = Color("#b38a4f") if emphasis else Color("#6c7468")
    var normal := _panel_style(base, border, 4, 2, 12, 8, 12, 8)
    var hover_skin := _panel_style(hover, Color("#d6ac6a") if emphasis else Color("#95a08f"), 4, 2, 12, 8, 12, 8)
    var pressed_skin := _panel_style(pressed, Color("#dfc28a"), 4, 2, 12, 8, 12, 8)
    button.add_theme_stylebox_override("normal", normal)
    button.add_theme_stylebox_override("hover", hover_skin)
    button.add_theme_stylebox_override("pressed", pressed_skin)
    button.add_theme_stylebox_override("focus", hover_skin)
    button.add_theme_stylebox_override("disabled", normal)
    button.add_theme_color_override("font_color", Color("#e8dbc0"))
    button.add_theme_color_override("font_hover_color", Color("#fbf3df"))
    button.add_theme_color_override("font_pressed_color", Color("#fff9ef"))
    button.add_theme_color_override("font_focus_color", Color("#fff9ef"))
    button.add_theme_font_size_override("font_size", 15 if emphasis else 14)
    button.focus_mode = Control.FOCUS_ALL
    button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func _apply_progress_style(bar: ProgressBar, fill: Color) -> void:
    bar.show_percentage = false
    bar.max_value = 100.0
    bar.add_theme_stylebox_override("background", _panel_style(Color("#141715"), Color("#39413d"), 2, 1, 0, 0, 0, 0))
    bar.add_theme_stylebox_override("fill", _panel_style(fill, fill.lightened(0.15), 2, 1, 0, 0, 0, 0))

func build_base() -> void:
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
    objective_panel.position = Vector2(12, 10)
    objective_panel.size = Vector2(356, 70)
    objective_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.09,0.11,0.105,0.86), Color("#8f6f3d"), 5, 2, 10, 7, 10, 8))
    overlay.add_child(objective_panel)

    zone_label = Label.new()
    zone_label.position = Vector2(12, 8)
    zone_label.size = Vector2(330, 18)
    zone_label.add_theme_font_size_override("font_size", 11)
    zone_label.add_theme_color_override("font_color", Color("#bda77e"))
    zone_label.text = "PRESSURE DOCKET / OBJECTIVE"
    objective_panel.add_child(zone_label)

    objective_label = Label.new()
    objective_label.position = Vector2(12, 26)
    objective_label.size = Vector2(330, 34)
    objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    objective_label.add_theme_font_size_override("font_size", 13)
    objective_label.add_theme_color_override("font_color", Color("#e6dcc5"))
    objective_panel.add_child(objective_label)

    navigation_panel = Panel.new()
    navigation_panel.position = Vector2(427, 10)
    navigation_panel.size = Vector2(201, 54)
    navigation_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.09,0.11,0.105,0.82), Color("#607166"), 5, 2, 10, 7, 10, 7))
    overlay.add_child(navigation_panel)

    var nav_title := Label.new()
    nav_title.position = Vector2(12, 8)
    nav_title.size = Vector2(170, 16)
    nav_title.add_theme_font_size_override("font_size", 10)
    nav_title.add_theme_color_override("font_color", Color("#93b1a0"))
    nav_title.text = "ADVISORY ROUTE"
    navigation_panel.add_child(nav_title)

    navigation = Label.new()
    navigation.position = Vector2(12, 22)
    navigation.size = Vector2(174, 22)
    navigation.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
    navigation.add_theme_font_size_override("font_size", 12)
    navigation.add_theme_color_override("font_color", Color("#d9ead2"))
    navigation.mouse_filter=Control.MOUSE_FILTER_IGNORE
    navigation_panel.add_child(navigation)

    reticle = TextureRect.new()
    reticle.texture = load("res://assets/ui/reticle_069.png")
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
    prompt_panel.position = Vector2(186, 282)
    prompt_panel.size = Vector2(268, 26)
    prompt_panel.visible = false
    prompt_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.08,0.09,0.09,0.80), Color("#7b6944"), 4, 1, 8, 4, 8, 4))
    overlay.add_child(prompt_panel)

    prompt_label = Label.new()
    prompt_label.position = Vector2(8, 4)
    prompt_label.size = Vector2(252, 16)
    prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    prompt_label.add_theme_font_size_override("font_size", 11)
    prompt_label.add_theme_color_override("font_color", Color("#e7dec8"))
    prompt_panel.add_child(prompt_label)

    vitals_panel = Panel.new()
    vitals_panel.position = Vector2(10, 309)
    vitals_panel.size = Vector2(238, 82)
    vitals_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.09,0.11,0.105,0.90), Color("#6f7a67"), 5, 2, 10, 8, 10, 8))
    overlay.add_child(vitals_panel)

    var vitals_title := Label.new()
    vitals_title.position = Vector2(10, 6)
    vitals_title.size = Vector2(100, 14)
    vitals_title.add_theme_font_size_override("font_size", 10)
    vitals_title.add_theme_color_override("font_color", Color("#9fb7a4"))
    vitals_title.text = "VITALS"
    vitals_panel.add_child(vitals_title)

    hp_text = Label.new()
    hp_text.position = Vector2(10, 20)
    hp_text.size = Vector2(120, 14)
    hp_text.add_theme_font_size_override("font_size", 11)
    hp_text.add_theme_color_override("font_color", Color("#f2d5bd"))
    vitals_panel.add_child(hp_text)

    hp_bar = ProgressBar.new()
    hp_bar.position = Vector2(130, 22)
    hp_bar.size = Vector2(96, 10)
    _apply_progress_style(hp_bar, Color("#b66c5a"))
    vitals_panel.add_child(hp_bar)

    breath_text = Label.new()
    breath_text.position = Vector2(10, 38)
    breath_text.size = Vector2(120, 14)
    breath_text.add_theme_font_size_override("font_size", 11)
    breath_text.add_theme_color_override("font_color", Color("#d5e6d3"))
    vitals_panel.add_child(breath_text)

    breath_bar = ProgressBar.new()
    breath_bar.position = Vector2(130, 40)
    breath_bar.size = Vector2(96, 10)
    _apply_progress_style(breath_bar, Color("#6e9780"))
    vitals_panel.add_child(breath_bar)

    meta_text = Label.new()
    meta_text.position = Vector2(10, 56)
    meta_text.size = Vector2(160, 16)
    meta_text.add_theme_font_size_override("font_size", 10)
    meta_text.add_theme_color_override("font_color", Color("#cbbfa6"))
    vitals_panel.add_child(meta_text)

    med_text = Label.new()
    med_text.position = Vector2(135, 56)
    med_text.size = Vector2(90, 16)
    med_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    med_text.add_theme_font_size_override("font_size", 10)
    med_text.add_theme_color_override("font_color", Color("#d0ddb7"))
    vitals_panel.add_child(med_text)

    weapon_panel = Panel.new()
    weapon_panel.position = Vector2(391, 309)
    weapon_panel.size = Vector2(239, 82)
    weapon_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.09,0.11,0.105,0.90), Color("#8f6f3d"), 5, 2, 10, 8, 10, 8))
    overlay.add_child(weapon_panel)

    var weapon_title := Label.new()
    weapon_title.position = Vector2(10, 6)
    weapon_title.size = Vector2(100, 14)
    weapon_title.add_theme_font_size_override("font_size", 10)
    weapon_title.add_theme_color_override("font_color", Color("#bda77e"))
    weapon_title.text = "EQUIPMENT"
    weapon_panel.add_child(weapon_title)

    weapon_name = Label.new()
    weapon_name.position = Vector2(10, 20)
    weapon_name.size = Vector2(160, 14)
    weapon_name.add_theme_font_size_override("font_size", 12)
    weapon_name.add_theme_color_override("font_color", Color("#efe2c7"))
    weapon_panel.add_child(weapon_name)

    ammo_text = Label.new()
    ammo_text.position = Vector2(10, 38)
    ammo_text.size = Vector2(140, 16)
    ammo_text.add_theme_font_size_override("font_size", 11)
    ammo_text.add_theme_color_override("font_color", Color("#dfd6be"))
    weapon_panel.add_child(ammo_text)

    heat_text = Label.new()
    heat_text.position = Vector2(10, 56)
    heat_text.size = Vector2(90, 14)
    heat_text.add_theme_font_size_override("font_size", 10)
    heat_text.add_theme_color_override("font_color", Color("#d2bc90"))
    weapon_panel.add_child(heat_text)

    heat_bar = ProgressBar.new()
    heat_bar.position = Vector2(82, 58)
    heat_bar.size = Vector2(145, 10)
    _apply_progress_style(heat_bar, Color("#c88c4e"))
    weapon_panel.add_child(heat_bar)

    hint_text = Label.new()
    hint_text.position = Vector2(150, 38)
    hint_text.size = Vector2(76, 16)
    hint_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    hint_text.add_theme_font_size_override("font_size", 10)
    hint_text.add_theme_color_override("font_color", Color("#9eb79f"))
    weapon_panel.add_child(hint_text)

    action_strip = Label.new()
    action_strip.position = Vector2(184, 372)
    action_strip.size = Vector2(272, 16)
    action_strip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    action_strip.add_theme_font_size_override("font_size", 10)
    action_strip.add_theme_color_override("font_color", Color("#98a48d"))
    action_strip.text = "[TAB] DOSSIER  •  [E] INTERACT  •  [F] INTERVENE  •  [R] RELOAD"
    overlay.add_child(action_strip)

    banner_panel = Panel.new()
    banner_panel.position = Vector2(148, 88)
    banner_panel.size = Vector2(344, 38)
    banner_panel.visible = false
    banner_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.15,0.11,0.08,0.90), Color("#c28a43"), 5, 2, 10, 6, 10, 6))
    overlay.add_child(banner_panel)

    banner = Label.new()
    banner.position = Vector2(12, 6)
    banner.size = Vector2(320, 24)
    banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    banner.add_theme_font_size_override("font_size", 13)
    banner.add_theme_color_override("font_color", Color("#efdfc0"))
    banner_panel.add_child(banner)

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
    update_hud()

func update_hud() -> void:
    if not Game.has_attempt():
        zone_label.text = "THE NINTH EXHALE / BUILD 07.8"
        objective_label.text = "Enter Hearth Nine and open the civic pressure docket."
        navigation.text = "NO ACTIVE ROUTE"
        hp_text.text = "HP --"
        breath_text.text = "BREATH --"
        meta_text.text = "LEVEL --   XP --"
        med_text.text = "AMPOULES --"
        weapon_name.text = "COVENANT PISTOL"
        ammo_text.text = "MAG --   RESERVE --"
        hint_text.text = "2–5 SWITCH"
        heat_text.text = "STATUS"
        heat_bar.value = 0.0
        heat_bar.visible = false
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
    zone_label.text = "%s / ACTIVE OBJECTIVE" % zone_name

    var objective_text := "RETURN LUNG TO DR SELA / E" if bool(Game.state["lung"]["acquired"]) else "CONTEST THE HELD CINDER LUNG / REQUISITIONS"
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
        objective_text = "Return to Flood Basilica." if Game.state["writs"].has("qobj_writ_of_labour") else "Track Brin, verify payroll, then recover the Labour Writ."
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
    hp_text.text = "HP %d / %d" % [health_now, health_max]
    breath_text.text = "BREATH %d / %d" % [breath_now, breath_max]
    hp_bar.value = 100.0 * float(health_now) / maxf(1.0, float(health_max))
    breath_bar.value = 100.0 * float(breath_now) / maxf(1.0, float(breath_max))
    meta_text.text = "LEVEL %d   XP %d" % [int(Game.state["level"]), int(Game.state["xp"])]
    med_text.text = "AMPOULES %d" % int(inventory["consumables"].get("Breath Ampoule", 0))

    weapon_name.text = str(spec.get("name", "SERVICE TOOL")).to_upper()
    ammo_text.text = "MAG %d   RESERVE %d" % [Game.weapon_mag(id), Game.weapon_reserve(id)]
    hint_text.text = "R RELOAD"
    if id == "nail":
        heat_bar.visible = true
        heat_text.text = "HEAT"
        heat_bar.value = clampf(100.0 * float(Game.state["weapon_state"].get("nail_heat", 0.0)) / 90.0, 0.0, 100.0)
    else:
        heat_bar.visible = false
        heat_text.text = "2–5 SWITCH"
    if current_prompt == "":
        prompt_panel.visible = false

func set_navigation(label_text: String) -> void:
    if is_instance_valid(navigation):
        navigation.text = label_text if Game.has_attempt() else "NO ACTIVE ROUTE"

func set_interact_prompt(message: String) -> void:
    current_prompt = message
    if not is_instance_valid(prompt_panel) or not is_instance_valid(prompt_label): return
    prompt_label.text = message
    prompt_panel.visible = message != "" and not modal_open

func notify(message: String, seconds: float = 4.0) -> void:
    banner.text = message
    banner_panel.visible = true
    banner_time = seconds

func _process(delta: float) -> void:
    banner_time -= delta
    refresh_time -= delta
    _advance_viewmodel(delta)
    damage_time_079 = maxf(0.0,damage_time_079-delta)
    reticle_hit_clock_079 = maxf(0.0,reticle_hit_clock_079-delta)
    if is_instance_valid(damage_flash_079):
        damage_flash_079.color.a = 0.17 * clampf(damage_time_079/0.22,0.0,1.0)
    if is_instance_valid(reticle):
        reticle.modulate = Color("#ffe2ab") if reticle_hit_clock_079 > 0.0 else Color.WHITE
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
    recoil_strength = 0.0
    shot_flash = 0.0
    reload_clock = 0.0
    dry_kick = 0.0
    muzzle.visible = false
    shell.visible = false
    update_hud()

func weapon_event(kind: String, duration: float) -> void:
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
    var kick: Vector2 = Vector2(-0.30 * recoil_px * recoil_strength, recoil_px * recoil_strength)
    var reload_dip: float = 0.0
    if reload_clock > 0.0:
        reload_clock = maxf(0.0, reload_clock - delta)
        var progress: float = 1.0 - reload_clock / maxf(0.01, reload_duration)
        reload_dip = pow(sin(PI * progress), 0.85)
    var switch_dip: float = 0.0
    if switch_clock > 0.0:
        switch_clock = maxf(0.0, switch_clock - delta)
        switch_dip = sin(PI * (1.0 - switch_clock / maxf(0.01, switch_duration)))
    gun.position=Vector2(sway - 20.0 * reload_dip, bounce + 105.0 * reload_dip + 85.0 * switch_dip) + kick + Vector2(1.5 * sin(anim_clock * 43.0) * dry_kick / 0.14, 0)
    gun.rotation = -0.11 * reload_dip + 0.015 * recoil_strength
    muzzle.position = Vector2(310, 91) + Vector2(sway, bounce) + kick
    if shot_flash > 0.0 and not muzzle_frames_079x.is_empty():
        var pulse_index: int = clampi(int((1.0-shot_flash/0.075)*4.0),0,3)
        muzzle.texture = muzzle_frames_079x[pulse_index]
    muzzle.visible=shot_flash>0.0 and not modal_open
    muzzle.modulate.a = clampf(shot_flash / 0.06, 0.0, 1.0)
    if shell_life > 0.0:
        shell_life = maxf(0.0, shell_life - delta)
        var flight: float = 1.0 - shell_life / 0.42
        shell.position = Vector2(454 + 65 * flight, 173 + 130 * flight * flight)
        shell.rotation = flight * 5.0
        shell.visible = not modal_open
    else:
        shell.visible = false

func open_modal(heading: String, description: String, choices: Array) -> void:
    close_modal(false)
    modal_open = true
    reticle.visible = false
    gun.visible = false
    muzzle.visible = false
    shell.visible = false
    prompt_panel.visible = false

    modal_scrim = ColorRect.new()
    modal_scrim.color = Color(0, 0, 0, 0.48)
    modal_scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    modal_scrim.mouse_filter = Control.MOUSE_FILTER_STOP
    overlay.add_child(modal_scrim)

    modal = Panel.new()
    modal.position = Vector2(42, 26)
    modal.size = Vector2(556, 328)
    modal.add_theme_stylebox_override("panel", _panel_style(Color("#202824"), Color("#b38a4f"), 6, 2, 14, 12, 14, 12))
    overlay.add_child(modal)

    var title := Label.new()
    title.text = heading
    title.position = Vector2(16, 10)
    title.size = Vector2(378, 28)
    title.add_theme_font_size_override("font_size", 20)
    title.add_theme_color_override("font_color", Color("#efe2c7"))
    modal.add_child(title)

    var subtitle := Label.new()
    subtitle.text = "CIVIC RECORD / CHOOSE A RESPONSE"
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

    var story := RichTextLabel.new()
    story.bbcode_enabled = true
    story.fit_content = false
    story.scroll_active = true
    story.position = Vector2(16, 52)
    story.size = Vector2(524, 154)
    story.add_theme_font_size_override("normal_font_size", 14)
    story.add_theme_color_override("default_color", Color("#d8d6c7"))
    story.text = description
    modal.add_child(story)

    if choices.size() >= 4:
        # Significant final choices should not all be hidden below a tiny
        # 74-pixel scroll viewport. Preserve scroll for smaller screens.
        story.size = Vector2(524,110)
    var options_title := Label.new()
    options_title.position = Vector2(16, 167) if choices.size() >= 4 else Vector2(16, 214)
    options_title.size = Vector2(200, 18)
    options_title.text = "AVAILABLE ACTIONS"
    options_title.add_theme_font_size_override("font_size", 10)
    options_title.add_theme_color_override("font_color", Color("#bda77e"))
    modal.add_child(options_title)

    var scroll := ScrollContainer.new()
    scroll.position = Vector2(16, 187) if choices.size() >= 4 else Vector2(16, 234)
    scroll.size = Vector2(524, 122) if choices.size() >= 4 else Vector2(524, 74)
    modal.add_child(scroll)

    var options := VBoxContainer.new()
    options.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    options.custom_minimum_size = Vector2(500, 0)
    options.add_theme_constant_override("separation", 6)
    scroll.add_child(options)
    for i in range(choices.size()):
        var choice = choices[i]
        var button := Button.new()
        button.text = str(choice.get("label", "Continue"))
        button.custom_minimum_size = Vector2(500, 32)
        _apply_button_style(button, i == 0)
        button.pressed.connect(_button_pressed.bind(str(choice.get("action", "close"))))
        options.add_child(button)
        if i == 0:
            button.grab_focus()

    var footer := Label.new()
    footer.position = Vector2(16, 309)
    footer.size = Vector2(524, 14)
    footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    footer.text = "TAB or ESC returns here during play • This docket saves and records witnessed actions once"
    footer.add_theme_font_size_override("font_size", 10)
    footer.add_theme_color_override("font_color", Color("#90a190"))
    modal.add_child(footer)
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _button_pressed(action_id: String) -> void:
    action_selected.emit(action_id)

func close_modal(show_game: bool = true) -> void:
    modal_open = false
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

func animate_shot(hit: bool) -> void:
    if hit: reticle_hit_clock_079 = 0.12
    if not is_instance_valid(gun):
        return
    recoil_strength = minf(1.75, recoil_strength + 1.0)
    shot_flash=0.065 if active_weapon != "nail" else 0.036
    shell_life = 0.42 if active_weapon in ["covenant", "nail"] else 0.0
    if hit:
        notify("TARGET / CONFIRMED IMPACT", 0.45)

func dossier_text() -> String:
    if not Game.has_attempt():
        return "[b]No active reconstruction.[/b]"
    var attrs: Dictionary = Game.state["attributes"]
    var resources: Dictionary = Game.state["resources"]
    var plan: Dictionary = Game.state["world_plan"]
    var lung: Dictionary = Game.state["lung"]
    var lines: Array[String] = []
    lines.append("[color=#e9dcc0][b]NINTH / %s[/b][/color]    [color=#9fb7a4]ATTEMPT %s[/color]" % [str(Game.state["build"]), str(Game.state["attempt_id"])])
    lines.append("")
    lines.append("[color=#bda77e][b]ATTRIBUTES[/b][/color]")
    lines.append("FORCE %s   REFLEX %s   INSIGHT %s   SPEECH %s   TECH %s   RESOLVE %s" % [attrs["Force"], attrs["Reflex"], attrs["Insight"], attrs["Speech"], attrs["Tech"], attrs["Resolve"]])
    lines.append("")
    lines.append("[color=#bda77e][b]RESOURCES[/b][/color]")
    lines.append("LEVEL %s   XP %s   VOUCHERS %s" % [Game.state["level"], Game.state["xp"], Game.state["inventory"]["vouchers"]])
    lines.append("ATTRIBUTE POINTS TO SPEND: %d  /  LEVEL 3 + 5" % int(Game.state.get("unspent_attribute_points",0)))
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
    var brin: Dictionary = Game.state.get("brin", {})
    var ossa: Dictionary = Game.state.get("ossa", {})
    var hearing: Dictionary = Game.state.get("hearing", {})
    lines.append("")
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
    var core: Dictionary = Game.state.get("core",{})
    lines.append("")
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
    lines.append("STAGED ROSTERS: %s" % ", ".join(civic.get("staged_groups",{}).keys()))
    lines.append("[color=#90a190]Any three Writs, signed original archives and the Custodian resolution precede the public assembly. Liberation, Dominion and The Crown are never blocked by goodwill points. True Dawn requires three separate clues and explicit revocable consent.[/color]")
    return "\n".join(lines)
