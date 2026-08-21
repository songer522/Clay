# Level 2 Chicken→Cow Chain Hit Detection Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** On modern iPhones, restore Level 2 behavior where a well-timed kicked chicken knocks down multiple cows in a row (not only the first).

**Architecture:** Keep frame-based aggressive collision (at most one cow per frame via `break`). Diagnose hen vs cow AABBs and kick-flight physics on device with `GameDebugLayer`, then apply the smallest fix in either `CollisionRectForObject` / hen-kicked bbox, or `special_kickHen` flight constants — without changing player→hen kick feel.

**Tech Stack:** Objective-C, cocos2d (legacy), Xcode on iPhone 17 (or equivalent modern device).

**Spec:** `docs/superpowers/specs/2026-08-20-level2-chicken-cow-chain-design.md`

---

## File map

| File | Responsibility |
|---|---|
| `Clay/Classes/Scenes/GameLayer.m` | `#define DEBUG_DRAW_BOUNDING_BOXES` gate |
| `Clay/Classes/Scenes/GameDebugLayer.m` / `.h` | Draw boxes; must match gameplay rects |
| `Clay/Classes/Game/Other/Level.m` | `CollisionRectForObject`, `testCollisionsForAggressive:Obstacles:` |
| `Clay/Classes/Game/Other/Collidable.h` | `COLLISION_BEHAVIOR_HEN_*`, `COLLISION_BEHAVIOR_COW_COLLAPSE` |
| `Clay/Classes/Game/GameObjects/GameObject.m` | `special_kickHen`, `COLLISION_BEHAVIOR_HEN_KICKED` update |
| `Clay/Classes/Game/Other/GameCollisionRect.h` + `.m` (**new**) | Shared AABB helper extracted from `Level.m` |
| `docs/superpowers/specs/2026-08-20-level2-chicken-cow-chain-findings.md` (**new**) | Phase A diagnosis write-up |

No XCTest target in this repo. Verification = **device repro + debug overlay**. Do not add a test target unless the implementer explicitly wants one for a pure helper (optional).

---

### Task 1: Enable collision debug overlay

**Files:**
- Modify: `Clay/Classes/Scenes/GameLayer.m` (line ~43)

- [ ] **Step 1: Turn on debug draw**

Change:

```objc
#define DEBUG_DRAW_BOUNDING_BOXES 0
```

to:

```objc
#define DEBUG_DRAW_BOUNDING_BOXES 1
```

Confirm existing `#if DEBUG_DRAW_BOUNDING_BOXES` blocks still create/re-parent `_debugLayer` (~lines 142–144 and ~222–224).

- [ ] **Step 2: Build and run Level 2 on device**

Start Level 2 (barn). Confirm boxes draw for player, kick projectile, hens, and cows.

- [ ] **Step 3: Commit**

```bash
git add Clay/Classes/Scenes/GameLayer.m
git commit -m "chore: enable collision debug overlay for Level 2 diagnosis"
```

---

### Task 2: Make debug boxes use the same rect as gameplay

**Why:** `GameDebugLayer`’s `drawBoxForCollidable:` hand-rolls sprite+bbox math. `Level.m`’s static `CollisionRectForObject` also applies modern-phone hurdle/sandpit padding. Overlay and gameplay must match.

**Files:**
- Create: `Clay/Classes/Game/Other/GameCollisionRect.h`
- Create: `Clay/Classes/Game/Other/GameCollisionRect.m`
- Modify: `Clay/Classes/Game/Other/Level.m`
- Modify: `Clay/Classes/Scenes/GameDebugLayer.m`
- Modify: `Clay.xcodeproj/project.pbxproj` (add new files to the Clay target)

- [ ] **Step 1: Extract `CollisionRectForObject` into a shared C function**

`GameCollisionRect.h`:

```objc
#import "Collidable.h"
#import <CoreGraphics/CGGeometry.h>

CGRect GameCollisionRectForObject(id<Collidable> object);
```

`GameCollisionRect.m`: move the **entire** current body of `static CGRect CollisionRectForObject(...)` from `Level.m` (including `!IS_IPAD` hurdle / `Track_Sandpit_1.png` adjustments). Keep behavior identical.

In `Level.m`, delete the static function and call `GameCollisionRectForObject` everywhere it was used (aggressive + normal collision helpers).

- [ ] **Step 2: Point debug draw at the shared helper**

Replace `drawBoxForCollidable:` body in `GameDebugLayer.m`:

