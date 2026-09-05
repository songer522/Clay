# Levels 9–11 Findings

**Date:** 2026-09-05
**Branch:** `feature/level91011`

Method: full read of the level 9–11 code paths, plus an offline decode of all fifteen
shipped TMX variants (`story_easy|normal|hard`, `timed_normal|hard` × levels 9–11),
resolving tileset tile properties and the `meta` / `pits` / `ledges` layers the same way
`CollisionDetection` does.

---

## Verified clean — do not re-audit

- Every `obstacle` / `object` name referenced by the level 9–11 maps resolves in
  `objects.plist`. No missing entries in any variant.
- **Pit and ledge geometry is consistent in all fifteen variants.** Meta bottom row
  (`collision != "full"` → pit) matches the drawn `pits` layer, and `ledgefull` in the
  four-row band `precalculateLedges` scans matches the drawn `ledges` layer. The only
  differences are single edge-cap art columns at the ends of runs, which is how the art
  is authored. Level 9 has no pits (36 ledge columns); level 10 has pits and no ledges
  (85 pit columns in `story_normal`, 102 in timed); level 11 has both (31 pit / 16 ledge
  columns in `story_normal`).
- **No column carries two ledge rows**, and no `ledgefull` sits outside the scanned band,
  so level 4's `ledgeRow - 1` landing tolerance cannot alias one tier onto another here.
- `levels.plist` layer lists match the TMX layers. `actives` is a synthetic marker
  consumed in `Level.m:loadLayers` and `objects` is the `obstacleLayer`; neither needs to
  exist as a TMX layer.
- `comics.plist`, `music.plist`, `hints.plist`, `memory.plist` all carry level 9–11 keys.
- `GameLayer._boss` is cleared per level load (`LevelManager.m:112`, before
  `prepareLevelNamed`), so no stale `BossJimShip` leaks from level 7 into levels 8–10.
- `PlayerActionSlowTime` captures `[gameLayer getBoss]` in `initialize`, which runs from
  `initAfterPlayerAndHudInit` **after** the map has loaded and called `receiveBoss:`, so
  the level 11 slow-time does reach the train.
- `medals.plist` has only a `timed` mode, so story mode gets nil medals. Pre-existing and
  global — not a 9–11 regression, and already a documented non-goal of the 5–8 pass.

---

## P0 — Level 11 boss entrance branches were swapped

`BossFinal.m`, `FINAL_BOSS_MOVE_TO_BOMBING`:

```objc
if ([[GameSettings shared] isIpad]) {
    _trainPosition = ccp(TRAIN_OFFSCREEN_LEFT,      TRAIN_Y_POSITION);   // -600, phone value
} else {
    _trainPosition = ccp(TRAIN_OFFSCREEN_LEFT_IPAD, TRAIN_Y_POSITION);   // -900, iPad value
}
```

`FINAL_BOSS_MOVE_TO_LEFT`, twenty lines below, pairs the same two constants the other way
round and is the reference. Consequences of the swap:

- **iPad** snapped the train to −600 and then drew it at `position.x + 280`
  (`updatePosition`), i.e. an effective −320 against a 1024-wide screen — not enough
  clearance, so the train could be visible before its entrance began.
- **Phone** started 300pt further out than authored. At `moveRight`'s 400pt/s that is
  ~0.75 s of extra dead time before the boss arrives at `TRAIN_BOMB_POSITION`.

**Fixed:** constants swapped back.

## P0 — Level 9 rain and lightning used one device's constants on both

Both carried unresolved `//IPAD FIX:` comments, so this looks like work that was started
and abandoned rather than deliberate tuning.

**`Raindrop.repositionSprite`**
- Spawn span `ccp(180 + rand()%760, 0)` is a 180..940 screen range — authored against the
  1024-wide iPad. On a 480-wide phone the majority of drops spawned off the right edge.
- World y `rand()%32 + 42*2.4`: the literal `2.4` is `MULTIPLIERY` applied
  unconditionally, so on a phone every drop rendered at 100.8–132.8 against a track at
  ~64 — roughly 40–70pt above the ground.

