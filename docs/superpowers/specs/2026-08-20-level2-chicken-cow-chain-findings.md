# Level 2 Chicken→Cow Chain — Diagnosis Findings

**Date:** 2026-08-20 (updated 2026-08-21)  
**Branch:** `feature/chicken`  
**Device:** Modern iPhone (wider than legacy 480pt)

## Root causes

### 1. Aggressive-test gate (fixed)
`if (!collision && obstacle.isAggressive)` skipped hen→cow tests while the player still overlapped the hen.

### 2. Camera visual cull used legacy 480-wide math (fixed)
`CAMERA_OFFSCREEN_PADDING_RIGHT` was hardcoded `780` (≈480+300). On wider phones the hen was culled/frozen around screen-x≈780 while still on-screen — looks like a mid-right fade, and physics stops before later cows.

### 3. Trajectory on modern layouts (retuned again)
iPhone kick: magnitude `1100`, angle `-8°`, gravity `320` (iPad keeps legacy `880/-20/500`). Aim: connected kicks sweep a full cow row like the 3.5″ original.

### 4. Supporting fixes already in tree
- Shared `GameCollisionRectForObject` for debug + gameplay
- Expanded kicked-hen AABB
- Explicit `_collided` on cow collapse
- Aggressive distance window `2500`
- Multi-cow hits allowed in one aggressive pass (`continue` instead of `break`)

## Verification checklist

- [ ] Connected kick knocks down **all** cows in a typical row
- [ ] Misses are rare (kick miss), not “first cow only”
- [ ] Kicked hen disappears **past** the right edge, not mid-screen
- [ ] Kick→hen feel still OK
