# Level 3 Town Run Collision + Feel Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restore Level 3 rolling-hay / mud / small-hay collisions on modern iPhone **and** iPad, then lightly retune crow and rolling-hay chase feel for widescreen without abandoning the original rhythm.

**Architecture:** Keep `GameCollisionRectForObject` as the single AABB source for gameplay + debug draw. Identify Level 3 props by stable `objectType` (plist key). Fix rolling-hay baseline bbox in `objects.plist`, then raise/enlarge rects for all screen sizes (no `!IS_IPAD` gate). Feel pass scales chase distance/speed with `winWidth/480` only for Level 3 flyer/rolling behaviors.

**Tech Stack:** Objective-C, legacy cocos2d, Xcode; verify with `DEBUG_DRAW_BOUNDING_BOXES` on device/simulator (iPhone + iPad).

**Spec:** `docs/superpowers/specs/2026-08-21-level3-collision-feel-design.md`

---

## File map

| File | Responsibility |
|---|---|
| `Clay/Classes/Game/GameObjects/GameObject.h` + `.m` | Store `objectType`; Level 3 chase feel scaling for `FLYER` / `ROLLING_HAYBALE` |
| `Clay/Classes/Game/Other/GameObjectController.m` | Set `objectType` from plist key when loading |
| `Clay/Classes/Game/Other/GameCollisionRect.m` | Dual-platform rect lifts for `leafpile` / `haybaleSmall` / `haybaleRolling` |
| `Clay/Plists/objects.plist` | Lower `haybaleRolling.boundingBox.y` from 130 |
| `Clay/Classes/GameConfig.h` | Confirm debug boxes on for Debug builds (already) |
| `docs/superpowers/specs/2026-08-21-level3-collision-feel-findings.md` (**new**) | Phase A notes + final rect/feel values |

No XCTest target in this repo. Verification = **overlay + iPhone + iPad playthrough**. Do not add a test target unless extracting a pure helper later.

**Starting numeric guesses** (iterate with overlay; replace in findings when locked):

| Prop | Baseline change | Rect adjust (both platforms) |
|---|---|---|
| `haybaleRolling` | `boundingBox.y`: `130` → `40` | after plist: if still low, `origin.y += 36*MULTIPLIERY`, `height += 20*MULTIPLIERY` |
| `leafpile` | none required first | `origin.y += 40*MULTIPLIERY`, `height += 22*MULTIPLIERY`, modest width pad like sandpit |
| `haybaleSmall` | none required first | `origin.y += 40*MULTIPLIERY`, `height += 18*MULTIPLIERY` |

Use the same `MULTIPLIERX` / `MULTIPLIERY` defines as `GameObjectController` (`1` phone, `2.133` / `2.4` iPad).

---

### Task 1: Record Phase A diagnosis

**Files:**
- Create: `docs/superpowers/specs/2026-08-21-level3-collision-feel-findings.md`

- [ ] **Step 1: Write findings stub from existing screenshots**

```markdown
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
```

- [ ] **Step 2: Commit**

```bash
git add docs/superpowers/specs/2026-08-21-level3-collision-feel-findings.md \
        docs/superpowers/specs/2026-08-21-level3-collision-feel-design.md
git commit -m "docs: Level 3 collision/feel design and findings stub"
```

---

### Task 2: Tag GameObjects with stable `objectType`

**Why:** `leafpile` / hay use `blank.png` + animations; sandpit-style frame-name matching will not work. Spec requires stable identity.

**Files:**
- Modify: `Clay/Classes/Game/GameObjects/GameObject.h`
- Modify: `Clay/Classes/Game/GameObjects/GameObject.m`
- Modify: `Clay/Classes/Game/Other/GameObjectController.m`

- [ ] **Step 1: Add property**

In `GameObject.h` ivars + property:

```objc
NSString *_objectType;

@property(nonatomic, copy) NSString *objectType;
```

In `GameObject.m` `@synthesize objectType = _objectType;`, init `_objectType = nil;`, and in `dealloc`:

```objc
[_objectType release];
```

- [ ] **Step 2: Set type at load**

In `GameObjectController.m` `initializeGameObject:Name:AddToLayer:`, after settings lookup succeeds:

```objc
gameObject.objectType = objectName;
```

- [ ] **Step 3: Build** (Xcode). Confirm no warnings on the new property.

- [ ] **Step 4: Commit**

