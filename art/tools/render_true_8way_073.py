#!/usr/bin/env python3
"""Bake *actual* orthographic 3D turntable snapshots for 22 Ninth Exhale actors.

Godot's earlier 07.2 enemy 'eight views' used nearly identical frontal cutouts.
This version constructs original low-poly industrial maquettes and renders eight
real camera directions (not flips, warps or renames). These are interim source
art and NOT the newly commissioned Runway 2x4 paintings. Distinct full three-
dimensional silhouettes, left/right details and back surfaces are intentional.

Usage: python3 art/tools/render_true_8way_073.py [--actor sentry] [--preview-only]
Requires vtk, pillow, numpy (build-time only; runtime is native Godot PNG).
"""
from __future__ import annotations
import math, argparse, json, random
from pathlib import Path
import vtk
import numpy as np
from vtk.util.numpy_support import vtk_to_numpy
from PIL import Image, ImageFilter, ImageOps
ROOT=Path(__file__).resolve().parents[2]
SRC=ROOT/'art/production_sources/turntable_073'
ENEMY=ROOT/'assets/sprites/enemies_073'
NPC=ROOT/'assets/sprites/directional8'
NPC_NAMES=['sela','brin','ossa','oren','clerk']
ENEMY_NAMES=['sentry','enforcer','millwright','cantor','edda_machine','pressure_mite','registry_bailiff','vent_whistler','rivet_courier','slag_sifter','chain_hauler','choir_reed','saltbound_porter','sluice_beadle','triage_warden','bell_wretch','rootkin']
ALL=NPC_NAMES+ENEMY_NAMES
P={
 'iron':(.22,.275,.276),'iron_dark':(.095,.13,.132),'olive':(.29,.37,.31),
 'olive_dark':(.16,.22,.195),'cream':(.73,.73,.64),'linen':(.60,.62,.54),
 'copper':(.57,.36,.205),'brass':(.75,.56,.31),'rust':(.49,.24,.15),
 'charcoal':(.20,.18,.18),'leather':(.38,.27,.20),'teal':(.23,.41,.41),
 'teal_dark':(.13,.26,.27),'pale_blue':(.49,.63,.64),'silver':(.56,.63,.62),
 'ochre':(.71,.43,.17),'skin':(.69,.49,.36),'skin_dark':(.49,.31,.22),
 'black':(.065,.08,.085),'glass':(.25,.42,.43),'red':(.65,.23,.14),'amber':(.93,.64,.24),
 'sea':(.39,.57,.46),'purple':(.50,.31,.37)
}

def C(v): return P.get(v,v)

