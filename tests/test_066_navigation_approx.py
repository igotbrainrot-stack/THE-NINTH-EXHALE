"""Author geometry 2-D clearance sampling; NOT Godot collision/nav validation."""
import re
import unittest
from pathlib import Path
from collections import deque

R=Path(__file__).resolve().parents[1]
BOX = re.compile(r'solid_box\("([^"]+)"\s*,\s*Vector3\(([-\d.]+),\s*([-\d.]+),\s*([-\d.]+)\)\s*,\s*Vector3\(([-\d.]+),\s*([-\d.]+),\s*([-\d.]+)\)')

def obstacles(path,opened=()):
    content=(R/'scripts'/path).read_text()
    data=[]
    for name,x,y,z,w,h,d in BOX.findall(content):
        if name in opened:continue
        x,y,z,w,h,d=map(float,[x,y,z,w,h,d])
        if y+h/2 < .5 or y-h/2 > 1.4:continue
        if any(k in name.lower() for k in ['floor','foundation','ceiling','header','lintel']):continue
        data.append((name,x-w/2,x+w/2,z-d/2,z+d/2))
    return data

def reachable(boxes,start,targets,bounds,step=.5,radius=.43):
    xmin,xmax,zmin,zmax=bounds
    to_cell=lambda point: (round((point[0]-xmin)/step),round((point[1]-zmin)/step))
    limx=round((xmax-xmin)/step);limz=round((zmax-zmin)/step)
    def passable(c):
        i,j=c
        if i<0 or i>limx or j<0 or j>limz:return False
        x=xmin+i*step; z=zmin+j*step
        return not any(a-radius<=x<=b+radius and d-radius<=z<=e+radius for _,a,b,d,e in boxes)
    start_cell=to_cell(start)
    if not passable(start_cell): return {name:False for name in targets}
    q=deque([start_cell]);seen={start_cell}
    while q:
        a,b=q.popleft()
        for nxt in [(a+1,b),(a-1,b),(a,b+1),(a,b-1)]:
            if nxt not in seen and passable(nxt): seen.add(nxt);q.append(nxt)
    def near(goal):
        cx,cz=to_cell(goal)
        return any(abs(a-cx)*step+abs(b-cz)*step<=2.0 for a,b in seen)
    return {name:near(point) for name,point in targets.items()}

class ApproxNavigation(unittest.TestCase):
    def test_sootworks_main_route_even_with_bypass_closed(self):
        data=obstacles('sootworks_builder.gd')
        reachable_map=reachable(data,(-19,8),{'Brin':(-11,6),'payroll':(-20,-12),'Millwright':(14,-3),'hearth return':(-21,19)},(-23,23,-22,22))
        self.assertTrue(all(reachable_map.values()),reachable_map)
    def test_basilica_main_route_even_with_side_passage_closed(self):
        data=obstacles('basilica_builder.gd')
        reachable_map=reachable(data,(-20,8),{'Ossa':(-19,5),'reel':(-22,-17),'hearing station':(10,-17),'signal governor':(20,4)},(-25,25,-23,23))
        self.assertTrue(all(reachable_map.values()),reachable_map)
    def test_optional_apertures_exist_and_are_body_width(self):
        soot=obstacles('sootworks_builder.gd')
        self.assertTrue(any('Worker service bypass shutter' in n for n,*_ in soot))
        self.assertTrue(any('Choir side passage shutter' in n for n,*_ in obstacles('basilica_builder.gd')))
        # Relevant shutters have a clear through-width 4.7 m / 5.5 m
        s=(R/'scripts/sootworks_builder.gd').read_text()
        b=(R/'scripts/basilica_builder.gd').read_text()
        self.assertIn('Vector3(0.8,2.84,4.7)',s)
        self.assertIn('Vector3(0.8,2.84,5.5)',b)

if __name__=='__main__':unittest.main()
