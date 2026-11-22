extends Node
## Build 09.3 weapon fire audio (child of the player). See audio_mix_093.gd for
## the modes. Dedicated players per mode, so long replacement sounds never
## steal the shared 8-voice action pool used by footsteps, hits and barks.

const Mix = preload("res://scripts/audio_mix_093.gd")

var one_shot_voices: Array[AudioStreamPlayer] = []
var one_shot_next: int = 0
var burst_voice: AudioStreamPlayer
var mono_voice: AudioStreamPlayer
var burst_clock: float = 99.0      # seconds since the burst bed was (re)started
var since_shot: float = 99.0       # seconds since the last burst-mode shot
var burst_release: float = 0.12
var burst_hold: float = 0.15       # gap after the last shot before releasing
var burst_db: float = -17.0
var last_mode: String = ""         # tests read these
var last_stream_path: String = ""

func _ready() -> void:
    name = "WeaponAudio093"
    for i in 3:
        var v := AudioStreamPlayer.new()
        v.name = "OneShot%d" % i
        add_child(v)
        one_shot_voices.append(v)
    burst_voice = AudioStreamPlayer.new()
    burst_voice.name = "BurstBed"
    add_child(burst_voice)
    mono_voice = AudioStreamPlayer.new()
    mono_voice.name = "MonoTone"
    add_child(mono_voice)

## Plays the fire sound for `id`. Returns false when the weapon has no usable
## replacement, so the caller plays the original fallback WAV instead.
## `attack` is a Callable(file_name, volume_db) for the layered fallback.
func fire(id: String, attack: Callable) -> bool:
    var profile: Dictionary = Mix.weapon_profile(id)
    if profile.is_empty():
        last_mode = "fallback"
        return false
    var stream: AudioStream = Mix.stream_for(str(profile["path"]))
    var mode: String = str(profile.get("mode", "one_shot"))
    var volume: float = float(profile.get("volume_db", -10.0))
    last_mode = mode
    last_stream_path = str(profile["path"])
    if profile.has("attack_layer_db") and attack.is_valid():
        attack.call("%s_fire.wav" % id, float(profile["attack_layer_db"]))
    match mode:
        "burst":
            since_shot = 0.0
            burst_release = float(profile.get("release", 0.12))
            burst_db = volume
            if not burst_voice.playing or burst_clock >= float(profile.get("retrigger", 0.5)):
                burst_voice.stream = stream
                burst_voice.volume_db = volume
                burst_voice.play()
                burst_clock = 0.0
        "mono":
            mono_voice.stream = stream
            mono_voice.volume_db = volume
            mono_voice.play()
        _:
            var v: AudioStreamPlayer = one_shot_voices[one_shot_next]
            one_shot_next = (one_shot_next + 1) % one_shot_voices.size()
            v.stream = stream
            v.volume_db = volume
            v.play(float(profile.get("start_offset", 0.0)))
    return true

func _process(delta: float) -> void:
    burst_clock += delta
    since_shot += delta
    if burst_voice != null and burst_voice.playing and since_shot > burst_hold:
        # Trigger released: fade the bed out instead of letting 0.6 s ring on.
        var t: float = clampf((since_shot - burst_hold) / maxf(burst_release, 0.01), 0.0, 1.0)
        burst_voice.volume_db = lerpf(burst_db, -60.0, t)
        if t >= 1.0:
            burst_voice.stop()

func stop_all() -> void:
    for v in one_shot_voices: v.stop()
    burst_voice.stop()
    mono_voice.stop()
