extends RefCounted
## Build 09.2 perception core (immersive-sim Phase 1).
##
## Deterministic by design: no dice anywhere. The bible bans random rolls for
## reactions (L699) and the originality register (POR-20) keeps outcomes in the
## human action log, so awareness rises and decays on fixed curves.
##
## What an NPC can know comes only from three channels:
##   SIGHT  a cone + line-of-sight test against the player, scaled by light
##          at the player's feet, distance and how fast the player moves;
##   SOUND  noise events (shots, footsteps, bursts, a witness crying out),
##          heard when within radius after an occlusion penalty;
##   TOLD   a living witness delivering what they saw (bible L1398: patrol
##          knowledge travels only via surviving radios or runners). 09.3:
##          Brin and Ossa run to their keeper when nobody perceived an assault.
## The pure functions below are testable headless; sense_092.gd applies them.

const GROUP_PERCEIVERS := "perceivers_092"

# Sight. Placeholder numbers scaled from Deus Ex: HR (19 m normal vision) down
# to districts that are 28-62 m across. Tune with the F3 overlay.
const EYE_HEIGHT := 1.45
const NEAR_RANGE := 3.2            # wide "someone is right behind me" cone
const NEAR_HALF_ANGLE := 80.0      # degrees either side of facing
const MAIN_RANGE := 13.0
const MAIN_HALF_ANGLE := 50.0
const CIVIC_RANGE := 16.0          # office-holders watching their counter
const RISE_PER_SECOND := 1.05      # about 1 s to notice a lit, close, walking player
const DECAY_PER_SECOND := 0.16
const DECAY_DELAY := 1.6           # seconds without a stimulus before decay

# Awareness tiers (0..1+). Hostile at 1.0 opens the existing combat loop.
const SUSPICIOUS := 0.25
const INVESTIGATE := 0.6
const HOSTILE := 1.0

# Noise radii in metres before occlusion. Weapons by catalog id.
const NOISE_WALK := 2.4
const NOISE_SPRINT := 7.5
const NOISE_DASH := 8.5
const NOISE_MELEE := 6.0
const NOISE_CRY := 20.0            # a threatened civilian calling for help
const NOISE_BURST := 20.0          # pressure fixture or hazard rupture
const WEAPON_NOISE := {"covenant": 18.0, "coil": 26.0, "nail": 22.0, "choir": 12.0}
const OCCLUDED_DISTANCE_FACTOR := 1.9   # a wall roughly doubles the path a sound travels

const LIGHT_FLOOR := 0.4           # districts keep ambient light; darkness halves, never hides
const MOTION_STILL := 0.7
const MOTION_WALK := 1.0
const MOTION_SPRINT := 1.45

static var debug: bool = false     # F3 overlay

# 09.3 SEARCH and HIGH ALERT (Blacklist rule: never drop straight back to calm).
# A patrol that loses a hostile target walks to the last known position and
# searches; afterwards it stays on HIGH ALERT for the rest of the visit.
const LOSE_TRACK_SECONDS := 6.0    # hostile but unseen this long -> SEARCH
const SEARCH_SECONDS := 12.0       # look around the last known position
const HIGH_ALERT_RANGE_SCALE := 1.3
const HIGH_ALERT_RISE_SCALE := 1.4
const SEARCH_RISE_SCALE := 1.8     # a searcher re-acquires fast
const REPORT_REACH := 3.5          # a fleeing witness tells a keeper within this
const RUNNER_SPEED := 3.2          # frightened civilian, slower than a sprinting player

# Deterministic barks (no random pick): the stimulus decides the line, so the
# player can always tell what caused a change (Mark of the Ninja's rule).
const BARKS := {
    "SUSPICIOUS:SIGHT": "SOMEONE THERE?",
    "SUSPICIOUS:SOUND": "HEARD THAT.",
    "INVESTIGATE:SIGHT": "CHECKING IT.",
    "INVESTIGATE:SOUND": "THAT CAME FROM OVER THERE.",
    "INVESTIGATE:VIOLENT": "THAT WAS A WEAPON.",
    "INVESTIGATE:CRY": "WHO'S HURT?",
    "INVESTIGATE:TOLD": "SHOW ME WHERE.",
    "HOSTILE:SIGHT": "THERE!",
    "HOSTILE:WITNESS": "I SAW THAT.",
    "SEARCH:LOST": "LOST THEM. SEARCHING.",
    "HIGH_ALERT:END": "STAYING SHARP.",
    "UNAWARE:CALM": "...NOTHING.",
}

