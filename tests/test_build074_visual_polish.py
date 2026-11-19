from pathlib import Path
import unittest
import numpy as np
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
NPC=ROOT/'assets/sprites/directional8'
ENEMY=ROOT/'assets/sprites/enemies_074'
NAMES=['sentry','enforcer','millwright','cantor','edda_machine','pressure_mite','registry_bailiff','vent_whistler','rivet_courier','slag_sifter','chain_hauler','choir_reed','saltbound_porter','sluice_beadle','triage_warden','bell_wretch','rootkin']

class Graphics074(unittest.TestCase):
    def test_painted_sela_brin_eight_independent_directions(self):
        for name in ['sela','brin']:
            views=[]
            feet=[]
            for face in range(1,9):
                with Image.open(NPC/f'{name}_{face}.png') as im:
                    self.assertEqual(im.size,(192,280))
                    a=np.asarray(im.convert('RGBA'))
                    self.assertGreater(int((a[:,:,3]>150).sum()),9000)
                    rows=np.where((a[:,:,3]>100).any(axis=1))[0]
                    feet.append(int(rows.max()))
                    views.append(a.astype(np.int16))
            self.assertLessEqual(max(feet)-min(feet),1,f'{name} feet jitter')
            for i in range(8):
                for j in range(i+1,8):
                    self.assertGreater(float(np.abs(views[i]-views[j]).mean()),4.0,(name,i+1,j+1))

    def test_painted_color_detail_not_reduced_to_maquette_palette(self):
        for name in ['sela','brin']:
            a=np.asarray(Image.open(NPC/f'{name}_1.png').convert('RGBA'))
            opaque=a[a[:,:,3]>150,:3]
            self.assertGreater(len(np.unique(opaque,axis=0)),6000,name)

    def test_all_polished_enemies_eight_atlases_and_frames(self):
        self.assertEqual(len(NAMES),17)
        for name in NAMES:
            for face in range(1,9):
                with Image.open(ENEMY/f'{name}_{face}.png') as im:
                    self.assertEqual(im.size,(768,768))
                    self.assertEqual(im.mode,'RGBA')
                    self.assertGreater(im.getchannel('A').getextrema()[1],240)

    def test_runtime_prefers_polished_but_preserves_previous_atlases(self):
        for name in ['enemy.gd','animated_echoform_068.gd']:
            t=(ROOT/'scripts'/name).read_text()
            self.assertLess(t.index('enemies_074/'),t.index('enemies_073/'))
            self.assertIn('alpha_cut',t)
        g=(ROOT/'scripts/enemy_gallery_068.gd').read_text()
        self.assertIn('"enemies_073" if compare_legacy else "enemies_074"',g)

    def test_floor_shadow_is_noncolliding_and_not_billboarded(self):
        s=(ROOT/'scripts/sprite_grounding_074.gd').read_text()
        self.assertIn('PlaneMesh.new()',s)
        self.assertIn('actor.add_child.call_deferred(decal)',s)
        self.assertNotIn('BILLBOARD_ENABLED',s)
        self.assertIn('Grounding074.add_contact_shadow',(ROOT/'scripts/directional_npc_sprite.gd').read_text())
        self.assertTrue((ROOT/'assets/ui/contact_shadow_074.png').is_file())

    def test_district_lights_only_no_new_collision_or_game_state(self):
        s=(ROOT/'scripts/district_mood_074.gd').read_text()
        self.assertIn('OmniLight3D.new()',s)
        self.assertIn('shadow_enabled = false',s)
        self.assertIn('Embedded floor wear / no collision',s)
        self.assertNotIn('CollisionShape3D',s)
        self.assertNotIn('Game.state',s)
        self.assertIn('DistrictMood074.new()',(ROOT/'scripts/main.gd').read_text())
        for path in ['hearth_wear.png','soot_oil.png','basilica_salt.png']:
            self.assertTrue((ROOT/'assets/textures/decals_074'/path).exists())

    def test_props_use_deterministic_material_variation(self):
        p=(ROOT/'scripts/prop_mesh_070.gd').read_text()
        a=(ROOT/'scripts/art_detail.gd').read_text()
        self.assertIn('func apply_finish_variation(',p)
        self.assertIn('model.apply_finish_variation(',a)
        self.assertNotIn('randomize()',p)

if __name__=='__main__':unittest.main(verbosity=2)
