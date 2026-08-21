# Level 2: Kicked Chicken → Cow Chain Hit Detection

**Date:** 2026-08-20  
**Branch:** `feature/chicken`  
**Status:** Approved approach (diagnose, then targeted fix)

## Problem

On modern iPhones (reproduced on iPhone 17), Level 2 barn gameplay no longer chains kicked chickens through a row of cows.

- **Works:** Kicking a chicken (player foot / frame-based kick) feels mostly correct.
- **Broken:** After the chicken is airborne, only the **first** cow in a row falls. Originally, correct timing let one kicked chicken hit **multiple** cows in sequence.
- **Context:** The game was authored for two layouts — ~3.5″ iPhone and ~9.7″ iPad. Collision for aggressive objects (kicked hens) is frame-based and intentionally hits **at most one** non-aggressive target per frame; multi-cow chains rely on the hen’s flight path overlapping successive cows across frames.

Visual diagnosis on device is ambiguous: the hen may miss later cows because of **trajectory**, **hitboxes**, or both.

## Goal

Restore original Level 2 feel: a well-timed kicked chicken can knock down multiple cows in a row on modern iPhone aspect ratios / point sizes, without changing kick-chicken feel, stone-chicken rules, or other levels’ collision behavior.

## Non-Goals

- Reworking global collision to multi-hit within a single frame
- Redesigning Level 2 layout or cow placement
- Changing stone chicken / kick-for-health balance unless required by the same root cause
- Full return of all gameplay to a letterboxed 480×320 design space (rejected as primary approach due to blast radius)

## Approach

**Diagnose with overlays, then apply a minimal targeted fix.**

1. Instrument Level 2 so hen (kicked / aggressive) and cow collision rects are visible (extend existing `GameDebugLayer` or equivalent).
2. On iPhone 17 (and ideally one legacy-sized simulator), kick into a cow row and observe whether the flying hen’s box stops overlapping later cows (trajectory / layout) or overlaps without registering (hit test / flags).
3. Fix only the failing layer:
   - **Hitbox / rect:** `CollisionRectForObject` and/or hen-kicked / cow bounding boxes used in `testCollisionsForAggressive`.
   - **Trajectory:** `special_kickHen` initial velocity / angle / gravity (`COLLISION_BEHAVIOR_HEN_KICKED` update) so the arc again sweeps the cow row in legacy-equivalent world space.
4. Remove or gate debug drawing so it is not on in shipping builds by default.

## Current Architecture (relevant)

| Piece | Role |
|---|---|
| `PlayerActionKick` | Frame-based foot projectile; calls `special_kickHen` on `COLLISION_BEHAVIOR_HEN_STATIC` |
| `GameObject special_kickHen` | Sets aggressive flight: magnitude ~880, angle -20°, gravity on, behavior `HEN_KICKED` |
| `Level testCollisionsForAggressive` | Each frame: one hen vs eligible cows; `break` after first hit (by design) |
| `CollisionRectForObject` | Builds AABB from sprite position + object bounding box (modernization helper) |
| Cow `startCollision:` | Marks cow hit; hen stays aggressive for later frames |

Chaining therefore depends on **multi-frame** overlap while the hen stays aggressive and airborne.

## Design Details

### Phase A — Diagnosis

- `GameDebugLayer` already draws player, kick projectiles, and non-`collided` obstacles using the same sprite + bounding-box math as gameplay collision. First step: enable it on device and reproduce the cow row.
- Gaps to close only if the existing overlay is insufficient:
  - Ensure kicked hens stay drawable while airborne (`special_kickHen` already keeps `_collided = false`).
  - Prefer drawing via `CollisionRectForObject` so overlay matches `testCollisionsForAggressive` exactly (today `drawBoxForCollidable` duplicates that math; keep them in sync if either changes).
  - Optional DEBUG log: hen `(x,y,vx,vy)` and aggressive hit/miss per frame during a cow-row attempt.
- Debug drawing must remain off by default for normal play.

**Exit criteria for Phase A:** Written conclusion: primarily trajectory, primarily rects, or both (with evidence from overlay / logs).

### Phase B — Targeted fix

Apply the smallest change set that restores multi-cow hits on modern iPhone:

1. Prefer fixing **shared coordinate / rect construction** if hen and cow disagree systematically on modern `winSize` / HD paths.
2. Prefer **hen-kicked-only** physics or bbox tweaks if only the airborne hen diverges (keep static hen / player kick unchanged).
3. Do **not** remove the per-frame single-target `break` unless diagnosis proves the hen overlaps multiple cows in one frame and still only counts one (unlikely given current symptoms).

### Phase C — Verification

Manual checklist (device preferred):

- [ ] Kick chicken: still lands reliably; health restore still works
- [ ] Single cow: still falls when hit by kicked hen
- [ ] Cow **row**: one kicked hen can fell multiple cows with correct timing
- [ ] Stone chicken: still should not be kicked for benefit / still behaves as obstacle
- [ ] No obvious regression to player–cow collision
- [ ] Debug overlays off for normal play

## Risks

| Risk | Mitigation |
|---|---|
| Tuning hen velocity “feels” different on kick | Keep player→hen path untouched; only adjust post-kick flight if needed |
| Overlay noise / shipping leak | DEBUG / explicit flag; default off |
| Fixing only iPhone 17 breaks iPad | Compare iPhone + iPad after change; avoid iPhone-only magic numbers unless gated |

## Success Criteria

On a modern iPhone (e.g. iPhone 17), Level 2 cow rows behave like the original: timing a kick so the hen flies through the line knocks down **more than the first cow**. Kick-chicken feel remains acceptable. Scope stays limited to hen→cow chain diagnosis and fix.

## Implementation Follow-up

After this spec is accepted, write an implementation plan under `docs/superpowers/plans/` (TDD where practical; for this legacy ObjC gameplay path, prefer overlay + device repro as the primary verification loop, with any pure math helpers tested if extracted).
