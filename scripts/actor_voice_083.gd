extends Node3D
## 08.3 localised nonverbal speech and enemy SFX. Audio never alters narrative state.
const NPC_CLIP_COUNT: int = 4
var kind: String = "npc"
var voice_index: int = 0
var syllables_remaining: int = 0
var cooldown: float = 0.0
var output: AudioStreamPlayer3D

func _ready() -> void:
    output = AudioStreamPlayer3D.new()
    output.name = "Actor voice / positional playback"
    output.max_distance = 13.0
    output.unit_size = 3.0
    output.volume_db = -11.0 if kind == "npc" else -9.0
    add_child(output)

func _process(delta: float) -> void:
    cooldown = maxf(0.0, cooldown - delta)
    if kind == "npc" and syllables_remaining > 0 and cooldown <= 0.0 and not output.playing:
        syllables_remaining -= 1
        _play_next_grunt()

func play_npc_grunt() -> void:
    if kind != "npc" or cooldown > 0.0: return
    var parent: Node = get_parent()
    if is_instance_valid(parent) and parent.has_meta("interaction_id"):
        var person: String = str(parent.get_meta("interaction_id"))
        if person in ["brin", "ossa"] and Game.has_attempt():
            if not bool(Game.state.get(person,{}).get("alive",true)): return
    syllables_remaining = 2 + (voice_index % 2)
    _play_next_grunt()

func _play_next_grunt() -> void:
    var sound_file: String = "res://assets/audio/actor_083/npc_grunt_%d.wav" % (voice_index % NPC_CLIP_COUNT)
    voice_index += 1
    _play(sound_file, 0.06)

func play_enemy(event: String) -> void:
    if kind == "npc" or cooldown > 0.0 and event not in ["hurt","death"]: return
    if event not in ["alert","windup","attack","hurt","death"]: return
    var sound_file: String = "res://assets/audio/actor_083/%s_%s.wav" % [kind,event]
    _play(sound_file, 0.10 if event == "hurt" else 0.23)

func _play(path: String, delay: float) -> void:
    if not ResourceLoader.exists(path): return
    output.stop()
    output.stream = load(path)
    output.pitch_scale = 0.96 + float(voice_index % 5) * 0.025
    output.play()
    cooldown = delay
