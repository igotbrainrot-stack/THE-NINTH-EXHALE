extends Node3D
const PropMesh070 = preload("res://scripts/prop_mesh_070.gd")
## ART PASS: original municipal-pressure architecture. Decorative meshes have no
## gameplay collision and therefore do not alter Build 04's critical routes.
## Visual detail is derived from the Master Bible's Pressure Docket art language.
var mats: Dictionary = {}

func prepare(source: Dictionary) -> void:
    mats = source
    var enamel := StandardMaterial3D.new()
    enamel.albedo_color = Color("#9caeb0")
    enamel.metallic = 0.12
    enamel.roughness = 0.74
    mats["enamel_detail"] = enamel
    var copper := StandardMaterial3D.new()
    copper.albedo_color = Color("#7e6353")
    copper.metallic = 0.2
    copper.roughness = 0.55
    mats["copper_detail"] = copper
    var porcelain := StandardMaterial3D.new()
    porcelain.albedo_color = Color("#d3cdb1")
    porcelain.roughness = 0.84
    mats["porcelain_detail"] = porcelain
    var unlit := StandardMaterial3D.new()
    unlit.albedo_color = Color("#df9a54")
    unlit.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    mats["light_detail"] = unlit
    var dull_red := StandardMaterial3D.new()
    dull_red.albedo_color = Color("#853e34")
    dull_red.roughness = 0.89
    mats["red_detail"] = dull_red
    var dark_glass := StandardMaterial3D.new()
    dark_glass.albedo_color = Color("#41686a")
    dark_glass.metallic = 0.15
    dark_glass.roughness = 0.45
    mats["glass_detail"] = dark_glass

func block(id: String, pos: Vector3, size: Vector3, mat: String) -> MeshInstance3D:
    var view := MeshInstance3D.new()
    view.name = id
    view.position = pos
    var cube := BoxMesh.new()
    cube.size = size
    view.mesh = cube
    view.material_override = mats[mat]
    add_child(view)
    return view

func tube(id: String, pos: Vector3, length: float, radius: float, axis: String, mat: String) -> void:
    var visual := MeshInstance3D.new()
    visual.name = id
    visual.position = pos
    var cylinder := CylinderMesh.new()
    cylinder.height = length
    cylinder.top_radius = radius
    cylinder.bottom_radius = radius
    cylinder.radial_segments = 10
    visual.mesh = cylinder
    visual.material_override = mats[mat]
    if axis == "x":
        visual.rotation.z = PI / 2.0
    elif axis == "z":
        visual.rotation.x = PI / 2.0
    add_child(visual)

func placard(message: String, pos: Vector3, scale: float = 0.0055) -> void:
    var card := Label3D.new()
    card.text = message
    card.position = pos
    card.font_size = 19
    card.pixel_size = scale
    card.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    card.modulate = Color("#e1d1a6")
    add_child(card)

func ceiling_beams(span_x: int, span_z: int, top: float, soot: bool) -> void:
    # Thin, noncolliding roof and open mechanical service channels.
    block("Maintenance ceiling",Vector3(0,top+0.12,0),Vector3(span_x,0.18,span_z),"ceiling" if mats.has("ceiling") else "dark")
    for x in range(-int(span_x / 2) + 4,int(span_x / 2),8):
        block("Cross-rib %d" % x,Vector3(float(x),top-0.09,0),Vector3(0.34,0.24,span_z-0.8),"requisition")
    for z in range(-int(span_z / 2) + 4,int(span_z / 2),8):
        block("Roof beam %d" % z,Vector3(0,top-0.1,float(z)),Vector3(span_x-1,0.3,0.32),"dark")
    for light_x in [-span_x * 0.25, span_x * 0.25]:
        for light_z in [-span_z * 0.25, span_z * 0.25]:
            block("Recessed service luminaire",Vector3(light_x,top-0.21,light_z),Vector3(2.2,0.045,0.55),"light_detail")
            block("Luminaire frame N",Vector3(light_x,top-0.2,light_z-0.32),Vector3(2.35,0.1,0.08),"copper_detail")
            block("Luminaire frame S",Vector3(light_x,top-0.2,light_z+0.32),Vector3(2.35,0.1,0.08),"copper_detail")

