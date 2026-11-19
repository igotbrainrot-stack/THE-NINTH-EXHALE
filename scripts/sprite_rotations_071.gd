extends RefCounted
## Eight-sector directional selection shared by all actor sprites.
## Actor faces local -Z. Camera on the actor's front => 1; successive
## 45-degree sectors to actor's LEFT => 2, 3, 4; back=5; right=6,7,8.
## 0 is reserved for a UNIVERSAL graphic, not a ninth direction.
const LABELS: Array = ["BILLBOARD (0)", "FRONT (1)", "FRONT LEFT (2)", "LEFT (3)", "BACK LEFT (4)", "BACK (5)", "BACK RIGHT (6)", "RIGHT (7)", "FRONT RIGHT (8)"]

static func view_from_relative(relative: Vector3) -> int:
    if relative.length_squared() < 0.0001:
        return 1
    var bearing: float = atan2(relative.x, -relative.z)
    return posmod(int(floor((-bearing + PI / 8.0) / (PI / 4.0))), 8) + 1

static func view_from_world(camera_position: Vector3, actor_transform: Transform3D) -> int:
    var relative: Vector3 = actor_transform.basis.inverse() * (camera_position - actor_transform.origin)
    return view_from_relative(relative)

static func label_for(view_id: int) -> String:
    return str(LABELS[clampi(view_id,0,8)])