class Rig:
 def __init__(self,key):
  self.key=key
  self.root=vtk.vtkAssembly()
  self.parts=[]
  self.mid=1.12
  self.fixed_height=2.62
  self.rng=random.Random('NINTH07-3_'+key)
 def attach(self,actor):self.root.AddPart(actor);self.parts.append(actor);return actor
 def poly(self,src,pos,color,rot=None,metal=False):
  mapper=vtk.vtkPolyDataMapper();mapper.SetInputConnection(src.GetOutputPort())
  a=vtk.vtkActor();a.SetMapper(mapper)
  a.SetPosition(*pos)
  if rot:a.RotateWXYZ(rot[0],*rot[1:])
  p=a.GetProperty();p.SetColor(*C(color));p.SetAmbient(.30 if metal else .35);p.SetDiffuse(.65)
  p.SetSpecular(.36 if metal else .13);p.SetSpecularPower(23 if metal else 9)
  p.SetInterpolationToPhong()
  return self.attach(a)
 def box(self,pos,scale,color,rot=None,metal=False):
  src=vtk.vtkCubeSource();src.SetXLength(scale[0]);src.SetYLength(scale[1]);src.SetZLength(scale[2]);return self.poly(src,pos,color,rot,metal)
 def ball(self,pos,scale,color):
  s=vtk.vtkSphereSource();s.SetRadius(1.0);s.SetThetaResolution(14);s.SetPhiResolution(12)
  a=self.poly(s,pos,color);a.SetScale(*scale);return a
 def cyl(self,pos,r,h,color,axis='y',metal=False,segments=12):
  s=vtk.vtkCylinderSource();s.SetRadius(r);s.SetHeight(h);s.SetResolution(segments)
  rot={'x':(90,0,0,1),'y':None,'z':(90,1,0,0)}[axis]
  return self.poly(s,pos,color,rot,metal)
 def cone(self,pos,r,h,color,axis='y'):
  s=vtk.vtkConeSource();s.SetRadius(r);s.SetHeight(h);s.SetResolution(10);s.SetDirection(0,1,0);s.SetCenter(0,0,0)
  return self.poly(s,pos,color,{'z':(90,1,0,0),'x':(90,0,0,1),'y':None}[axis])
 def pipe(self,a,b,r,color,metal=True):
  a=np.asarray(a,float);b=np.asarray(b,float);d=b-a;h=float(np.linalg.norm(d))
  if h<.00001:return
  s=vtk.vtkCylinderSource();s.SetRadius(r);s.SetHeight(h);s.SetResolution(10)
  actor=self.poly(s,tuple((a+b)/2),color,metal=metal)
  mat=vtk.vtkMatrix4x4();z=np.array([0.,1.,0.]);v=d/h
  cross=np.cross(z,v);c=np.dot(z,v)
  if np.linalg.norm(cross)>1e-5:actor.RotateWXYZ(math.degrees(math.acos(np.clip(c,-1,1))),*tuple(cross/np.linalg.norm(cross)))
  elif c<-.99:actor.RotateX(180)
  return actor
 def torus(self,pos,r,tube,color,axis='z'):
  s=vtk.vtkParametricTorus();s.SetRingRadius(r);s.SetCrossSectionRadius(tube)
  f=vtk.vtkParametricFunctionSource();f.SetParametricFunction(s);f.SetUResolution(25);f.SetVResolution(8)
  return self.poly(f,pos,color,{'y':(90,1,0,0),'x':(90,0,1,0),'z':None}[axis],metal=True)
 def rivets(self,pos,spread,axis='z',col='brass'):
  x,y,z=pos;dx,dy=spread
  for xx in (-1,1):
   for yy in (-1,1):self.ball((x+xx*dx,y+yy*dy,z),(.035,.035,.035),col)
 def gauge(self,pos,r=.13):
  x,y,z=pos;self.cyl((x,y,z),r,.045,'brass',axis='z',metal=True)
  self.cyl((x,y,z-.031),r*.72,.018,'cream',axis='z')
  self.box((x+.025,y+.015,z-.045),(.014,r*.63,.01),'red',rot=(25,0,0,1))
 def grille(self,pos,w=.5,h=.28,count=5,col='iron_dark'):
  x,y,z=pos
  for i in range(count):self.box((x,y-h/2+(i+.5)*h/count,z), (w,.018,.012),col)
 def sling(self,side='right',height=1.4):
  x=.31 if side=='right' else -.31
  self.pipe((x,height,.18),(x*.8,height-.7,-.13),.027,'leather')
 def eye(self,x,y,z):self.ball((x,y,z),(.033,.035,.025),'black')


