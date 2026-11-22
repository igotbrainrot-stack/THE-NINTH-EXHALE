extends Control
## Build 09.0 HUD feedback layer (procedural, no new art):
## - civic STAMP: the signature moment for recorded milestones (Writ, level, perk,
##   hearing, Lung). Vesper is a city of witnessed records, so big moments are
##   stamped onto the screen in vermilion ink, one at a time.
## - notice SLIPS: stacked filing slips replacing the single overwritten banner.
## - edge VIGNETTE: red pressure at the screen edge on damage and at low health.
## - HIT/KILL marker around the reticle, replacing the old banner spam.
## - DAMAGE TRAIL on the health and breath bars.

const INK := Color("#a94d3b")
const INK_DARK := Color("#5e231a")
const SLIP_TEXT := Color("#171918")
const MAX_SLIPS := 3
const SLIP_ORIGIN := Vector2(408, 40)
const SLIP_SIZE := Vector2(224, 22)

var ui: Node                       # game_ui.gd
var slips: Array[Control] = []
var stamp_queue: Array = []
var stamp_node: Control = null
var vignette: ColorRect
var damage_pulse: float = 0.0
var low_health: float = 0.0
var pulse_clock: float = 0.0
var marker: Control
var marker_time: float = 0.0
var marker_kill: bool = false
var trails: Dictionary = {}        # bar -> {"rect": ColorRect, "from": float, "hold": float}
var thud: AudioStreamPlayer
var watch: Dictionary = {}         # last seen state for milestone detection

const VIGNETTE_SHADER := """
shader_type canvas_item;
uniform float intensity = 0.0;
uniform vec4 tint : source_color = vec4(0.66, 0.16, 0.11, 1.0);
void fragment() {
    vec2 p = UV * 2.0 - 1.0;
    p.x *= 1.3;
    float edge = smoothstep(0.62, 1.42, length(p));
    COLOR = vec4(tint.rgb, clamp(edge * intensity, 0.0, 0.78));
}
"""

func setup(owner_ui: Node) -> void:
    ui = owner_ui
    name = "HudFx090"
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    vignette = ColorRect.new()
    vignette.name = "PressureVignette"
    vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
    vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var mat := ShaderMaterial.new()
    var shader := Shader.new()
    shader.code = VIGNETTE_SHADER
    mat.shader = shader
    vignette.material = mat
    add_child(vignette)
    marker = Control.new()
    marker.name = "HitMarker"
    marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
    marker.position = Vector2(320, 200)
    marker.draw.connect(_draw_marker)
    add_child(marker)
    thud = AudioStreamPlayer.new()
    thud.stream = load("res://assets/audio/metal_hit.wav")
    thud.volume_db = -14.0
    thud.pitch_scale = 0.55
    add_child(thud)

# ---------------------------------------------------------------- slips
func slip(message: String, seconds: float = 4.0) -> void:
    # A repeat of a notice still on screen refreshes it with a count instead
    # of stacking copies ("PISTOL EMPTY" three times told the player nothing).
    for existing in slips:
        if is_instance_valid(existing) and str(existing.get_meta("message", "")) == message:
            var count: int = int(existing.get_meta("count", 1)) + 1
            existing.set_meta("count", count)
            existing.set_meta("age", 0.0)
            existing.set_meta("life", maxf(seconds, float(existing.get_meta("life"))))
            existing.modulate.a = 1.0
            (existing.get_child(0) as Label).text = "%s  ×%d" % [message, count]
            return
    var panel := Panel.new()
    panel.set_meta("message", message)
    panel.set_meta("count", 1)
    panel.name = "NoticeSlip"
    panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    # A filing slip: aged paper with a brass spine, readable over any scene.
    var paper := StyleBoxFlat.new()
    paper.bg_color = Color("#e1d1a6", 0.94)
    paper.border_color = Color("#b38a4f")
    paper.border_width_left = 4
    paper.border_width_bottom = 1
    paper.shadow_color = Color(0, 0, 0, 0.45)
    paper.shadow_size = 2
    paper.shadow_offset = Vector2(1, 1)
    panel.add_theme_stylebox_override("panel", ui.hud_optional_skin("hud_slip", paper))
    add_child(panel)
    var label := Label.new()
    label.text = message
    label.position = Vector2(10, 2)
    # Instructions ("...FIND THE MANUAL VALVE AT THE NORTH DOOR") must be read
    # whole, so slips wrap to up to three lines instead of trimming.
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    # clip_text stops the wrapped label from imposing its own (taller) minimum
    # height; the slip is sized from the measured text instead.
    label.clip_text = true
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    label.add_theme_font_size_override("font_size", 10)
    label.add_theme_constant_override("line_spacing", -2)
    label.add_theme_color_override("font_color", SLIP_TEXT)
    panel.add_child(label)
    var font: Font = label.get_theme_font("font")
    var width: float = SLIP_SIZE.x - 16.0
    var text_h: float = font.get_multiline_string_size(message, HORIZONTAL_ALIGNMENT_LEFT, width, 10, 3).y
    var height: float = maxf(SLIP_SIZE.y, minf(text_h, 42.0) + 6.0)
    panel.size = Vector2(SLIP_SIZE.x, height)
    label.size = Vector2(width, height - 4.0)
    panel.set_meta("life", seconds)
    panel.set_meta("age", 0.0)
    slips.push_front(panel)
    while slips.size() > MAX_SLIPS:
        var old: Control = slips.pop_back()
        old.queue_free()
    _layout_slips(true)