static func bark_for(state: String, cause: String) -> String:
    return str(BARKS.get("%s:%s" % [state, cause], ""))

## How visible the player is right now, 0..1, from the same light and motion
## factors the guards use. Drives the HUD cue; pure and testable headless.
static func player_visibility(light: float, speed: float) -> float:
    var motion: float = MOTION_SPRINT if speed > 6.0 else (MOTION_WALK if speed > 0.5 else MOTION_STILL)
    return clampf(clampf(light, LIGHT_FLOOR, 1.0) * motion / MOTION_SPRINT, 0.0, 1.0)

## The most alarmed perceiver within `reach` of `at`: [state, awareness].
## States rank UNAWARE < HIGH_ALERT < SUSPICIOUS < SEARCH < INVESTIGATE < HOSTILE.
const STATE_RANK := {"UNAWARE": 0, "HIGH_ALERT": 1, "SUSPICIOUS": 2, "SEARCH": 3, "INVESTIGATE": 4, "HOSTILE": 5}
static func most_alarmed(tree: SceneTree, at: Vector3, reach: float) -> Array:
    var best: Array = ["UNAWARE", 0.0]
    if tree == null: return best
    for sense in tree.get_nodes_in_group(GROUP_PERCEIVERS):
        if not is_instance_valid(sense) or not sense.is_inside_tree(): continue
        var body = sense.get("owner_enemy")
        if not is_instance_valid(body) or int(body.get("hp")) <= 0: continue
        if (body as Node3D).global_position.distance_to(at) > reach: continue
        # The body's flag is the truth for combat; a sense left saying HOSTILE
        # by a body that stopped ticking (an isolated keeper) is not a threat.
        var st: String = "HOSTILE" if bool(body.get("hostile")) else str(sense.get("state"))
        if st == "HOSTILE" and not bool(body.get("hostile")): st = "UNAWARE"
        if int(STATE_RANK.get(st, 0)) > int(STATE_RANK.get(str(best[0]), 0)):
            best = [st, float(sense.get("awareness"))]
    return best

## Rise in awareness per second for one sighting. Pure: tested headless.
static func sight_rate(distance: float, view_range: float, light: float, motion: float) -> float:
    if distance > view_range: return 0.0
    var proximity: float = lerpf(1.7, 0.45, clampf(distance / maxf(view_range, 0.01), 0.0, 1.0))
    return RISE_PER_SECOND * proximity * clampf(light, LIGHT_FLOOR, 1.0) * motion

## True when `target` is inside one of the two cones in front of `eye`.
## `forward` is the perceiver's facing (actor faces local -Z, as Rotation8).
static func in_cones(eye: Vector3, forward: Vector3, target: Vector3, main_range: float) -> bool:
    var flat: Vector3 = Vector3(target.x - eye.x, 0.0, target.z - eye.z)
    var distance: float = flat.length()
    if distance < 0.05: return true
    var facing: Vector3 = Vector3(forward.x, 0.0, forward.z).normalized()
    var angle: float = rad_to_deg(facing.angle_to(flat / distance))
    if distance <= NEAR_RANGE and angle <= NEAR_HALF_ANGLE: return true
    return distance <= main_range and angle <= MAIN_HALF_ANGLE

## A world-geometry ray (layer 1) between two points, ignoring `exclude`.
static func clear_line(space: PhysicsDirectSpaceState3D, from: Vector3, to: Vector3, exclude: Array) -> bool:
    if space == null: return true
    var query := PhysicsRayQueryParameters3D.create(from, to)
    query.collision_mask = 1
    query.exclude = exclude
    var hit: Dictionary = space.intersect_ray(query)
    return hit.is_empty()