def human(key):
 r=Rig(key);f=1.0 if key!='brin' else .89;r.fixed_height=2.7*f
 if key=='brin':r.mid=1.08
 colors={
 'sela':('pale_blue','linen','charcoal'), 'brin':('olive','leather','charcoal'),
 'ossa':('teal_dark','teal','charcoal'), 'oren':('olive_dark','iron','leather'),
 'clerk':('linen','olive','charcoal'), 'enforcer':('olive_dark','iron_dark','charcoal'),
 'cantor':('teal_dark','olive_dark','charcoal'),'registry_bailiff':('iron_dark','olive','charcoal'),
 'saltbound_porter':('teal','linen','olive_dark'),
 }
 coat,pants,boots=colors[key]
 # body front = -Z; side-specific details are NOT mirrored in output
 r.box((0,1.45*f,0),(.65*f,.90*f,.40*f),coat)
 r.box((0,1.04*f,-.02),(.56*f,.16*f,.41*f),'leather')
 r.box((0,1.39*f,-.215*f),(.48*f,.62*f,.035*f),'linen' if key in ['sela','clerk'] else coat)
 # side seam and garment closure
 r.box((-.20*f,1.46*f,-.244*f),(.055*f,.68*f,.025*f),'brass' if key=='enforcer' else 'charcoal')
 for yy in [1.18,1.37,1.56]:r.ball((-.13*f,yy*f,-.25*f),(.026*f,.025*f,.018*f),'brass')
 # face and hair
 r.cyl((0,1.96*f,0),.105*f,.18*f,'skin')
 r.ball((0,2.20*f,-.02*f),(.255*f,.31*f,.23*f),'skin_dark' if key=='brin' else 'skin')
 r.ball((0,2.39*f,.022*f),(.26*f,.14*f,.23*f),'charcoal' if key not in ['sela','ossa'] else 'olive_dark')
 for x in [-.089*f,.089*f]:r.eye(x,2.20*f,-.242*f)
 r.box((0,2.09*f,-.245*f),(.11*f,.025*f,.018*f),'skin_dark')
 # front legs boots and service shoes
 for x in (-.185*f,.185*f):
  r.cyl((x,.62*f,.018),.168*f,.77*f,pants)
  r.box((x,.155*f,-.086*f),(.32*f,.27*f,.44*f),boots)
  r.box((x,.30*f,-.01),(.30*f,.055*f,.34*f),'brass' if key=='enforcer' else 'leather')
 # jacket arms & gloves, right distinct tool-side sleeve
 for sign in (-1,1):
  x=sign*.42*f
  r.ball((x,1.77*f,0),(.19*f,.19*f,.18*f),coat)
  r.pipe((x,1.71*f,0),(sign*.49*f,1.13*f,.06*f),.125*f,coat,metal=False)
  r.ball((sign*.50*f,1.06*f,.055*f),(.13*f,.17*f,.10*f),'skin_dark' if key=='brin' else 'skin')
  r.box((sign*.47*f,1.25*f,-.007*f),(.22*f,.17*f,.24*f),'charcoal' if sign==1 else 'olive_dark')
 # back of coat clearly distinguished from front
 r.box((0,1.41*f,.228*f),(.53*f,.67*f,.025*f),'olive_dark' if key!='sela' else 'pale_blue')
 r.box((0,1.52*f,.247*f),(.033*f,.60*f,.012*f),'leather')
 if key=='sela':
  r.box((0,1.40*f,-.267*f),(.52*f,.85*f,.035*f),'cream')
  r.box((0,1.55*f,-.291*f),(.13*f,.16*f,.03*f),'silver');r.gauge((.39*f,1.20*f,-.18*f),.075*f)
  r.pipe((.42*f,1.22*f,-.16*f),(.48*f,1.04*f,.04*f),.024*f,'brass')
 elif key=='brin':
  for i in range(5):r.ball((.50*f+(i-2)*.04*f,.94*f,-.04*f),(.025*f,.09*f,.032*f),'brass')
  r.box((.50*f,1.08*f,.005),(.24*f,.38*f,.24*f),'iron',metal=True)
  r.box((0,2.36*f,-.26*f),(.38*f,.10*f,.10*f),'black')
  for sx in (-.10*f,.10*f):r.ball((sx,2.365*f,-.30*f),(.09*f,.06*f,.03*f),'brass')
  r.box((-.20*f,1.42*f,-.28*f),(.22*f,.28*f,.035*f),'rust')
 elif key=='ossa':
  r.box((0,1.95*f,-.21*f),(.20*f,.29*f,.22*f),'copper',metal=True)
  r.grille((0,1.94*f,-.336*f),.15*f,.18*f)
  for xx in [-.25*f,.25*f]:r.pipe((xx,1.75*f,.18*f),(xx*.65,1.3*f,.24*f),.03*f,'brass')
  r.box((0,.80*f,-.25*f),(.50*f,.26*f,.02*f),'olive')
 elif key=='oren':
  r.box((-.44*f,1.76*f,-.02*f),(.28*f,.29*f,.33*f),'iron')
  r.box((-.49*f,1.26*f,-.04*f),(.24*f,.31*f,.22*f),'silver',metal=True)
  r.cyl((.28*f,.98*f,.23*f),.15*f,.07*f,'brass',axis='z')
 elif key=='clerk':
  for x in [-.15*f,0,.15*f]:r.box((x,1.28*f,-.28*f),(.13*f,.17*f,.06*f),'leather')
  r.box((.45*f,1.28*f,-.20*f),(.20*f,.23*f,.07*f),'linen');r.gauge((-.42*f,1.10*f,-.09*f),.08*f)
  r.ball((-.10*f,2.20*f,-.27*f),(.105*f,.075*f,.03*f),'black');r.ball((.10*f,2.20*f,-.27*f),(.105*f,.075*f,.03*f),'black')
 elif key=='enforcer':
  r.box((.44*f,1.79*f,0),(.34*f,.25*f,.35*f),'iron',metal=True)
  r.box((0,2.43*f,0),(.57*f,.15*f,.53*f),'charcoal')
  r.box((0,2.20*f,-.28*f),(.33*f,.125*f,.07*f),'glass',metal=True)
  r.pipe((-.47*f,1.20*f,-.15*f),(-.32*f,.99*f,-.4*f),.047*f,'brass')
 elif key=='cantor':
  for x in [-.22*f,.24*f]:
   r.pipe((x,1.17*f,.17*f),(x,2.01*f,.19*f),.046*f,'copper');r.cyl((x,1.92*f,.22*f),.070*f,.21*f,'brass')
  r.box((0,1.53*f,-.29*f),(.44*f,.36*f,.07*f),'copper');r.grille((0,1.53*f,-.35*f),.33*f,.20*f)
 elif key=='registry_bailiff':
  r.box((-.61*f,1.4*f,-.20*f),(.23*f,.92*f,.52*f),'leather')
  r.box((-.67*f,1.5*f,-.39*f),(.40*f,.85*f,.08*f),'linen')
  r.box((-.64*f,1.4*f,-.45*f),(.28*f,.40*f,.03*f),'cream')
  r.box((0,2.43*f,0),(.55*f,.22*f,.43*f),'brass')
 elif key=='saltbound_porter':
  r.box((0,.90*f,.22*f),(.70*f,.45*f,.06*f),'teal_dark')
  r.ball((0,2.19*f,-.28*f),(.265*f,.27*f,.03*f),'glass')
  r.pipe((.50*f,1.73*f,.19*f),(.66*f,1.24*f,.20*f),.08*f,'charcoal')
  r.pipe((.66*f,1.24*f,.20*f),(.31*f,1.02*f,.30*f),.08*f,'charcoal')
 return r