```bash
git add Clay/Classes/Game/GameObjects/GameObject.h \
        Clay/Classes/Game/GameObjects/GameObject.m \
        Clay/Classes/Game/Other/GameObjectController.m
git commit -m "feat: tag GameObjects with plist objectType for collision matching"
```

---

### Task 3: Fix rolling-hay baseline bbox in plist

**Files:**
- Modify: `Clay/Plists/objects.plist` (`haybaleRolling` → `boundingBox` → `y`)

- [ ] **Step 1: Change y from 130 to 40**

Under `haybaleRolling` / `boundingBox`:

```xml
<key>y</key>
<integer>40</integer>
```

(Keep width/height/x as-is for this step.)

- [ ] **Step 2: Commit**

```bash
git add Clay/Plists/objects.plist
git commit -m "fix: lower rolling-hay collision bbox y for Level 3"
```

---

### Task 4: Dual-platform Level 3 rects in `GameCollisionRect`

**Files:**
- Modify: `Clay/Classes/Game/Other/GameCollisionRect.m`
- Modify: `docs/superpowers/specs/2026-08-21-level3-collision-feel-findings.md`

- [ ] **Step 1: Add MULTIPLIER defines and Level 3 branch**

At top of `GameCollisionRect.m` (alongside existing `IS_IPAD`):

```objc
#define MULTIPLIERX (IS_IPAD ? 2.133f : 1.0f)
#define MULTIPLIERY (IS_IPAD ? 2.4f : 1.0f)
```

After the existing hen-kicked expansion block (still before `return rect`), add a **separate** block that runs on **both** phone and pad (do **not** wrap in `!IS_IPAD`):

```objc
if ([object isKindOfClass:[GameObject class]]) {
    GameObject *gameObject = (GameObject *)object;
    NSString *type = gameObject.objectType;

    if ([type isEqualToString:@"leafpile"]) {
        // Mud slow-pad: raise into path foot band (both iPhone and iPad).
        rect.origin.x -= 12.0f * MULTIPLIERX;
        rect.size.width += 24.0f * MULTIPLIERX;
        rect.origin.y += 40.0f * MULTIPLIERY;
        rect.size.height += 22.0f * MULTIPLIERY;
    } else if ([type isEqualToString:@"haybaleSmall"]) {
        rect.origin.y += 40.0f * MULTIPLIERY;
        rect.size.height += 18.0f * MULTIPLIERY;
        rect.origin.x -= 6.0f * MULTIPLIERX;
        rect.size.width += 12.0f * MULTIPLIERX;
    } else if ([type isEqualToString:@"haybaleRolling"]
               || [gameObject getCurrentCollisionBehavior] == COLLISION_BEHAVIOR_ROLLING_HAYBALE) {
        rect.origin.y += 36.0f * MULTIPLIERY;
        rect.size.height += 20.0f * MULTIPLIERY;
        rect.origin.x -= 8.0f * MULTIPLIERX;
        rect.size.width += 16.0f * MULTIPLIERX;
    }
}
```

Import nothing extra if `GameObject.h` / `Collidable.h` already expose behavior enums (add `#import "GameObject.h"` if not already present — it is).

- [ ] **Step 2: Run Level 3 on iPhone (Debug build, boxes on)**

Confirm green boxes sit on the mud / small hay / rolling hay visuals and pink overlaps while running. If still low/high, nudge the `origin.y` / `height` constants by ~8pt steps and retest. Update findings table with final numbers.

- [ ] **Step 3: Run Level 3 on iPad (or iPad simulator)**

Same checklist. If pad multipliers overshoot, prefer adjusting `MULTIPLIERY` usage (e.g. slightly smaller lift) rather than introducing `!IS_IPAD`. Record final values in findings.

- [ ] **Step 4: Functional check**

- Mud → slow  
- Small hay → collide / fall  
- Rolling hay → collide when chasing across path  

- [ ] **Step 5: Commit**

```bash
git add Clay/Classes/Game/Other/GameCollisionRect.m \
        docs/superpowers/specs/2026-08-21-level3-collision-feel-findings.md
git commit -m "fix: align Level 3 hay/mud collision rects on iPhone and iPad"
```

---

### Task 5: Widescreen feel — crow + rolling hay chase

**Files:**
- Modify: `Clay/Classes/Game/GameObjects/GameObject.m` (Level 3 update cases ~737–742)
- Modify: `docs/superpowers/specs/2026-08-21-level3-collision-feel-findings.md`

