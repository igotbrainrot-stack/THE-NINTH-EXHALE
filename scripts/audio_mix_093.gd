extends RefCounted
## Build 09.3 audio routing, read from data/audio_mix_093.json.
##
## Weapon fire: each weapon uses either its original fallback WAV or a
## replacement source with a playback mode chosen for how that sound is built:
##   one_shot  play once per shot (optionally from an offset, with the short
##             fallback layered underneath for an instant attack);
##   burst     a long burst file played as a bed, retriggered at most every
##             `retrigger` seconds while firing and faded out on release;
##   mono      each shot cuts the previous one (sustained tones never stack).
## A missing or unloadable replacement always falls back to the WAV.

const CONFIG_PATH := "res://data/audio_mix_093.json"

static var _config: Dictionary = {}
static var _loaded: bool = false
static var _streams: Dictionary = {}

static func config() -> Dictionary:
    if not _loaded:
        _loaded = true
        var f := FileAccess.open(CONFIG_PATH, FileAccess.READ)
        if f != null:
            var parsed = JSON.parse_string(f.get_as_text())
            if parsed is Dictionary:
                _config = parsed
    return _config

static func reload() -> void:
    _loaded = false
    _streams.clear()
    config()

static func weapon_profile(id: String) -> Dictionary:
    var profile: Dictionary = config().get("weapons", {}).get(id, {})
    if str(profile.get("source", "fallback")) != "runway": return {}
    if stream_for(str(profile.get("path", ""))) == null: return {}
    return profile

static func music_profile(key: String) -> Dictionary:
    var profile = config().get("music", {}).get(key, {})
    if not (profile is Dictionary) or str(profile.get("source", "")) != "runway": return {}
    if stream_for(str(profile.get("path", ""))) == null: return {}
    return profile

## Loads a stream once. Works before Godot has imported an MP3 (reads bytes).
static func stream_for(path: String) -> AudioStream:
    if path == "": return null
    if _streams.has(path): return _streams[path]
    var stream: AudioStream = null
    if ResourceLoader.exists(path):
        stream = load(path) as AudioStream
    elif path.ends_with(".mp3") and FileAccess.file_exists(path):
        var mp3 := AudioStreamMP3.new()
        mp3.data = FileAccess.get_file_as_bytes(path)
        stream = mp3
    if stream is AudioStreamMP3:
        # Looping is handled by the players (bar-accurate), never by the stream.
        (stream as AudioStreamMP3).loop = false
    _streams[path] = stream
    return stream