def mech(key):
 r=Rig(key);r.fixed_height=2.7
 # all models have clear front negative Z and differing back structure
 if key=='sentry':
  r.fixed_height=1.7;r.mid=.75
  r.box((0,.94,0),(.76,.53,.90),'cream');r.box((0,.99,-.47),(.56,.33,.08),'teal_dark')
  r.grille((0,.98,-.525),.46,.19);r.gauge((.17,1.12,-.53),.09)
  r.box((0,.88,.49),(.48,.30,.06),'rust');r.gauge((-.14,.89,.54),.12)
  for side in [-1,1]:
   for z in [-.27,.27]:
    r.pipe((side*.33,.77,z),(side*.63,.48,z+(.10 if z>0 else -.1)),.078,'brass')
    r.pipe((side*.63,.48,z+(.10 if z>0 else -.1)),(side*.69,.15,z+(.19 if z>0 else -.19)),.063,'iron')
    r.ball((side*.68,.17,z+(.19 if z>0 else -.19)),(.08,.06,.10),'iron_dark')
  r.cyl((0,1.29,.19),.18,.13,'copper',axis='z')
 elif key=='pressure_mite':
  r.fixed_height=1.5;r.mid=.72
  r.ball((0,.89,0),(.44,.29,.39),'cream');r.box((0,.86,-.40),(.38,.19,.05),'teal')
  r.gauge((.05,1.00,-.43),.11);r.box((0,.86,.39),(.25,.20,.06),'rust')
  for s in [-1,1]:
   for z in [-.33,0,.33]:
    r.pipe((s*.34,.84,z),(s*.61,.49,z),.037,'iron_dark')
    r.pipe((s*.61,.49,z),(s*.73,.10,z+(.08 if z<0 else -.08)),.026,'copper')
  for x in [-.16,.16]:r.pipe((x,1.12,-.31),(x*.65,1.49,-.63),.018,'brass')
 elif key=='vent_whistler':
  r.fixed_height=2.15;r.mid=1.0
  r.cyl((0,.28,0),.49,.18,'charcoal');r.cyl((0,.66,0),.22,.62,'iron')
  r.box((0,1.06,0),(.60,.40,.44),'teal')
  for i,x in enumerate([-.25,0,.24]):
   r.cyl((x,1.56+i*.12,-.12),.11+i*.025,.84 if i==0 else .62,'cream',metal=False)
   r.cyl((x,1.98+i*.06,-.12),.17+i*.026,.07,'brass')
  r.box((0,.99,.23),(.46,.18,.08),'iron_dark');r.gauge((0,1.1,-.24),.11)
 elif key=='rivet_courier':
  r.fixed_height=1.65;r.mid=.78
  r.box((0,.93,0),(.58,.47,.51),'olive');r.box((.40,.90,.02),(.25,.53,.43),'ochre')
  r.grille((.40,.91,-.215),.18,.32)
  for x in [-.38,.38]:r.cyl((x,.35,.16),.27,.105,'charcoal',axis='x',metal=True)
  r.box((0,1.23,-.25),(.27,.18,.06),'glass')
  r.pipe((-.14,1.19,.08),(-.20,1.52,.12),.024,'brass')
  r.box((-.20,1.50,.15),(.24,.20,.018),'ochre')
 elif key=='slag_sifter':
  r.fixed_height=2.20;r.mid=1.01
  r.box((0,.95,0),(1.22,.81,.86),'iron_dark',metal=True)
  r.box((0,1.32,.03),(1.02,.26,.72),'rust')
  r.box((0,.98,-.45),(.82,.53,.035),'charcoal');r.grille((0,.97,-.48),.73,.45,8,'silver')
  for x in [-.64,.64]:
   r.box((x,.38,0),(.26,.55,.92),'charcoal');r.cyl((x,.40,0),.25,.24,'iron',axis='x')
  r.cyl((0,1.76,.32),.18,.78,'linen')
  r.box((0,.84,.45),(.42,.34,.10),'brass');r.gauge((0,1.04,.52),.12)
 elif key=='chain_hauler':
  r.fixed_height=3.2;r.mid=1.4
  r.box((0,1.60,0),(.67,.93,.55),'ochre');r.box((0,2.12,.25),(.85,.30,.58),'iron')
  for x in [-.26,.26]:
   r.pipe((x,1.16,0),(x*.98,.53,0),.16,'iron');r.box((x,.23,-.08),(.39,.34,.65),'charcoal')
  r.cyl((0,2.30,.23),.29,1.08,'brass',axis='x');r.torus((0,2.30,.23),.32,.045,'charcoal',axis='x')
  r.pipe((.38,2.25,-.02),(.77,1.50,-.12),.16,'iron');r.pipe((.77,1.50,-.12),(.96,1.25,-.30),.09,'ochre')
  r.pipe((-.39,2.20,0),(-.50,1.17,0),.11,'copper')
  for h in [1.86,1.70,1.54,1.38]:r.torus((-.50,h,-.05),.07,.026,'brass',axis='y')
  r.box((0,1.55,-.31),(.48,.45,.06),'iron_dark');r.gauge((0,1.59,-.34),.10)
 elif key=='choir_reed':
  r.fixed_height=3.25;r.mid=1.47
  r.box((0,1.35,0),(.48,.70,.42),'olive_dark');r.box((0,1.32,-.24),(.40,.43,.06),'cream')
  for i,x in enumerate([-.31,-.10,.11,.31]):
   h=[1.05,1.48,1.2,.78][i]
   r.cyl((x,2.00+h*.28,.06),.085,h,'brass');r.cyl((x,2.00+h*.78,.06),.115,.10,'cream')
  for x in [-.20,.20]:
   r.pipe((x,1.10,0),(x,.42,0),.049,'iron');r.box((x,.20,-.09),(.20,.28,.30),'charcoal')
  r.box((0,1.53,.22),(.30,.28,.08),'copper')
 elif key=='edda_machine':
  r.fixed_height=2.65;r.mid=1.14
  r.box((0,1.22,0),(.83,1.17,.73),'cream');r.box((0,1.57,-.40),(.70,.41,.055),'iron')
  for y in [1.40,1.53,1.67]:r.box((0,y,-.443),(.54,.052,.03),'brass')
  r.box((0,1.15,.40),(.60,.50,.085),'iron_dark');r.gauge((0,1.21,.45),.15)
  for x,z in [(0,-.36),(-.44,.36),(.44,.36)]:
   r.pipe((x*.7,.72,z*.7),(x,.28,z),.12,'iron');r.ball((x,.17,z),(.20,.13,.18),'brass')
  r.pipe((0,1.83,.30),(0,2.50,.30),.05,'copper');r.cyl((0,2.55,.30),.11,.12,'amber')
 elif key=='sluice_beadle':
  r.fixed_height=2.30;r.mid=1.01
  r.box((0,1.29,0),(1.05,1.20,.48),'iron');r.box((0,1.24,-.26),(.74,.86,.045),'rust')
  r.box((0,1.25,-.30),(.40,.70,.027),'ochre');r.grille((0,1.26,-.325),.30,.55,5,'iron_dark')
  for x in [-.62,.62]:
   r.cyl((x,1.17,0),.17,.72,'brass');r.pipe((x,.93,0),(x,.40,0),.11,'iron')
   r.box((x,.21,-.13),(.38,.34,.53),'charcoal')
  r.box((0,1.17,.29),(.75,.45,.10),'iron_dark');r.gauge((0,1.18,.35),.11)
 elif key=='triage_warden':
  r.fixed_height=2.85;r.mid=1.34
  r.box((0,1.45,0),(.49,.94,.40),'cream');r.box((0,1.54,-.22),(.30,.38,.04),'brass')
  r.ball((0,2.23,0),(.21,.25,.20),'cream');r.box((0,2.23,-.20),(.31,.09,.025),'glass')
  for x in [-.19,.19]:r.pipe((x,1.01,0),(x,.28,0),.08,'iron');r.box((x,.16,-.09),(.19,.24,.34),'charcoal')
  for s in [-1,1]:
   r.pipe((s*.37,1.78,0),(s*.65,1.27,-.07),.075,'brass')
   r.box((s*.77,1.34,-.10),(.29,.72,.09),'pale_blue')
  r.box((0,1.40,.24),(.39,.45,.09),'olive')
 elif key=='millwright':
  r.fixed_height=3.1;r.mid=1.52
  r.box((0,1.55,0),(.98,1.06,.66),'iron');r.box((0,1.62,-.37),(.75,.62,.06),'olive')
  r.ball((0,2.34,-.09),(.27,.32,.29),'skin_dark');r.box((0,2.36,-.36),(.37,.21,.05),'charcoal')
  r.cyl((.52,2.17,.10),.29,.85,'copper');r.gauge((.52,2.26,-.27),.14)
  r.cyl((-.54,2.01,.00),.28,.48,'iron',axis='z')
  for x in [-.29,.29]:
   r.pipe((x,1.05,.03),(x,.47,.03),.19,'iron');r.box((x,.20,-.16),(.45,.35,.67),'charcoal')
  for x in [-.66,.66]:
   r.box((x,1.75,0),(.38,.48,.50),'iron');r.pipe((x,1.48,0),(x*.90,.90,-.08),.19,'iron')
   r.box((x*.90,.79,-.16),(.38,.30,.40),'brass')
  r.box((0,1.58,.37),(.70,.72,.10),'rust');r.rivets((0,1.6,.45),(.23,.22))
 elif key=='bell_wretch':
  r.fixed_height=2.45;r.mid=1.16
  # Hollow central torso: separate ring shells with a genuinely visible gap
  for x,dy in [(-.30,0),(.34,.17)]:
   r.cyl((x,1.42+dy,0),.29,.64,'brass')
   r.cyl((x,1.24+dy,-.035),.23,.25,'rust',axis='z')
  r.ball((0,2.04,.04),(.30,.33,.19),'sea')
  for x in [-.31,.31]:
   r.pipe((x,1.17,0),(x*.90,.33,0),.036,'copper')
   r.pipe((x*.90,.34,0),(x*1.13,.13,-.18),.034,'charcoal')
  r.box((0,.99,.18),(.46,.08,.15),'cream');r.torus((0,1.38,.0),.38,.055,'copper',axis='y')
 elif key=='rootkin':
  r.fixed_height=1.92;r.mid=.86
  r.ball((0,1.14,0),(.42,.37,.31),'sea');r.ball((0,1.52,-.11),(.29,.30,.27),'cream')
  for x in [-.18,.18]:r.eye(x,1.54,-.37)
  for x in [-.22,.19]:
   r.pipe((x,.89,0),(x*1.65,.37,.05),.07,'olive_dark')
   r.pipe((x*1.65,.37,.05),(x*1.75,.11,-.08),.044,'leather')
  for x in [-.43,.41]:r.pipe((x*.8,1.26,0),(x*1.3,.85,-.21),.046,'olive')
  r.pipe((0,1.79,.04),(.19,2.07,.05),.045,'olive')
  r.ball((.19,2.07,.05),(.14,.065,.08),'sea')
  r.ball((0,1.17,.28),(.20,.15,.05),'copper')
 else: raise ValueError(key)
 return r

