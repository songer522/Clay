# Levels 5–8 Widescreen Modernization Plan

**Goal:** Bring City / Undead / Computer / Volcano Run to the same widescreen state as
levels 1–4, covering the code paths those levels never exercised (death pits, multi-height
ledges, projectile combat, the level 7 boss, and the shoot/block/blow actions).

**Architecture:** Keep `GameCollisionRectForObject` the single AABB source. Every
widescreen formula must reproduce the legacy numbers exactly at 480×320 phone and
1024×768 iPad, so it is a no-op at the authored design size and diverges only where the
screen is genuinely bigger. Derive from live `winSize` rather than literals; use the
`widthScale = max(1, winWidth/480)` idiom established in levels 3–4.

**Spec:** `docs/superpowers/specs/2026-09-04-levels5678-widescreen-design.md`
**Findings:** `docs/superpowers/specs/2026-09-04-levels5678-widescreen-findings.md`

**Verification:** No XCTest target, and per the levels 2–4 plans one must not be added.
Verification is the debug overlay plus playthrough on iPhone and iPad. Build with
`DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer` — `xcode-select` points at
CommandLineTools, so bare `xcodebuild` fails. Note there is **no iOS 18.6 simulator
runtime**; the app's deployment target means only iOS 26+ simulators are eligible.

---

## File map

| File | Responsibility |
|---|---|
| `Clay/Classes/Game/Other/Projectile.m` | On-screen gate from live `winSize` + `_offscreenPadding`; ground resolved against the pit/ledge map |
| `Clay/Classes/Base/CollisionDetection.h` + `.m` | Map-derived pit row / ledge band / column bound; `hasDeathpitAtWorldX:`, `ledgeTopAtWorldX:` |
| `Clay/Classes/Base/Camera.m` | Vertical clamp axis fix (`MULTIPLIERX` → `MULTIPLIERY`) |
| `Clay/Classes/Game/Bosses/BossJimShip.m` | Right-anchored station/entrance/exit, scaled approach speed, `fabsf`, scaled bullet re-aim gate, `getProjectilesForDebugDraw` |
| `Clay/Classes/Game/Bosses/ComboAttack.m` | `IS_IPAD`-gated multipliers, width-derived stage x, consistently scaled bbox |
| `Clay/Classes/Game/GameObjects/GameObject.m` | `GameObjectWidthScale()`; L5–8 chase scaling; fireball `dt`; L6/L8 hitbox scaling |
| `Clay/Classes/Game/PlayerActions/PlayerActionShoot.m` | Scaled swept bullet column |
| `Clay/Classes/Game/PlayerActions/PlayerActionBlow.m` | Test `isIpad` before `currentRenderScale` |

---

### Task 1: Make the overlay authoritative — DONE

- [x] `BossJimShip getProjectilesForDebugDraw` so level 7 draws anything at all.

### Task 2: Shared engine fixes — DONE

- [x] Projectile on-screen gate from live `winSize`.
- [x] `Camera.m` vertical clamp axis.
- [x] Projectile ground resolved against pits and ledges.
- [x] `CollisionDetection` geometry derived from the map, with a column clamp.
- [x] Verified behaviour-identical on levels 3–8 against an offline TMX decode.

### Task 3: Per-level passes — code done, feel unverified

- [x] **L5 City** — mad dog and clapping crowd `widthScale`.
- [x] **L6 Undead** — P0 shooting fix; shoot column, zombie head/heart, mystery box
      hitboxes; zombie chase `widthScale`.
- [x] **L7 Computer** — P0 combo attack; boss station, entrance, approach speed, `fabsf`,
      bullet re-aim gate; computerMelissa `widthScale`.
- [x] **L8 Volcano** — fire demon and armoured-demon `widthScale`; fireball `dt`; firefox
      hitboxes; blow-action branch ordering.
- [ ] **Play each level on phone and iPad with the overlay on** and lock the chase
      constants. See "Still open" in the findings doc for the specific checks.
- [ ] Measure the `slow` strips, the three `boundingBox.x = -50` blow targets, and L5
      `garbage offsetx 90` with the overlay before touching plist baselines. Change the
      plist baseline **or** the code pad, never both in one pass (level 3's double-lift).

### Task 4: Docs — DONE

- [x] Design, plan, findings trio.
- [x] README corrected: level 6 has no boss, the only boss in 5–8 is level 7's.
