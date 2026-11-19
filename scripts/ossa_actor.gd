extends StaticBody3D
signal threatened_085
const FEAR_HP_THRESHOLD_085: int = 27 # below 60% of 45 maximum HP
## Sister Ossa is an autonomous civic witness, not a disposable Writ token.
## A lethal attack is an irreversible event, and cannot trigger later dialogue.
var hp: int = 45

func _ready() -> void:
    collision_layer = 5
    set_meta("interaction_id", "ossa")
    if Game.has_attempt():
        hp = int(Game.state.get("actors",{}).get("ossa",{}).get("hp",45))
    var collision := CollisionShape3D.new()
    var capsule := CapsuleShape3D.new()
    capsule.height = 1.75
    capsule.radius = 0.38
    collision.shape = capsule
    collision.position.y = 0.88
    add_child(collision)
    var visual := Sprite3D.new()
    visual.texture = load("res://assets/sprites/ossa.png")
    visual.pixel_size = 0.016
    visual.shaded = false
    visual.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    visual.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
    visual.position.y = 0.98
    visual.set_script(preload("res://scripts/directional_npc_sprite.gd"))
    visual.set("sprite_stem", "ossa")
    add_child(visual)
    var label := Label3D.new()
    var resolution: String = str(Game.state.get("ossa",{}).get("decision",""))
    label.text = "SISTER OSSA / UNAMPLIFIED CHOIR" if resolution == "help" else ("SISTER OSSA / REGULATED VOICE" if resolution == "exploit" else "SISTER OSSA / VOLUNTARY CHOIR")
    label.position.y = 2.15
    label.font_size = 25
    label.pixel_size = 0.006
    label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    label.modulate = Color("#e1d1a6")
    add_child(label)
    if hp < FEAR_HP_THRESHOLD_085 and hp > 0:
        _show_threatened_state_085()
    var voice := preload("res://scripts/actor_voice_083.gd").new()
    voice.name = "Voice083"
    add_child(voice)


func _show_threatened_state_085() -> void:
    # Named civilian witness: defensive stance, not a magically equipped firearm.
    set_meta("threatened_085",true)
    for child in get_children():
        if child.has_method("set_threatened_085"):
            child.call("set_threatened_085",true)
        if child is Label3D:
            child.text = "THREATENED WITNESS"
            child.modulate = Color("#f5a272")

func _enter_threatened_state_085() -> void:
    _show_threatened_state_085()
    if Game.record_event("witness.085.ossa.threatened", "player_provoked_intimidation", {"witness":"Sister Ossa", "hp":hp, "response":"defensive_civilian"}):
        threatened_085.emit()

func take_hit(damage: int) -> void:
    if not Game.has_attempt() or not bool(Game.state.get("ossa",{}).get("alive",false)):
        return
    for child in get_children():
        if child.has_method("hurt_079z"):
            child.hurt_079z()
    get_node("Voice083").call("play_npc_grunt")
    var hp_before_085: int = hp
    hp = maxi(0, hp-damage)
    if hp > 0 and hp < FEAR_HP_THRESHOLD_085 and hp_before_085 >= FEAR_HP_THRESHOLD_085:
        _enter_threatened_state_085()
    Game.state["actors"]["ossa"]["hp"] = hp
    if hp > 0: Game.save_attempt() # Intimidation and injury survive reload.
    if hp == 0:
        if Game.kill_ossa():
            queue_free()
