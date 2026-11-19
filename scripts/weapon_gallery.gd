extends Control
## Non-canonical art/animation inspection gallery. Does not modify Game.state.
## Purpose: inspect all four weapons immediately without unlocking equipment.
const WeaponCatalog = preload("res://scripts/weapon_catalog.gd")
var current_id := "covenant"
var gun: TextureRect
var flash: TextureRect
var heading: Label
var footer: Label
var clock := 0.0
var recoil := 0.0
var muzzle_time := 0.0
var reload_time := 0.0
var reload_total := 1.8
var switch_time := 0.0

func _ready() -> void:
    var background := ColorRect.new()
    background.color=Color("#252d29")
    background.position=Vector2.ZERO
    background.size=Vector2(640,400)
    background.mouse_filter=Control.MOUSE_FILTER_IGNORE
    add_child(background)
    gun=TextureRect.new()
    gun.position=Vector2.ZERO
    gun.size=Vector2(640,400)
    gun.pivot_offset=Vector2(580,394)
    gun.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
    gun.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    gun.mouse_filter=Control.MOUSE_FILTER_IGNORE
    add_child(gun)
    flash=TextureRect.new()
    flash.texture=load("res://assets/weapons/muzzle_flash.png")
    flash.position=Vector2(310,91)
    flash.size=Vector2(124,124)
    flash.mouse_filter=Control.MOUSE_FILTER_IGNORE
    flash.visible=false
    add_child(flash)
    var header := ColorRect.new()
    header.color=Color("#111816")
    header.size=Vector2(640,77)
    header.mouse_filter=Control.MOUSE_FILTER_IGNORE
    add_child(header)
    heading=Label.new()
    heading.position=Vector2(16,10)
    heading.size=Vector2(500,52)
    heading.add_theme_color_override("font_color",Color("#e5d1ac"))
    heading.add_theme_font_size_override("font_size",17)
    add_child(heading)
    var bar := ColorRect.new()
    bar.position=Vector2(0,338)
    bar.size=Vector2(640,62)
    bar.color=Color("#111816")
    bar.mouse_filter=Control.MOUSE_FILTER_IGNORE
    add_child(bar)
    footer=Label.new()
    footer.position=Vector2(14,345)
    footer.size=Vector2(620,50)
    footer.add_theme_font_size_override("font_size",13)
    footer.add_theme_color_override("font_color",Color("#ddbe83"))
    footer.text="[2] PISTOL   [3] COIL   [4] NAIL   [5] CHOIR\n[LEFT CLICK] FIRE   [R] RELOAD   [ESC] RETURN"
    add_child(footer)
    var back := Button.new()
    back.text="RETURN"
    back.position=Vector2(550,10)
    back.size=Vector2(78,36)
    back.pressed.connect(_return_title)
    add_child(back)
    _choose("covenant")

func _choose(id: String) -> void:
    if not WeaponCatalog.ARSENAL.has(id):return
    current_id=id
    var path: String="res://assets/weapons/%s_idle.png" % id
    gun.texture=load(path)
    recoil=0.0
    reload_time=0.0
    muzzle_time=0.0
    switch_time=0.24
    heading.text="NONCANON WEAPON GALLERY / BUILD 06.4\n%s  •  MAG %d  •  RELOAD %.2fs" % [str(WeaponCatalog.spec(id)["name"]),int(WeaponCatalog.spec(id)["mag"]),float(WeaponCatalog.spec(id)["reload"])]

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        match event.physical_keycode:
            KEY_2:_choose("covenant")
            KEY_3:_choose("coil")
            KEY_4:_choose("nail")
            KEY_5:_choose("choir")
            KEY_R:_reload_preview()
            KEY_ESCAPE:_return_title()
    elif event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
        _fire_preview()

func _fire_preview() -> void:
    if reload_time>0.0:return
    recoil=minf(1.5,recoil+1.0)
    muzzle_time=0.07

func _reload_preview() -> void:
    reload_total=float(WeaponCatalog.spec(current_id)["reload"])
    reload_time=reload_total
    muzzle_time=0.0

func _process(delta: float) -> void:
    if not is_instance_valid(gun):return
    clock+=delta
    recoil=move_toward(recoil,0.0,delta*5.3)
    muzzle_time=maxf(0.0,muzzle_time-delta)
    var reload_dip := 0.0
    if reload_time>0.0:
        reload_time=maxf(0.0,reload_time-delta)
        reload_dip=pow(sin(PI*(1.0-reload_time/maxf(0.01,reload_total))),0.85)
    var swap_dip := 0.0
    if switch_time>0.0:
        switch_time=maxf(0.0,switch_time-delta)
        swap_dip=sin(PI*(1.0-switch_time/0.24))
    var shoot_dip := 15.0 if current_id=="coil" else (3.2 if current_id=="nail" else 9.0)
    var move := Vector2(sin(clock*1.5)*0.65-20.0*reload_dip, sin(clock*1.8)*0.65+105.0*reload_dip+85.0*swap_dip)
    gun.position=move+Vector2(-0.3*shoot_dip*recoil,shoot_dip*recoil)
    gun.rotation=-0.11*reload_dip+0.015*recoil
    flash.visible=muzzle_time>0.0
    flash.position=Vector2(310,91)+move
    flash.modulate.a=clampf(muzzle_time/0.07,0.0,1.0)

func _return_title() -> void:
    get_tree().change_scene_to_file("res://scenes/main.tscn")
