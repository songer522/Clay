# Level 2 Chicken→Cow Chain — Diagnosis Findings

**Date:** 2026-08-20  
**Branch:** `feature/chicken`  
**Device:** Modern iPhone (user repro; overlay enabled)

## Primary cause (updated)

**`rects` (AABB mismatch), with trajectory as a contributing factor**

Initial overlay read suggested trajectory. After flight retune, user reported the hen **looks** like it hits the second cow, but only the first cow is detected. That points to the kicked hen’s legacy **15×15** collision box not covering the visual sprite, so gameplay AABB misses while sprites appear to overlap.

## Evidence

1. First cow falls; later cows in the row do not.
2. After iPhone flight retune (940 / -14° / gravity 380), visual contact with later cows still fails to register.
3. Idle hen kick feel was already OK — only airborne hen→cow chaining fails.

## Fix path

- **Task 4B (done):** flatter/faster iPhone kick arc (kept).
- **Task 4A (in progress):** enlarge AABB only while `COLLISION_BEHAVIOR_HEN_KICKED`; explicitly set `_collided` on cow collapse so the aggressive loop can advance to the next cow.
- Keep per-frame single-cow `break` (original design).