## Effective distance a sound travels. In the open it is the straight line.
## 09.5 (after Doom's sector flood, which carries gunfire through open space
## but not through solid walls or shut doors): behind a wall it is the length
## of the walking route round it, from walk_grid_093; a sealed room is never
## heard (INF). Without a world to route through it falls back to the 09.2
## estimate (a wall roughly doubles the distance). Pass `radius` so sounds
## that could not carry that far anyway skip the route search.
static func heard_distance(space: PhysicsDirectSpaceState3D, source: Vector3, listener: Vector3, exclude: Array, world: Node3D = null, radius: float = INF) -> float:
    var direct: float = source.distance_to(listener)
    var open: bool = clear_line(space, source + Vector3(0, 1.0, 0), listener + Vector3(0, 1.0, 0), exclude)
    if open: return direct
    if world == null or not world.is_inside_tree(): return direct * OCCLUDED_DISTANCE_FACTOR
    if direct > radius: return direct * OCCLUDED_DISTANCE_FACTOR
    return preload("res://scripts/walk_grid_093.gd").path_length(world, source, listener)

# 09.5 muzzle flash: firing lights the shooter for a moment (Doom's flash
# frames, Cultic's dynamic light). Guards and the HUD cue both read it through
# player_light(); deterministic, and gone FLASH_SECONDS after the last shot.
const FLASH_SECONDS := 0.22
const MUZZLE_FLASH := {"covenant": 0.55, "coil": 0.9, "nail": 0.45, "choir": 0.25}
static var flash_level: float = 0.0
static var flash_until_ms: int = 0

static func register_shot(weapon_id: String) -> void:
    flash_level = float(MUZZLE_FLASH.get(weapon_id, 0.5))
    flash_until_ms = Time.get_ticks_msec() + int(FLASH_SECONDS * 1000.0)

static func flash_now() -> float:
    return flash_level if Time.get_ticks_msec() < flash_until_ms else 0.0

## Light on the player: the district's lamps, raised by a recent muzzle flash.
static func player_light(world_root: Node, point: Vector3) -> float:
    return maxf(light_at(world_root, point), flash_now())

## Light at a point, 0..1, summed analytically from the OmniLight3D nodes under
## `root`. Renderer-independent and identical in headless tests.
static func light_at(root: Node, point: Vector3) -> float:
    if root == null: return 1.0
    var total: float = 0.0
    for light in root.find_children("*", "OmniLight3D", true, false):
        var omni: OmniLight3D = light
        if not omni.visible: continue
        var reach: float = maxf(omni.omni_range, 0.01)
        var d: float = omni.global_position.distance_to(point)
        if d >= reach: continue
        var falloff: float = pow(1.0 - d / reach, maxf(omni.omni_attenuation, 0.1))
        total += omni.light_energy * falloff
    return clampf(LIGHT_FLOOR + total * 0.6, LIGHT_FLOOR, 1.0)

## Broadcast a noise to every perceiver. `violent` marks gunfire, impacts and
## cries; `kind` is a short tag shown in barks and the debug overlay.
static func emit_noise(tree: SceneTree, at: Vector3, radius: float, kind: String, violent: bool, source: Node = null) -> int:
    if tree == null: return 0
    var heard: int = 0
    for listener in tree.get_nodes_in_group(GROUP_PERCEIVERS):
        if listener == source or not is_instance_valid(listener): continue
        if listener.has_method("hear_092") and bool(listener.call("hear_092", at, radius, kind, violent)):
            heard += 1
    return heard

## A notable act seen or heard by perceivers. Each perceiver decides from its
## own senses; a record is only written by a living witness who perceived it.
static func witness_assault(tree: SceneTree, victim: String, at: Vector3, attacker_pos: Vector3) -> Array:
    var witnesses: Array = []
    if tree == null: return witnesses
    for listener in tree.get_nodes_in_group(GROUP_PERCEIVERS):
        if is_instance_valid(listener) and listener.has_method("witness_assault_092"):
            var channel: String = str(listener.call("witness_assault_092", victim, at, attacker_pos))
            if channel != "": witnesses.append([listener, channel])
    return witnesses

static func state_name(awareness: float, hostile: bool) -> String:
    if hostile: return "HOSTILE"
    if awareness >= INVESTIGATE: return "INVESTIGATE"
    if awareness >= SUSPICIOUS: return "SUSPICIOUS"
    return "UNAWARE"
