# Track Lapse (Clay)

An endless-runner-style iOS platformer originally built on cocos2d-iphone, now
modernized to build and run on current iOS SDKs. The Xcode project and sources
still use the original code name **Clay**; the shipping app name is
**Track Lapse** (`CFBundleDisplayName`).

You run through themed levels — Track Run, Barn Run, Town Run, Disco Run, City
Run, Undead Run, Computer Run, Volcano Run — dodging and interacting with
obstacles, chaining reactions (kicked hens into cows, rolling hay, zombies),
and racing the clock for bronze/silver/gold medals. Levels are separated by
comic-panel cutscenes, and some levels feature boss encounters.

Note that boss encounters are driven by objects placed in the TMX maps, not by the
`boss` key in `levels.plist` — that key is present on level 6 but is read by nothing.
Of levels 1–8, only **level 7** has a boss (`jimSpaceShip` → `Bosses/BossJimShip.m`);
the remaining boss code (`BossFinal`, `BossFinalJim`) belongs to level 11.

## Requirements

- Xcode with an iOS 18.6 SDK or newer
- macOS
- iPhone or iPad (Simulator or device); the app target is universal
  (`TARGETED_DEVICE_FAMILY = 1,2`) and runs in landscape

Build settings of note:

| Setting | Value |
| --- | --- |
| Scheme / target | `Clay` |
| Bundle id | `com.yang.clay` |
| App target deployment target | iOS 18.6 |
| Project-level deployment target | iOS 12.0 |
| Version | 1.0.1 |

## Build and run

Open the project in Xcode:

```sh
open Clay.xcodeproj
```

Select the `Clay` scheme, pick a simulator or device, and run.

From the command line:

```sh
# Build for the simulator
xcodebuild -project Clay.xcodeproj -scheme Clay \
  -destination 'platform=iOS Simulator,name=iPhone 16' build
```

There is no package manager step — all third-party code is vendored in-tree
under `Clay/libs` and `Clay/src`.

## Debug switches

Both live in `Clay/Classes/GameConfig.h` and default to on for `DEBUG` builds:

- `DEBUG_DRAW_BOUNDING_BOXES` — draws the collision / hit-box overlay
  (`GameDebugLayer`). This is the primary tool for diagnosing collision bugs:
  green boxes are obstacles, pink is the player.
- `DEBUG_UNLOCK_EVERYTHING` — unlocks all modes, timed levels, and DLC IAP
  flags.

Override either by defining it to `0` in a prefix header or build setting.

## Project layout

```
Clay.xcodeproj/          Xcode project
Clay/
  Classes/
    Base/                Engine-side building blocks: animation, camera,
                         collision, input, map/TMX loading, plist loading,
                         sound, particles, save data
    Scenes/              App lifecycle (AppDelegate, SceneDelegate) and every
                         screen: main menu, choose mode/level, HUD, game layer,
                         comics, pause, credits, end-of-level
    Game/
      GameObjects/       GameObject + factory, obstacles (chicken, zombie,
                         static), region management
      PlayerActions/     Player move/jump/kick/etc. actions
      Bosses/            Boss encounters and combo attacks
      Effects/           Lasers, lightning, rain, water level effects
      GUI/               In-game widgets: buttons, windows, labels, health
      Other/             Level manager, save points, best times, projectiles,
                         IAP helpers
    Cocos2D-Extensions/  Video player and clipping-node additions
  Plists/                Data-driven game content (see below)
  Resources/             Art, audio, comics, particles, level art, Info.plist
  libs/                  Vendored cocos2d 1.0.1, CocosDenshion, FontLabel,
                         TouchJSON, cocoslive
  src/                   Vendored Facebook iOS SDK + SBJSON
  scripts/               Python/shell content tooling (new level and animation
                         scaffolding, sound/music conversion, level fixups)
Resources/levels/        Source TMX tile maps (real_level_1_hd … _7_hd)
docs/superpowers/        Design docs, plans, and findings per work item
build/                   Build output (git-ignored)
```

## Data-driven content

Most gameplay content is authored as plists in `Clay/Plists` rather than in
code:

- `levels.plist` — per-level definition: TMX file, tile layer list, obstacle
  layer, music track, pre/post comic, third action button (`kick`, `woo`, …),
  next level, player Y offset
- `objects.plist` — obstacle definitions; the entry name becomes the object's
  `objectType` at spawn, and each entry's `boundingBox` feeds the collision AABB
- `player.plist`, `anims.plist`, `skins.plist` — player, animation, and skin
  data
- `medals.plist` — bronze/silver/gold time thresholds per level, per mode
  (`normal`, `hard`, `timed`)
- `comics.plist`, `hints.plist`, `credits.plist`, `music.plist`,
  `sounds.plist`, `memory.plist`, `settings.plist`

Levels themselves are Tiled (`.tmx`) maps in `Resources/levels`, loaded through
`MapLayer` / `PListLoader`.

## Modernization notes

The project began as a 2011 cocos2d-iphone game and has been brought forward:

- Scene-based UIKit life cycle — window and view controller setup lives in
  `SceneDelegate`; `AppDelegate` still exposes `.window` / `.viewController`
  because older screens reach for them through the application delegate.
- Layout and gameplay constants that were authored for 480×320 have been
  retuned for modern iPhone and iPad aspect ratios (collision rects, obstacle
  chase speeds, jump windows), generally by scaling against `winWidth`.
- Collision AABBs are built by a shared helper, `GameCollisionRectForObject`
  (`Clay/Classes/Game/Other/GameCollisionRect.m`) so the debug overlay and
  gameplay always agree on the same rect.

Legacy collision fixes per level are documented in `docs/superpowers`, with a
design / plan / findings trio for each investigation (Level 2 chicken–cow
chain, Level 3 collision + feel).

## Third-party code and licenses

Vendored libraries ship with their original licenses:

- cocos2d-iphone 1.0.1 — `Clay/libs/LICENSE_cocos2d.txt`
- CocosDenshion — `Clay/libs/LICENSE_CocosDenshion.txt`
- FontLabel — `Clay/libs/LICENSE_FontLabel.txt`
- TouchJSON — `Clay/libs/LICENSE_TouchJSON.txt`

Original game code is © Xecudev, LLC.