```objc
-(void)drawBoxForCollidable:(id<Collidable>)object
{
    CGRect rect = GameCollisionRectForObject(object);
    float left = CGRectGetMinX(rect);
    float right = CGRectGetMaxX(rect);
    float bottom = CGRectGetMinY(rect);
    float top = CGRectGetMaxY(rect);

    ccDrawLine(ccp(left, top), ccp(right, top));
    ccDrawLine(ccp(right, top), ccp(right, bottom));
    ccDrawLine(ccp(right, bottom), ccp(left, bottom));
    ccDrawLine(ccp(left, bottom), ccp(left, top));
}
```

Import `GameCollisionRect.h` at the top of `GameDebugLayer.m`.

- [ ] **Step 3: Add new files to the Xcode target and build**

Verify Level 2 overlay still looks correct.

- [ ] **Step 4: Commit**

```bash
git add Clay/Classes/Game/Other/GameCollisionRect.h \
  Clay/Classes/Game/Other/GameCollisionRect.m \
  Clay/Classes/Game/Other/Level.m \
  Clay/Classes/Scenes/GameDebugLayer.m \
  Clay.xcodeproj/project.pbxproj
git commit -m "refactor: share collision rect helper between gameplay and debug draw"
```

---

### Task 3: Device diagnosis (write down the answer)

**Files:**
- Create: `docs/superpowers/specs/2026-08-20-level2-chicken-cow-chain-findings.md`
- Optionally modify: `Clay/Classes/Game/Other/Level.m` (temporary `NSLog`, remove later)

- [ ] **Step 1: Reproduce with overlays on**

Kick a chicken into a **row of cows**. Observe:

1. Flying hen box **stops overlapping** later cow boxes after first hit → trajectory / Y layout → Task **4B** (and maybe 4A).
2. Hen box **keeps overlapping** later cows while they stay up → aggressive test / flags → Task **4A** (inspect `testCollisionsForAggressive:Obstacles:` + `canAggressiveHit` / `hasBeenHit`).
3. Unclear / both → note **both**; do 4A then 4B as needed.

Optional temporary log inside `testCollisionsForAggressive:Obstacles:` when `[source getCollisionBehavior] == COLLISION_BEHAVIOR_HEN_KICKED`:

```objc
NSLog(@"henAggressive hit=%d pos=(%.1f,%.1f)",
      collision,
      [source getCCSprite].position.x,
      [source getCCSprite].position.y);
```

- [ ] **Step 2: Write findings file**

Include: device/OS, primary cause (`trajectory` | `rects` | `both`), one-sentence overlay evidence, which Task 4 path to take.

- [ ] **Step 3: Commit findings**

```bash
git add docs/superpowers/specs/2026-08-20-level2-chicken-cow-chain-findings.md
git commit -m "docs: record Level 2 chicken-cow chain diagnosis findings"
```

---

### Task 4A: Fix path — collision rects (only if findings say `rects` or `both`)

**Files:**
- Modify: `Clay/Classes/Game/Other/GameCollisionRect.m`
- Possibly inspect: `Clay/Plists/objects.plist` keys `hen` / `cow` (prefer code-side kicked-hen tweak over plist churn)

- [ ] **Step 1: Widen/shift only kicked-hen rects**

After building the base rect, if the object is a `GameObject` whose **current** behavior is `COLLISION_BEHAVIOR_HEN_KICKED`, expand slightly (tune from overlay):

```objc
if ([object isKindOfClass:[GameObject class]]) {
    GameObject *go = (GameObject *)object;
    if ([go getCurrentCollisionBehavior] == COLLISION_BEHAVIOR_HEN_KICKED
        || [go getCollisionBehavior] == COLLISION_BEHAVIOR_HEN_KICKED) {
        // Use whichever accessor actually reflects HEN_KICKED on airborne hens
        // (verify in GameObject.m: getCollisionBehavior vs getCurrentCollisionBehavior).
        rect.origin.x -= 8.0f;
        rect.size.width += 16.0f;
        rect.origin.y -= 8.0f;
        rect.size.height += 16.0f;
    }
}
```

**Important:** In this codebase, aggressive flight sets `_currentBehavior = COLLISION_BEHAVIOR_HEN_KICKED` inside `special_kickHen`. Confirm which getter `GameCollisionRectForObject` / aggressive tests should use before shipping the condition — prefer the same getter `testCollisionsForAggressive` already uses for the achievement branch (`getCollisionBehavior`).

Do **not** change static hen or player kick boxes here.

- [ ] **Step 2: Device-check a cow row** — one kicked hen fells **>1** cow with good timing.

