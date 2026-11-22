extends Node
## Build 09.0: every interactable in every district shows a written prompt
## that fits the prompt tab, and every advisory-route target in main.gd sits
## within 2.5 m of something the player can use (the Three-Writ route used to
## point at an empty floor 20 m from the desk).
## The fallback turns raw ids into text, which leaked build tags such as
## "[E] HEARTH SWITCH 079". Exits 1 if any prompt still exposes an id.
var failures: Array[String] = []
var checked: int = 0

func _ready() -> void:
    call_deferred("_run")

func _run() -> void:
    var scene: Node = load("res://scenes/hearth_nine.tscn").instantiate()
    add_child(scene)
    await get_tree().process_frame
    scene.begin_attempt("Witness")
    await get_tree().process_frame
    scene.hud.close_modal(true)
    var leak := RegEx.create_from_string("\\b0\\d\\d[A-Z]?\\b|_")
    var routes: Dictionary = _route_targets()
    for zone in ["hearth", "sootworks", "basilica", "ashmarket", "orchard", "barracks", "core", "assembly", "lift"]:
        Game.state["zone"] = zone
        scene.reload_district_world()
        for i in range(3): await get_tree().process_frame
        var seen: Dictionary = {}
        for node in _walk(scene.world):
            if not node.has_meta("interaction_id"): continue
            var id: String = str(node.get_meta("interaction_id"))
            if seen.has(id): continue
            seen[id] = true
            checked += 1
            var prompt: String = scene.player._prompt_for_interaction(id)
            scene.hud.set_interact_prompt(prompt)
            var lbl: Label = scene.hud.prompt_label
            var w: float = lbl.get_theme_font("font").get_string_size(lbl.text, HORIZONTAL_ALIGNMENT_LEFT, -1, lbl.get_theme_font_size("font_size")).x
            if w > lbl.size.x:
                failures.append("%s: prompt too wide (%d > %d px): %s" % [zone, w, lbl.size.x, prompt])
            if leak.search(prompt) != null:
                failures.append("%s: %s -> %s" % [zone, id, prompt])
            elif prompt == "[E] " + id.replace("_", " ").to_upper():
                # Written from the raw id, not authored.
                failures.append("%s: %s has no written prompt (%s)" % [zone, id, prompt])
        print("PROMPT090_ZONE %s: %d interactables" % [zone, seen.size()])
        # Every advisory-route target must lead to something the player can use.
        var spots: Array = []
        for node in _walk(scene.world):
            if node is Node3D and node.has_meta("interaction_id"): spots.append(node.global_position)
        for route in routes.get(zone, []):
            var best: float = INF
            for p in spots:
                best = minf(best, Vector2(p.x, p.z).distance_to(Vector2(route[1].x, route[1].z)))
            if best > 2.5:
                failures.append("%s: route '%s' at %s is %.1fm from any interactable" % [zone, route[0], route[1], best])
    for f in failures: print("PROMPT090_FAIL: ", f)
    print("PROMPT090_SUMMARY: %d checked, %d failed" % [checked, failures.size()])
    Music.request_quit(1 if failures.size() > 0 or checked < 20 else 0)

## Reads the route table straight from main.gd so new targets are covered.
func _route_targets() -> Dictionary:
    var src: String = FileAccess.get_file_as_string("res://scripts/main.gd")
    var body: String = src.get_slice("func _nav_target() -> Dictionary:", 1).get_slice("\nfunc ", 0)
    var out: Dictionary = {}
    var zone: String = ""
    var zone_re := RegEx.create_from_string("if zone == \"([a-z]+)\"")
    var pos_re := RegEx.create_from_string("\"label\":\"([^\"]+)\",\"pos\":Vector3\\(([-0-9.]+),([-0-9.]+),([-0-9.]+)\\)")
    for line in body.split("\n"):
        var z := zone_re.search(line)
        if z != null: zone = z.get_string(1)
        for m in pos_re.search_all(line):
            if zone == "": continue
            if not out.has(zone): out[zone] = []
            out[zone].append([m.get_string(1), Vector3(float(m.get_string(2)), float(m.get_string(3)), float(m.get_string(4)))])
    var count: int = 0
    for k in out: count += out[k].size()
    print("PROMPT090_ROUTES: %d route targets read" % count)
    return out

func _walk(root: Node) -> Array:
    var out: Array = [root]
    for c in root.get_children(): out.append_array(_walk(c))
    return out
