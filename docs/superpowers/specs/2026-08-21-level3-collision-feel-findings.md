# Level 3 Collision / Feel — Findings

**Date:** 2026-08-21  
**Branch:** `feature/level3`

## Phase A (pre-fix)

- Devices: modern iPhone (screenshots) + pending iPad confirm
- Rolling hay, mud (`leafpile`), small hay: green boxes deep in corn; player pink box on path → no overlap / no collision
- `haybaleRolling` plist `boundingBox.y == 130` is a primary sink; leafpile/small hay share `offsety == -45` low-pad pattern with Level 2 sandpit/manure
- Crow / tall hay / hurdles: not confirmed broken yet (check during Task 4–5)

## Phase B values

**2026-08-21 device feedback:** first rect pass (`origin.y += 36–40*MY` on top of rolling plist `y` 130→40) floated green boxes **above** the path / hay visuals. Root cause: double lift.

**Retune (current):** keep plist rolling `boundingBox.y = 40`; drop large `origin.y` raises; use sandpit-style modest pad (both platforms, no `!IS_IPAD`):

| Prop | objectType | Final bbox / rect notes |
|---|---|---|
| rolling hay | haybaleRolling | plist `y=40`; phone: `x-=8`, `w+=16`, `y-=6`, `h+=14`. **iPad:** `y-=64`, `h+=14` (no MY on pad) |
| mud | leafpile | `x-=12*MX`, `w+=24*MX`, `y-=8*MY`, `h+=22*MY` |
| small hay | haybaleSmall | `x-=6*MX`, `w+=12*MX`, `y-=8*MY`, `h+=18*MY` |

`MX` = `MULTIPLIERX` (1.0 phone / 2.133 pad), `MY` = `MULTIPLIERY` (1.0 phone / 2.4 pad). Re-check overlay after rebuild.

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
| crow `offsety` / bbox | 140 / 55×35 | **restored** — original design: single jump clears under; double-jump hits (hint) |

Spot-check: hurdles / tall haybale still unverified on device. Crow height/chase weaken reverted after confirming original hint intent.

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
- GameCollisionRect dual-platform pads (retuned after overshoot — no large y lifts)
- FLYER / ROLLING_HAYBALE chase scaled by max(1, winWidth/480)

Rebuild and re-check green boxes vs path; further nudge only if still high/low.
