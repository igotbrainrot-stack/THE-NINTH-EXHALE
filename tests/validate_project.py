#!/usr/bin/env python3
"""Source/data checks only; NOT a Godot importer or an engine playtest."""
import json
import re
import unittest
from pathlib import Path
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
EXPECTED={'weapons':16,'weapon_mods':20,'armour_sets':8,'consumables':23,'echoforms':12,'quest_objects':14,'local_storylets':20,'major_npcs':8,'districts':5,'hearing_commands':5}

class ProjectSourceValidation(unittest.TestCase):
    def setUp(self):
        self.ids=json.loads((ROOT/'data/master_ids.json').read_text())
        self.catalogue=json.loads((ROOT/'data/v6_reference_catalogue.json').read_text())
        self.master=(ROOT/'docs/MASTER_GAME_BIBLE_FINAL.md').read_text()
        self.scripts={p.stem:p.read_text() for p in (ROOT/'scripts').glob('*.gd')}

    def test_master_inventory_counts(self):
        for category,amount in EXPECTED.items():
            self.assertEqual(len(self.ids[category]),amount,category)
        for category in ['weapons','weapon_mods','armour_sets','consumables','echoforms','quest_objects','local_storylets','major_npcs']:
            self.assertEqual(len(self.catalogue[category]),EXPECTED[category],category)

    def test_technical_ids_are_unique(self):
        technical=[id for mapping in self.ids.values() for id in mapping.values()]
        self.assertEqual(len(technical),len(set(technical)))
        self.assertTrue(all(re.fullmatch(r'[a-z][a-z0-9_]+',k) for k in technical))

    def test_stable_quest_id_does_not_invent_second_cipher(self):
        items=self.ids['quest_objects']
        self.assertIn("Governor's Maintenance Cipher",items)
        self.assertEqual(sum('cipher' in name.lower() for name in items),1)
        self.assertIn('`cipher`',self.master)

    def test_source_does_not_import_obsolete_creature_moves(self):
        hearing=self.ids['hearing_commands']
        self.assertEqual(set(hearing),{'Press','Attune','Brace','Observe','Withdraw'})
        self.assertNotIn('TYPE_ADVANTAGE',self.scripts['run_state'])

    def test_canon_documents_present(self):
        for name in ['MASTER_GAME_BIBLE_FINAL.md','PROTECTED_ORIGINALITY_REGISTER.md','DEVELOPMENT_HANDOVER.md']:
            self.assertTrue((ROOT/'docs'/name).is_file())
        self.assertEqual(len(re.findall(r'^## 1\.\s',self.master,re.M)),1)
        self.assertIn('Lumen Engine',self.master)
        self.assertIn('White Quiet',self.master)

    def test_player_and_pistol_logic_source(self):
        script=self.scripts['player']
        for term in ['extends CharacterBody3D','move_and_slide()','PhysicsRayQueryParameters3D','fire_equipped','try_interact','reload_weapon','set_control_active']:
            self.assertIn(term,script)
        self.assertIn('current_fire_cooldown',script)
        self.assertIn('"damage":24', (ROOT/'scripts/weapon_catalog.gd').read_text())

    def test_lung_has_four_valid_routes(self):
        self.assertIn('["fight","bargain","tech","steal"]',self.scripts['run_state'])
        for token in ['claim:bargain','claim:tech','claim:steal','claim:fight']:
            self.assertIn(token,self.scripts['main'])
        self.assertIn('Claimant Ward',self.scripts['run_state'])
        self.assertIn('energy',self.scripts['main'].lower())

    def test_state_save_and_provenance_guards(self):
        script=self.scripts['run_state']
        for term in ['event_ids','record_event','load_attempt','save_attempt','state["status"] = "failed"','nix_archived_failures','continuing_failure_chain','award_xp_once']:
            self.assertIn(term,script)
        self.assertIn('DirAccess.rename_absolute',script)
        self.assertIn('"Energy"] -= 1',script)
        self.assertIn('"Correction"] -= 1',script)
        self.assertIn('"Hearth Nine"] += 8',script)
        self.assertIn('"Claimant Ward"] -= 5',script)

    def test_character_presets_and_levels(self):
        script=self.scripts['run_state']
        for build in ['Breaker','Witness','Mechanist','Stalker']:
            self.assertIn('"%s"' % build,script)
        builds={
            'Breaker':[6,3,2,1,2,4],
            'Witness':[2,2,5,5,1,3],
            'Mechanist':[2,2,3,2,6,3],
            'Stalker':[4,5,3,2,3,1]
        }
        for build,stats in builds.items():
            self.assertEqual(sum(stats),18)
            self.assertTrue(all(1<=x<=6 for x in stats))
        self.assertIn('[0, 100, 230, 390, 580, 800, 1050]',script)

    def test_first_location_physically_built_as_collidable_source(self):
        script=self.scripts['world_builder']
        self.assertIn('BoxShape3D.new()',script)
        self.assertIn('CollisionShape3D.new()',script)
        self.assertIn('Writ inspection lintel',script)
        self.assertIn('pressure wall',script.lower())
        self.assertIn('Dr Sela Vale',script)
        self.assertIn('Requisition Clerk',script)

    def test_interaction_ids_all_have_dispatch(self):
        world=self.scripts['world_builder']
        main=self.scripts['main']
        values=set(re.findall(r'add_(?:actor|console)\([^\n]*?"([a-z_]+)"\s*,\s*Vector3',world))
        self.assertGreaterEqual(len(values),8)
        for value in values:
            self.assertIn('"%s"' % value,main,value)

    def test_all_preloaded_resources_exist(self):
        content='\n'.join(self.scripts.values())
        for path in re.findall(r'(?:load|preload)\("(res://[^"%]+)"\)',content):
            self.assertTrue((ROOT/path.removeprefix('res://')).exists(),path)
        self.assertTrue((ROOT/'scenes/main.tscn').exists())
        self.assertIn('res://scenes/main.tscn',(ROOT/'project.godot').read_text())

    def test_procedural_placeholder_art_is_original_generated_files(self):
        self.assertTrue((ROOT/'tests/make_placeholder_art.py').exists())
        sprites=list((ROOT/'assets/sprites').glob('*.png'))
        textures=list((ROOT/'assets/textures').glob('*.png'))
        self.assertGreaterEqual(len(sprites),9)
        self.assertGreaterEqual(len(textures),5)
        for path in sprites+textures:
            with Image.open(path) as image:
                image.verify()

    def test_gdscript_parentheses_and_quote_structure(self):
        # Lexical bracket/quote sanity, not an actual GDScript parser.
        for path in (ROOT/'scripts').glob('*.gd'):
            code=path.read_text()
            stack=[]
            pairs={')':'(',']':'[','}':'{'}
            in_string=False;escaped=False;comment=False
            for i,ch in enumerate(code):
                if ch=='\n': comment=False
                if comment:continue
                if in_string:
                    if escaped:escaped=False
                    elif ch=='\\':escaped=True
                    elif ch=='"':in_string=False
                    continue
                if ch=='#':comment=True;continue
                if ch=='"':in_string=True;continue
                if ch in '([{':stack.append((ch,i))
                elif ch in ')]}':
                    self.assertTrue(stack,f'{path.name}: unexpected {ch} at {i}')
                    old,pos=stack.pop()
                    self.assertEqual(old,pairs[ch],f'{path.name}: {old} at {pos} closed by {ch} at {i}')
            self.assertFalse(in_string,f'{path.name}: unterminated string')
            self.assertFalse(stack,f'{path.name}: unbalanced {stack[:4]}')

if __name__=='__main__':
    unittest.main(verbosity=2)
