#!/usr/bin/env python3
"""Convert exported original Runway music into Godot's embedded adaptive loops.

Export MP3s from connected Runway and name as in art/RUNWAY_072_MUSIC_TASKS.json.
  python3 art/tools/import_runway_music_072.py --source ~/Downloads/ninth_music

The Godot project already includes fallback loops at the same paths. This
command replaces only the tracks you supply and preserves your original MP3s.
"""
from __future__ import annotations
import argparse,json,shutil,subprocess,hashlib
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
FILES=('hearth_night_intake','sootworks_service_debt','basilica_submerged_choir','pressure_breach_combat')
RATES={'hearth_night_intake':90,'sootworks_service_debt':102,'basilica_submerged_choir':78,'pressure_breach_combat':132}
OUT=ROOT/'assets/music'
SOURCES=ROOT/'art/production_sources/runway_music_072'

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--source',required=True,type=Path)
    ap.add_argument('--dry-run',action='store_true')
    ap.add_argument('--full-track',action='store_true',help='Keep the entire exported composition instead of an 8-bar rhythmic loop')
    args=ap.parse_args()
    if not args.source.is_dir():ap.error('Music exports directory does not exist')
    wanted={}
    for name in FILES:
        for ext in ('.mp3','.m4a','.wav','.ogg'):
            candidate=args.source/(name+ext)
            if candidate.is_file():wanted[name]=candidate;break
    print('Exports found:',len(wanted),'of',len(FILES))
    print('Missing:',', '.join(sorted(set(FILES)-set(wanted))) or '(none)')
    if args.dry_run:return
    SOURCES.mkdir(parents=True,exist_ok=True);OUT.mkdir(exist_ok=True,parents=True)
    results={}
    for name,source in wanted.items():
        saved=SOURCES/source.name
        shutil.copy2(source,saved)
        dest=OUT/(name+'.ogg')
        cmd=['ffmpeg','-y','-hide_banner','-loglevel','error','-i',str(source)]
        if not args.full_track:
            # 8 bars at this track's prompt tempo. Runway may vary tempo;
            # visually check musical loop point, then opt for --full-track.
            seconds=32*60.0/RATES[name]
            cmd+=['-t',f'{seconds:.4f}','-af',f'afade=t=out:st={max(0.0,seconds-.09):.4f}:d=0.09']
        cmd+=['-c:a','libvorbis','-qscale:a','5','-ac','2',str(dest)]
        subprocess.run(cmd,check=True)
        results[name]={'source':str(saved.relative_to(ROOT)), 'embedded':str(dest.relative_to(ROOT)), 'sha256':hashlib.sha256(dest.read_bytes()).hexdigest()}
        print('Imported original Runway music:',name, round(dest.stat().st_size/1024), 'KiB')
    (ROOT/'art/RUNWAY_072_IMPORTED_MUSIC.json').write_text(json.dumps(results,indent=2)+'\n')

if __name__=='__main__':main()
