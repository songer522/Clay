# Levels 5–8: Widescreen Collision, Boss, and Pit/Ledge Modernization

**Date:** 2026-09-04
**Branch:** `feature/level5678`
**Status:** Implemented; engine + collision verified, feel pass still open

## Problem

Levels 1–4 have been through the widescreen modernization pass. Levels 5–8 — City Run,
Undead Run, Computer Run, Volcano Run — had not, and they are the first levels to
exercise several code paths that the earlier work never touched:

- **Death pits.** Levels 1–4 contain zero. Level 5 has 20 pit columns, level 6 has 244
  (338 in timed_hard, 38% of the map), level 8 has 253.
- **Multi-height ledges.** Levels 4–6 use only meta row 10. Level 8 uses rows 7, 8, 9
  and 10.
- **Projectile combat.** Level 6's `shoot` action, level 8's `fireball` and fire-demon
  bullets, level 7's boss bullets and megacannon.
- **A boss.** Level 7's `jimSpaceShip`.
- **New third actions:** `shoot` (L6), `block` (L7), `blow` (L8).

Two of the defects found are not tuning drift — they are functional breakage on every
modern device.

## Corrections to the project's own description

- **Level 6 has no boss.** `levels.plist` carries `boss = "zombies"`, but nothing reads
  the key (`LevelManager.m:63-93` consumes only `fileName`, `obstacleLayer`,
  `thirdAction`, `layerList`, `playerOffsetY`, `nextLevelName`, `postLevelComic`,
  `music`, `preComic`). Level 7's `worldType = "realWorld"` is likewise dead.
- **The only boss in 5–8 is level 7's** `jimSpaceShip` → `Bosses/BossJimShip.m`.
  `BossFinal` / `BossFinalJim` belong to level 11.
- **Level 8 has no boss wiring at all.**
- **`Clay/Resources/levels/level5..8_hd.tmx` and `Resources/levels/real_level_*_hd.tmx`
  are dead legacy maps.** Live maps resolve as `<mode>_<difficulty>_<fileName>` with `_hd`
  inserted (`Level.m:124`, `LevelManager.m:70-77`), i.e.
  `Clay/Resources/levels/story_normal/story_normal_level5_hd.tmx`. The legacy copies
  reference obstacles that no longer exist in `objects.plist` (`headlessZombie`,
  `retroHurdle`, `retroCrow`, `retroPig`, `retroGarbage`) and must not be loaded.
- **Level 8's ledges are a staircase, not stacked tiers.** Decoding the meta layers shows
  rows 7–10 are all populated but **no column carries more than one ledge row**, so
  `_ledgeHeightAtColumn`'s one-height-per-column design holds and the level 4
  `ledgeRow - 1` tolerance cannot alias one tier onto another.

## Findings

### P0 — Level 6 shooting was dead past screen x 480

`Projectile.m checkIfOnScreen` hardcoded `x < 480 && y < 320` and gated all
aggressive-projectile collision testing. Level 6 bullets (`PROJECTILE_BEHAVIOR_BULLET`,
`_isAggressive`, `_vx = 800`) therefore stopped damaging zombies at screen x 480 — the
middle of a modern iPhone, the left 40% of an iPad. The player watched bullets pass
through visible zombies with no effect.

`_offscreenPadding` already existed and was assigned per behaviour but was **never read
anywhere in the codebase** — plainly intended for this test.

### P0 — Level 7 combo attack was off-screen on every phone

`ComboAttack.m` multiplied every authored position by the iPad factors (`2.133`, `4`,
`3`) with **no `IS_IPAD` guard**, unlike every other site in the codebase. With the ship
at `_y = 230`, combo 2's `220 * 3 = 660` put the attack far above a 390pt-tall phone
screen: the attack played its charge sound and was never visible.

