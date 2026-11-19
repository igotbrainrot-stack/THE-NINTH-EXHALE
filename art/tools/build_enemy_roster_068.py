#!/usr/bin/env python3
"""One authoring source for The Ninth Exhale's Build 06.8 combat enemy catalogue.
Original designs, no imported commercial franchise monsters. Intro crawler and bosses retain all quest IDs.
"""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
# id, visible name, district, HP, cooldown, attack, movement style, move speed, range, wake radius, base damage, initial position, spawn rank
ROWS=[
 ('sentry','Faulty Intake Filter Crawler','hearth',32,2.8,'rush','rush',3.7,2.0,9,4,[-17.2,.15,9],0),
 ('enforcer','Requisition Enforcer','hearth',70,2.25,'line','guard',2.1,10.5,0,9,[18,.15,0],0),
 ('millwright','Millwright Power Frame','sootworks',125,2.8,'heavy','boss',1.25,10.5,0,12,[14,.15,-3],0),
 ('cantor','Cantor Signal Keeper','basilica',125,2.45,'signal','boss',1.6,10.5,0,8,[14,.15,5],0),
 ('edda_machine','Edda Triage Regulator','lift',90,2.4,'heavy','boss',1.5,10.5,0,10,[7,.15,3],0),
 ('pressure_mite','Pressure Mite','hearth',20,2.05,'rush','flanker',3.5,1.55,7,5,[-3,.15,-5],1),
 ('registry_bailiff','Registry Bailiff','hearth',62,3.1,'line','shield',1.4,8.2,7,7,[7,.15,10],2),
 ('vent_whistler','Vent Whistler','hearth',40,3.35,'signal','turret',0,10.2,9,5,[13,.15,-11],3),
 ('rivet_courier','Rivet Courier','sootworks',32,1.85,'line','skirmish',3.4,10,12,5,[-8,.15,-2],1),
 ('slag_sifter','Slag Sifter','sootworks',75,3.8,'heavy','siege',1.0,9.0,9,8,[18,.15,-14],2),
 ('chain_hauler','Chain Hauler','sootworks',88,3.3,'pull','control',1.5,8.5,10,5,[6,.15,11],3),
 ('choir_reed','Choir Reed','basilica',36,2.05,'signal','skirmish',2.8,9.5,9,5,[7,.15,-4],1),
 ('saltbound_porter','Saltbound Porter','basilica',68,2.8,'rush','flanker',2.1,2.2,8,7,[-11,.15,11],2),
 ('sluice_beadle','Sluice Beadle','basilica',82,3.15,'heavy','shield',1.2,8.0,8,8,[17,.15,9],3),
 ('triage_warden','Triage Warden','lift',88,3.4,'signal','shield',1.5,9.3,8,7,[-3,.15,-2],1),
]
runway={
 'sentry':'08e04dd9-52d1-4846-826b-4219acf44b66',
 'enforcer':'f200e985-8e21-4c84-886c-362d032b1fb1',
 'millwright':'801d69fe-8518-43f3-b8f2-8687412e9040',
 'cantor':'b005c780-2b5c-4fd3-9cde-7c86f60b5922',
 'edda_machine':'cd0635f9-a474-48f0-9e92-4ce44e9894a2',
 'pressure_mite':'b43ef69b-9714-4c20-b569-5ee11e22741b',
 'registry_bailiff':'34c95596-677e-462f-9109-82363eac7f55',
 'vent_whistler':'5f97904a-f8bb-4346-bbe1-5518edf27704',
 'rivet_courier':'e0d3997e-177a-4ef6-8d36-c6a7f2bd12a4',
 'slag_sifter':'cb7335bb-9e1b-4f9a-948b-ebcb6c1fd3b2',
 'chain_hauler':'8410cd9b-222b-4437-b422-26493cca634f',
 'choir_reed':'f0e88654-027d-4c27-b13b-9372e730a01b',
 'saltbound_porter':'3bf61745-2947-4bd1-9847-0d1d369105ed',
 'sluice_beadle':'bc1d1c2a-990e-461e-8475-14deb8357384',
 'triage_warden':'5b8727db-ad85-47c0-b889-4dc0c160588a',
 'bell_wretch':'1857db79-9466-49d9-bf82-860b98f03db8',
 'rootkin':'678186a5-30c4-4085-832f-8a0bc7243201'
}
ents=[]
for id,name,zone,hp,interval,attack,move,speed,reach,wake,damage,pos,rank in ROWS:
 ents.append(dict(id=id,name=name,zone=zone,hp=hp,interval=interval,attack=attack,move=move,speed=speed,reach=reach,wake=wake,damage=damage,pos=pos,rank=rank,runway_task_id=runway[id],sprite_origin='Runway original source turnaround'))
assert len(ents)==15 and len(runway)==17
# Primary data manifest (Godot reads the same JSON, not duplicate hand-maintained tables)
(ROOT/'data').mkdir(exist_ok=True)
(ROOT/'data'/'enemy_roster_068.json').write_text(json.dumps({'build':'06.8','original_combat_types':5,'new_combat_types':10,'combat_enemies':ents,'hearing_only':['bell_wretch','rootkin'],'runway_hearing_tasks':{k:runway[k] for k in ['bell_wretch','rootkin']},'sprite_status':'Render requested via Runway; image outputs are only marked integrated after source PNG export and atlas validation'},indent=2)+'\n')
script='''extends RefCounted
## Build 06.8 enemy catalogue. The JSON file is the canonical authoring source.
## No enemy kill produces farmable XP. Writ holders retain their original keys.
const FILE_PATH = "res://data/enemy_roster_068.json"
static var _entries: Dictionary = {}
static func _init_catalog() -> void:
    if not _entries.is_empty(): return
    var file: FileAccess = FileAccess.open(FILE_PATH, FileAccess.READ)
    if file == null: return
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY: return
    for spec in parsed.get("combat_enemies", []):
        _entries[str(spec.get("id", ""))] = spec
static func spec(id: String) -> Dictionary:
    _init_catalog()
    return _entries.get(id,{})
static func combat_types() -> Array:
    _init_catalog()
    return _entries.keys()
static func optional_types(zone: String) -> Array:
    _init_catalog()
    var matches: Array = []
    for entry in _entries.values():
        if str(entry.get("zone", "")) == zone and int(entry.get("rank",0)) > 0:
            matches.append(str(entry["id"]))
    matches.sort()
    return matches
'''
(ROOT/'scripts'/'enemy_roster_068.gd').write_text(script)
print('wrote enemy roster 15 combat + 2 hearing',ROOT)
