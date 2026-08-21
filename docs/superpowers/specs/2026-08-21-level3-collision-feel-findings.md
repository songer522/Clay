# Level 3 Collision / Feel — Findings

**Date:** 2026-08-21  
**Branch:** `feature/level3`

## Phase A (pre-fix)

- Devices: modern iPhone (screenshots) + pending iPad confirm
- Rolling hay, mud (`leafpile`), small hay: green boxes deep in corn; player pink box on path → no overlap / no collision
- `haybaleRolling` plist `boundingBox.y == 130` is a primary sink; leafpile/small hay share `offsety == -45` low-pad pattern with Level 2 sandpit/manure
- Crow / tall hay / hurdles: not confirmed broken yet (check during Task 4–5)

## Phase B values (fill during implementation)

**Provisional (overlay not run in agent env — confirm on device)**

Starting plan numbers applied in `GameCollisionRect` (both iPhone and iPad via `MULTIPLIERX`/`MULTIPLIERY`; not gated behind `!IS_IPAD`). Steps 2–4 (iPhone/iPad overlay + functional playtest) deferred to human / Task 6.

| Prop | objectType | Final bbox / rect notes |
|---|---|---|
| rolling hay | haybaleRolling | **Provisional:** `y += 36*MY`, `h += 20*MY`, `x -= 8*MX`, `w += 16*MX` (also when `COLLISION_BEHAVIOR_ROLLING_HAYBALE`); plist bbox y already 40 (Task 3) |
| mud | leafpile | **Provisional:** `x -= 12*MX`, `w += 24*MX`, `y += 40*MY`, `h += 22*MY` |
| small hay | haybaleSmall | **Provisional:** `y += 40*MY`, `h += 18*MY`, `x -= 6*MX`, `w += 12*MX` |

`MX` = `MULTIPLIERX` (1.0 phone / 2.133 pad), `MY` = `MULTIPLIERY` (1.0 phone / 2.4 pad).

## Phase C feel (fill during implementation)

**Provisional (device feel check deferred to Task 6 / human)**

Final formulas (Task 5):
- `widthScale = max(1, winWidth / 480)`
- ChaseSpeed = legacy × widthScale
- chase distance = `GAME_OBJECT_DISTANCE_ONSCREEN` (1000) × widthScale

| Knob | Legacy | Final |
|---|---|---|
| rolling ChaseSpeed | -150 | `-150 * max(1, winWidth/480)` |
| crow ChaseSpeed | -250 | `-250 * max(1, winWidth/480)` |
| chase distance scale | 1000 | `1000 * max(1, winWidth/480)` |

Spot-check: hurdles / tall haybale still unverified on device; backlog if needed. Crow `offsety` left unchanged (defer to human Task 6).

## Verification checklist

- [ ] iPhone: rolling hay, mud, small hay collide; green boxes aligned — **PENDING human device**
- [ ] iPad: same — **PENDING human device**
- [ ] Crow dodge/hit timing acceptable on both — **PENDING human device**
- [ ] Rolling-hay chase not extreme on either — **PENDING human device**
- [ ] Hurdles / tall haybale: no new obvious miss or unfair hit — **PENDING human device**
- [x] Woo / achievements untouched (no intentional edits) — verified by git diff scope (Tasks 2–5)

## Implementation status (agent)

Code changes complete on `feature/level3`:
- objectType tagging
- haybaleRolling bbox y 130→40
- GameCollisionRect dual-platform lifts (provisional constants)
- FLYER / ROLLING_HAYBALE chase scaled by max(1, winWidth/480)

Device overlay tuning may still adjust Phase B constants after human playtest.