- [ ] **Step 1: Scale chase distance and speed by width**

Replace the Level 3 cases:

```objc
case COLLISION_BEHAVIOR_ROLLING_HAYBALE:
{
    CGFloat widthScale = [[CCDirector sharedDirector] winSize].width / 480.0f;
    if (widthScale < 1.0f) { widthScale = 1.0f; }
    [self chaseAtDistance:GAME_OBJECT_DISTANCE_ONSCREEN * widthScale
             DefaultSpeed:0.0f
               ChaseSpeed:-150.0f * widthScale
               ChaseSound:@"townRollingHayAppear"];
    break;
}
case COLLISION_BEHAVIOR_FLYER:
{
    CGFloat widthScale = [[CCDirector sharedDirector] winSize].width / 480.0f;
    if (widthScale < 1.0f) { widthScale = 1.0f; }
    [self chaseAtDistance:GAME_OBJECT_DISTANCE_ONSCREEN * widthScale
             DefaultSpeed:0.0f
               ChaseSpeed:-250.0f * widthScale
               ChaseSound:@"crowAppears"];
    break;
}
```

Ensure `CCDirector` header is already imported transitively; if not, `#import "cocos2d.h"` / existing director include.

**Note:** `FLYER` / `ROLLING_HAYBALE` appear Level 3–specific in this codebase; if a later audit finds shared use, gate with `[objectType isEqualToString:@"crow"]` / `haybaleRolling` instead.

- [ ] **Step 2: Playtest feel on iPhone and iPad**

- Crow: readable telegraph; dodge without mandatory double-jump cheese; not spawn-on-face  
- Rolling hay: chase readable, not instantly unfair on wide phones  
- If crow **height** is wrong (not just timing), adjust `crow` `offsety` in `objects.plist` (currently `140`) in small steps (±10) with overlay — document in findings  

- [ ] **Step 3: Spot-check hurdles + tall `haybale`**

If tall hay / hurdles green boxes are also in the corn with no collision, either fold a minimal `haybale` / hurdle lift into `GameCollisionRect` (same dual-platform style) or file as follow-up in findings — do not expand into a full Level 3 rebalance.

- [ ] **Step 4: Commit**

```bash
git add Clay/Classes/Game/GameObjects/GameObject.m \
        Clay/Plists/objects.plist \
        docs/superpowers/specs/2026-08-21-level3-collision-feel-findings.md
git commit -m "fix: scale Level 3 crow and rolling-hay chase for widescreen"
```

---

### Task 6: Dual-device verification checklist + findings finalize

**Files:**
- Modify: `docs/superpowers/specs/2026-08-21-level3-collision-feel-findings.md`

- [ ] **Step 1: Run full checklist**

- [ ] iPhone: rolling hay, mud, small hay collide; green boxes aligned  
- [ ] iPad: same  
- [ ] Crow dodge/hit timing acceptable on both  
- [ ] Rolling-hay chase not extreme on either  
- [ ] Hurdles / tall haybale: no new obvious miss or unfair hit  
- [ ] Woo / achievements untouched (no intentional edits)

- [ ] **Step 2: Finalize findings** with locked constants and any leftover backlog.

- [ ] **Step 3: Commit**

```bash
git add docs/superpowers/specs/2026-08-21-level3-collision-feel-findings.md
git commit -m "docs: record Level 3 collision and feel verification results"
```

---

## Plan self-review

1. **Spec coverage:** Dual-device goal, three props, no `!IS_IPAD`, plist rolling y, feel pass, findings, checklist — each maps to a task. Woo/achievements explicitly untouched.  
2. **Placeholders:** Starting numbers are concrete; findings file is where finals are recorded after overlay. No TBD steps.  
3. **Types:** `objectType` string keys match plist (`leafpile`, `haybaleSmall`, `haybaleRolling`); behaviors `COLLISION_BEHAVIOR_ROLLING_HAYBALE` / `FLYER` match `Collidable.h`.

---

## Execution handoff

Plan complete and saved to `docs/superpowers/plans/2026-08-21-level3-collision-feel.md`. Two execution options:

**1. Subagent-Driven (recommended)** — fresh subagent per task, review between tasks  

**2. Inline Execution** — run tasks in this session with executing-plans checkpoints  

Which approach?
