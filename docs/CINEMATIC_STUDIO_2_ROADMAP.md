# DripVision Cinematic Studio 2.0 — Implementation Map

## Stage 1 (landed in this pass)
- Edit Bay models, notifier, persistence path
- Full-screen Edit Bay (preview, transport, multi-track timeline, tools)
- Real state ops: select, move, split, delete, trim fields, color, filters, transitions, volume, memory panel
- Preview color matrix + vignette/letterbox from adjustments
- Seed timeline from sceneListProvider
- Save to `users/{uid}/editProjects/{id}`
- God Mode screen + claim/role gate
- firestore.rules template for admin + edit projects
- Entry points: Studio, Timeline, Create

## Stage 2 (next)
- FFmpeg export applying ClipAdjustments + transitions
- Audio waveform / multi-clip audio ducking
- Pinch-zoom timeline, magnetic snap
- Cloud Function: set custom claims `admin: true`
- Token unlimited via claims (not only Firestore role)
- RevenueCat webhook → revenue aggregates for God Mode
- AI usage writes from server on each generation

## Stage 3
- Remote feature flags consumed app-wide
- Explore CMS from God Mode
- Character DNA inspector deep-link from clip
- Desktop-class gesture polish

## Unique vs CapCut
1. Universe memory on every clip (character, location, style)
2. Story → scenes → Edit Bay continuous pipeline
3. Server God Mode for operator economics
4. Continuity-aware regenerate from clip metadata