func wall_service_frames(span_x: int, span_z: int, y: float) -> void:
    for x in range(-int(span_x / 2) + 3,int(span_x / 2),5):
        for z in [-float(span_z)/2.0+0.42,float(span_z)/2.0-0.42]:
            block("Service wall mullion",Vector3(float(x),y,z),Vector3(0.22,4.0,0.2),"enamel_detail")
    for z in range(-int(span_z / 2) + 3,int(span_z / 2),5):
        for x in [-float(span_x)/2.0+0.42,float(span_x)/2.0-0.42]:
            block("End wall mullion",Vector3(x,y,float(z)),Vector3(0.2,4.0,0.22),"enamel_detail")

func vent(pos: Vector3, horizontal: bool = true) -> void:
    block("Recessed louvre backing",pos,Vector3(1.5,0.86,0.08),"dark")
    block("Air vent bezel",pos+Vector3(0,0,0.02),Vector3(1.62,0.94,0.04),"enamel_detail")
    for k in range(6):
        block("Vent slat %d" % k,pos+Vector3(0,-0.33+0.13*k,0.09),Vector3(1.37,0.042,0.055),"dark")

func decorate_hearth() -> void:
    ceiling_beams(56,36,4.52,false)
    wall_service_frames(56,36,2.2)
    # The ceiling and ward are infrastructural, not glamorous. Existing scripted
    # actor and console positions are deliberately left unobstructed.
    for zz in [-14.2,-10.3,-6.5,2.2,6.2,10.6,14.6]:
        tube("West-side correction trunk",Vector3(-27.3,3.5,zz),3.0,0.095,"z","copper_detail")
        block("West trunk clamp",Vector3(-27.1,3.48,zz),Vector3(0.2,0.29,0.3),"enamel_detail")
    tube("Ward air distribution main",Vector3(-15.0,3.7,15.7),18.0,0.13,"x","enamel_detail")
    tube("Ward recirculation return",Vector3(-14.9,3.25,15.6),18.0,0.07,"x","copper_detail")
    for x in [-24.0,-19.0,-14.0,-9.0]:
        tube("Suspended respirator feed",Vector3(x,2.7,15.7),1.8,0.04,"y","copper_detail")
        block("Respirator manifold bracket",Vector3(x,2.1,15.65),Vector3(0.5,0.25,0.2),"enamel_detail")
    # Slightly offset padded cots / headboard details; only original bed base collides.
    for z in [-11.0,-15.0]:
        block("Cot mattress",Vector3(-22,0.86,z),Vector3(4.5,0.13,1.83),"ward")
        block("Cot linen pillow",Vector3(-23.55,1.0,z),Vector3(0.68,0.16,1.12),"porcelain_detail")
        block("Folded repair blanket",Vector3(-20.73,0.98,z),Vector3(1.0,0.11,1.7),"glass_detail")
        block("Cot head rail",Vector3(-24.38,1.3,z),Vector3(0.12,0.83,1.9),"enamel_detail")
        placard("WARD / TRIAGE",Vector3(-24.4,1.82,z))
    # Window recesses are ornamental wall fittings, not holes through collision.
    for z in [-12.0,0.8,11.0]:
        block("Shielded ward observation pane",Vector3(-27.48,2.0,z),Vector3(0.09,1.44,2.2),"glass_detail")
        block("Observation lintel",Vector3(-27.38,2.83,z),Vector3(0.18,0.12,2.55),"enamel_detail")
        block("Observation sill",Vector3(-27.38,1.17,z),Vector3(0.24,0.17,2.55),"enamel_detail")
    # Exposed service lines provide visual hierarchy and a reason for air pressure.
    for x in [4.0,12.0,20.0,26.0]:
        block("Quorum facade rib",Vector3(x,2.2,-17.48),Vector3(0.34,4.05,0.22),"copper_detail")
    tube("Requisition pressure main",Vector3(15.0,3.2,-16.9),19.5,0.12,"x","copper_detail")
    for x in [8.0,14.0,21.0]:
        block("Counter ledger drawer",Vector3(x,0.58,-10.0),Vector3(1.3,0.15,0.07),"porcelain_detail")
    vent(Vector3(13.0,2.35,-17.43))
    vent(Vector3(19.0,2.35,-17.43))
    placard("AIR QUOTA / REPAIR NOT CONSENT",Vector3(-5,2.6,-17.18))
    placard("HOLDING / REGISTERED CLAIM",Vector3(17,2.65,-17.21))

