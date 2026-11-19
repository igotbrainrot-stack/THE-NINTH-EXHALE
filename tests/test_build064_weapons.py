import json, re, unittest
from pathlib import Path
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
SRC=ROOT/'scripts'
CATALOG=(SRC/'weapon_catalog.gd').read_text()
PLAYER=(SRC/'player.gd').read_text()
UI=(SRC/'game_ui.gd').read_text()
STATE=(SRC/'run_state.gd').read_text()
MAIN=(SRC/'main.gd').read_text()
SOOT=(SRC/'sootworks_builder.gd').read_text()
class Weapons064(unittest.TestCase):
    def test_four_specific_original_weapons(self):
        for key in ('covenant','coil','nail','choir'):
            self.assertIn('"'+key+'"', CATALOG)
            self.assertTrue((ROOT/'assets/weapons'/f'{key}_idle.png').exists())
    def test_original_canonical_stats(self):
        for expected in ('"damage":24, "interval":0.42, "mag":6, "reload":1.8',
                         '"damage":8, "pellets":8, "interval":1.05, "mag":2, "reload":1.6',
                         '"damage":8, "interval":0.085, "mag":60, "reload":2.5',
                         '"damage":30, "interval":0.44, "mag":12, "reload":2.2'):
            self.assertIn(expected,CATALOG)
    def test_weapon_art_alpha_viewport_and_nonempty(self):
        for name in ('covenant','coil','nail','choir'):
            with Image.open(ROOT/'assets/weapons'/f'{name}_idle.png') as im:
                self.assertEqual(im.size,(640,400))
                self.assertEqual(im.mode,'RGBA')
                alpha=im.getchannel('A')
                self.assertTrue(8000 < sum(1 for x in alpha.get_flattened_data() if x>160) < 640*400*.7)
    def test_attack_and_automatic_fire_only_riveter(self):
        self.assertIn('Game.consume_weapon_round(id)', PLAYER)
        self.assertIn('Input.is_action_pressed("fire"):',PLAYER)
        self.assertIn('if Game.equipped_weapon()=="nail"',PLAYER)
        self.assertIn('current_fire_cooldown=maxf(0.09,float(spec["interval"])*0.88)',PLAYER)
    def test_heat_balance_and_no_free_passive_refills(self):
        self.assertIn('>=90.0',PLAYER)
        self.assertIn('<=55.0',PLAYER)
        self.assertIn('heat-18.0*delta',PLAYER)
        self.assertIn('float(spec["heat"])',PLAYER)
    def test_reload_is_delayed_and_cancelled_on_swap(self):
        self.assertIn('reload_remaining=float(spec["reload"])',PLAYER)
        self.assertIn('if reload_remaining<=0.0:',PLAYER)
        self.assertIn('Game.refill_weapon_mag(reload_item,capacity)',PLAYER)
        self.assertIn('reloading=false\n    reload_remaining=0.0',PLAYER)
        self.assertIn('Game.weapon_reserve(id)<=0',PLAYER)
        self.assertIn('state["weapon_state"]["reserves"][id]=weapon_reserve(id)-amount',STATE)
    def test_old_pistol_magazine_and_save_compatibility(self):
        self.assertIn('if id=="covenant":return fire_ammo()',STATE)
        self.assertIn('if id=="covenant":return reload_pistol()',STATE)
        self.assertIn('if not state.has("weapon_state")',STATE)
        self.assertIn('"equipped":"covenant"',STATE)
    def test_one_time_tools_and_story_reward(self):
        self.assertIn('add_console("Worker tools issue", "sootworks_weapon_rack"',SOOT)
        self.assertIn('"sootworks.worker_tool_issue"',STATE)
        self.assertIn('if state["event_ids"].has("sootworks.worker_tool_issue"):return false',STATE)
        self.assertIn('"wp_choirbreaker"',STATE)
        self.assertIn('func weapon_owned',STATE)
        self.assertIn('state["weapon_state"]["reserves"][id]=8 if id=="coil" else 60',STATE)
        self.assertIn('state["weapon_state"]["magazines"][id]=2 if id=="coil" else 60',STATE)
        self.assertIn('if not Game.weapon_owned(id)',PLAYER)
    def test_bindings_and_animated_viewmodel(self):
        self.assertIn('player.weapon_switched.connect(hud.set_weapon)',MAIN)
        self.assertIn('player.weapon_anim.connect(hud.weapon_event)',MAIN)
        for expected in ('"reload"','"switch"','"dry"','recoil_strength=move_toward','gun.position=Vector2','shot_flash=0.065', 'muzzle.visible=shot_flash>0.0'):
            self.assertIn(expected,UI)
        self.assertNotIn('gun.position=Vector2(390,212)',UI)
    def test_hud_above_gun_layers(self):
        for text in ('overlay.move_child(gun,0)','overlay.move_child(muzzle,1)','overlay.move_child(shell,2)'):
            self.assertIn(text,UI)
    def test_controls_key_1_heals_2_to_5_select(self):
        self.assertIn('KEY_1:heal_requested.emit()',PLAYER)
        for key,name in [(2,'covenant'),(3,'coil'),(4,'nail'),(5,'choir')]:
            self.assertIn(f'KEY_{key}:select_weapon("{name}")',PLAYER)
    def test_gallery_is_noncanonical_and_openable_from_title(self):
        gallery=(ROOT/'scripts/weapon_gallery.gd').read_text()
        scene=(ROOT/'scenes/weapon_gallery.tscn').read_text()
        title=(ROOT/'scenes/main.tscn').read_text()
        start=(ROOT/'scripts/start_screen.gd').read_text()
        self.assertIn('WeaponGallery',scene)
        self.assertIn('GalleryButton',title)
        self.assertIn('gallery_button.pressed.connect(_enter_weapon_gallery)',start)
        self.assertIn('res://scenes/weapon_gallery.tscn',start)
        self.assertIn('_fire_preview()',gallery)
        self.assertIn('_reload_preview()',gallery)
        self.assertNotIn('Game.state[',gallery)
    def test_generated_runway_source_provenance_is_honest(self):
        m=json.loads((ROOT/'art/WEAPON_RUNWAY_064_MANIFEST.json').read_text())
        tasks={o['task_id'] for o in m['new_runway_weapon_sources']}
        self.assertEqual(len(tasks),4)
        self.assertIn('not embedded automatically',m['actual_build_sources'])
        self.assertTrue((ROOT/'art/tools/import_runway_weapon_exports.py').exists())
if __name__=='__main__':unittest.main()