**`Lightning`**
- Spawn span `ccp(50 + rand()%330, 193)` is a 50..380 range authored against the 480-wide
  phone, so on iPad every bolt landed in the left 380pt of a 1024pt screen.
- The parallax line `CGPointMake(_position.x + newPosX, _position.y*2.4)` is again an
  unconditional iPad multiplier, drawing the phone's bolt at 463 against a 320-tall
  screen — i.e. entirely above the visible area.

**Fixed:** both spans are now derived from live `winSize.width`, reproducing the legacy
range exactly at each clip's authored width (1024 for the rain, 480 for the lightning),
and both `2.4` literals are gated on `IS_IPAD` via `MULTIPLIERY`.

> **Open for the play-test.** The lightning y change is the one to watch: it moves the
> phone bolt from 463 (off-screen) to 193 (near the top of a 320-tall screen), which is
> what the `//IPAD FIX:` comment describes as the intent, and is an exact no-op on iPad.
> Confirm the bolt reads correctly on a phone rather than sitting too low.
>
> `Lightning.repositionSprite` also calls `[_sprite setPosition:_position]` with the
> unmultiplied y, so there is one frame at the raw height before `update:` applies the
> multiplier. Pre-existing; left alone.
>
> The raindrop **count** is still a flat 6 regardless of screen width. Left alone
> deliberately — do not add particles unless the overlay shows the rain reading as sparse.

## P0 — Level 10's `spin` floor test did not scale

`PlayerActionSpin.m` — `#define SPIN_PLAYER_GROUND_Y 64`, tested as
`if (_player.y <= SPIN_PLAYER_GROUND_Y) { [self endAction]; }`.

There are two real floors and a bare 64 is neither of them on iPad: the grounded player
sits at `64*MULTIPLIERY` (`Player.m:220`) and level 10's underwater floor gate is
`22*MULTIPLIERY` (`Player.m:223`). On iPad the anchor therefore could not reliably end on
contact and ran out its full 10.75 s `_duration` instead.

**Fixed:** `64.0f * MULTIPLIERY` — exact on phone, proportional on iPad.

> **Open for the play-test.** The phone baseline of 64 sits well above the underwater
> floor gate of 22, so the swim ends ~42pt short of the floor on a phone. That is the
> shipped feel and was deliberately **not** retuned. Measure it with the overlay before
> changing the baseline.

## P0 — Level 11 train-door hitbox could never touch the player

Reported from play with the overlay ("the hit box is too low"), and confirmed by the
arithmetic. This was **missed in the first pass**: the door box was scaled as one of the
half-scaled hitboxes below without checking whether it landed anywhere near the player.
Scaling a box that is in the wrong place does not fix it.

`GameCollisionRectForObject` builds every box as `(spritePosition - bbox.origin, bbox.size)`.
`Projectile.setPosition` converts a world point to screen, and for the door the camera terms
cancel exactly, so its screen y was just `TRAIN_Y_POSITION` plus the authored per-device
offset in `update:` — `132 - 95 = 37` on phone, `132 - 15 = 117` on iPad. The player's box
bottom is his grounded screen y plus 10 (plist `bbox.y` is a raw −10) and moves with the
camera letterbox:

| | player box | door box (as shipped) | gap |
|---|---|---|---|
| legacy phone 480×320 | 180 – 280 | 25 – 50 | 130 |
| iPhone 16 ≈956×440 | 300 – 400 | 25 – 50 | 250 |
| iPad 1024×768 | 493.6 – 733.6 | 105 – 130 | 328.6 |

The box sat 130–330pt below the player's feet on every device, so **the door attack landed
no hits at all**, and the gap grew with screen height because the door's y was a constant
while the player's tracked the camera.

**Fixed:** `FinalBossDoorScreenY()` anchors the door box's bottom to the player's grounded
collision box bottom, reading the door's own `bbox.origin.y` back so the two cannot drift
apart. The authored horizontal offsets (`+250` iPad / `0` phone) are art alignment and are
kept. Resulting overlap, identical in proportion on every device:

