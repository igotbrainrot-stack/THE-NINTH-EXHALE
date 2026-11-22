extends Node
## Build 09.3 bar-accurate music loop for a stream that was not authored to loop
## (it ends mid-phrase). Plays the file from the start once, then loops
## [loop_start, loop_end) by handing over between two players with a short
## equal-power crossfade. The source file is never edited.
##
## Behaves like an AudioStreamPlayer for the music director: `playing`,
## `play()`, `stop()` and `volume_db`.

var stream: AudioStream
var loop_start: float = 0.0
var loop_end: float = 0.0
var crossfade: float = 0.06
var volume_db: float = -72.0:
    set(value):
        volume_db = value
        _apply_volume()
var playing: bool = false
var loops_done: int = 0          # tests read this

var _players: Array[AudioStreamPlayer] = []
var _active: int = 0
var _fade_clock: float = -1.0    # >= 0 while a handover crossfade runs
var _clock: float = 0.0          # position of the active player, our own count

func configure(source: AudioStream, start: float, end: float, fade: float) -> void:
    stream = source
    loop_start = start
    loop_end = end
    crossfade = maxf(fade, 0.01)
    if _players.is_empty():
        for i in 2:
            var p := AudioStreamPlayer.new()
            p.name = "LoopVoice%d" % i
            p.bus = "Master"
            add_child(p)
            _players.append(p)
    for p in _players:
        p.stream = stream

func play(from_position: float = 0.0) -> void:
    if stream == null or _players.is_empty(): return
    for p in _players: p.stop()
    _active = 0
    _fade_clock = -1.0
    _clock = from_position
    _players[0].play(from_position)
    playing = true
    _apply_volume()

func stop() -> void:
    for p in _players: p.stop()
    playing = false
    _fade_clock = -1.0

## Position of the music (seconds into the file) on the active voice.
func position() -> float:
    return _clock

func _gain_db_for(index: int) -> float:
    if _fade_clock < 0.0:
        return volume_db if index == _active else -80.0
    var t: float = clampf(_fade_clock / crossfade, 0.0, 1.0)
    # Equal power: the incoming voice rises as the outgoing one falls.
    var g: float = sin(t * PI * 0.5) if index == _active else cos(t * PI * 0.5)
    return volume_db + linear_to_db(maxf(g, 0.0001))

func _apply_volume() -> void:
    for i in _players.size():
        _players[i].volume_db = _gain_db_for(i)

func _process(delta: float) -> void:
    if not playing or _players.is_empty(): return
    var active: AudioStreamPlayer = _players[_active]
    # Trust the player's own position when it reports one; count otherwise.
    var reported: float = active.get_playback_position()
    _clock = reported if reported > 0.0 else _clock + delta
    if _fade_clock >= 0.0:
        _fade_clock += delta
        if _fade_clock >= crossfade:
            _players[1 - _active].stop()
            _fade_clock = -1.0
    elif _clock >= loop_end - crossfade:
        # Hand over: the other voice starts at the loop start, same bar phase.
        _active = 1 - _active
        _players[_active].play(loop_start)
        _clock = loop_start
        _fade_clock = 0.0
        loops_done += 1
    _apply_volume()
