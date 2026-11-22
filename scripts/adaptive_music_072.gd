extends Node
## The Ninth Exhale 07.2 — original ambient + combat soundtrack director.
## Four looped streams, fading continuously. No combat music when a story-only
## official stands nearby unless that official is actually hostile.
## Persists between district scene loads; never modifies campaign/save state.

const MUSIC = {
    "hearth": "res://assets/music/hearth_night_intake.ogg",
    "sootworks": "res://assets/music/sootworks_service_debt.ogg",
    "basilica": "res://assets/music/basilica_submerged_choir.ogg",
    "ashmarket": "res://assets/music/ashmarket_bonded_hours.ogg",
    "orchard": "res://assets/music/orchard_wet_lattice_077.ogg",
    "barracks": "res://assets/music/barracks_order_zero_077.ogg", # original procedural 07.5 district score
    "lift": "res://assets/music/hearth_night_intake.ogg",
    "core": "res://assets/music/core_first_signature_076.ogg",
    "assembly": "res://assets/music/core_first_signature_076.ogg",
    "combat": "res://assets/music/pressure_breach_combat.ogg"
}
const AudioMix093 = preload("res://scripts/audio_mix_093.gd")
const MusicLooper093 = preload("res://scripts/music_looper_093.gd")
const AMBIENT_GAIN: float = 0.30
const COMBAT_GAIN: float = 0.43
const CROSSFADE_TIME: float = 2.2
const COMBAT_ENGAGE_DISTANCE: float = 23.0
const AUTO_THREAT_DISTANCE: float = 13.0
const CALM_DELAY: float = 7.0

var listener: Node3D = null
var tracks: Dictionary = {}
var gains: Dictionary = {}
var trims: Dictionary = {}          # 09.3: per-layer level match (linear)
var combat_hold: float = 0.0
var active_combat: bool = false
var muted: bool = false
var user_music_volume: float = 0.70
var last_zone: String = "hearth"
var quitting: bool = false

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    # Window close goes through request_quit() so the music players are stopped
    # before the engine shuts down (otherwise "16 resources still in use at exit").
    get_tree().set_auto_accept_quit(false)
    for key in ["hearth","sootworks","basilica","ashmarket","orchard","barracks","core","assembly","combat"]:
        var path: String = str(MUSIC[key])
        # 09.3: the combat layer can be a replacement track looped on bar lines
        # (data/audio_mix_093.json); the original Ogg stays the fallback.
        if key == "combat":
            var profile: Dictionary = AudioMix093.music_profile("combat")
            if not profile.is_empty():
                var looper = MusicLooper093.new()
                looper.name = "Original music / combat (runway, looped)"
                add_child(looper)
                looper.configure(AudioMix093.stream_for(str(profile["path"])), float(profile.get("loop_start", 0.0)), float(profile.get("loop_end", 0.0)), float(profile.get("crossfade", 0.06)))
                looper.volume_db = -72.0
                tracks[key] = looper
                gains[key] = 0.0
                trims[key] = db_to_linear(float(profile.get("trim_db", 0.0)))
                continue
        if not ResourceLoader.exists(path):
            push_warning("Missing music layer: " + path)
            continue
        var track := AudioStreamPlayer.new()
        track.name = "Original music / " + key
        track.stream = load(path)
        # Ogg sample looping is set on the stream, avoiding restart crackle.
        if track.stream is AudioStreamOggVorbis:
            track.stream.loop = true
        track.bus = "Master"
        track.volume_db = -72.0
        add_child(track)
        tracks[key] = track
        gains[key] = 0.0

func set_listener(target: Node3D) -> void:
    listener = target
    if target == null:
        combat_hold = 0.0
        active_combat = false

func toggle_mute() -> void:
    muted = not muted

func set_music_volume(value: float) -> void:
    user_music_volume = clampf(value,0.0,1.0)

func _zone_key() -> String:
    if not Game.has_attempt():
        return "assembly" if str(Game.state.get("status","")) == "completed" else "hearth"
    var zone: String = str(Game.state.get("zone","hearth"))
    return zone if zone in ["hearth","sootworks","basilica","ashmarket","orchard","barracks","core","assembly"] else "hearth"

func _combat_threat_nearby() -> bool:
    if not Game.has_attempt() or not is_instance_valid(listener): return false
    # The player has already been defeated or is in a dialogue/menu.
    if not bool(listener.get("active")): return false
    for enemy in get_tree().get_nodes_in_group("hostile"):
        if not is_instance_valid(enemy) or not (enemy is Node3D):
            continue
        var foe: Node3D = enemy as Node3D
        var hp: int = int(foe.get("hp"))
        if hp <= 0: continue
        var distance: float = listener.global_position.distance_to(foe.global_position)
        var is_fighting: bool = bool(foe.get("hostile"))
        # 09.3: only enemies actually fighting start combat music. The old
        # "near an optional enemy" trigger played battle music beside guards
        # that had not noticed you, which gave stealth away (perception 09.2).
        if is_fighting and distance <= COMBAT_ENGAGE_DISTANCE:
            return true
    return false

func _process(delta: float) -> void:
    var zone: String = _zone_key()
    if last_zone != zone:
        last_zone = zone
        combat_hold = 0.0
        active_combat = false
    if _combat_threat_nearby():
        combat_hold = CALM_DELAY
        active_combat = true
    else:
        combat_hold = maxf(0.0,combat_hold - delta)
        if combat_hold <= 0.0: active_combat = false
    var transition_speed: float = delta / CROSSFADE_TIME
    for key in tracks.keys():
        var track = tracks[key]
        var is_ambient: bool = str(key) == zone and not active_combat
        var is_battle: bool = str(key) == "combat" and active_combat
        var target: float = AMBIENT_GAIN if is_ambient else (COMBAT_GAIN if is_battle else 0.0)
        var current: float = float(gains[key])
        current = move_toward(current,target,transition_speed * COMBAT_GAIN)
        gains[key] = current
        var gain: float = current * user_music_volume * (0.0 if muted else 1.0) * float(trims.get(key, 1.0))
        track.volume_db = linear_to_db(maxf(0.0001,gain))
        # Only audible layers decode. Previously all nine Ogg layers played
        # forever at -72 dB, costing CPU and leaking at exit.
        if current > 0.0 or target > 0.0:
            if not track.playing: track.play()
        elif track.playing:
            track.stop()

func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_CLOSE_REQUEST:
        request_quit()

## The single way the game should quit. Any AudioStreamPlayer still playing at
## shutdown (music layers, weapon voices, enemy barks) is reported by Godot as a
## leaked resource, so every player in the tree is stopped and released first,
## and the audio server is given a moment to drop its playbacks.
func request_quit(exit_code: int = 0) -> void:
    if quitting: return
    quitting = true
    set_process(false)
    _silence_all_players()
    # A playback started in the last frame or two can still be registered by the
    # audio server after the first stop, so silence again one frame later.
    await get_tree().process_frame
    _silence_all_players()
    # Shared combat VFX caches (static, so not freed with the scene tree).
    preload("res://scripts/combat_tracer_079x.gd").clear_shared_cache()
    preload("res://scripts/combat_impact_079.gd").clear_shared_cache()
    await get_tree().create_timer(0.2, true, false, true).timeout
    await get_tree().process_frame
    get_tree().quit(exit_code)

func _silence_all_players() -> void:
    for type_name in ["AudioStreamPlayer", "AudioStreamPlayer2D", "AudioStreamPlayer3D"]:
        for node in get_tree().root.find_children("*", type_name, true, false):
            node.stop()
            node.stream = null