| | player box | door box | overlap |
|---|---|---|---|
| legacy phone 480×320 | 180 – 280 | 180 – 205 | 25 (bottom 25%) |
| iPhone 16 ≈956×440 | 300 – 400 | 300 – 325 | 25 (bottom 25%) |
| iPad 1024×768 | 493.6 – 733.6 | 493.6 – 553.6 | 60 (bottom 25%) |

The box covers the bottom quarter of the player — a legs-height sweep, which suits a train
door. The height is left on the authored 25 (×`MULTIPLIERY`) baseline; if it needs to catch
him higher, move the height, not the anchor.

### The door also missed *horizontally* — regression plus a pre-existing miss

Raised in review: applying `FinalBossStageX()` to the `ATTACK_1C` endpoint pushed the whole
sweep rightward, so on an 874-wide phone the train stopped at x 444 and the door box sat at
424–438, nowhere near the player. Correct, and confirmed — that regression defeated the
vertical fix above.

Checking the authored values showed the horizontal reach **never worked on either device**.
Note `cameraTracking.x` is scaled (`Player.m:82`, `75 * MULTIPLIERX`), so the player sits at
screen x 75 on a phone and 160 on an iPad:

| | player box x | door box x | result |
|---|---|---|---|
| legacy phone 480, dest 50 | 55 – 87 | 30 – 44 | **miss by 11** |
| legacy iPad 1024, dest −180 | 117.3 – 185.6 | 27.3 – 57.2 | **miss by 60** |
| iPhone 17 Pro 874, dest 444 (this branch) | 55 – 87 | 424 – 438 | **miss by 337** |

So there was no legacy behaviour worth preserving in that endpoint.

**Root of the mistake:** `FinalBossStageX` is right for *station* positions, which are
anchored to the screen's right edge. The door sweep is not a station - it is a lunge **at the
player**, who is pinned near the left. Applying the right-anchor to it was a category error.

**Fixed:** `doorLungeDestinationX` derives the endpoint from the player's live collision rect
and the door's own bbox, so the door box centres on him. It reads the player rect rather than
re-deriving from the plist, so it stays correct if either box is retuned.

The sweep also has much further to travel from a right-anchored start on a wide screen. The
rate is now sized to the distance with 60% of the phase budgeted for travel, leaving 40% as
dwell so the door rests on the player long enough to register - sized to arrive exactly at the
end, an 874-wide phone gave a **zero-length hit window**. The rate never drops below the
authored one, so both design sizes are untouched:

| | overlap with player | arrives | dwell | rate (legacy) |
|---|---|---|---|---|
| legacy phone 480 | 43.8% of his width | 0.70 s | 0.70 s | 0.65 (0.65) |
| iPhone 17 Pro 874 | 43.8% | 0.84 s | 0.56 s | 1.48 (0.65) |
| legacy iPad 1024 | 43.7% | 0.59 s | 0.81 s | 1.30 (1.30) |
| iPad ~1366 | 43.7% | 0.84 s | 0.56 s | 1.72 (1.30) |

Still arithmetic, not play — the boss has not been reached in the simulator.

### Hitbox activation window — already correct, no change made

Checked because it was raised alongside the placement. The door art is part of Jim's own
sprite (`anims.plist` sequence `FinalBoss_4_Jim`), and the phase machine already gates the
hitbox to exactly the fully-open window:

| phase | animation | frames | door |
|---|---|---|---|
| `ATTACK_1B` (0.4 s) | `darkBossJimDoorAttack1` | 1,2,3,4,4,4,4 — swinging open | disabled |
| `ATTACK_1C` (1.4 s) | `darkBossJimDoorAttack2` | 4,4 — held fully open | `[_door reset]` → active |
| `ATTACK_1D` (0.4 s) | `darkBossJimDoorAttack3` | 3,2,1,… — closing | `[_door disable]` |

At the 0.1 s frame delay, 1B's 0.4 s is exactly frames 1→4, so the box switches on the
instant the door reaches fully open. `changeToAnimationNamed:` and `checkWait:` both scale
by `_speedModifier`, so the animation and the phase timer stay in sync under slow-time. No
extra frame-number gating was added.

