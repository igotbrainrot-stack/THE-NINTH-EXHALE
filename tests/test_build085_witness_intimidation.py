from pathlib import Path
import unittest
ROOT=Path(__file__).resolve().parents[1]
class WitnessIntimidationTests(unittest.TestCase):
 def test_named_actor_threshold_persists(self):
  for k in ('brin','ossa'):
   s=(ROOT/'scripts'/f'{k}_actor.gd').read_text()
   self.assertIn('FEAR_HP_THRESHOLD_085: int = 27',s)
   self.assertIn('hp_before_085 >= FEAR_HP_THRESHOLD_085',s)
   self.assertIn('hp > 0 and hp < FEAR_HP_THRESHOLD_085',s)
   self.assertIn('Game.record_event(',s)
   self.assertIn('THREATENED WITNESS',s)
 def test_no_magic_gun(self):
  for k in ('brin','ossa'):
   s=(ROOT/'scripts'/f'{k}_actor.gd').read_text()
   self.assertNotIn('OfficeEnforcer.new()',s)
 def test_guard_response_connected(self):
  # 09.2: the keeper is no longer alerted by fiat. The threatened witness
  # cries out and only office-holders who perceive it react (bible L1398).
  s=(ROOT/'scripts'/'main.gd').read_text()
  self.assertIn('func _hook_named_witnesses_085()',s)
  body=s.split('func _on_named_witness_threatened_085(',1)[1].split('\nfunc ',1)[0]
  self.assertNotIn('guard.anger()',body)
  self.assertIn('Perception092.witness_assault(',body)
  self.assertIn('"cry_for_help"',body)
 def test_sprite_threatens_without_scale(self):
  s=(ROOT/'scripts'/'directional_npc_sprite.gd').read_text()
  self.assertIn('set_threatened_085',s)
  self.assertNotIn('scale = ',s)
if __name__=='__main__': unittest.main()
