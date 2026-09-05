# Levels 5–8 Widescreen: Findings and Locked Values

**Date:** 2026-09-04
**Branch:** `feature/level5678`
**Design:** `2026-09-04-levels5678-widescreen-design.md`

## Phase A diagnosis

Per level, the levels 1–4 process requires a written `trajectory | rects | both` verdict
before changing code.

| Level | Verdict | Note |
|---|---|---|
| 5 City | **trajectory** | No broken rects found. Mad dog and clapping crowd trigger late; pits are new but the pit code itself is sound. |
| 6 Undead | **both** | Shooting functionally dead past screen x 480 (P0), plus unscaled projectile/mystery-box rects and unscaled zombie chase. |
| 7 Computer | **both** | Combo attack off-screen on phones and its rect half-scaled (P0), plus boss station/entrance/speed all 480-anchored. |
| 8 Volcano | **trajectory** (mostly) | Chase and the frame-rate-tied fireball arc; rect work is iPad scaling only. Ledge staircase verified sound. |

## Changes and locked values

All formulas below reproduce the original numbers exactly at legacy 480×320 phone and
1024×768 iPad, so they are no-ops at the authored design size.

### Shared engine

| File | Change |
|---|---|
| `Projectile.m checkIfOnScreen` | `480/320` literals → live `winSize` ± the per-behaviour `_offscreenPadding` (previously assigned but never read). Removed the dead commented-out iPad twin. |
| `Camera.m` | vertical clamp `402 * MULTIPLIERX` → `402 * MULTIPLIERY`. iPad gains 964.8 vs 857.5. |
| `Projectile.m` ground | Resolves against the map: `-FLT_MAX` over a death-pit column, ledge top when the column has one, else the legacy 85/140 constant. |
| `CollisionDetection.m` | `deathpitRow 13` → `_mapHeight - 1`; ledge scan `10..7` → `_mapHeight-4 .. _mapHeight-7`; `1300` → `COLLISION_MAX_COLUMNS` with a `_mapWidth` clamp + log. New `hasDeathpitAtWorldX:` / `ledgeTopAtWorldX:`. |
| `BossJimShip.m` | Implements `getProjectilesForDebugDraw` (bullets + megacannon + combo attacks) so level 7 draws under `DEBUG_DRAW_BOUNDING_BOXES` at all. Returns a +1 retained array, matching `BossFinal` and what `GameDebugLayer` releases. |

### Level 7 boss

| Value | Before | After |
|---|---|---|
| Station box | `x = 240` (half of 480), width 140 unscaled | `winWidth - ScreenX(240)`, width `ScreenX(140)` |
| Entrance target | `ScreenX(380)` | `winWidth - ScreenX(100)` |
| Off-screen park | `ScreenX(1500)` | `winWidth + ScreenX(1500 - 480)` |
| Approach speed | `300.0f` flat | `300.0f * widthScale` |
| Arrival test | integer `abs()` on a float | `fabsf()` |
| Bullet re-aim gate | raw `120.0f` | `BossShipScreenY(120.0f)` |

Measured at runtime — phone 844×390: station `[604.0 .. 744.0]`, entrance `744.0`,
approach `527.5`. iPad 1210×834: station `[698.1 .. 996.7]`, entrance `996.7`, approach
`756.2`. The ship now holds station to the right of the player (pinned at x 75) on both.

### Level 7 combo attack

Multipliers gated behind `IS_IPAD`; stage x measured in from the live right edge; bbox
origin and size scaled consistently.

Measured combo y — **phone: 45 / 70 / 220** against a 390pt screen (all visible).
**iPad: 180 / 280 / 660** against 834 (unchanged, byte-for-byte what shipped).
Before the fix every device got 180 / 280 / 660, so **combo 2 at 660 was off the top of
every phone**.

### Chase and trigger scaling (`GameObject.m`)

Added the `widthScale` idiom to: mad dog (L5), clapping crowd (L5), zombie walk /
male-zombie walk (L6), male-zombie fade / zombie walk fast (L6), computerMelissa (L7),
fire demon (L8), armoured-demon wind-up `closeToPlayer:300` (L8). Introduced a shared
`GameObjectWidthScale()` next to `GAME_OBJECT_DISTANCE_ONSCREEN`.

`COLLISION_BEHAVIOR_FIREBALL_MOVING`: `_vx += 160.0f` → `_vx += 160.0f * 60.0f * dt`
(and the same for `_vy += 100.0f`), preserving the authored 60fps arc while removing the
frame-rate dependency.

### Hitboxes

iPad scaling applied to the level 6/8 boxes and spawn offsets that had none: zombie head
and heart (box and detach height), fire-demon bullet (box and spawn), firefox (both
states), mystery box (all three states), and the firefox fire projectile whose width was
iPad-scaled while its height and origin were not.

`PlayerActionShoot`: swept bullet column now `50/200/50/420 × MULTIPLIER`.
`PlayerActionBlow`: `isIpad` tested **before** `currentRenderScale`, so the level 8 wind
hitbox cannot silently halve if iPad retina is ever enabled.

## Verification