func decorate_sootworks() -> void:
    ceiling_beams(48,46,4.58,true)
    wall_service_frames(48,46,2.2)
    # Chimney-facing furnace bays have different silhouette from the clinic.
    for z in [-18.0,-8.0,2.0,12.0]:
        block("Furnace surround",Vector3(23.54,2.18,z),Vector3(0.28,3.35,3.7),"dark")
        block("Furnace aperture",Vector3(23.32,1.96,z),Vector3(0.09,2.15,2.54),"red_detail")
        block("Constrained furnace core",Vector3(23.22,1.81,z),Vector3(0.045,1.28,1.62),"light_detail")
        block("Furnace foot plate",Vector3(23.18,0.45,z),Vector3(0.35,0.22,3.2),"requisition")
        for off in [-1.6,1.6]:
            block("Furnace upright",Vector3(23.15,2.1,z+off),Vector3(0.3,3.6,0.18),"copper_detail")
        tube("Furnace return pipe",Vector3(22.95,3.63,z),3.2,0.12,"z","copper_detail")
        placard("FURNACE / LOAD %02d" % int((z+18.0)/10.0+1.0),Vector3(22.8,3.8,z))
    tube("Foundry supply conduit A",Vector3(8.0,3.9,-20.7),20.0,0.17,"x","copper_detail")
    tube("Foundry supply conduit B",Vector3(7.0,3.35,-20.8),22.0,0.11,"x","enamel_detail")
    for x in [-18.0,-11.0,-4.0,4.0,11.0,18.0]:
        tube("Suspended steam feeder",Vector3(x,3.8,-20.6),0.85,0.085,"y","enamel_detail")
    # Convincing equipment without placing any new invisible collision.
    for z in [-17.0,-9.0,1.0,9.0,17.0]:
        block("Pressure-protected service plate",Vector3(0.55,2.35,z),Vector3(0.16,2.7,3.55),"requisition")
        block("Field identifier inset",Vector3(0.43,2.55,z),Vector3(0.055,0.42,1.1),"porcelain_detail")
        tube("Service riser",Vector3(0.3,1.8,z+1.4),2.75,0.07,"y","copper_detail")
    # Hazard paint and floor rails are visual, not a new traversal gate.
    for x in [6.0,11.0,16.0,21.0]:
        block("Furnace floor safety stripe",Vector3(x,0.032,4),Vector3(0.2,0.035,30.0),"light_detail")
    for x in [-20.0,-15.0,-10.0]:
        block("Workers' wall locker backing",Vector3(x,1.38,22.48),Vector3(2.6,2.45,0.11),"enamel_detail")
        block("Workers' locker inset",Vector3(x,1.35,22.37),Vector3(1.95,1.72,0.11),"dark")
        block("Locker name-card",Vector3(x,2.03,22.3),Vector3(1.36,0.18,0.04),"porcelain_detail")
    vent(Vector3(-11.0,2.4,-22.5))
    placard("SHIFT SAFETY / CONTROL LINE ONLY",Vector3(-8,2.9,22.0))
    placard("WAGES POSTED / ATTENDANCE IS NOT CONSENT",Vector3(-14,3.0,-22.0))