## P0 (open, NOT fixed) — the Level 11 bomb spawns below the ground plane

Raised in review as "the same failure shape as the door". Checked, and it is. **Not fixed
in this branch** — see the reasoning at the end.

`throwBomb` / `throwGrape` build the spawn point as
`convertToWorldXY(_trainPosition + authored screen offset)` — `+40` on phone, `+260` on
iPad — and `Projectile.update:` then ground-triggers whenever the world y falls to
`groundPosition + _offsetGroundDetectionY` (85/140 resolved against the pit/ledge map,
plus −10 for the bomb and −20 for the grape). Running the spawn through the same camera
arithmetic the door used:

| projectile | config | spawn world y | ground threshold | ground-triggers |
|---|---|---|---|---|
| bomb | legacy phone 480×320 | 66.0 | 75.0 | **frame 1** |
| bomb | iPhone 16 ≈956×440 | −54.0 | 75.0 | **frame 1** |
| bomb | iPad 1024×768 | 62.0 | 130.0 | **frame 1** |
| grape | legacy phone 480×320 | 66.0 | 65.0 | frame 46 (0.77 s) — a real arc |
| grape | iPhone 16 ≈956×440 | −54.0 | 65.0 | **frame 1** |
| grape | iPad 1024×768 | 62.0 | 120.0 | **frame 1** |

For `PROJECTILE_BEHAVIOR_DARK_BOMB` a ground trigger is `[self startCollision]` +
`bombExplosion` + `_isActive = false`, so the bomb detonates at the train on the frame it
is thrown and never travels toward the player.

**Why this is not fixed here.** Two things say the spawn constants are more subtle than
they look, and picking new ones blind is exactly the mistake that produced the door bug:

1. The grape works on a legacy 480×320 phone and nowhere else. That one configuration
   producing a sensible 0.77 s arc is good evidence the model above is right — but it
   clears its threshold by **1pt** (66 vs 65). Constants that fragile were tuned against
   something, and the bomb misses its own threshold by only 9pt.
2. The authored offsets are `+40` (phone) and `+260` (iPad) — a 6.5× difference where
   `MULTIPLIERY` is 2.4. At least one of them was already wrong before any of this work.

So either the bomb has been broken since 2012, or there is a constraint here not visible
in the code. The overlay will settle it in seconds; guessing will not. Needs a decision on
where the bomb should leave Jim's hands before anything is changed.

## Simulator run — 2026-09-05, iPhone 17 Pro (874×402pt, iOS 27)

Driven through a new DEBUG-only `-startLevel` launch-argument hook (see below). widthScale
on this device is ≈1.82, so it exercises the wide-phone case directly.

**Passed.** All three levels load, render and run with no errors in the runtime log. Level 9
gameplay is live and reacting at sensible distances — the umbrella flies up, a paper plane
crosses, the squirrel throws a nut. Levels 10 and 11 render correctly. The player's collision
box hugs the sprite from feet to head on every level; the level 9 frog/squirrel boxes and the
level 11 bat boxes track their sprites.

### Tooling defect found and fixed: the debug overlay was painted over

`DEBUG_DRAW_BOUNDING_BOXES` appeared to do nothing. `GameDebugLayer` added itself with
`[scene addChild:self]` at the default `z == 0`, but `GameLayer +scene` adds the game layer to
the scene **after** `setupLayers` has added the debug layer, so at equal z the insertion order
put the world on top and the boxes were painted over. Fixed with an explicit `z:1000`.

This matters beyond this branch: **every "verify with the overlay" step in the levels 2–11
plans was relying on a layer that could be invisible.**

### Level 9 rain was invisible — diagnosed and fixed (z-ordering)

Pre-existing, not a regression: verified by checking the pre-change `Raindrop.m` /
`Lightning.m` / `RainyLevelEffects.m` out of the merge base (`e8d2dcb6`) and rebuilding —
the rain is missing there too.

**Instrumented rather than guessed.** Logging each raindrop after its animation loaded gave:

```
parent=<GameLayer> pos=(777.0,83.0) visible=1 opacity=255 scale=1.00 size=(14.5,11.5)
```