Built and run on **iPhone 16e / iOS 26.2 (844×390)** and **iPad Pro 11-inch M5 / iOS 26.2
(1210×834)**. A temporary launch-time harness exercised the real
`CollisionDetection` code against every live map and logged the computed geometry; it has
since been removed and `project.pbxproj` restored byte-identical to HEAD.

Pit and ledge tables, measured at runtime through the refactored code:

| map | pit columns | ledge columns | ledge tops (phone / iPad) |
|---|---|---|---|
| story_normal_level3 | 0 | 0 | – |
| story_normal_level4 | 0 | 76 | 128 / 192 |
| story_normal_level5 | 20 | 36 | 128 / 192 |
| story_normal_level6 | 244 | 39 | 128 / 192 |
| story_normal_level7 | 0 | 0 | – |
| story_normal_level8 | 253 | 310 | **128–224 / 192–384** |
| timed_hard_level6 | 338 | 55 | 128 / 192 |
| timed_hard_level8 | 291 | 282 | **128–224 / 192–384** |

Every figure matches an independent offline decode of the TMX meta layers, which
establishes that the map-height-derived `precalculateDeathpits` / `precalculateLedges`
produce **identical** results to the old hardcoded `13` and `10..7` on the shipped maps —
the acceptance criterion for that de-risking change. Levels 3 and 4 are unchanged, so the
shared refactor does not disturb the already-tuned levels.

Level 8's four ledge tiers resolve to four distinct heights (128/160/192/224 on phone,
192/256/320/384 on iPad), confirming the staircase is handled correctly.

## Round 2 — defects found by playing (2026-09-04)

Two bugs reported from an actual playthrough of levels 5–8. Both are the same underlying
class: **an absolute position authored in one coordinate space, used in another.**

### L7 — combo attack swept below the player's feet

*Reported: "the spinning projectiles the boss shoots are positioned too low."*

`ComboAttack`'s `_attackPosition` / `_endAttackPosition` are **absolute screen** positions,
but `Camera` shifts the whole world **up** by `CameraPhoneVerticalOffset()` —
`(winHeight - 320) / 2` — on phones taller than the legacy design height. Absolute
screen-space positions never got that shift, so they sat low relative to the world.

On an 844×390 phone the offset is 35pt. Working it through:

| | legacy 320 phone | 390 phone (before) | 390 phone (after) |
|---|---|---|---|
| player feet, screen y | 28 | 63 | 63 |
| combo 0 target y | 45 | 45 | 80 |
| **gap above feet** | **+17** | **−18 (inside the ground)** | **+17** |

Combos 0 and 1 were *below* the player's feet. Fixed by adding
`[Camera phoneVerticalOffset]` to the absolute targets via a new `ComboAttackScreenY()`,
which restores the authored gap exactly. `_initialPosition` is a delta from the ship and
deliberately does **not** get the offset. iPad's offset is 0, so iPad is untouched.

Exposed `+[Camera phoneVerticalOffset]` for this. **The ship's own y (raw 230 / 160) has
the same drift and was deliberately left alone** — moving it would also move its bullets
and re-frame the whole fight, which was not what was reported. Worth eyeballing.

### L8 — landed rock could be walked through

*Reported: "the rocks falling from sky are too low after they land, player can walk
through without jumping."*

Two compounding causes, verified against the map data:

1. **Wrong rest height.** The rock landed at a hardcoded `80 * MULTIPLIERY`. Decoding
   `story_normal_level8_hd.tmx` shows every ground obstacle — including the `fireball`
   itself — is placed on **row 11**, which is world y **96 on an HD phone** and **192 on
   iPad** (`Level.m:729-733`, `_divide` 2 vs 1). So `80 * 2.4 = 192` was *correct on iPad*
   and `80 * 1 = 80` was 16 too low on phone: tuned on iPad, never checked on phone.
   Now lands at `_startingPosition.y` — where the TMX actually placed it — so it rests on
   the same ground as every other level 8 obstacle on both devices, with the legacy
   constant kept as a fallback.

2. **Box too small to reach the player.** The player's plist box has `bbox.y = -10`, which
   lifts his rect 10pt *above* his feet (world 74–174 when grounded). `fireball`'s box is
   12×20 with `bbox.y = 0`, so even resting at the correct height it spans only 56–76 —
   grazing the player's box by 2pt. Its sibling `fireDemon` sits on the same row with the
   same `offsety = -40` and works because its plist gives it `bbox.y = -10` and height 40.
   Added a `COLLISION_BEHAVIOR_FIREBALL_LANDED` rule in `GameCollisionRect.m` that lifts
   the box by 10.

   **Corrected after play-testing:** the first attempt also grew the height to 40 to match
   `fireDemon`. That made the box 66–106 and **forced a double jump** — `fireDemon` is a
   tall standing enemy, not a low rock, so it was the wrong sibling to copy. The height is
   back on the plist baseline and only the lift remains:

   | | rect | top | result |
   |---|---|---|---|
   | plist baseline, old rest height | 40–60 | 60 | walked through |
   | lift + height 40 (`fireDemon`) | 66–106 | 106 | **forced a double jump** |
   | **lift only (shipped)** | **66–86** | **86** | solid overlap, single jump |
   | `fireHedgehog`, known-good low obstacle | 59–74 | 74 | single jump |

   Tuning lever if it ever needs it: move the lift, leave the height on the plist baseline.

   These are two different corrections (where the rock rests, and the box relative to the
   rock), not the level 3 double-lift, which was the same correction applied twice.