# Authored furniture and daily-life clutter. Build 07.0 reconstructs all
# 66 previous 2D standees as real, fixed-orientation 3D geometry.
# Core traversal and interactable service terminals retain the tested hull lanes.
func decorate_population(district: String) -> void:
    var placements: Array = []
    match district:
        "hearth":
            placements = [
                [1,-22.2,-11.2,1.05],[1,-22.2,-15.2,1.05],
                [2,-15.0,-13.1,1.0],[2,-17.0,-8.7,0.9],
                [3,-24.7,-5.3,0.85],[3,-15.5,-6.6,0.9],
                [4,-13.0,12.3,0.87],[4,8.0,15.1,0.85],
                [5,-24.8,2.5,1.0],[5,24.3,-10.1,1.0],
                [6,-26.5,11.2,1.03],[6,26.4,-6.0,1.03],
                [7,-14.0,14.7,1.05],[7,14.7,-16.0,1.0],
                [8,-20.0,3.0,0.76],[8,-9.0,-9.0,0.76],
                [9,24.1,13.0,1.02],[9,6.0,-15.0,0.9],
                [3,22.1,-16.6,0.73],[4,20.4,14.7,0.8],
                [5,-25.0,-14.5,0.72],[8,18.0,-13.3,0.68]
            ]
        "sootworks":
            placements = [
                [1,-17.0,-17.6,1.02],[1,-7.1,15.9,1.02],
                [2,-19.8,-21.5,0.95],[2,-10.1,21.8,0.95],
                [3,21.5,-18.1,1.1],[3,20.8,10.0,1.06],
                [4,-14.0,19.9,0.9],[4,13.8,20.4,0.9],
                [5,21.7,-12.8,1.1],[5,-11.2,-20.2,0.88],
                [6,-6.1,21.5,1.0],[6,15.1,-21.3,1.0],
                [7,-17.1,4.4,1.08],[7,20.1,19.3,1.02],
                [8,22.3,-2.2,0.95],[8,-21.2,5.6,0.95],
                [9,-19.9,-8.1,1.02],[9,-15.8,16.5,1.02],
                [4,18.0,20.2,0.84],[5,22.0,-20.5,0.76],
                [7,22.0,7.6,0.92],[2,-12.0,-22.0,0.92]
            ]
        "basilica":
            placements = [
                [1,-18.0,-20.5,1.0],[1,-22.0,12.2,1.03],
                [2,-11.5,15.9,0.95],[2,22.2,16.5,0.94],
                [3,-14.2,-11.0,1.08],[3,-14.0,4.0,1.08],
                [4,-8.0,-21.2,0.98],[4,-21.7,3.2,1.0],
                [5,22.6,-17.4,1.04],[5,22.4,9.0,1.04],
                [6,-21.9,-5.0,0.89],[6,18.9,-21.7,0.89],
                [7,-9.0,18.6,0.88],[7,13.0,21.0,0.87],
                [8,-22.0,-14.4,1.04],[8,-21.4,17.9,1.04],
                [9,-14.0,21.2,0.9],[9,20.5,-1.4,0.92],
                [7,-7.0,-4.2,0.75],[8,24.5,20.8,0.8],
                [3,-8.0,5.0,0.9],[6,24.0,-10.5,0.88]
            ]
        _:
            return
    for entry in placements:
        var index: int = int(entry[0])
        var scale_value: float = float(entry[3])
        var px: float = float(entry[1])
        var pz: float = float(entry[2])
        var model := PropMesh070.new()
        model.position = Vector3(px,0.0,pz)
        # All surfaces have real mesh depth. Orientation remains physical;
        # neither chairs nor any static furniture follows the player's yaw.
        if absf(px) > 20.0:
            model.rotation.y = PI * 0.5 if px > 0.0 else -PI * 0.5
        elif pz > 10.0:
            model.rotation.y = PI
        else:
            model.rotation.y = 0.0
        model.setup(district,index,scale_value)
        model.apply_finish_variation(int(px*13.0 + pz*19.0 + float(index)*7.0))
        add_child(model)
