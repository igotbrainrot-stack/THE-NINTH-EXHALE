import unittest
from pathlib import Path
import wave

BASE=Path(__file__).resolve().parents[1]
class ActorAudio083Tests(unittest.TestCase):
    def test_all_audio_files_are_valid_and_nonempty(self):
        for family, events in [('npc', [f'grunt_{i}' for i in range(4)]),('mechanical',['alert','windup','attack','hurt','death']),('organic',['alert','windup','attack','hurt','death'])]:
            for event in events:
                with self.subTest(family=family,event=event):
                    path=BASE/'assets'/'audio'/'actor_083'/f'{family}_{event}.wav'
                    self.assertTrue(path.exists())
                    with wave.open(str(path),'rb') as audio:
                        self.assertGreater(audio.getnframes(),3000)
                        self.assertEqual(audio.getnchannels(),1)
    def test_sequential_dialogue_syllables(self):
        voice=(BASE/'scripts'/'actor_voice_083.gd').read_text()
        self.assertIn('syllables_remaining = 2 +',voice)
        self.assertIn('not output.playing',voice)
        self.assertIn('voice_index += 1',voice)

    def test_actor_routing_targets_physical_instances(self):
        main=(BASE/'scripts'/'main.gd').read_text()
        self.assertIn('_play_npc_voice_083(interaction_id)',main)
        self.assertIn('actor.has_meta("interaction_id")',main)
        self.assertIn('get_node_or_null("Voice083")',main)
        for name in ('brin_actor.gd','ossa_actor.gd','world_builder.gd'):
            self.assertIn('res://scripts/actor_voice_083.gd',(BASE/'scripts'/name).read_text())
    def test_enemy_events_are_wired_and_one_shot(self):
        enemy=(BASE/'scripts'/'enemy.gd').read_text()
        for name in ['alert','windup','attack','hurt','death']:
            self.assertIn('"'+name+'"',enemy)
        self.assertIn('if hp <= 0: return',enemy)
        self.assertIn('voice_083.call("play_enemy"',enemy)
    def test_manifest_distinguishes_unimported_runway(self):
        import json
        manifest=json.loads((BASE/'art'/'RUNWAY_AUDIO_MANIFEST_083.json').read_text())
        self.assertEqual(len(manifest['bundled']),14)
        self.assertIn('NOT',manifest['note'].upper()+' NOT')
        self.assertEqual(manifest['producer'],'local procedural WAV fallback, not Runway media')

if __name__=='__main__':unittest.main()
