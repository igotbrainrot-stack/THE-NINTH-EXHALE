extends Node
## Live engine test: spawn district witnesses, damage across 60%, verify exactly once and persistence.
func _ready() -> void:
    call_deferred("_run")

func _assert_ok(value: bool, label: String) -> void:
    if value:
        print("WITNESS_085_PASS: ",label)
    else:
        push_error("WITNESS_085_FAIL: "+label)

func _run() -> void:
    var scene = load("res://scenes/hearth_nine.tscn").instantiate()
    add_child(scene)
    await get_tree().process_frame
    scene.begin_attempt("Witness")
    for i in range(5): await get_tree().process_frame
    for pair in [["sootworks","Brin Harker","brin"],["basilica","Sister Ossa","ossa"]]:
        var zone_name: String = pair[0]
        var node_name: String = pair[1]
        var actor_key: String = pair[2]
        Game.state["zone"] = zone_name
        scene.reload_district_world()
        for i in range(5): await get_tree().process_frame
        var witness: Node = scene.world.get_node_or_null(node_name)
        _assert_ok(is_instance_valid(witness),zone_name+" witness spawned")
        if not is_instance_valid(witness): continue
        witness.take_hit(19) # 45 -> 26, below 27 (=60% HP)
        await get_tree().process_frame
        var event_key: String = "witness.085.%s.threatened" % actor_key
        _assert_ok(Game.state["event_ids"].has(event_key),zone_name+" intimidation recorded")
        _assert_ok(bool(witness.get_meta("threatened_085",false)),zone_name+" threatened state visible")
        _assert_ok(int(Game.state["actors"][actor_key]["hp"]) == 26,zone_name+" injury state stored")
        _assert_ok(is_instance_valid(scene.guard) and scene.guard.hostile,zone_name+" district guard alerted")
        var events_before: int = Game.state["events"].size()
        witness.take_hit(1)
        _assert_ok(Game.state["events"].size() == events_before,zone_name+" threat event not duplicated")
        scene.reload_district_world()
        for i in range(4): await get_tree().process_frame
        var reloaded: Node = scene.world.get_node_or_null(node_name)
        _assert_ok(is_instance_valid(reloaded) and bool(reloaded.get_meta("threatened_085",false)),zone_name+" threatened state restored")
    print("WITNESS_085_END")
    get_tree().quit()
