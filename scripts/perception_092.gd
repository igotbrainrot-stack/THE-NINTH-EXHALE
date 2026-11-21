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
##          knowledge travels only via surviving radios or runners).
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

## Effective distance a sound travels: straight line, or longer round a wall.
static func heard_distance(space: PhysicsDirectSpaceState3D, source: Vector3, listener: Vector3, exclude: Array) -> float:
    var direct: float = source.distance_to(listener)
    var open: bool = clear_line(space, source + Vector3(0, 1.0, 0), listener + Vector3(0, 1.0, 0), exclude)
    return direct if open else direct * OCCLUDED_DISTANCE_FACTOR

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
