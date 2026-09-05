# Levels 9–11: Widescreen Collision, Ambient Effects, and Final-Boss Modernization

**Date:** 2026-09-05
**Branch:** `feature/level91011`
**Status:** Implemented; builds clean, feel pass still open

## Problem

Levels 1–4 and then 5–8 have each been through a widescreen modernization pass. Levels
9–11 — Stormy Run, Aquarium Run, Final Run — had not, and they are the first levels to
exercise several code paths the earlier work never touched:

- **An ambient effects layer.** Level 9's rain and lightning (`RainyLevelEffects`,
  `Raindrop`, `Lightning`) plus the wind triggers. Nothing comparable exists in 1–8.
- **Underwater player physics.** Level 10 sets `isNewUnderwaterPhysics`, which gives the
  player a second floor definition (`22*MULTIPLIERY`) alongside the normal
  `64*MULTIPLIERY`.
- **The final boss.** Level 11's `BossFinal` train, its bomb/grape/door projectiles, and
  the `PassengerCar`. The 5–8 design listed these files as an explicit non-goal.
- **New third actions:** `woo` (L9), `spin` (L10), `slowtime` (L11).

## Corrections to the project's own description

- **`BossFinalJim` is unreachable in every shipped map.** The README says
  `BossFinal`/`BossFinalJim` belong to level 11. That is true of `BossFinal`, but no
  level 11 map variant contains the `finalBossSpawn` tile that would fire
  `TRIGGER_BOSS_FINALJIM_SPAWN`, so the shadow-Tim chase never spawns. See the findings.
- **The level 11 boss is the train, not the shadow.** `GameLayer._boss` on level 11 is
  the `BossFinal` instance created by the `finalJimBoss` map object
  (`Level.m:677-679`), so every `TRIGGER_FINAL_BOSS_*` routes to the train.

## Findings

Full detail, including the offline map audit, is in
`2026-09-05-levels91011-widescreen-findings.md`. In summary:

### P0 — Level 11 boss entrance used the wrong device constant

`BossFinal.m FINAL_BOSS_MOVE_TO_BOMBING` gave the iPad `TRAIN_OFFSCREEN_LEFT` (−600, the
phone value) and the phone `TRAIN_OFFSCREEN_LEFT_IPAD` (−900). The branches were swapped;
`FINAL_BOSS_MOVE_TO_LEFT` twenty lines below pairs them correctly and is the reference.

### P0 — Level 9's rain and lightning were positioned with device-blind constants

Both `Raindrop` and `Lightning` carried unresolved `//IPAD FIX:` comments, an
unconditional literal `2.4` (`MULTIPLIERY` applied on every device), and a spawn span
authored for one screen size only — the raindrops' for a 1024-wide iPad, the lightning's
for a 480-wide phone.

### P0 — Level 10's `spin` floor test did not scale

`SPIN_PLAYER_GROUND_Y` was a bare `64`, matching neither of the two real floors on iPad.

### P1 — No level 9–11 chase or trigger used the `widthScale` idiom

`closeToPlayer:` is a world-space X test and the player is pinned at screen x 75, so all
extra modern width is distance an obstacle must cross before it reacts. Levels 3–8 route
these through `GameObjectWidthScale()`. Levels 9–11 used none of it; the level 9 cases
used `MULTIPLIERX`, which scales for iPad only and never for a wide phone.

### P1 — Boss stage positions anchored to a 480-wide screen

`TRAIN_BOMB_POSITION` (230, the centre of a 480 screen) and `TRAIN_DOOR_POSITION` (310)
are screen-space x values, so the train parked on top of the left-pinned player rather
than across from him — the same defect the 5–8 pass fixed in `BossJimShip`.

### P2 — Half-scaled hitboxes

Several boxes are set in code, bypassing the `MULTIPLIERX/Y` scaling the plist path
applies at load: the squirrel nut, the squid ink projectile, the gargoyle's open-wings
box, the dark bomb, the grapes, and the train door.

## Approach

Same as the 5–8 pass: derive from live `winSize` rather than literals.
`GameCollisionRectForObject` stays the single AABB source; nothing in this pass needed a
new pad there.

**Scope of the "no-op at the authored size" claim.** This holds for the pure widescreen
work — `FinalBossStageX` (`extraWidth` is 0 at both 480 and 1024) and the
`MULTIPLIERX`→`GameObjectWidthScale()` swaps (the two are equal at 1024). It does **not**
hold blanket-wide, and three groups of change deliberately alter one reference device:

- **The two Level 9 effect clips pick different references.** The lightning span was
  authored at 480, so it is a no-op on phone and changes iPad (50–380 → ~107–811). The
  raindrop span was authored at 1024, so it is a no-op on iPad and changes phone. That
  asymmetry is inherent — each clip was written against one device and broken on the
  other.
- **Chase *speeds* scale on iPad** (angler −100 → −213, tronika −60/−200 → −128/−427).
  This is not an arbitrary difficulty change: the player's own world speed already scales
  by `MULTIPLIERX` (`Runner.m`, `RUNNER_VELOCITY_RATE 14.0f * MULTIPLIERX`), so an
  unscaled chase speed made the obstacle *relatively* 2.133× slower on iPad than
  authored. Scaling restores the intended ratio, and matches the 5–8 idiom.
- **A bug fix changes the device it was broken on**, by definition — the swapped boss
  entrance constants, the door hitbox, the `spin` floor test.

Where a per-device pair turned out to be hand-tuned rather than a scaling bug — the
level 11 spike stop height (65 / 165, where `65*MULTIPLIERY` would be 156) and the bat's
`-0.12/1.1` → `-0.24/2.2` pair (a clean 2×, not 2.4×) — the pair was **kept** and
commented, rather than collapsed into a multiplier that would have changed iPad feel.

## Non-goals

- **Map content.** No TMX file is touched. The unreachable `finalBossSpawn` /
  `finalBossDies` tiles are reported, not authored, by explicit decision.
- **Wiring `BossFinalJim` up.** Making the shadow chase reachable needs a `GameLayer`
  boss-routing change, not just a tile, and is a gameplay change rather than a fix.
- **`WaterLevelEffects`.** An empty class; level 10 has no ambient effects layer. Not
  building one.
- **`medals.plist`.** Still only a `timed` mode. Pre-existing and global; already a
  documented non-goal of the 5–8 pass.
