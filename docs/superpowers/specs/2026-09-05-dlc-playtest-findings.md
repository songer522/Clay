# DLC interactive playtest — 2026-09-05

**Playtest result: not ready for sign-off.** Dojo Run crashed during normal punch/jump play on both a modern iPhone and iPad. Three additional visual/gameplay issues were observed. No production fixes were made during the investigation itself.

**Status after the follow-up fix pass (2026-09-05, same day).** Both P1 findings and the P2 hint overflow are fixed and re-tested; the P2 iPad layout finding is only partly fixed. Each carries a note below. Sign-off is still outstanding: the fixes address the reported defects, but end-to-end completion of either DLC map — finish trigger, medal award and saved completion — remains unverified, exactly as it was after the original pass, and the black band below the iPad world is unchanged (only the controls stranded in it were moved). See the revised completion notes at the end.

## Scope and method

Tested the two shipped DLC levels: **Training Run (12, pump)** and **Dojo Run (13, punch)**, reached through **Play → Timed Mode → DLC**. Both DLC maps ship only in `timed/normal`; there are no additional DLC difficulty variants to test.

| Simulator | OS | Landscape viewport (points) | Training | Dojo |
|---|---|---|---|---|
| iPhone SE, 3rd generation | iOS 26.2 | 667 × 375 | Interactive obstacle/health/checkpoint testing; see completion notes below | Repeated punch/jump play, ledges, knives, ninjas, death and retry |
| iPhone 17 Pro | iOS 27.0 | 874 × 402 | Pump, jump, sprint, pause/resume, menu return; repeated retries | **Crash**, reproduced with Zombies enabled |
| iPad Pro 13-inch, M5 | iOS 27.0 | 1376 × 1032 | Pump/jump, obstacles, pause/resume and menu return | **Same crash**; knife placement and framing defects |

Built the `Clay` Debug scheme for the simulator. Used a temporary standalone XCTest driver to inject real coordinate taps and presses and capture screenshots. Reviewed the live screens and adjusted the inputs. The existing debug unlock flags grant DLC access; purchase/restore transactions were not exercised.

A later compact-phone Training pass used temporary read-only telemetry (player position, health, obstacle positions) to time XCTest inputs more accurately. This did **not** change movement, collision, health, map data, checkpoints, or end triggers. The telemetry source edit was restored immediately after building. Test tooling, full screenshots, video and crash reports are under the ignored `build/dlc-ui*` and `build/dlc-evidence/` directories.

This was simulator functional testing, not physical-device performance, audio, thermal, or touch ergonomics certification. Timing measurements across simultaneously running simulators are not performance benchmarks.

## P1 — Dojo punch reads a deallocated animation action and crashes

**Observed on iPhone 17 Pro and iPad Pro 13-inch.** Enter Dojo, repeatedly punch approaching ninjas, and interleave jump/held-jump inputs. The app terminates while updating the punch hitbox. The first phone occurrence followed a Training run and a menu transition to Dojo; a fresh direct Dojo launch also reproduced it with Zombies enabled.

Evidence:

- Original phone crash: `Clay-2026-09-05-135336.ips` (captured 13:53:30 local time).
- Phone diagnostic reproduction: `Clay-2026-09-05-140038.ips`.
- Independent iPad crash: `Clay-2026-09-05-140056.ips`.
- Zombies diagnostic at 14:00:35: `-[CCXAnimate getCurrentFrame]: message sent to deallocated instance`.

Common application stack:

```text
Animation.m:140             -[Animation getCurrentFrameNumber]
PlayerActionPunch.m:115      -[PlayerActionPunch updateBoundingBox]
PlayerActionPunch.m:64       -[PlayerActionPunch update:]
Player.m:762                 -[Player update:Level:]
GameLayer.m:322              -[GameLayer updateLogic:]
```

`Animation.useAnimationToReplaceSprite:` stores an autoreleased `CCXAnimate` in `_animateAction`; its action wrapper owns the running action. The stored pointer is subsequently queried by punch. The Zombie run establishes that the referenced action has already been freed. `@try/@catch` in `Animation` and `PlayerActionPunch` does not make that dangling pointer safe or catch an `EXC_BAD_ACCESS`.

**Fix direction:** correct animation-action ownership/lifetime and invalidate stale frame readers when actions finish or are replaced. Check shared `Animation` instances and transitions as part of the fix; simply adding another exception handler will not address this crash. Regression-test repeated punch, jump, collision, death/retry and animation replacement on phone and tablet.

Full reports/log: `build/dlc-evidence/phone-dojo-crash.ips`, `Clay-2026-09-05-140038.ips`, `Clay-2026-09-05-140056.ips`, and `phone-repro-stderr.log`.

