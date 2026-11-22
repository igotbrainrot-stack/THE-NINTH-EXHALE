# Build 09.2 — Weapon art research and design translation

## Scope and provenance

The four weapon masters and action sheets in this build were generated for THE NINTH EXHALE with Runway GPT Image 2.6 Sunburst. Four Tripo H3.1 source models were also generated (approximately 1.4M triangles each, materials present). Those models are retained as source references only; they are not runtime assets and need retopology/LOD before any real-time use.

3D-Shep-Bot searches were used to look for matching industrial/mechanical reference assets. No third-party model was close enough to the game's specific weapon silhouettes and art direction to justify importing it. No 3D-Shep-Bot geometry or textures are included in the game. All third-party licensing review remains pending.

## Mechanical research translated into the designs

### Covenant Pistol — compact civic service sidearm

- Keep a compact, flat-sided service-pistol silhouette, with machined slide, exposed ejection/inspection opening, restrained brass fittings and worn grip.
- The game viewmodel remains a single RGBA sprite. Recoil and casing effects are aligned by manifest anchors; the current muzzle and shell-port coordinates are provisional until the Godot capture is checked.
- The first action strip has four source poses. The game still uses procedural fallback for draw, reload, dry-fire and intervention.

### Coil Shotgun — electrical discharge assembly

- The design uses copper conductors only where they read as current-carrying rails/busbars, with ceramic/laminated insulation at supports and a mechanically credible cooling/ventilation path.
- Mersen's busbar design guide notes conductor material and mechanical rigidity as design constraints, thermal ventilation for removing excess heat, and laminated insulation as a practical barrier between conductor layers:
  https://us.mersen.com/en/resources/bus-bars-expert-corner/design-guide-bus-bars
- Translation into the art: paired conductor bars, ceramic spacers, insulated terminals, visible heat path and a two-stage firing recoil rather than a generic glowing sci-fi tube.
- The current 6-frame fire strip is built from four Runway source poses with two deliberate holds; more distinct poses are still needed for final sign-off.

### Nail Storm — pneumatic riveter / mandrel driver

- The silhouette is an industrial riveter, not a rotary minigun. Its readable mechanisms are the nose assembly, feed/jaw housing, piston/cylinder, return spring, exhaust and spent mandrel collector.
- Tameson's pneumatic rivet-gun guide describes the jaws pulling a mandrel, a spring-returned piston, a nose piece, nail ejector and capture cup:
  https://tameson.co.uk/pages/pneumatic-rivet-gun
- The Huck 2024-series pneudraulic tool manual illustrates distinct pull and return strokes: the pull piston travels rearward, then returns forward; the air piston reverses and exhaust is routed through the tool:
  https://bylerrivet.com/wp-content/uploads/2020/03/huck-2024-rivet-gun-manual-hk1077.pdf
- Translation into the art: a two-pose piston stroke, a hinged recoil cage, square service apertures and a visible spent-fastener collection pan. The current fire strip is only two frames; the full vent/reload art is still outstanding.

### Choirbreaker — acoustic cancellation / waveguide device

- Treat it as an industrial acoustic instrument, not a conventional gun: a membrane, perforated blind, sliding shutter plate and multiple shaped waveguide paths.
- US20150055811A1 describes a membrane and a nearby shutter moving on an orthogonal path; aligned and offset openings modulate the acoustic output, with spring return and comb-drive examples:
  https://patents.google.com/patent/US20150055811A1/en
- US9571923B2 describes multiple smooth, continuous acoustic paths inside a waveguide:
  https://patents.google.com/patent/US9571923B2/en
- Translation into the art: layered rectangular channels, sliding shutter apertures, mechanical guides and a visible membrane housing. The current fire sheet has four distinct source poses plus a held pose; the idle shutter ripple remains missing.

## Current coverage and limits

- Generated and integrated: 4-frame idle strips and fire/action strips for all four weapons.
- Idle loops are derived from one master pose with small (<=2 px) breathing offsets; they are not four independently generated poses.
- Fire/action frame counts: Covenant 4, Coil 6, Nail 2, Choir 5. Coil and Choir include duplicated holds as recorded in the manifest.
- Not yet authored as image strips: reload, dry, draw and intervene for all weapons; Nail Storm vent; Choir idle shutter ripple.
- The license_review field remains pending for every generated element.
- No gameplay code or legacy assets/weapons/*_idle.png files were changed by the art importer.
