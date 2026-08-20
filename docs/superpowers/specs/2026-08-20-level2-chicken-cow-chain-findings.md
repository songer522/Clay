# Level 2 Chicken→Cow Chain — Diagnosis Findings

**Date:** 2026-08-20  
**Branch:** `feature/chicken`  
**Device:** Modern iPhone (user repro; overlay enabled)

## Primary cause (updated again)

**Aggressive-test gate bug in `Level testCollisions:`**

```objc
if (!collision && obstacle.isAggressive)
```

While the player AABB still overlaps the kicked hen (very common right after kick, worse after enlarging the hen box), `collision` is true for that frame, so **hen→cow tests are skipped**. First cow can still fall (player body contact and/or a brief window when AABBs separate). Later cows only see the hen visually; aggressive detection never runs in time.

Contributing factors (addressed, not sufficient alone):
- Tiny legacy kicked-hen AABB vs visual sprite
- Flight arc on modern layouts

## Fix

1. Always run aggressive tests when `obstacle.isAggressive` (remove `!collision` gate).
2. Widen player↔hen proximity window for those tests (`900` → `2500`).
3. Keep prior kicked-hen AABB expand + iPhone flight retune.