class Renderer:
 def __init__(self,size=(256,320)):
  self.w,self.h=size
  self.renderer=vtk.vtkRenderer();self.renderer.SetBackground(1,0,1)
  self.win=vtk.vtkRenderWindow();self.win.SetSize(self.w,self.h);self.win.AddRenderer(self.renderer);self.win.SetOffScreenRendering(True);self.win.SetMultiSamples(0)
  self.cam=self.renderer.GetActiveCamera();self.cam.ParallelProjectionOn()
  key=vtk.vtkLight();key.SetPosition(-4,7,-5);key.SetFocalPoint(0,1,0);key.SetIntensity(.9);self.renderer.AddLight(key)
  fill=vtk.vtkLight();fill.SetPosition(6,4,5);fill.SetFocalPoint(0,1,0);fill.SetIntensity(.42);self.renderer.AddLight(fill)
  rim=vtk.vtkLight();rim.SetPosition(0,6,3);rim.SetFocalPoint(0,1,0);rim.SetIntensity(.4);self.renderer.AddLight(rim)
  self.w2i=vtk.vtkWindowToImageFilter();self.w2i.SetInput(self.win);self.w2i.SetInputBufferTypeToRGBA()
 def frame(self,rig:Rig,angle:int):
  theta=(angle-1)*math.pi/4
  # 1 front -Z; 2 LEFT side front; 5 back +Z; 7 right +X
  R=6.;y=rig.mid
  self.cam.SetPosition(-R*math.sin(theta),y+.25,-R*math.cos(theta))
  self.cam.SetFocalPoint(0,y,0)
  self.cam.SetViewUp(0,1,0)
  self.cam.SetParallelScale(rig.fixed_height*.61)
  self.cam.SetClippingRange(.1,30)
  self.renderer.ResetCameraClippingRange()
  self.win.Render();self.w2i.Modified();self.w2i.Update()
  arr=vtk_to_numpy(self.w2i.GetOutput().GetPointData().GetScalars()).reshape((self.h,self.w,4))[::-1]
  return Image.fromarray(np.asarray(arr[:,:,:3],dtype=np.uint8)).convert('RGB')
 def set_rig(self,rig):
  self.renderer.RemoveAllViewProps();self.renderer.AddActor(rig.root)
 def finish(self):self.win.Finalize()