All six drops: attached to the GameLayer, on screen, fully opaque, real 14.5×11.5 frame
loaded (not the 4×4 `blank.png` placeholder). So they were being drawn and something was
covering them.

**Root cause: z-ordering.** `Sprite` adds to the GameLayer at the default `z == 0`, and
every TMX map layer is *also* `z == 0` because `Level.m`'s `currentZ += 1` is commented out
(`Level.m:226`). Ordering therefore falls back to insertion order, and `RainyLevelEffects`
is constructed part-way through `loadLayers` (at the `ledges` entry) — so `ledges`,
`front-1` and `meta`, added after it, paint straight over the rain.

**Corrections to the earlier report in this doc:**

- The `Rain_RP_` frames are **ground splash ripples at track height**, not falling streaks.
  That makes the world-y fix above (`42*MULTIPLIERY`, i.e. 42–74 on a phone, straddling the
  track at 64) correct *and* necessary — the original unconditional `42*2.4` put the ripples
  at 100–133, floating in the air above the track. It simply could not be observed while the
  z bug hid them.
- **The lightning was never broken.** It renders fine; strikes are just 4–9 s apart and the
  earlier screenshots missed the gaps. It escapes the z bug because it draws up in the sky,
  where the later layers have no opaque art. Claiming it was missing was wrong.

**Fix:** lift the ripples above the map with an explicit z. Because every other node is at
`z == 0` there is no value that sits above the track art but below the player, so they now
draw over him as well — the lesser evil against not rendering at all. Verified in the
simulator, including a temporary 4× scale to prove the ripples render before trusting them at
their real size.

`_rainBehindTim` (the splash around Tim) is very likely hidden by the same mechanism, and is
**not** fixed here: its name says it belongs behind the player, and the flat `z == 0` world
gives no slot between the track art and the player. Left for a deliberate layering pass.

### Level 10 fails to load three animations

`waterBubblesLAnim`, `spinningAnim`, `floatingAnim` all log
`ERROR! AnimationController.m - unable to load animation with name: …`. All three exist in
`anims.plist`, so their spritesheet is not loaded at that point. Pre-existing — this branch
touched no plists and no animation code.

### Still not covered by the run

The level 11 boss was not reached. The player auto-runs but has no input, so he cannot clear
the pits and never gets to the `finalBossEnters` triggers. **The door hitbox, the train
framing and the bomb spawn are therefore still unverified in play** — they remain the
priority for a human pass, which the hook now makes cheap to set up.

## P1 — No level 9–11 chase or trigger used the `widthScale` idiom

`closeToPlayer:` (`GameObject.m`) is a plain world-space X comparison, and the player is
pinned at screen x 75 (`player.plist cameraTracking`), so every extra point of screen
width is distance an obstacle must cross before it reacts. The levels 3–4 pass
established `widthScale = max(1, winWidth/480)` and 5–8 adopted it everywhere. Levels
9–11 used it nowhere.

The level 9 cases are the worst of it: `MULTIPLIERX*315` (umbrella) and `MULTIPLIERX*480`
(paper plane) *look* scaled, but `MULTIPLIERX` is `IS_IPAD ? 2.133 : 1` — it does nothing
at all for a wide phone.

**Fixed** — `GameObjectWidthScale()` applied to:

| Level | Site | Was |
|---|---|---|
| 9 | umbrella fly-up curve | `MULTIPLIERX*315` |
| 9 | paper plane dive / cruise | `MULTIPLIERX*480`, `MULTIPLIERX*GAME_OBJECT_DISTANCE_ONSCREEN` |
| 9 | squirrel nut throw | `400.0f` |
| 10 | pufferfish inflate bands | `550` / `300` / `150` |
| 10 | jimWater bob | `550` |
| 10 | angler fish chase + speed | `GAME_OBJECT_DISTANCE_ONSCREEN`, `-100` |
| 10 | tronika chase + speeds | `180`, `-60`, `-200` |
| 10 | squid firing range | `300` |
| 11 | spike drop trigger | `150` |
| 11 | bomb proximity detonation | `40` |
| 11 | gargoyle wake-up | `300` |