It went unnoticed because `BossJimShip` never overrode `getProjectilesForDebugDraw`, so
`Boss.m:102` returned nil and `DEBUG_DRAW_BOUNDING_BOXES` drew **nothing at all** for
level 7. Its bounding box was also half-scaled (iPad-scaled origin, unscaled 24×24 size),
producing a box entirely up-and-left of the sprite.

### P1 — Boss ship framing anchored to a 480-wide screen

`_targetOnScreen` was built around x 240 (half of 480) with an unscaled width, and the
entrance target was a literal 380. Since the player is pinned at screen x 75
(`player.plist cameraTracking`), all extra modern width appears to his right — so the
ship hovered on top of the player instead of across from him. Approach speed was a flat
300pt/s, and the arrival test used the **integer** `abs()` on a float difference.

### P1 — Camera vertical clamp used the wrong axis

`Camera.m` clamped `rect.size.height` with `MULTIPLIERX` (2.133) instead of `MULTIPLIERY`
(2.4), costing the iPad 107pt of vertical camera range on exactly the levels that have
ledges.

### P1 — No level 5–8 chase used the `widthScale` idiom

The levels 3–4 pass established `widthScale = max(1, winWidth / 480)`. None of the level
5–8 cases used it: mad dog, zombies, computerMelissa, fire demons, the armoured demon
wind-up, the clapping crowd. All trigger too late on a wide screen.

`COLLISION_BEHAVIOR_FIREBALL_MOVING` also applied `_vx += 160.0f; _vy += 100.0f;` once
per frame with **no `dt`**, tying the fireball's arc to the frame rate.

### P2 — Pit/ledge geometry and projectile ground

`precalculateDeathpits` hardcoded `deathpitRow = 13` and `precalculateLedges` scanned
rows 10→7, both correct only because every shipped map is 14 rows tall. The per-column
tables are fixed at 1300 entries with no clamp.

`Projectile.m` resolved ground against flat constants (85 phone / 140 iPad), ignoring the
map entirely — so on levels 6 and 8 a bouncing zombie head came to rest **in mid-air over
a death pit** and sank through ledges. That was also a third independent definition of
"ground", alongside `COLLISION_PLAYER_GROUND_Y_POSITION 64.0f` and `Player.m`'s
`64*MULTIPLIERY`.

### P2 — Half-scaled hitboxes

Level 5–8 collision correctly routes through `GameCollisionRectForObject`, so there is no
bypass bug of the levels 2–4 kind. But many `setBoundingBox:` literals were unscaled or
inconsistently scaled (zombie head/heart, firefox, mystery box, fire-demon bullet, and
one box with an iPad-scaled width but unscaled height).

`PlayerActionShoot`'s bullet box is a 420-tall swept column that spans a 320pt playfield
by construction; unscaled it no longer covers the column on iPad.

`PlayerActionBlow` tested `currentRenderScale >= 2.0f` **before** `isIpad`, so it only
reached the iPad box because `SceneDelegate` force-disables retina on iPad — enabling
retina there would have silently halved the level 8 wind hitbox.

## Non-goals

- `medals.plist` — has no `story` key at all, so story mode gets nil medals
  (`ChooseLevelScreen.m:191`). Last touched 2012; **no medal times have been retuned for
  any level, including 1–4**. Pre-existing and global, not a 5–8 regression.
- Level 11 boss files (`BossFinal`, `BossFinalJim`), which have their own 480-isms.
- The `-4.0f` foot probes in `CollisionDetection.m`. They are unscaled, but level 4's
  ledges work today and scaling them would change iPad pit/ledge timing on already-tuned
  levels with no evidence of a defect. Left alone deliberately; see findings.

## Approach

Shared engine fixes first, so the debug overlay is trustworthy and the P0s are cleared
before any per-level tuning. Every fix is written to reproduce the legacy numbers exactly
at 480×320 phone / 1024×768 iPad, so the change is a no-op on the authored design size
and only diverges where the screen actually is bigger.
