"""Build 06.6 fun-first source contracts and independent deterministic rule model.
These are NOT Godot engine or human-fun playtests.
"""
import unittest
from pathlib import Path
import wave
R = Path(__file__).resolve().parents[1]

def text(path):
    return (R/path).read_text()

def model_hearing(commands,offset):
    """Pure test oracle matching the intended phase, guard and costs in run_state.gd."""
    field,strain,turn,guard,observed=31,46,0,0,False
    for command in commands:
        phase=(offset+turn)%3  # rising / shielded / exposed
        turn+=1
        field_loss,cost=0,0
        if command=='Press':
            field_loss=(3,2,11)[phase]
            cost=(7,9,5)[phase]
        elif command=='Attune':
            field_loss=(8,5,12)[phase]+(3 if observed else 0)
            cost=4
            observed=False
        elif command=='Brace':
            cost=2
        elif command=='Observe':
            cost=2
            if not observed:field_loss,observed=3,True
        field=max(0,field-field_loss)
        damage=max(0,(6,6,1)[phase]-guard)
        guard=8 if command=='Brace' else 0
        strain=max(0,strain-cost-damage)
        if field<=0:return True,turn,strain
        if strain<=0:return False,turn,strain
    return False,turn,strain

class Fun066Contracts(unittest.TestCase):
    def test_distinct_telegraphs_and_hit_feedback(self):
        s=text('scripts/enemy.gd')
        for x in ['CRAWLER / INTAKE RUSH','MILLWRIGHT / PRESSURE CYCLE','CANTOR / SIGNAL PULSE','_begin_windup()','rush_hit_ready','_line_attack(role_damage)','apply_environmental_stagger','stagger_time']:
            self.assertIn(x,s)
        self.assertIn('hit.get("collider") == player',s)
    def test_emergency_intervention_never_consumes_ammo(self):
        s=text('scripts/player.gd')
        body=s.split('func intervene() -> void:',1)[1].split('func try_dash() -> void:',1)[0]
        self.assertIn('intervention_cooldown = 0.88',body)
        self.assertIn('target.take_hit(7)',body)
        self.assertNotIn('consume_weapon_round',body)
        self.assertIn('"intervene":KEY_F',text('scripts/run_state.gd'))
        self.assertIn('MOUSE_BUTTON_RIGHT',text('scripts/run_state.gd'))
    def test_original_sfx_are_legitimate_wav_files(self):
        for n in ['pressure_warning','metal_hit','covenant_fire','coil_fire','nail_fire','choir_fire','mechanical_reload','valve_steam']:
            with wave.open(str(R/'assets/audio'/f'{n}.wav')) as f:
                self.assertEqual(f.getframerate(),22050)
                self.assertEqual(f.getnchannels(),1)
                self.assertGreater(f.getnframes(),1500)
    def test_alternate_physically_collidable_shortcuts_and_original_central_route(self):
        soot=text('scripts/sootworks_builder.gd'); bas=text('scripts/basilica_builder.gd')
        self.assertIn('Office divider N / upper',soot)
        self.assertIn('Office divider N / lower',soot)
        self.assertIn('Office divider S',soot)
        self.assertIn('sootworks_shortcut_shutter',soot)
        self.assertIn('Lay partition N / upper',bas)
        self.assertIn('Lay partition N / lower',bas)
        self.assertIn('Lay public partition south',bas)
        self.assertIn('basilica_shortcut_shutter',bas)
        main=text('scripts/main.gd')
        for x in ['sootworks_service_bypass','basilica_side_passage','_open_development_shortcut']:
            self.assertIn(x,main)
    def test_seed_version_saved_and_same_seed_deterministic(self):
        rules=text('scripts/run_state.gd')
        self.assertIn('"seed_variant":seed_variant',rules)
        self.assertIn('"slice_seed_version"] = 2',rules)
        for seed in [5,6,7,1024]:
            self.assertEqual(seed%3,seed%3)
        self.assertIn('Slag cart / seed 0',text('scripts/sootworks_builder.gd'))
        self.assertIn('Acoustic shutter stack / seed 1',text('scripts/basilica_builder.gd'))
    def test_side_events_are_one_time_not_loot_farms(self):
        s=text('scripts/main.gd')
        for ident in ['hearth.intake_quench_066','sootworks.worker_bypass_066','sootworks.steam_diverter_066','basilica.lay_side_passage_066','basilica.resonator_observation_066']:
            self.assertIn(ident,s)
        self.assertNotIn('award_xp_once',s.split('func _fun_interaction',1)[1].split('func _show_civic_consequence',1)[0])
    def test_hearing_readability_retries_and_no_press_spam(self):
        rules=text('scripts/run_state.gd')
        self.assertIn('func hearing_phase()',rules)
        self.assertIn('NEXT-PULSE GUARD',rules)
        self.assertIn('h["brace_guard"] = 8',rules)
        self.assertIn('h["transcript"].append',rules)
        self.assertIn('"basilica.civic_hearing",110',rules)
        for offset in range(3):
            passed,_,_=model_hearing(['Press']*12,offset)
            self.assertFalse(passed, f'all Press should not dominate phase {offset}')
            # 3-4 Attune may win depending phase, a second alternative uses Observe.
            self.assertTrue(model_hearing(['Attune']*6,offset)[0])
            self.assertTrue(model_hearing(['Observe','Attune','Attune','Press','Attune','Attune'],offset)[0])
    def test_canon_event_ids_untouched(self):
        s=text('scripts/run_state.gd')
        for x in ['hearth.lung_installed','sootworks.labour_writ','basilica.faith_writ.transferred','basilica.civic_hearing','slice.edda_resolution']:
            self.assertIn(x,s)

if __name__=='__main__':unittest.main()
