extends Node
## Build 09.3 audio integration runtime test: routing, playback modes, the
## bar-accurate combat loop, fallbacks, and stealth-safe combat music.
## Counts declared vs completed checks and exits 1 on any failure.
const Mix = preload("res://scripts/audio_mix_093.gd")
const WeaponAudio = preload("res://scripts/weapon_audio_093.gd")
const Looper = preload("res://scripts/music_looper_093.gd")
const Enemy = preload("res://scripts/enemy.gd")
const DECLARED := 17
var passes: int = 0
var failures: Array[String] = []
var attack_calls: Array = []

func _ready() -> void:
    call_deferred("_run")

func check(ok: bool, label: String) -> void:
    if ok: passes += 1; print("AUD093_PASS: ", label)
    else: failures.append(label); print("AUD093_FAIL: ", label)

func frames(seconds: float) -> void:
    var t: float = 0.0
    while t < seconds:
        await get_tree().process_frame
        t += get_process_delta_time()

func _attack(file_name: String, db: float) -> void:
    attack_calls.append([file_name, db])

func _run() -> void:
    Mix.reload()
    # Routing (4)
    check(not Mix.weapon_profile("coil").is_empty() and not Mix.weapon_profile("nail").is_empty() and not Mix.weapon_profile("choir").is_empty(), "coil, nail and choir route to the recovered Runway sounds")
    check(Mix.weapon_profile("covenant").is_empty(), "the Covenant keeps its original sound (no replacement exists)")
    var music: AudioStream = Mix.stream_for(str(Mix.music_profile("combat").get("path", "")))
    check(music != null and absf(music.get_length() - 30.772) < 0.1, "the combat track loads (%.2f s)" % (music.get_length() if music else -1.0))
    var sfx: AudioStream = Mix.stream_for(str(Mix.weapon_profile("nail")["path"]))
    check(sfx != null and sfx.get_length() > 0.9 and sfx.get_length() < 1.2, "a weapon sound loads (%.2f s)" % (sfx.get_length() if sfx else -1.0))
    # Weapon modes (7)
    var wa = WeaponAudio.new()
    add_child(wa)
    await get_tree().process_frame
    var attack := Callable(self, "_attack")
    check(wa.fire("coil", attack) and wa.last_mode == "one_shot", "coil plays as a one-shot")
    check(attack_calls.size() == 1 and attack_calls[0][0] == "coil_fire.wav", "with the short fallback crack layered for an instant attack")
    check(not wa.fire("covenant", attack), "a weapon without a replacement tells the caller to play its WAV")
    # Nail: hold the trigger for 1.5 s at the real cadence (0.09 s).
    var restarts: int = 0
    var t: float = 0.0
    var since_shot: float = 99.0
    var last_clock: float = 99.0
    while t < 1.5:
        if since_shot >= 0.09:
            wa.fire("nail", attack)
            since_shot = 0.0
        if wa.burst_clock < last_clock: restarts += 1
        last_clock = wa.burst_clock
        await get_tree().process_frame
        var d: float = get_process_delta_time()
        t += d
        since_shot += d
    check(restarts >= 2 and restarts <= 4, "the nail burst bed restarts every ~0.5 s, not every shot (%d restarts in 1.5 s, ~16 shots)" % restarts)
    check(wa.burst_voice.playing, "it keeps playing while the trigger is held")
    await frames(0.5)
    check(not wa.burst_voice.playing, "and fades out after release")
    wa.fire("choir", attack)
    var first_stream = wa.mono_voice.stream
    wa.fire("choir", attack)
    var busy: int = 0
    for v in wa.one_shot_voices:
        if v.playing and v.stream == first_stream: busy += 1
    check(wa.last_mode == "mono" and busy == 0, "choir tones cut each other instead of stacking")
    wa.stop_all()
    # Fallback when the replacement is switched off in data (1)
    Mix._config = {"weapons": {"coil": {"source": "fallback"}}}
    check(not wa.fire("coil", attack), "switching a weapon to 'fallback' in data restores the WAV")
    Mix.reload()
    # Music loop (3)
    var looper = Looper.new()
    add_child(looper)
    var prof: Dictionary = Mix.music_profile("combat")
    looper.configure(music, float(prof["loop_start"]), float(prof["loop_end"]), float(prof["crossfade"]))
    looper.play(float(prof["loop_end"]) - 0.5)
    looper.volume_db = -20.0
    await frames(0.8)
    check(looper.loops_done == 1, "the combat track hands over at the bar-line loop end")
    check(looper.position() < float(prof["loop_start"]) + 1.0, "and continues from the loop start (%.2f s)" % looper.position())
    await frames(0.3)
    var voices_on: int = 0
    for p in looper._players:
        if p.playing: voices_on += 1
    check(voices_on == 1, "the crossfade ends with one voice playing")
    looper.stop()
    # Director wiring and stealth-safe trigger (2)
    check(Music.tracks.has("combat") and Music.tracks["combat"].get_script() == Looper, "the music director uses the looped Runway combat track")
    check(absf(float(Music.trims.get("combat", 1.0)) - db_to_linear(-2.5)) < 0.01, "and trims it 2.5 dB to sit with the other score")
    var total: int = passes + failures.size()
    print("AUD093_SUMMARY: %d passed, %d failed, %d of %d declared checks ran" % [passes, failures.size(), total, DECLARED])
    Music.request_quit(1 if failures.size() > 0 or total != DECLARED else 0)