The bare `GAME_OBJECT_DISTANCE_ONSCREEN` "has appeared" triggers were left alone where
they are already 1000pt — wider than any device.

**Note that the chase *speeds* are not a no-op on iPad** (angler −100 → −213, tronika
−60/−200 → −128/−427). That is deliberate and is not an arbitrary difficulty change: the
player's own world speed already scales by `MULTIPLIERX`
(`Runner.m`, `RUNNER_VELOCITY_RATE 14.0f * MULTIPLIERX`), so an unscaled chase speed left
the obstacle *relatively* 2.133× slower on iPad than authored. Scaling restores the
intended ratio. Still worth confirming on the overlay, since it does change iPad feel
against what shipped.

## P1 — Boss stage positions were anchored to a 480-wide screen

`TRAIN_BOMB_POSITION` (230 — the centre of a 480 screen), `TRAIN_DOOR_POSITION` (310),
`TRAIN_OFFSCREEN_RIGHT` (1200) and the `FINAL_BOSS_ATTACK_1C` destinations (−180 iPad /
50 phone) are all screen-space x values. With the player pinned left, all extra modern
width falls to his right, so the train parked on top of him instead of across from him —
the same defect the 5–8 pass fixed in `BossJimShip._targetOnScreen`.

**Fixed:** a `FinalBossStageX()` helper shifts each stage x right by exactly the width
beyond the authored size (480 phone / 1024 iPad), leaving the per-device sprite offsets
in `updatePosition` untouched. Exact no-op at both authored sizes.

The offscreen-**left** constants were left alone: the left edge is where the player
already is, and −600 / −900 is ample clearance at any width.

## P2 — Half-scaled hitboxes

Boxes set in code bypass the `MULTIPLIERX/Y` scaling that the plist path applies at load.
Fixed to the house convention — x and width by `MULTIPLIERX`, height by `MULTIPLIERY`,
**y left raw** (scaling `bbox.y` is what sank the level 6 brains/hearts in round 2):

| Level | Site | Was |
|---|---|---|
| 9 | squirrel nut spawn offset + box | `(_x-25, _y+19)`, `CGRectMake(5,12,16,16)` |
| 10 | squid ink spawn offset + box | `(_x-12, _y-28)`, `CGRectMake(10,25,20,30)` |
| 11 | gargoyle open-wings | `CGRectMake(-45,0,25,60)` |
| 11 | dark bomb | `CGRectMake(30,30,60,60)` |
| 11 | grapes | `CGRectMake(7,18,14,20)` |
| 11 | train door | `CGRectMake(20,12,14,25)` — but see the P0 entry below; the size was never the real problem |

The squid ink case is the clearest: the `firefox` projectile set up eight lines above it
in the same method scales correctly, and the squid's does not.

Two sprite **offsets** in the same family, both matching the level 8 "blow plume rode
above Tim's forehead" defect, were also scaled:

- `RainyLevelEffects` rain-behind-Tim — `(player.x-70, player.y+40)`, with the iPad branch
  left commented out.
- `PlayerActionSlowTime` sprite — `(_parent.x-70, _parent.y)`.

### Deliberately left as hand-tuned per-device pairs

Not every device branch is a scaling bug. These were **kept and commented** rather than
collapsed into a multiplier, because doing so would change iPad feel:

- Level 11 spike stop height, `65` / `165`. `65*MULTIPLIERY` is 156, not 165.
- Level 11 bat arc, `-0.12/1.1` phone → `-0.24/2.2` iPad. That is a clean 2×, not 2.4×,
  and the accompanying `_y = 160.0f` is iPad-only by design.
- `BossFinal`'s `moveLeft`/`moveRight` rate doubling and the `PassengerCar` /
  `updatePosition` sprite offsets, which are authored art alignment.

## P2 — Cleanups

- `Projectile.m setInitialVelocity` — `PROJECTILE_BEHAVIOR_RAINY_SQUIRREL_NUT` had no
  `break;` and fell into `WATER_SQUID_INK`. Harmless today (the next case only breaks)
  but a trap for the next edit. `break` added.
