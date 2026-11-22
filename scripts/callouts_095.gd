extends RefCounted
## Build 09.5 combat callouts, after F.E.A.R.'s combat dialogue (Orkin, Game AI
## Pro ch. 2): "If the AI didn't say it, it didn't happen." Every callout names
## something the enemy is really doing, at the moment it does it:
##   WINDUP_<attack>  the telegraph before a strike (reads with the warning light)
##   PAIN             the enemy crossed its pain threshold and flinched
##   MAN_DOWN         an ally SAW the death; it goes to the body and stays on
##                    high alert (body discovery, witness-gated)
##   RELOAD           a hostile saw Ninth start a reload; it attacks sooner
## Deterministic: lines rotate in a fixed order per event (no random pick,
## bible L699). One voice at a time: a global gap between callouts and a
## per-speaker gap, so a fight never turns into a wall of text. Dead
## enemies never speak. Ninth has no pronoun in the bible, so no line uses one.
## 09.6: only people speak; machines get captioned sounds (MACHINE_LINES).

const P = preload("res://scripts/perception_092.gd")

const LINES := {
    "WINDUP_line": ["TAKING THE SHOT!", "LINE UP — FIRE!", "SIGHTS ON!"],
    "WINDUP_heavy": ["STAND CLEAR!", "BRINGING IT DOWN!", "CLEAR THE FLOOR!"],
    "WINDUP_rush": ["GOING IN!", "CLOSING!", "GET IN CLOSE!"],
    "WINDUP_signal": ["SOUNDING THE PULSE!", "PULSE COMING!", "HOLD YOUR EARS!"],
    "WINDUP_pull": ["HOOK!", "CHAIN OUT!", "DRAG 'EM IN!"],
    "PAIN": ["AGH — I'M HIT!", "HIT!", "STILL STANDING!"],
    "MAN_DOWN": ["MAN DOWN!", "WE LOST ONE!", "THEY DROPPED ONE!"],
    "RELOAD": ["RELOADING — PUSH!", "DRY — PUSH NOW!", "NOW, WHILE IT LOADS!"],
}
## 09.6: automata don't talk. A machine's callout is the sound it makes,
## captioned: the same moment and the same information, no words. Machines
## don't read Ninth's reload either; that is a person noticing a person.
const MACHINE_LINES := {
    "WINDUP_line": ["[BARREL CYCLES]"],
    "WINDUP_heavy": ["[PRESSURE BUILDS]"],
    "WINDUP_rush": ["[MOTOR REVS]"],
    "WINDUP_signal": ["[EMITTER OPENS]"],
    "WINDUP_pull": ["[WINCH LOCKS]"],
    "PAIN": ["[PLATING BUCKLES]", "[VALVE SHRIEKS]"],
    "MAN_DOWN": ["[ALARM TONE]"],
}
const GLOBAL_GAP_MS := 900          # at most about one callout per second
const SPEAKER_GAP_MS := 3500        # the same enemy does not chatter
const URGENT := ["MAN_DOWN", "RELOAD"]  # may cut the global gap
const MAN_DOWN_REACH := 15.0
const RELOAD_REACH := 12.0
const RELOAD_PRESS := 0.3           # seconds until the next attack, at most

static var _rotation: Dictionary = {}
static var _last_global_ms: int = -100000
static var _last_by_speaker: Dictionary = {}
static var spoken: Array = []       # [speaker key, event, line]; tests read it

static func reset() -> void:
    _rotation.clear()
    _last_by_speaker.clear()
    _last_global_ms = -100000
    spoken.clear()

## The next line for an event, in a fixed rotation.
static func next_line(event: String, voice: String = "speech") -> String:
    var lines: Array = (MACHINE_LINES if voice == "machine" else LINES).get(event, [])
    if lines.is_empty(): return ""
    var slot: String = voice + ":" + event
    var i: int = int(_rotation.get(slot, 0))
    _rotation[slot] = i + 1
    return str(lines[i % lines.size()])