**Fixed** (`76db046b`). The diagnosis above was confirmed at the source. `Animation` stored `_animateAction`, `_speedAction` and `_anim` as *unretained* pointers to autoreleased cocos2d objects; their only owner was the sprite's action manager, via the repeat wrapper. Punch is a one-shot `CCRepeat times:1`, so when it completed the action manager stopped and released it, freeing the `CCXAnimate` while `PlayerActionPunch` kept reading it for the rest of `_duration`. `stopAllActions` from an interleaved jump frees it the same way. Because `Animation` instances are cached singletons shared by every sprite, this was never DLC-specific.

The fix retains what `Animation` stores and releases the previous ones, and resets `CCXAnimate`'s frame to `-1` in `startWithTarget:` and `stop`, so a finished or stopped action reports "no frame" instead of a stale one — `PlayerActionPunch` then takes its `default:` case and deactivates the hitbox. Both `CCRepeat` and `CCRepeatForeverWithSpeed` forward `stop` to the inner action, and the latter restarts and steps within one tick, so looping animations see no transient `-1`. The `@try/@catch` from `08bc2750` was removed: it could never have caught this, as a freed object is `EXC_BAD_ACCESS`, not an ObjC exception.

Re-tested on iPhone 17 Pro with `-NSZombieEnabled YES`: roughly 190 punches with interleaved jumps, plus a pause/resume cycle. No zombie messages and no new crash reports, against three in the original pass. The punch hitbox was confirmed still firing (both player and punch boxes visible mid-swing), so the deactivation path did not simply disable punching. Level 9 was smoke-tested separately because `Animation` is shared game-wide.

## P1 — Dojo knives land below the iPad floor

**Observed on iPad; phone comparison captured.** After a throwing knife lands, its collision box sits in the dark structure under the floor rather than on the running surface. The knife is not readable as the ground obstacle shown on the phone.

- [iPad knife collision box below the floor](assets/2026-09-05-dlc-playtest/ipad-dojo-knife.png)
- [Compact iPhone knife on the floor](assets/2026-09-05-dlc-playtest/compact-dojo-knife.png)

`GameObject.m:1398–1413`, `COLLISION_BEHAVIOR_DART_MOVING`, stops every dart at `_y = 95.0f`, with no iPad scaling. The player's ground baseline is `64 * MULTIPLIERY` (153.6 on iPad), so the same 95-point knife baseline lands below the iPad ground. The initial dart offsets are also fixed phone values (`+720`, `+286`).

**Fix direction:** align the landing height and throw path with the device-scaled world geometry, then verify sprite and collision-box alignment together. This changes obstacle readability and collision behavior, not just decoration.

**Fixed** (`5c47b1ef`). The landing height, the launch offset and the throw accelerations now scale with the world (`MULTIPLIERX`/`MULTIPLIERY`), so the parabola keeps its authored shape instead of stretching over a 2.4x taller fall. This matches the fireball-rock fix immediately above it in the same switch, which had the same class of defect. Phone multipliers are 1, so phone behaviour is arithmetically unchanged.

Re-tested on iPad Pro 13-inch: the knife now comes to rest on the tatami with its collision box sharing the player's ground baseline, where before the box floated in the dark understructure with no sprite on the running surface.

## P2 — Phone pause hints overflow their panel

**Observed in both DLC levels, on compact and wide phones.** Pause Training or Dojo. The hint's second/third lines extend below the blue background and over the level artwork. Long global hints reproduce the same issue.

- [Wide phone Training hint](assets/2026-09-05-dlc-playtest/phone-training-hint.png)
- [Compact phone Dojo hint](assets/2026-09-05-dlc-playtest/compact-dojo-hint.png)
- [Compact phone long global hint](assets/2026-09-05-dlc-playtest/compact-training-hint.png)

The corresponding iPad Training hint fits inside its panel. `HintBox.m:43–63` gives the text a fixed `250 × 100` phone layout at 22-point font size, independent of the panel's actual interior height, and places it below the panel center. It also anchors the entire hint to legacy x coordinates, so it remains left of center on a wide phone.

**Fix direction:** size the panel from wrapped text or fit the text to the panel's interior; anchor the group to the live viewport. Check all rotating hints, not only the first DLC hint.

**Fixed** (`5c47b1ef`). Measuring the panel art first was necessary: it is only **288.5 x 54.5** on a phone, which holds about two lines at the authored 22pt, while most hints wrap to three or four. A first attempt that only fitted text to that interior drove the font to an unreadable 11pt, so the final fix does both — the text block is sized from the panel, one font size is shared across the whole rotation so the text does not jump between hints, and the panel grows downward (top edge fixed, so the HINT tab stays attached) only once the readable 16pt floor is reached. The iPad panel already fits every hint at 22pt, so it keeps its current appearance and is never scaled.

The group now anchors to `winSize/2` rather than the legacy `x = 240`, which reproduces the authored position exactly at 480 and centres on modern screens.

Re-tested on iPhone 17 Pro (874 x 402) and iPhone SE 3rd generation (667 x 375), stepping through the rotation rather than only the first hint. The longest global hint — the 85-character sprint hint, which needed 107pt at 22pt — wraps to three lines fully inside the panel on both.