- `BossFinal.m` — `BOSS_FINAL_MAX_TRAIN_X` was defined and never read. Removed.

---

## Authored but unreachable content — reported only, no map edits

By explicit decision this pass changes no TMX file. Recorded here so the gaps are known.

- **`finalBossSpawn` (Icons gid 17) appears in none of the five level 11 map variants.**
  `TRIGGER_BOSS_FINALJIM_SPAWN` therefore never fires and **`BossFinalJim` — the
  shadow-Tim chase the whole `slowtime` action is themed around — never spawns.**
  Placing the tile alone would not be enough: `GameLayer.m` routes that trigger to
  `_boss`, which on level 11 is the `BossFinal` train, so `switchToPhase:` would land on
  `Boss`'s empty base implementation. Making the shadow chase reachable is a boss-routing
  change.
- **`finalBossDies` appears in no map** → `FINAL_BOSS_DIE` never triggers. The train is
  dismissed by `finalBossExits` and the level ends at `nextlevelNE`; the boss is never
  killed.
- `finalBossAttack3` is absent from `story_normal` and `timed_hard` (present once each in
  `story_easy`, `story_hard`, `timed_normal`).
- Defined in `objects.plist` but placed in no shipped map: `darkGargoyle`,
  `darkBatStatic` (L11), `rainyUmbrellaFlyAcross`, `rainyWater` (L9).
  `RainyLevelEffects` still special-cases `COLLISION_BEHAVIOR_UMBRELLA_FLY_ACROSS` in
  both `triggerWind` and `endWindEffect`.
- `WaterLevelEffects` is an empty class — level 10 has no ambient effects layer, unlike
  level 9's rain. It is never instantiated.
- Level 11 `timed_normal` tags its bumper tile `object:bumper` where every other variant
  uses `obstacle:bumper`, so in that one map it loads through the decoration path rather
  than the obstacle path. `bumper` has `playerEffect: none`, so the impact is cosmetic.
- Level 9 `timed_hard`, level 10 `timed_hard` and level 11 `timed_hard` contain no
  `checkpoint` tile. Consistent across all three, so this reads as intentional for that
  difficulty rather than a data loss.

---

## Still open

Everything above builds clean with no new warnings, but **none of it has been played**.

- [x] Levels 9–11 load, render and run on a modern iPhone with the overlay on
      (see the simulator run section). Chase constants **not** locked - that needs play.
- [ ] Repeat on an **iPad**, which none of this has touched.
- [x] Level 9 rain diagnosed and fixed (z-ordering); lightning was never broken.
- [ ] `_rainBehindTim` is probably hidden by the same z bug. Needs a deliberate decision
      about layering, since it is meant to sit behind the player.
- [ ] The flat `z == 0` world (`Level.m:226`) is the underlying hazard and has now produced
      two visible bugs (the debug overlay and the rain). Worth a considered pass.
- [ ] L9: confirm the raindrops land on the track and the lightning reads correctly on a
      phone (see the note under the P0 rain/lightning entry).
- [ ] L10: confirm the `spin` anchor ends on floor contact on both devices, and decide
      whether the phone's 64 baseline should drop toward the 22 underwater floor.
- [ ] L11: confirm the train enters from fully offscreen on both devices and settles
      across from Tim rather than over him, and that the bomb/grape boxes track their
      sprites.
- [ ] L11: confirm the re-anchored door box now connects, and decide whether a
      legs-height sweep (bottom 25% of the player's box) is the intended feel or whether
      the door should catch more of him — if so raise the **height**, not the anchor.
- [ ] **The bomb spawn — highest priority.** Confirmed above: the bomb ground-triggers on
      frame 1 on every device and the grape does so everywhere except a legacy 480×320
      phone. Watch one bomb attack on the overlay and decide where the throw should
      originate, then fix the spawn offsets. Do not guess them.
- [ ] The remaining `//IPAD FIX:` comment in `BossFinalJim.m` (shadow feet alignment,
      `SHADOW_YPOS 133`) is untouched — that class is unreachable, so it was not worth
      retuning blind.