### UX — jump touch zone biased right and far too small

*Reported: "the jump button detection box might be off to the right, often when I tap on
the centre the player won't jump."*

The jump hitbox was a fixed **200×200 box centred on the button art**, and the art sits
34pt from the left edge. So two-thirds of the box fell off-screen:

| | before | after |
|---|---|---|
| jump zone, 844×390 phone | x 0..134, y 0..165 | **x 0..506, y 0..390** |
| centre of the *usable* area | x 67 — **+33pt right of the art at x 34** | left-anchored, no waste |
| screen centre (x 422) | dead | jumps |

That right-bias is exactly what was reported: the art is at 34 but the touchable area's
centre is 67, so taps on the left half of the button missed. It also left the entire middle
of a modern wide screen inert.

Replaced with a screen-anchored zone: full height, from the left edge to 60% of the width,
clamped to stop `80 * MULTIPLIERX` clear of the action button, and never smaller than the
old on-screen area. **The button art does not move** — only the touch region grows.

| device | jump zone | screen centre | gap to action button |
|---|---|---|---|
| 844×390 phone | x 0..506, full height | jumps | 210pt |
| 1210×834 iPad | x 0..726, full height | jumps | 211pt |
| legacy 480×320 | x 0..272, full height | jumps | 80pt |

The pause button is tested before the HUD in `GameController`, so the top-left corner still
pauses despite the zone now being full height.

### L8 — blow plume came out of Tim's forehead

*Reported: "the smoke player blow is a little too high, it should be from his mouth, now
it's from his forehead."*

Measured off the sprite sheet (`characterBlowing-hd.plist` + the art itself):

- Tim's visible art is 278px of his 300px frame; his mouth sits **~52% up** that.
- The wind sprite is anchored **bottom-left**, and the developed puff (`BlowingWind_5..7`)
  fills nearly the whole 170px frame, so its visual centre is ~87px above the anchor.
- At the legacy `50 * MULTIPLIERY`, the plume centre landed at +93 on a phone against a
  mouth at +82, and its top reached +134 — above the forehead at ~115. The *first* frame
  was at the mouth, but the developed plume rode over his head, which is what reads as
  "from the forehead".

Solving for "plume centre == mouth" gives **~0.28 × Tim's rendered height** on both phone
(139pt → 39) and iPad (278pt → 78), so the offset is now derived from
`[[player getSprite] getHeight]` rather than a per-device constant — the same idiom as
`BlockShieldOffsetY` in `PlayerActionBlock`. Cached at `startAction` so the plume doesn't
bob as the blow frames change size. Legacy constant kept as a fallback.

Worth noting the old constant was ~17pt too high on iPad but only ~11pt on phone, so this
also removes a device inconsistency rather than just nudging one number.

## Still open

- **Re-check the two round-2 fixes in play:** the L7 combo attack should now sweep just
  above the player's feet (jumpable, not buried), and the L8 landed rock should stop the
  player unless he jumps. If the rock still passes through, the next lever is its
  `GameCollisionRect` rule, not the landing height.
- **The L7 boss ship's own y still has the vertical drift** described in round 2. Left
  alone on purpose; check whether the ship looks low relative to the world on a tall phone.
- **Gameplay feel was not verified by me.** No simulator UI automation was available in this
  environment (XcodeBuildMCP's UI automation workflow is not enabled, and the Xcode 27
  simulator host runs windowless so there was no window to drive). The following need a
  human play session or an enabled automation setup:
  - L6: fire bullets at zombies on the **far right** of the screen and confirm they die.
    This is the direct regression test for the P0.
  - L7: trigger all three combo attacks and confirm attack 3 is now visible on a phone;
    confirm the ship holds station opposite the player.
  - L8: climb the row 7–10 ledge staircase without sinking or flickering; blow at a fire
    demon and confirm the fire strips.
  - L5/L6/L8: run pit sections and confirm death fires at the pit edge, not late.
  - All: overlay check that green boxes track their sprites.
- **Chase constants are first-pass.** Every level 5–8 chase now scales with width, but the
  scaled values have not been played. Levels 1–4 each needed several device rounds; expect
  some of these to want a second pass.
- **Data-level suspects untouched**, pending overlay measurement: the three L8 blow targets
  with `boundingBox.x = -50`, the `slow` strips (`sewerWater`, `zombieWater`,
  `VolcanoBBQLarge/Small`, all 87×15 with `offsetx -60/-64`), and L5 `garbage` with
  `offsetx 90`. These are the low-wide-pad class that needed retuning in levels 1–4, but
  changing plist baselines without an overlay measurement risks the double-lift mistake
  from level 3.
- **`timed_hard` for L5/L6/L8 has zero checkpoints**, so pit deaths restart from spawn.
  Worth a design decision now that pits are reachable and frequent.
