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

- [ ] Play levels 9, 10 and 11 on a modern iPhone **and** an iPad with
      `DEBUG_DRAW_BOUNDING_BOXES` on, and lock the retuned chase constants.
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
- [ ] **The bomb and grape boxes have not had the same placement check the door just
      failed.** Their positions come from `throwBomb`/`throwGrape`'s device-branched
      offsets and then follow gravity, so they are not a fixed-offset bug of the same
      shape, but confirm on the overlay that they actually reach the player's band.
- [ ] The remaining `//IPAD FIX:` comment in `BossFinalJim.m` (shadow feet alignment,
      `SHADOW_YPOS 133`) is untouched — that class is unreachable, so it was not worth
      retuning blind.