## Speak through the enemy's sense bark label. Returns true if it was said.
static func say(enemy: Node, event: String) -> bool:
    if not is_instance_valid(enemy) or int(enemy.get("hp")) <= 0: return false
    var sense = enemy.get("sense_092")
    if not is_instance_valid(sense): return false
    var now: int = Time.get_ticks_msec()
    var key: int = enemy.get_instance_id()
    if now - int(_last_by_speaker.get(key, -100000)) < SPEAKER_GAP_MS: return false
    if not (event in URGENT) and now - _last_global_ms < GLOBAL_GAP_MS: return false
    var line: String = next_line(event, voice_of(enemy))
    if line == "": return false
    sense.call("_say", line)
    _last_global_ms = now
    _last_by_speaker[key] = now
    spoken.append([str(enemy.get("actor_key")), event, line])
    return true

static func voice_of(enemy: Node) -> String:
    return str(enemy.call("voice_kind")) if enemy.has_method("voice_kind") else "speech"

static func _sees(from_enemy: Node3D, point: Vector3, exclude: Array) -> bool:
    var eye: Vector3 = from_enemy.global_position + Vector3(0, P.EYE_HEIGHT, 0)
    return P.clear_line(from_enemy.get_world_3d().direct_space_state, eye, point + Vector3(0, 1.0, 0), exclude)

## An enemy died. The nearest living enemy that can SEE the body calls it out,
## goes to look, and stays on high alert. Nobody saw it: nothing happens.
static func man_down(dead: Node3D) -> Node:
    if not is_instance_valid(dead) or not dead.is_inside_tree(): return null
    var best: Node3D = null
    var best_d: float = MAN_DOWN_REACH
    for n in dead.get_tree().get_nodes_in_group("hostile"):
        if n == dead or not is_instance_valid(n) or int(n.get("hp")) <= 0: continue
        var d: float = (n as Node3D).global_position.distance_to(dead.global_position)
        if d > best_d: continue
        var excl: Array = [(n as CollisionObject3D).get_rid(), (dead as CollisionObject3D).get_rid()]
        var player = n.get("player")
        if is_instance_valid(player): excl.append((player as CollisionObject3D).get_rid())
        if not _sees(n, dead.global_position, excl): continue
        best = n
        best_d = d
    if best == null: return null
    var sense = best.get("sense_092")
    if is_instance_valid(sense) and not bool(best.get("hostile")):
        # Walk to the body (a violent stimulus there), then search, then stay sharp.
        sense.call("hear_092", dead.global_position, 999.0, "body", true)
        sense.set("high_alert", true)
        var key: String = str(best.get("actor_key"))
        if Game.has_attempt() and Game.state.get("actors", {}).has(key):
            Game.state["actors"][key]["high_alert_093"] = true
    say(best, "MAN_DOWN")
    return best

## Ninth started a reload. The nearest hostile enemy that can see Ninth calls
## it and presses: its next attack comes sooner.
static func player_reloading(tree: SceneTree, player: Node3D) -> Node:
    if tree == null or not is_instance_valid(player): return null
    var best: Node3D = null
    var best_d: float = RELOAD_REACH
    for n in tree.get_nodes_in_group("hostile"):
        if not is_instance_valid(n) or int(n.get("hp")) <= 0 or not bool(n.get("hostile")): continue
        if voice_of(n) != "speech": continue
        var d: float = (n as Node3D).global_position.distance_to(player.global_position)
        if d > best_d: continue
        var excl: Array = [(n as CollisionObject3D).get_rid()]
        if player is CollisionObject3D: excl.append((player as CollisionObject3D).get_rid())
        if not _sees(n, player.global_position, excl): continue
        best = n
        best_d = d
    if best == null: return null
    if say(best, "RELOAD"):
        best.set("attack_timer", minf(float(best.get("attack_timer")), RELOAD_PRESS))
    return best
