# Level 3: Town Run Collision Fix + Feel Tuning

**Date:** 2026-08-21  
**Branch:** `feature/level3`  
**Status:** Approved design (approach 1 — Level 2-style targeted rect fix, then feel pass)

## Problem

On modern devices, Level 3 (Town Run) ground / chase obstacles no longer collide reliably:

- **Rolling hay** (`haybaleRolling`), **mud / leaf pile** (`leafpile`), and **small hay** (`haybaleSmall`) show green debug boxes well below their sprites (into the corn), so the player’s pink box never overlaps.
- Gameplay consequence: no slow / collide effects when running over these props.
- Same class of issue as Level 2 low pads (sandpit / manure): `GameCollisionRectForObject` builds AABBs from sprite position + legacy `boundingBox` values authored for ~480×320 phone / older layout. Rolling hay is worse because `objects.plist` sets `boundingBox.y` to **130**, which pulls the rect far under a top-anchored sprite.

Crow height / rolling-hay chase timing may also feel off on wide screens; that is secondary to restoring collision.

## Goal

1. Align green boxes with rolling hay, mud (`leafpile`), and small hay sprites so run/jump reliably triggers original effects (slow / collide).
2. **Works on both iPhone and iPad across common screen sizes** — collision and tuned feel must not depend on phone-only hardcodes.
3. Keep the original Level 3 rhythm skeleton, with **perceptible widescreen retunes** where needed (crow appear height/timing, rolling-hay chase speed, jump windows) via light `winWidth/480` (or equivalent) scaling — not a full rebalance.
4. Debug overlays remain the acceptance tool; shipping play does not require overlays on.

## Non-Goals

- Redesigning the Level 3 TMX layout or full obstacle density
- Global rewrite of offset-based collision for every level
- Woo health rules, achievements, or mode-specific redesign in this pass (explicit later enhancements)

## Approach

**Level 2-style targeted fix (chosen):** extend shared collision rects + correct rolling-hay baseline bbox, verify on device overlays, then retune Level 3 feel constants.

Rejected alternatives:

- **Plist-only:** may not fix modern foot height / wide layouts alone; rolling hay’s top anchor + large `y` is awkward to fix by data alone.
- **Global offset-collision rewrite:** high blast radius across levels; out of scope.

## Current Architecture (relevant)

| Piece | Role |
|---|---|
| `GameCollisionRectForObject` | Single AABB builder for gameplay + `GameDebugLayer` green/pink boxes |
| `GameObjectController` + `objects.plist` | Loads offsets, anchors, `boundingBox` (phone `MULTIPLIER*=1`, iPad uses pad multipliers) |
| `GameObject` `COLLISION_BEHAVIOR_ROLLING_HAYBALE` / `FLYER` | Chase AI + sounds for rolling hay / crow |
| `leafpile` | Slow pad (`playerEffect` = slow); blank sprite + `townLeafpileAnim` — **cannot** match by `Track_Sandpit_1.png` frame name |
| `DEBUG_DRAW_BOUNDING_BOXES` | Auto-on in Xcode Debug builds (`GameConfig.h`) |

## Design Details

### Phase A — Short diagnosis

- Play Level 3 on **iPhone and iPad** with debug boxes on.
- Confirm the three props still sit low; note crow / tall haybale / hurdles only if clearly broken (same root cause → may fold into Phase B; otherwise backlog).

**Exit:** Written note of which props fail on which device class.

### Phase B — Collision fix (both platforms)

1. **`objects.plist` `haybaleRolling`:** reduce `boundingBox.y` from the 130-scale sink so the baseline rect is near the visual foot of the rolling bale (retune with overlay; do not leave a phone-only value).
2. **`GameCollisionRect.m`:** raise / modestly enlarge rects for Level 3 targets, matched by **stable identity** (prefer collide behavior and/or object name / effect — not fragile animation frame names). Apply on **iPhone and iPad** using `MULTIPLIERX/Y` or size relative to legacy 480×320 — **do not** gate these Level 3 fixes behind `!IS_IPAD`.
3. Overlay acceptance: green box on sprite foot band; pink box overlaps while running; mud slows, hay collides as before.

### Phase C — Feel tuning (skeleton preserved)

After collision is correct on both device classes:

- Crow (`FLYER` / chase distance / height-related placement)
- Rolling hay `ChaseSpeed` / on-screen trigger distance
- Jump windows only if collision fix alone leaves unfair hits

Scale lightly with screen width where timing depends on how long props stay on-screen. Avoid rewriting whole-level pacing.

### Phase D — Wrap-up

- Keep debug-draw policy consistent with the rest of the project.
- Record short findings under `docs/superpowers/specs/` (companion to this design).
- Run the dual-device checklist below.

## Risks

| Risk | Mitigation |
|---|---|
| Special-cases miss iPad | No `!IS_IPAD` for these Level 3 rects; verify iPad overlay |
| Matching by sprite frame name fails for `blank.png` anims | Match behavior / object identity |
| Rolling-hay bbox change too aggressive | Iterate with overlay; prefer shared helper math over huge magic numbers |
| Feel tweaks change other levels sharing `FLYER` / rolling behavior | Prefer Level 3–local gates or confirm shared behavior is safe |
| Phone fix regresses iPad (or reverse) | Explicit dual-device checklist before calling done |

## Success Criteria

- On a modern **iPhone** and a modern **iPad**, the three props collide when the player runs through their visuals; debug boxes agree with gameplay.
- Crow / rolling-hay timing feels acceptable on wide screens without abandoning original rhythm.
- No intentional changes to woo / achievements; no obvious new regressions on hurdles / tall haybale.

## Verification Checklist

- [ ] iPhone: rolling hay, mud, small hay collide; green boxes aligned
- [ ] iPad: same
- [ ] Crow dodge / hit feel acceptable; appear timing OK on both
- [ ] Rolling-hay chase speed / appear not extreme on either
- [ ] Hurdles / tall haybale: no new obvious miss or unfair hit
- [ ] Woo / achievements untouched

## Implementation Follow-up

After this spec is accepted on disk, write an implementation plan under `docs/superpowers/plans/` (overlay + dual-device repro as primary verification; extract pure math helpers only if useful for tests).
