extends Node
## Build 08.8: every actor that has imported Runway turnaround art must actually
## render it (NPC faces + idle strips, enemy atlases, hearing Echoforms), across all
## eight districts. Actors without new art must keep their 07.x sprites.
## Exits with code 1 on failure. Run with an isolated HOME.
var failures: Array[String] = []
var passes: int = 0
var seen: Dictionary = {}

func _ready() -> void:
    call_deferred("_run")

func check(ok: bool, label: String) -> void:
    if ok:
        passes += 1
        print("ART088_PASS: ", label)
    else:
        failures.append(label)
        print("ART088_FAIL: ", label)

func _run() -> void:
    var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://art/BUILD_088_ART_IMPORT_MANIFEST.json"))
    var entries: Dictionary = manifest["entries"]
    var scene: Node = load("res://scenes/hearth_nine.tscn").instantiate()
    add_child(scene)
    await get_tree().process_frame
    scene.begin_attempt("Witness")
    await get_tree().process_frame
    scene.hud.close_modal(true)
    # The intake crawler ("sentry") only exists during Hearth Nine's opening alarm.
    Game.state["intro"]["stage"] = "alarm"
    scene.spawn_intro_sentry()
    for i in range(3): await get_tree().process_frame
    _scan(scene, entries, "hearth alarm")
    if is_instance_valid(scene.intro_sentry): scene.intro_sentry.queue_free()
    Game.state["intro"]["stage"] = "stabilised"
    for zone_name in ["hearth","sootworks","basilica","ashmarket","orchard","barracks","core","assembly"]:
        Game.state["zone"] = zone_name
        scene.reload_district_world()
        for i in range(3): await get_tree().process_frame
        _scan(scene, entries, zone_name)
    for key in entries.keys():
        var kind: String = str(entries[key]["kind"])
        if kind == "npc" or key in ["rootkin","bell_wretch","enforcer","sentry","millwright","cantor"]:
            check(seen.has(key), "%s appeared in some district and was checked" % key)
    print("ART088_SUMMARY: %d passed, %d failed" % [passes, failures.size()])
    await get_tree().process_frame
    Music.request_quit(1 if failures.size() > 0 else 0)

func _atlas_path(tex) -> String:
    if tex is AtlasTexture and tex.atlas != null: return tex.atlas.resource_path
    if tex is Texture2D: return tex.resource_path
    return ""

func _scan(scene: Node, entries: Dictionary, zone_name: String) -> void:
    for node in scene.world.find_children("*", "", true, false):
        var script: Script = node.get_script()
        if script == null: continue
        var path: String = script.resource_path
        if path.ends_with("directional_npc_sprite.gd"):
            var stem: String = str(node.sprite_stem)
            if stem == "" or seen.has(stem): continue
            seen[stem] = true
            var face: String = _atlas_path(node.face_textures.get(1))
            if entries.has(stem):
                check(face.contains("/npc_088/") and node.face_textures.size() == 8, "%s NPC uses 08.8 faces (%s)" % [stem, face])
                var idle: Array = node.ambient_frames.get(1, [])
                check(idle.size() == 4 and _atlas_path(idle[0]).contains("/npc_idle_088/"), "%s idle strip is 08.8 art, not 07.2" % stem)
            else:
                check(not face.contains("/npc_088/"), "%s (no new art) keeps its 07.x sprite" % stem)
        elif path.ends_with("animated_echoform_068.gd"):
            var id: String = str(node.echoform_id)
            if seen.has(id): continue
            seen[id] = true
            check(_atlas_path(node.animations[1][0]).contains("/enemies_088/") == entries.has(id), "%s hearing Echoform art source (%s)" % [id, _atlas_path(node.animations[1][0])])
        elif path.ends_with("enemy.gd"):
            var k: String = str(node.actor_key)
            if seen.has(k) or node.animated_textures.is_empty(): continue
            seen[k] = true
            var atlas: String = _atlas_path(node.animated_textures[1][0])
            # 09.6: an actor drawing borrowed placeholder art (the Unsaid) is
            # judged by the art key it actually draws.
            var art: String = str(node.call("art_key_096")) if node.has_method("art_key_096") else k
            check(atlas.contains("/enemies_088/") == entries.has(art) and node.animated_textures[1].size() == 12, "%s enemy atlas in %s (%s)" % [k, zone_name, atlas.get_file()])
