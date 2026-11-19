extends Sprite3D
## 08.0: purely visual final pose; never occupies a collision layer,
## never speaks, awards XP, or enters a save as a living actor.
const LIFETIME: float = 5.5
var life: float = LIFETIME

func configure(final_frame: Texture2D, source_pixel_size: float) -> void:
    texture = final_frame
    pixel_size = source_pixel_size
    texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
    billboard = BaseMaterial3D.BILLBOARD_ENABLED
    shaded = false
    alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
    alpha_scissor_threshold = 0.26
    modulate = Color.WHITE
    add_to_group("temporary_combat_remains_080")

func _process(delta: float) -> void:
    life = maxf(0.0, life - delta)
    if life < 1.25:
        modulate.a = life / 1.25
    if life <= 0.0:
        queue_free()
