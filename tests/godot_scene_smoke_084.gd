extends Node
## Isolated headless Godot scene smoke test, not a full playthrough.
func _ready() -> void:
    call_deferred("_run")

func _run() -> void:
    var scene: Node = load("res://scenes/hearth_nine.tscn").instantiate()
    add_child(scene)
    await get_tree().process_frame
    scene.begin_attempt("Witness")
    for i in range(6):
        await get_tree().process_frame
    for zone_name in ["sootworks","basilica","ashmarket","orchard","barracks","core","assembly","hearth"]:
        Game.state["zone"] = zone_name
        scene.reload_district_world()
        for i in range(3):
            await get_tree().process_frame
        print("SMOKE_ZONE_OK: ",zone_name, " world=", scene.world.name)
    print("SMOKE_END")
    get_tree().quit()
