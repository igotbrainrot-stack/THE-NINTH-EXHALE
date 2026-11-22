# Build 09.2 — Weapon Art Import QA

Runway masters and action sheets; per-frame AI foreground segmentation; RGB-independent alpha normalization; solid-silhouette crop; no chromakey.

| Weapon | Idle | Fire/action | Idle opaque | Fire opaque | Unique fire poses | Missing states |
|---|---:|---:|---:|---:|---:|---|
| covenant | 4 | 4 | 9.3% | 7.2% | 4 | reload, dry, draw, intervene |

**covenant frame map:** {'source_indices': [0, 1, 2, 3], 'unique_source_poses': 4, 'duplicated_holds': []}; idle is a four-frame micro-breath loop derived from the master pose.
| coil | 4 | 6 | 18.4% | 12.5% | 4 | reload, dry, draw, intervene |

**coil frame map:** {'source_indices': [0, 1, 1, 2, 2, 3], 'unique_source_poses': 4, 'duplicated_holds': [1, 2]}; idle is a four-frame micro-breath loop derived from the master pose.
| nail | 4 | 2 | 10.4% | 9.3% | 2 | reload, dry, draw, intervene; vent |

**nail frame map:** {'source_indices': [2, 3], 'unique_source_poses': 2, 'duplicated_holds': []}; idle is a four-frame micro-breath loop derived from the master pose.
| choir | 4 | 5 | 11.8% | 10.9% | 4 | reload, dry, draw, intervene |

**choir frame map:** {'source_indices': [0, 1, 2, 2, 3], 'unique_source_poses': 4, 'duplicated_holds': [2]}; idle is a four-frame micro-breath loop derived from the master pose.

## Coverage and quality gates

Alpha is normalized independently of RGB; dark steel and black details are never chromakeyed. Solid cropping uses the alpha core (>128) with 8px padding to remove low-alpha halos and restore viewmodel scale.
Coil and Choir use duplicated holds in the first pass; see frame maps. They need more distinct source poses before final animation sign-off.
Choir idle resonator ripple is outstanding. Reload, dry, draw and intervene remain procedural; Nail Storm vent remains procedural.
Tripo source models are ~1.4M triangles each and remain source-only pending retopology/LOD.
Muzzle anchors are provisional; confirm against the Godot in-game captures. Original Runway sheets and AI-segmented alpha sheets are retained.