## P2 — Large iPad gameplay leaves a large black band below the world

**Observed in both DLC levels on the 13-inch iPad.** The artwork ends at about y = 768 in a 1032-point-high viewport, leaving roughly 264 points (26% of the height) black. Jump, action and sprint buttons sit at the bottom of that band, detached from the running surface. They remain tappable, but the layout wastes a substantial part of the screen.

- [Training on large iPad](assets/2026-09-05-dlc-playtest/ipad-training-layout.png)
- [Dojo on large iPad](assets/2026-09-05-dlc-playtest/ipad-dojo-layout.png)

`HudButton.m` uses a fixed iPad button Y of `30 * 2.4`, while the level/camera framing retains the authored playfield height. The HUD and world therefore use different vertical extents. The issue may affect non-DLC maps too; this pass establishes it for both DLC maps.

**Fix direction:** make an explicit choice between a consistently letterboxed playfield/HUD and viewport-filling artwork/framing. Avoid stretching only one layer or moving controls without checking jump visibility and collision alignment.

**Partly fixed** (`5c47b1ef`), and the framing of this finding needs correcting. The choice had in fact already been made in the codebase: the iPad playfield is anchored to the top of the viewport, and both `Player.m`'s `ModernIpadGameplayVerticalOffset()` and `HudLayer.m`'s `HudLayerIpadVerticalOffset()` already offset by the full extra height using the same formula. `HudButtonY` simply never got the same treatment, which is why the pause button and timer sat correctly on the artwork while the jump/action/sprint buttons did not. Applying the same offset moves them from `y = 72` to `y = 336` on a 1376 x 1032 iPad, back onto the running surface (world bottom edge = 264). Hitboxes derive from the position, so touch targets followed; the jump touch rect already spanned the full height and is unaffected.

**The black band itself is unchanged.** Only the stranded controls were moved. Eliminating the band means reframing the world or its camera, which would touch collision alignment on every level, not just the DLC maps — that remains an open call, and is the part of this finding still outstanding.

Verified numerically rather than visually: the available iPad simulator letterboxes the app into portrait instead of running true landscape, so a screenshot would not have represented the reported configuration. A temporary probe logged `winSize=1376.0x1032.0 legacyY=72.0 offset=264.0 finalY=336.0` in place, the 264 matching the band width measured independently during the original pass. The probe was removed afterwards.

## Debug-only observations

- The existing `-startLevel` shortcut initially puts the HUD behind the game world. [Example](assets/2026-09-05-dlc-playtest/debug-shortcut-hud.png). Normal menu/comic entry displays the HUD correctly, so this is **not** reported as a normal DLC entry failure. The scene adds the `GameLayer` after its initialization has already added/reset the HUD at the same z order.
- The collision overlay also draws over introductory comic panels. This is debug presentation, not release gameplay evidence.
- Unsigned simulator logs report Game Center entitlement/service errors. They were not treated as DLC-specific failures.

## Completion notes

Both levels were exercised interactively on all three viewport sizes. **These were not six successful full clears.**

- The compact-phone Training pass crossed the first two real checkpoint triggers (world x = 10,176 and 16,160), and reached approximately x = 21,503 of the finish trigger at 38,176. Its telemetry records actual deaths and checkpoint recovery. The third checkpoint, finish screen, medal award and saved completion remain unverified.
- Wide-phone Training included more than seven minutes on the game timer with pump/jump/sprint, pauses, menu return and repeated retries. iPad Training included more than three minutes and the same interaction/layout checks. Elapsed time is not a claim of map completion.
- Dojo included several minutes of repeated punch/jump/ledge/knife/ninja interaction on compact phone and iPad. Sustained runs crashed on the wide phone and iPad. The compact phone was not observed to clear the finish trigger either. Dojo's completion screen, medals and saved completion remain unverified.
- Main menu → timed DLC selection → both intro comics → gameplay, pause/resume and return to DLC selection were exercised. The supplied Debug build unlocks purchases, so real payment and restore flows remain out of scope.

No production code, content or balance changes remained from the investigation itself; the report and selected evidence images were its only repository additions. Full touch-driver logs and local evidence are retained under the ignored `build/` directories.

The follow-up fix pass then made the production changes recorded above, in `76db046b` and `5c47b1ef`, touching `Animation`, `CCXAnimate`, `GameObject` (dart behaviour only), `HintBox` and `HudButton`. Both temporary probes used during that pass were removed and the tree verified clean; the restored sources build successfully and the test-only simulators were shut down.

**What still blocks sign-off.** The crash no longer reproduces, so the original blocker is cleared, but the completion gaps above are unchanged: neither DLC map has been driven to its finish trigger, and the completion screen, medal award and saved completion remain unverified on every viewport. The iPad black band is still present. Real purchase and restore flows remain out of scope. A sign-off pass should now attempt end-to-end clears of both maps, which the crash previously prevented.
