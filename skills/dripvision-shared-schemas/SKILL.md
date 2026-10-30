---
name: dripvision-shared-schemas
description: "Shared JSON schemas and data structures for DripVision cinematic production. Use when defining Character DNA, Continuity Bible entries, Shot Plans, Creative Preferences, or video generation metadata."
type: knowledge
lifecycle: active
---

# DripVision Shared Schemas

Canonical data structures used across Character DNA, Continuity Detective, Shot Planner, Eternal Universe Manager, and Swarm Conductor skills. Load the relevant reference file only when you need the full schema.

## Available Schemas

| Schema | File | Primary Use |
|--------|------|-------------|
| Character DNA | `references/character-dna.md` | Identity, appearance, wardrobe, voice |
| Continuity Bible | `references/continuity-bible.md` | Scene rules, timeline, props, lighting |
| Shot Plan | `references/shot-plan.md` | Cinematography sequences |
| Creative Preferences | `references/creative-preferences.md` | Permanent / project / temporary style |
| Video Generation Metadata | `references/video-metadata.md` | API results, costs, seeds, scores |

Always version Character DNA changes. Never overwrite historical values. Store a `dna_hash` on every scene that uses a character so continuity checks can detect drift.