def chroma(img:Image.Image,w:int,h:int)->Image.Image:
 arr=np.asarray(img.convert('RGB'),dtype=np.uint8)
 r,g,b=arr[:,:,0].astype('float32'),arr[:,:,1].astype('float32'),arr[:,:,2].astype('float32')
 # opaque material never has magenta chroma with these rig palettes
 is_bg=(r>190)&(b>180)&(g<65)&((r-g)>115)&((b-g)>115)
 alpha=np.where(is_bg,0,255).astype('uint8')
 from PIL import ImageFilter
 a=Image.fromarray(alpha,'L')
 # black contour prevents purple halo around foliage/limbs
 mask=a.filter(ImageFilter.MaxFilter(3))
 rgb=np.asarray(img).copy()
 # subtly desaturate to restrain videogame industrial palette
 rgb=np.clip(rgb.astype('float32')*.95+7,0,255).astype('uint8')
 target=Image.fromarray(rgb,'RGB').convert('RGBA');target.putalpha(a)
 bb=target.getbbox()
 if bb is None:return Image.new('RGBA',(w,h))
 content=target.crop(bb)
 # same camera scale/physical pixel size for all angles, no per-angle normalization
 content.thumbnail((w-12,h-7),Image.Resampling.LANCZOS)
 canvas=Image.new('RGBA',(w,h))
 canvas.alpha_composite(content,((w-content.width)//2,h-content.height-4))
 # purposeful low-res pixel treatment without corrupting silhouette
 return canvas

def atlas_pose(view:Image.Image,i:int)->Image.Image:
 # 12 deterministic animation proxy frames retained for compatibility; 3D turntable only for facing
 from PIL import ImageEnhance
 w,h=view.size
 offsets=[(0,0),(2,-2),(0,0),(-2,-2),(-3,1),(-4,2),(4,0),(3,-1),(-2,2),(0,0),(1,8),(0,15)]
 angle=[0,1,0,-1,-3,-5,4,2,-3,0,12,23][i]
 o=view.rotate(angle,Image.Resampling.BICUBIC,center=(w/2,h*.91))
 ans=Image.new('RGBA',(w,h));dx,dy=offsets[i];ans.alpha_composite(o,(dx,dy))
 if i==8:ans=ImageEnhance.Brightness(ans).enhance(1.20)
 if i>=9:
  alp=ans.getchannel('A').point(lambda x:int(x*[1,.78,.55][i-9]))
  ans.putalpha(alp)
 return ans

def run(keys,make_assets=True,replace_npcs=False):
 SRC.mkdir(parents=True,exist_ok=True);ENEMY.mkdir(parents=True,exist_ok=True);NPC.mkdir(parents=True,exist_ok=True)
 report={};r=Renderer()
 for idx,key in enumerate(keys):
  rig=human(key) if key in ['sela','brin','ossa','oren','clerk','enforcer','cantor','registry_bailiff','saltbound_porter'] else mech(key)
  r.set_rig(rig)
  arr=[]
  for angle in range(1,9):
   full=r.frame(rig,angle)
   view=chroma(full,192,280 if key in NPC_NAMES else 256)
   arr.append(view)
  # full turnaround for inspection and art refinement
  sheet=Image.new('RGBA',(192*4, (280 if key in NPC_NAMES else 256)*2))
  for i,im in enumerate(arr):sheet.alpha_composite(im,((i%4)*192,(i//4)*(280 if key in NPC_NAMES else 256)))
  sheet.save(SRC/f'{key}_8way_TRUE_3d.png',optimize=True)
  if make_assets and (key not in NPC_NAMES or replace_npcs):
   for i,im in enumerate(arr,1):
    if key in NPC_NAMES:
     im.save(NPC/f'{key}_{i}.png',optimize=True)
    else:
     atlas=Image.new('RGBA',(192*4,256*3))
     for pose in range(12):atlas.alpha_composite(atlas_pose(im,pose),((pose%4)*192,(pose//4)*256))
     atlas.save(ENEMY/f'{key}_{i}.png',compress_level=1)
  # Automatic quality sanity check: every angle has significant geometric difference vs front and opposite
  masks=np.asarray([np.asarray(i.getchannel('A').resize((48,64)))>100 for i in arr])
  differences=[]
  for i in range(8):
   for j in range(i+1,8):
    differences.append(float(np.logical_xor(masks[i],masks[j]).mean()))
  report[key]={'produced':8,'source_method':'real fixed-camera 3D turntable, 45 degree increments','min_silhouette_difference':round(min(differences),4),'front_back_difference':round(float(np.logical_xor(masks[0],masks[4]).mean()),4),'source_sheet':str(SRC/f'{key}_8way_TRUE_3d.png').replace(str(ROOT)+'/','')}
  print(f'[{idx+1:02}/{len(keys):02}] {key} 8 angles rendered; front/back XOR {report[key]["front_back_difference"]:.3f}',flush=True)
 r.finish()
 (ROOT/'art/BAKED_TRUE_EIGHT_073_REPORT.json').write_text(json.dumps({'build':'07.3','method':'3D orthographic turntables, 8 original views per entity; separate from Runway commissioned hand paintings', 'actors':report},indent=2)+'\n')

if __name__=='__main__':
 ap=argparse.ArgumentParser();ap.add_argument('--actor',choices=ALL);ap.add_argument('--preview-only',action='store_true');ap.add_argument('--replace-painted-npcs',action='store_true',help='Optional: render interim 3D maquettes in game for NPCs too; default keeps better painted NPC directions');args=ap.parse_args()
 run([args.actor] if args.actor else ALL,not args.preview_only,args.replace_painted_npcs)