- [ ] **Step 3: Commit**

```bash
git add Clay/Classes/Game/Other/GameCollisionRect.m
git commit -m "fix: enlarge kicked-hen collision rect for multi-cow hits on modern phones"
```

---

### Task 4B: Fix path — kick flight physics (only if findings say `trajectory` or `both`)

**Files:**
- Modify: `Clay/Classes/Game/GameObjects/GameObject.m` — `special_kickHen` and/or `updateCollisionBehavior:` case `COLLISION_BEHAVIOR_HEN_KICKED`

Current kick flight (`special_kickHen`):

```objc
float magnitude = 880.0f;
_angle = -20;
_vx = magnitude * cosf((_angle * 3.14159)/180.0f);
_vy = magnitude * sinf((_angle * 3.14159)/180.0f);
_currentBehavior = COLLISION_BEHAVIOR_HEN_KICKED;
```

While kicked (`updateCollisionBehavior:`):

```objc
case COLLISION_BEHAVIOR_HEN_KICKED:
case COLLISION_BEHAVIOR_HEN_DEAD:
    _angle += _rotationAmount * dt;
    [self getCCSprite].rotation = _angle;
    _vy += 500.0f * dt;
    break;
```

Position integrate in `update:`: `_x += _vx * dt; _y -= _vy * dt;`.

- [ ] **Step 1: Change one constant at a time** (magnitude, `-20` angle, or gravity `500.0f`) while watching overlay until the arc sweeps cow bodies across a typical row. Prefer gravity/angle over huge magnitude jumps.

If values must differ from iPad, gate with `![[GameSettings shared] isIpad]` only after confirming iPad still feels right.

- [ ] **Step 2: Confirm player→hen kick still feels OK** (foot projectile vs static hen).

- [ ] **Step 3: Device-check cow row again.**

- [ ] **Step 4: Commit**

```bash
git add Clay/Classes/Game/GameObjects/GameObject.m
git commit -m "fix: retune kicked-hen flight so cow rows chain on modern iPhone"
```

---

### Task 5: Full verification checklist

- [ ] Kick chicken: still connects; health restore still works  
- [ ] Single cow: still falls when hit by kicked hen  
- [ ] Cow **row**: one kicked hen can fell multiple cows with correct timing  
- [ ] Stone chicken: still not beneficial / still obstacle  
- [ ] No obvious player–cow regression  
- [ ] Spot-check iPad if available  

Amend findings doc if anything remains.

---

### Task 6: Disable debug overlay for normal builds

**Files:**
- Modify: `Clay/Classes/Scenes/GameLayer.m`
- Modify: `Clay/Classes/Game/Other/Level.m` (remove any temporary `NSLog`)

- [ ] **Step 1: Turn debug off**

```objc
#define DEBUG_DRAW_BOUNDING_BOXES 0
```

- [ ] **Step 2: Build; confirm no boxes in normal play**

- [ ] **Step 3: Commit**

```bash
git add Clay/Classes/Scenes/GameLayer.m Clay/Classes/Game/Other/Level.m
git commit -m "chore: disable collision debug overlay after chicken-cow fix"
```

---

### Task 7: Out of scope (do not do unless findings force it)

- Do **not** remove the `break` in `testCollisionsForAggressive:Obstacles:` (one hit per frame is original design).
- Do **not** retune `PlayerActionKick` foot boxes as the primary fix (kick→hen already OK).
- Do **not** “fix” the timed-mode achievement check that compares `COLLISION_BEHAVIOR_HEN_DEAD` while kick sets `HEN_KICKED` unless already touching that code — track separately.
- Do **not** letterbox the whole game to 480×320 for this fix.

---

## Self-review (plan vs spec)

| Spec requirement | Plan task |
|---|---|
| Phase A diagnosis via overlay | Tasks 1–3 |
| Sync overlay with gameplay rects | Task 2 |
| Targeted rect fix | Task 4A |
| Targeted trajectory fix | Task 4B |
| Keep per-frame single cow hit | Task 7 |
| Leave kick-chicken feel alone | Tasks 4A/4B + 5 |
| Debug off when done | Task 6 |
| Success = multi-cow chain on modern iPhone | Task 5 |

---

## Execution handoff

Plan saved to `docs/superpowers/plans/2026-08-20-level2-chicken-cow-chain.md`.

**Two execution options:**

1. **Subagent-Driven (recommended)** — fresh subagent per task, review between tasks  
2. **Inline Execution** — run tasks in this session with `executing-plans` and checkpoints  

Which approach?