func _layout_slips(animate_newest: bool) -> void:
    var y: float = 0.0
    for i in range(slips.size()):
        var s: Control = slips[i]
        var target := SLIP_ORIGIN + Vector2(0, y)
        y += s.size.y + 3.0
        # A slip still sliding in from the previous notice must not finish its
        # old move after this one, or two slips end up stacked on one spot.
        # (get_meta with a null default still errors in 4.4, so test first.)
        if s.has_meta("move_tween"):
            var old_tween = s.get_meta("move_tween")
            if old_tween is Tween and (old_tween as Tween).is_valid(): (old_tween as Tween).kill()
        if i == 0 and animate_newest:
            s.position = target + Vector2(40, 0)
            s.modulate.a = 0.0
            var t := s.create_tween().set_parallel(true)
            t.tween_property(s, "position", target, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
            t.tween_property(s, "modulate:a", 1.0, 0.12)
            s.set_meta("move_tween", t)
        else:
            s.modulate.a = maxf(s.modulate.a, 1.0) if float(s.get_meta("age", 0.0)) <= float(s.get_meta("life", 1.0)) else s.modulate.a
            var t2 := s.create_tween()
            t2.tween_property(s, "position", target, 0.12)
            s.set_meta("move_tween", t2)

# ---------------------------------------------------------------- stamp
func stamp(title: String, detail: String = "") -> void:
    stamp_queue.append([title, detail])
    if stamp_node == null: _next_stamp()

func _next_stamp() -> void:
    if stamp_queue.is_empty():
        stamp_node = null
        return
    var item: Array = stamp_queue.pop_front()
    var box := Panel.new()
    box.name = "CivicStamp"
    box.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var outer := StyleBoxFlat.new()
    outer.bg_color = Color(0.09, 0.10, 0.09, 0.72)
    outer.border_color = INK
    outer.set_border_width_all(3)
    outer.set_corner_radius_all(3)
    # A painted stamp frame (hud_091/hud_stamp_frame.png) replaces both the
    # flat border and the inner rule when GPT delivers one.
    var painted: bool = ui.hud_art_has_override("hud_stamp_frame")
    box.add_theme_stylebox_override("panel", ui.hud_optional_skin("hud_stamp_frame", outer))
    add_child(box)
    box.size = Vector2(300, 74)
    box.position = Vector2(170, 128)
    box.pivot_offset = box.size / 2.0
    var inner := Panel.new()
    inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var inner_style := StyleBoxFlat.new()
    inner_style.bg_color = Color(0, 0, 0, 0)
    inner_style.border_color = Color(INK, 0.85)
    inner_style.set_border_width_all(1)
    inner.add_theme_stylebox_override("panel", inner_style)
    inner.visible = not painted
    box.add_child(inner)
    inner.position = Vector2(6, 6)
    inner.size = box.size - Vector2(12, 12)
    var head := Label.new()
    head.text = str(item[0]).to_upper()
    head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    head.add_theme_font_size_override("font_size", 24)
    head.add_theme_color_override("font_color", INK)
    head.add_theme_color_override("font_outline_color", Color(INK_DARK, 0.8))
    head.add_theme_constant_override("outline_size", 2)
    box.add_child(head)
    head.position = Vector2(8, 10)
    head.size = Vector2(284, 30)
    var sub := Label.new()
    sub.text = str(item[1])
    sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    sub.clip_text = true
    sub.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
    sub.add_theme_font_size_override("font_size", 11)
    sub.add_theme_color_override("font_color", Color("#e6dcc5"))
    sub.add_theme_color_override("font_outline_color", Color("#171918"))
    sub.add_theme_constant_override("outline_size", 3)
    box.add_child(sub)
    sub.position = Vector2(8, 44)
    sub.size = Vector2(284, 18)
    box.rotation = deg_to_rad(-4.0)
    box.scale = Vector2(1.7, 1.7)
    box.modulate.a = 0.0
    stamp_node = box
    var t := box.create_tween()
    t.tween_property(box, "scale", Vector2.ONE, 0.11).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
    t.parallel().tween_property(box, "modulate:a", 0.96, 0.09)
    t.tween_callback(func(): if is_instance_valid(thud) and thud.stream != null: thud.play())
    t.tween_property(box, "position", box.position + Vector2(2, 1), 0.03)
    t.tween_property(box, "position", box.position, 0.03)
    t.tween_interval(1.5)
    t.tween_property(box, "modulate:a", 0.0, 0.45)
    t.tween_callback(func():
        box.queue_free()
        _next_stamp())

# ---------------------------------------------------------------- feedback
func damage_taken(amount: int) -> void:
    damage_pulse = clampf(damage_pulse + 0.55 + float(amount) * 0.015, 0.0, 1.0)

func shot_result(hit: bool, killed: bool) -> void:
    if not hit: return
    marker_kill = killed
    marker_time = 0.32 if killed else 0.13
    marker.queue_redraw()
    if killed and is_instance_valid(thud) and thud.stream != null:
        thud.pitch_scale = 0.8
        thud.play()
        thud.pitch_scale = 0.55

func _draw_marker() -> void:
    if marker_time <= 0.0: return
    var col := INK if marker_kill else Color("#e6dcc5")
    var gap := 5.0 if not marker_kill else 4.0
    var arm := 4.0 if not marker_kill else 7.0
    var w := 1.0 if not marker_kill else 2.0
    for d in [Vector2(1,1), Vector2(-1,1), Vector2(1,-1), Vector2(-1,-1)]:
        var dir: Vector2 = d.normalized()
        marker.draw_line(dir * gap, dir * (gap + arm), col, w, false)

## A pale chunk on a bar marks the value just lost, then drains away.
func track_bar(bar: ProgressBar, new_value: float) -> void:
    if not is_instance_valid(bar): return
    var info: Dictionary = trails.get(bar, {})
    if info.is_empty():
        var rect := ColorRect.new()
        rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
        rect.color = Color("#efe2c7", 0.75)
        rect.visible = false
        bar.add_child(rect)
        info = {"rect": rect, "from": new_value, "hold": 0.0, "last": new_value}
        trails[bar] = info
    # Hold only when the value actually fell since the last refresh; otherwise
    # the 0.15 s HUD refresh would keep the trail frozen.
    if new_value < float(info["last"]) - 0.5:
        info["hold"] = 0.35
    if new_value > float(info["from"]):
        info["from"] = new_value
    info["last"] = new_value
    var rect: ColorRect = info["rect"]
    _place_trail(bar, rect, new_value, float(info["from"]))

func _place_trail(bar: ProgressBar, rect: ColorRect, now: float, from: float) -> void:
    var span: float = maxf(bar.max_value - bar.min_value, 1.0)
    var inner := Rect2(Vector2(2, 2), bar.size - Vector2(4, 4))
    var x0: float = inner.position.x + inner.size.x * clampf((now - bar.min_value) / span, 0.0, 1.0)
    var x1: float = inner.position.x + inner.size.x * clampf((from - bar.min_value) / span, 0.0, 1.0)
    rect.visible = x1 - x0 >= 1.0
    rect.position = Vector2(x0, inner.position.y)
    rect.size = Vector2(maxf(0.0, x1 - x0), inner.size.y)

# ---------------------------------------------------------------- milestones
## Polled from the HUD refresh: stamps and slips for recorded state changes, so
## every route that grants a Writ or passes the hearing is covered.
func watch_state() -> void:
    if not Game.has_attempt():
        watch.clear()
        return
    var attempt: String = str(Game.state.get("attempt_id", ""))
    var writs: Array = Game.state.get("writs", [])
    var passed: bool = bool(Game.state.get("hearing", {}).get("passed", false))
    var lung: bool = bool(Game.state.get("lung", {}).get("installed", false))
    var level: int = int(Game.state.get("level", 1))
    var perks: Array = Game.state.get("perks", [])
    var evidence: int = 0
    var keepers: int = 0
    for e in Game.state.get("events", []):
        var kind: String = str(e.get("kind", ""))
        if kind in ["evidence", "original_evidence"]: evidence += 1
        elif kind == "keeper_defeated": keepers += 1
    if str(watch.get("attempt", "")) != attempt:
        watch = {"attempt": attempt, "writs": writs.size(), "passed": passed, "lung": lung,
            "evidence": evidence, "level": level, "perks": perks.size(), "keepers": keepers}
        return
    if level > int(watch["level"]):
        stamp("Level %d" % level, "Spend the new point in the docket (TAB)")
    if perks.size() > int(watch["perks"]):
        stamp("Perk recorded", _perk_name(str(perks.back())))
    if keepers > int(watch["keepers"]):
        stamp("Custodian defeated", "The ward's keeper is on the record")
    if writs.size() > int(watch["writs"]):
        var office: String = str(writs.back()).trim_prefix("qobj_writ_of_").capitalize()
        stamp("Writ recorded", "%s office  ·  %d of 3 for the quorum" % [office, mini(writs.size(), 3)])
    if passed and not bool(watch["passed"]):
        stamp("Hearing passed", "The public interference hearing is on record")
    if lung and not bool(watch["lung"]):
        stamp("Lung installed", "Hearth Nine breathes; the cost is in the ledger")
    if evidence > int(watch["evidence"]):
        slip("EVIDENCE FILED / DOCKET (TAB)", 3.5)
    watch["writs"] = writs.size(); watch["passed"] = passed; watch["lung"] = lung; watch["evidence"] = evidence
    watch["level"] = level; watch["perks"] = perks.size(); watch["keepers"] = keepers

func _perk_name(id: String) -> String:
    if Game.PERKS_089.has(id):
        return "%s  %s" % [id, str(Game.PERKS_089[id].get("name", ""))]
    return id

func _process(delta: float) -> void:
    pulse_clock += delta
    damage_pulse = maxf(0.0, damage_pulse - delta * 1.9)
    var target_low: float = 0.0
    if Game.has_attempt():
        var frac: float = float(Game.state.get("health", 0)) / maxf(1.0, float(Game.max_health()))
        if frac < 0.3: target_low = 0.32 + 0.16 * sin(pulse_clock * 5.0) + (0.3 - frac)
    low_health = lerpf(low_health, target_low, clampf(delta * 6.0, 0.0, 1.0))
    var modal_open: bool = ui != null and bool(ui.modal_open)
    for sl in slips:
        if is_instance_valid(sl): sl.visible = not modal_open
    (vignette.material as ShaderMaterial).set_shader_parameter("intensity", 0.0 if modal_open else maxf(damage_pulse, low_health))
    if marker_time > 0.0:
        marker_time -= delta
        marker.queue_redraw()
    for bar in trails.keys():
        if not is_instance_valid(bar): continue
        var info: Dictionary = trails[bar]
        if float(info["hold"]) > 0.0:
            info["hold"] = float(info["hold"]) - delta
        else:
            info["from"] = move_toward(float(info["from"]), bar.value, (bar.max_value - bar.min_value) * delta * 0.9)
        _place_trail(bar, info["rect"], bar.value, float(info["from"]))
    var changed: bool = false
    for s in slips.duplicate():
        if modal_open: break   # notices wait while the docket is read
        var age: float = float(s.get_meta("age")) + delta
        s.set_meta("age", age)
        var life: float = float(s.get_meta("life"))
        if age > life:
            s.modulate.a = maxf(0.0, 1.0 - (age - life) / 0.3)
            if age > life + 0.3:
                slips.erase(s); s.queue_free(); changed = true
    if changed: _layout_slips(false)
