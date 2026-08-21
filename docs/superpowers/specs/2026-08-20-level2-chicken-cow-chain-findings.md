# Level 2 Chicken→Cow Chain — Diagnosis Findings

**Date:** 2026-08-20 (updated 2026-08-21)  
**Branch:** `feature/chicken`  
**Device:** Modern iPhone (wider than legacy 480pt)

## Root causes

### 1. Aggressive-test gate (fixed)
`if (!collision && obstacle.isAggressive)` skipped hen→cow tests while the player still overlapped the hen.

### 2. Camera visual cull used legacy 480-wide math (fixed)
`CAMERA_OFFSCREEN_PADDING_RIGHT` was hardcoded `780` (≈480+300). On wider phones the hen was culled/frozen around screen-x≈780 while still on-screen — looks like a mid-right fade, and physics stops before later cows.

### 3. Kick trajectory — flat cruise (accepted)
Legacy parabolic arc (`880/-20/g=500`) was authored for ~480pt width and drops out of the cow band on modern screens.
**Decision:** keep **flat cruise** as the intended kick feel — kicked hens lock altitude (`vy=0`, no gravity), `vx` scales with `winWidth/480`, and only fall+fade past the live right edge. Feels distinct and chains cow rows reliably.
Also: kicked-hen visibility uses sprite screen-x (not world cull), plus world-space hen→cow fallback band.

### 4. Supporting fixes already in tree
- Shared `GameCollisionRectForObject` for debug + gameplay
- Expanded kicked-hen AABB
- Explicit `_collided` on cow collapse
- Aggressive distance window `2500`
- Multi-cow hits allowed in one aggressive pass (`continue` instead of `break`)
- `DEBUG_DRAW_BOUNDING_BOXES` auto-on for Xcode Debug builds (`GameConfig.h`)

## Verification checklist

- [x] Connected kick knocks down **all** cows in a typical row
- [x] Kicked hen flies **flat** (accepted trajectory)
- [x] Kicked hen disappears **past** the right edge, not mid-screen
- [ ] Kick→hen feel still OK in full-level play
- [ ] Misses are rare (kick miss), not “first cow only”
