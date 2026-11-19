extends RefCounted
## Small physically grounded shadow decal for moving billboards.
## It stays parallel to the FLOOR; unlike furniture/NPC Sprite3D it never
## billboards to the camera and has no collision or effect on enemy behavior.
const SHADOW_FILE = "res://assets/ui/contact_shadow_074.png"

static func add_contact_shadow(actor: Node3D, width: float, depth: float) -> void:
    if not is_instance_valid(actor): return
    if actor.has_node("ContactShadow074"): return
    if not ResourceLoader.exists(SHADOW_FILE): return
    var plane := PlaneMesh.new()
    plane.size = Vector2(width, depth)
    var decal := MeshInstance3D.new()
    decal.name = "ContactShadow074"
    decal.mesh = plane
    decal.position = Vector3(0.0,0.037,0.0)
    var finish := StandardMaterial3D.new()
    finish.albedo_texture = load(SHADOW_FILE)
    finish.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    finish.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    finish.cull_mode = BaseMaterial3D.CULL_DISABLED
    finish.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
    decal.material_override = finish
    # Defer during actor subtree entry: the parent can still be setting up children.
    # The decal is cosmetic; its insertion does not need to be synchronous.
    actor.add_child.call_deferred(decal)
