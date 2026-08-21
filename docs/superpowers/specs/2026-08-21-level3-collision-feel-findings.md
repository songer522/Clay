# Level 3 Collision / Feel — Findings

**Date:** 2026-08-21  
**Branch:** `feature/level3`

## Phase A (pre-fix)

- Devices: modern iPhone (screenshots) + pending iPad confirm
- Rolling hay, mud (`leafpile`), small hay: green boxes deep in corn; player pink box on path → no overlap / no collision
- `haybaleRolling` plist `boundingBox.y == 130` is a primary sink; leafpile/small hay share `offsety == -45` low-pad pattern with Level 2 sandpit/manure
- Crow / tall hay / hurdles: not confirmed broken yet (check during Task 4–5)

## Phase B values (fill during implementation)

| Prop | objectType | Final bbox / rect notes |
|---|---|---|
| rolling hay | haybaleRolling | |
| mud | leafpile | |
| small hay | haybaleSmall | |

## Phase C feel (fill during implementation)

| Knob | Legacy | Final |
|---|---|---|
| rolling ChaseSpeed | -150 | |
| crow ChaseSpeed | -250 | |
| chase distance scale | 1000 | |
