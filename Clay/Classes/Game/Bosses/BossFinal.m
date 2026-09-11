//
//  BossFinal.m
//  Clay
//
//  Created by Brian Cable on 1/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BossFinal.h"
#import "Sprite.h"
#import "Player.h"
#import "LayerManager.h"
#import "LevelManager.h"
#import "GameLayer.h"
#import "GameDebugLayer.h"
#import "Projectile.h"
#import "PassengerCar.h"
#import "PlayerAction.h"
#import "GameSettings.h"
#import "Camera.h"
#import "GameCollisionRect.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define MULTIPLIERX (IS_IPAD ? 2.133f : 1.0f)
#define MULTIPLIERY (IS_IPAD ? 2.4f : 1.0f)

#define TRAIN_OFFSCREEN_LEFT -600.0f
#define TRAIN_OFFSCREEN_LEFT_IPAD -900.0f
#define TRAIN_OFFSCREEN_RIGHT 1200.0f
#define TRAIN_BOMB_POSITION 230.0f
#define TRAIN_DOOR_POSITION 310.0f
#define TRAIN_Y_POSITION 132.0f

// How long the door sweep itself runs. 1B (open) and 1D (close) are locked to their 0.4s
// animations, so this is the only tunable part of the attack.
#define DOOR_ATTACK_SWEEP_SECONDS 0.4f

// GameCollisionRectForObject builds every box as (spritePosition - bbox.origin, bbox.size),
// and both the door and the player resolve to screen space, so the two can be lined up
// directly. The player stands at world 64*MULTIPLIERY and his plist bbox.y is a raw -10, so
// his collision box starts PLAYER_BOX_OFFSET_Y above his feet.
//
// The authored -95 (phone) / -15 (iPad) offsets below the train put the door box 130pt to
// 330pt BELOW that, where it could never touch him - the door attack landed no hits at all.
// The gap also grew with the camera letterbox, so it got worse on taller modern screens.
// Anchor the box bottom to the player's grounded box bottom instead. Adding the door's own
// bbox origin.y here cancels against the subtraction GameCollisionRectForObject does, so the
// net box bottom is exactly the player's box bottom - the round trip exists only so that
// retuning the door's bbox cannot silently move the anchor.
#define PLAYER_GROUNDED_WORLD_Y 64.0f
#define PLAYER_BOX_OFFSET_Y 10.0f

static CGFloat FinalBossDoorScreenY(Projectile *door)
{
    // Anchored to the player's grounded FEET, not to the bottom of his collision box. His
    // plist bbox.y is a raw -10, so his box starts PLAYER_BOX_OFFSET_Y above his feet; lining
    // the door up with that box put the sweep at shin height and left only 15pt of a 40pt
    // jump as clearance. Dropping it by that same offset keeps a solid 15pt overlap while he
    // is grounded and gives the jump 10pt more room - reported from play as "the hit box
    // needs to be slightly lower".
    CGFloat playerFeet =
        [[Camera sharedCamera] convertToScreenY:(PLAYER_GROUNDED_WORLD_Y * MULTIPLIERY)];
    return playerFeet + [door getBoundingBox].origin.y;
}

// The train's stage x values are screen-space and were authored against a 480-wide phone
// (230 is its centre) / 1024-wide iPad. The player is pinned near the left edge
// (player.plist cameraTracking x 75), so every extra point of a modern screen's width
// appears to his right - a literal 230 now parks the train on top of him instead of
// across from him, the same defect the Level 7 pass fixed in BossJimShip. Shift the stage
// by exactly the width beyond the authored size, leaving the per-device sprite offsets in
// updatePosition untouched. Exact no-op at 480 phone / 1024 iPad.
static CGFloat FinalBossStageX(CGFloat legacyStageX)
{
    CGFloat legacyWidth = IS_IPAD ? 1024.0f : 480.0f;
    CGFloat extraWidth = [[CCDirector sharedDirector] winSize].width - legacyWidth;
    if (extraWidth < 0.0f) { extraWidth = 0.0f; }
    return legacyStageX + extraWidth;
}

@implementation BossFinal

-(void)startBoss
{
    _player = [[LayerManager sharedLayers] getPlayer];
    _resetSpriteVisibility = FALSE;
    _gameLayer = [[LayerManager sharedLayers] currentLayer];
    
    _queuedPhases = [[NSMutableArray alloc] initWithCapacity:10];
    _phase = FINAL_BOSS_IDLE;
    
    _bombs = [[NSMutableArray alloc] initWithCapacity:6];
    _grapes = [[NSMutableArray alloc] initWithCapacity:6];

    _passengerCar = [PassengerCar instance];
    [_passengerCar setPosition:CGPointMake(-90.0f, 0.0f)];
    
    _replaceGrapeId = 0;
    _replaceBombId = 0;
    
    _isPlayingHorn = false;
    _isPlayingTrain = false;
    
    
    _trainWheels = [Sprite spriteWithFile:@"blank.png" AddToLayer:NO];
    _trainJim = [Sprite spriteWithFile:@"blank.png" AddToLayer:NO];
    
    _speedModifier = 1.0f;
    _hasThrownBomb = false;
    
    _waitUntilPlayerGetsBackUp = false;
    
    _door = [Projectile projectileWithBehavior:PROJECTILE_BEHAVIOR_DARK_TRAIN_DOOR];
    [_door setBoundingBox:CGRectMake(20 * MULTIPLIERX, 12, 14 * MULTIPLIERX, 25 * MULTIPLIERY)];
    [_door disable];
    
    _waitToPlayHorn = 0.5f;
    _waitToPlayTrainSound = 1.5f;
    
    for (int i=0; i<6; i++) {
        Projectile *bomb = [Projectile projectileWithBehavior:PROJECTILE_BEHAVIOR_DARK_BOMB];
        [_bombs addObject:bomb];
    }
    
    for (int i=0; i<6; i++) {
        Projectile *grape = [Projectile projectileWithBehavior:PROJECTILE_BEHAVIOR_DARK_GRAPES];
        [_grapes addObject:grape];
    }
    
    if ([[GameSettings shared] isIpad]) {
        _trainPosition = ccp(-1000,165);        
    } else {
        _trainPosition = ccp(-800,165);
    }
    [self updatePosition:_trainPosition];
    [self setVisible:YES];
}

-(void)throwBomb
{
    Projectile *bomb = [_bombs objectAtIndex:_replaceBombId];
    _replaceBombId = (_replaceBombId + 1) % 6;
    
    CGPoint position;
    if ([[GameSettings shared] isIpad]) {
        position = [[Camera sharedCamera] convertToWorldXY:CGPointMake(_trainPosition.x +  112.0f, _trainPosition.y + 260.0f)];
    } else {
        position = [[Camera sharedCamera] convertToWorldXY:CGPointMake(_trainPosition.x - 62.0f, _trainPosition.y + 40.0f)];        
    }
    [bomb reset];
    [bomb throwBombFromPosition:position];
    [[SoundEngine shared] playSound:@"bossFinalThrow"];
}

-(void)throwGrape
{
    Projectile *grape = [_grapes objectAtIndex:_replaceGrapeId];
    _replaceGrapeId = (_replaceGrapeId + 1) % 6;
    
    CGPoint position;
    if ([[GameSettings shared] isIpad]) {
        position = [[Camera sharedCamera] convertToWorldXY:CGPointMake(_trainPosition.x +  112.0f, _trainPosition.y + 260.0f)];
    } else {
        position = [[Camera sharedCamera] convertToWorldXY:CGPointMake(_trainPosition.x - 62.0f, _trainPosition.y + 40.0f)];        
    }
    
    [grape reset];
    [grape throwBombFromPosition:position];
    [[SoundEngine shared] playSound:@"bossFinalThrow"];
}


-(void)addSpritesToLayer:(id)layer SpriteBatch:(CCSpriteBatchNode*)spriteBatch
{
    [_passengerCar addToLayer:layer];
    [layer addChild:[_trainWheels getCCSprite]];
    [[AnimationController sharedController] replaceSprite:_trainWheels withAnimationNamed:@"darkBossWheelAnim"];
    [layer addChild:[_trainJim getCCSprite]];
    [[AnimationController sharedController] replaceSprite:_trainJim withAnimationNamed:@"darkBossJimIdle1"];

    for (Projectile *grape in _grapes) {
        [layer addChild:[grape getCCSprite]];
    }
    
    for (Projectile *bomb in _bombs) {
        [layer addChild:[bomb getCCSprite]];
    }

}

-(void)detonateBombs
{
    bool _shouldPlaySound = false;
    
    for (Projectile *bomb in _bombs) {
        if ([bomb getActive]) {
            [[_player getThirdAction] setKilledEnemy:YES];
            [bomb startCollision];
            _shouldPlaySound = true;
        }
    }
    
    if (_shouldPlaySound) {
        [[SoundEngine shared] playSound:@"bombExplosion"];
    }
}

-(NSMutableArray*)getProjectilesForDebugDraw
{
    NSMutableArray *objects = [[NSMutableArray alloc] initWithArray:_bombs];
    [objects addObjectsFromArray:_grapes];
    [objects addObject:_door];
    return objects;
}

-(void)changeAnimationSpeed:(float)modifier
{
    //[[_train getAnimation] changeAnimationSpeed:modifier];
    if (modifier < 1.0f) {
        _speedModifier = modifier; //for now, eventually modifier        
    } else {
        _speedModifier = 1.0f;
    }
    [[_trainWheels getAnimation] changeAnimationSpeed:modifier];
    [[_trainJim getAnimation] changeAnimationSpeed:modifier];
}


-(bool)checkWait:(float)dt
{
    bool returnVal = false;
    if (_waitToSwitch>0) {
        _waitToSwitch-=(dt * _speedModifier);
        if (_waitToSwitch<=0.0f) {
            returnVal = true;
        }
    }
    return returnVal;
}


-(void)finishedPhase
{
    switch (_phase) {
        case FINAL_BOSS_ATTACK_1:
            [self triggerAction:FINAL_BOSS_ATTACK_1B];
            break;
        case FINAL_BOSS_ATTACK_1B:
            [self triggerAction:FINAL_BOSS_ATTACK_1C];
            break;
        case FINAL_BOSS_ATTACK_1C:
            [self triggerAction:FINAL_BOSS_ATTACK_1D];
            break;
        case FINAL_BOSS_ATTACK_1D:
            [self triggerAction:FINAL_BOSS_ATTACK_1E];
            break;
        case FINAL_BOSS_ATTACK_1E:
        case FINAL_BOSS_ATTACK_2B:
        case FINAL_BOSS_ATTACK_3B:
        case FINAL_BOSS_ATTACK_4B:
            [self changeToAnimationNamed:@"darkBossJimIdle1" forSprite:_trainJim];
            [self triggerAction:FINAL_BOSS_IDLE];
            break;
        case FINAL_BOSS_ATTACK_2:
            [self triggerAction:FINAL_BOSS_ATTACK_2B];
            break;
        case FINAL_BOSS_ATTACK_3:
            [self triggerAction:FINAL_BOSS_ATTACK_3B];
            break;
        case FINAL_BOSS_ATTACK_4:
            [self triggerAction:FINAL_BOSS_ATTACK_4B];
            break;
        case FINAL_BOSS_MOVE_TO_BOMBING:
        case FINAL_BOSS_MOVE_TO_RIGHT:
        case FINAL_BOSS_MOVE_TO_LEFT:
            [self triggerAction:FINAL_BOSS_IDLE];
            break;
        default:
            break;
    }
}



-(void)resetSpriteVisibility
{
    [self setAlpha:1.0f];
    [self setVisible:YES];
    _resetSpriteVisibility = false;
}


-(void)setAlpha:(float)alpha
{
    [_train setAlpha:1.0f];
    [_trainWheels setAlpha:1.0f];
    [_trainJim setAlpha:1.0f];
}


-(void)setSprite:(Sprite *)sprite
{
    _train = sprite;
}


-(void)setVisible:(_Bool)isVisible
{
    [[_train getCCSprite] setVisible:isVisible];
    [[_trainWheels getCCSprite] setVisible:isVisible];
    [[_trainJim getCCSprite] setVisible:isVisible];
}


-(void)testCollisions:(Projectile*)projectile
{
    Level *level = [[LevelManager shared] currentLevel];
    if (projectile!=nil && [projectile getActive]) {
        if([level testCollisionWithGameObject:_player Source:projectile]) {
            [_player startCollision:PLAYER_EFFECT_COLLIDE Source:projectile];
            [projectile startCollision];
        }                    
    }
}


// Where the train must stop so the door's box lands on the player.
//
// This endpoint is NOT a stage position and must not go through FinalBossStageX: the station
// x values are anchored to the right edge, but the door sweep is a lunge *at the player*, who
// is pinned near the left. Right-anchoring it pushed the sweep 337pt clear of him on an
// 874-wide phone.
//
// The attack is a SWEEP PAST the player, not a park on top of him. The authored endpoints
// (50 on a 480 phone, -180 on a 1024 iPad) both finish just to his left, and the hit happens
// while the box crosses him on the way there. Centring the endpoint on him instead made the
// hit window the whole remaining phase - 0.56s on an 874-wide phone, 0.70s at the authored
// 480 - while a single jump only clears a 25-tall box for 0.33s. The attack was then
// impossible to jump no matter how it was timed. Ending past him puts the window back at the
// crossing: (player 32 + door 14) / rate, i.e. 0.14s at the authored rate.
//
// Derived from the live boxes rather than the two authored literals so it holds at any screen
// size; it reproduces them closely at both design sizes (49 vs 50 phone, -145 vs -180 iPad).
-(CGFloat)doorLungeDestinationX
{
    CGRect playerRect = GameCollisionRectForObject(_player);
    CGRect doorBox = [_door getBoundingBox];

    //invert what GameCollisionRectForObject does to the door, so its box's right edge
    //finishes clear of the player's left edge
    const CGFloat clearance = 12.0f * MULTIPLIERX;
    CGFloat doorScreenX = CGRectGetMinX(playerRect) - clearance
                          + doorBox.origin.x - doorBox.size.width;

    return doorScreenX - (IS_IPAD ? 250.0f : 0.0f);   //back out the sprite offset in update:
}

-(void)triggerAction:(FinalBossPhase)phase
{    
    
    switch (phase) {
            
        //come from left side of screen to bomb position
        case FINAL_BOSS_MOVE_TO_BOMBING:
            if([self canTrigger:FINAL_BOSS_MOVE_TO_BOMBING]) {
                // The two constants were swapped here: iPad snapped to the phone value
                // (-600), which is not enough clearance for a sprite drawn at
                // position.x + 280 in updatePosition, so the train popped into frame
                // mid-entrance; the phone started 300pt further out than intended and
                // arrived ~0.75s late at moveRight's 400pt/s. FINAL_BOSS_MOVE_TO_LEFT
                // below pairs them correctly and is the reference.
                if ([[GameSettings shared] isIpad]) {
                    _trainPosition = ccp(TRAIN_OFFSCREEN_LEFT_IPAD,TRAIN_Y_POSITION);
                } else {
                    _trainPosition = ccp(TRAIN_OFFSCREEN_LEFT,TRAIN_Y_POSITION);
                }
                _destinationX = FinalBossStageX(TRAIN_BOMB_POSITION);
                _phase = phase;
                _inAttack = true;
                _isOnScreen = true;
            }
            break;
        case FINAL_BOSS_MOVE_TO_LEFT:
            if ([self canTrigger:FINAL_BOSS_MOVE_TO_LEFT]) {
                if ([[GameSettings shared] isIpad]) {
                    _destinationX = TRAIN_OFFSCREEN_LEFT_IPAD;
                } else {
                    _destinationX = TRAIN_OFFSCREEN_LEFT;
                }
                _phase = phase;  
                _inAttack = true;
                _isOnScreen = false;
            }
            break;
        case FINAL_BOSS_MOVE_TO_RIGHT:
            if ([self canTrigger:FINAL_BOSS_MOVE_TO_RIGHT]) {
                _destinationX = FinalBossStageX(TRAIN_OFFSCREEN_RIGHT);
                _phase = phase;
                _inAttack = true;
            }
            break;
        
            
        //door attack
        case FINAL_BOSS_ATTACK_1:
            if ([self canTrigger:FINAL_BOSS_ATTACK_1]) {
                _destinationX = FinalBossStageX(TRAIN_DOOR_POSITION);
                _phase = phase;
                _inAttack = true;
            }
            break;
        case FINAL_BOSS_ATTACK_1B:
            [self changeToAnimationNamed:@"darkBossJimDoorAttack1" forSprite:_trainJim];
            _waitToSwitch = 0.4f;
            _phase = phase;
            break;
        case FINAL_BOSS_ATTACK_1C:
            [self changeToAnimationNamed:@"darkBossJimDoorAttack2" forSprite:_trainJim];
            _destinationX = [self doorLungeDestinationX];

            // The phase was a flat 1.4s: the sweep finished in about 0.84s and the train then
            // sat there with the box still live. Reported from play as the door "still
            // hitting Tim after he jumped over it" - the jump cleared the crossing, the box
            // parked a few points to his left, and it caught him again on the way down.
            //
            // The box now retires at the crossing (see update:), and the phase itself is cut
            // to DOOR_ATTACK_SWEEP_SECONDS so the train does not linger either. That takes
            // the whole door attack - 1B open, 1C sweep, 1D close - from 2.2s to 1.2s, the
            // one second the play-test asked for.
            //
            // The rate is sized to cover the distance in that window. The authored rate is
            // kept only as a lower bound - the shorter phase means the sweep is faster than
            // it shipped at every width, which is the point: the old one lingered. Where the
            // anti-skip cap below cannot cover the distance in time, the phase stretches to
            // match rather than leaving the door in transit when it ends.
            {
                CGFloat legacyRate = IS_IPAD ? 1.30f : 0.65f;
                CGFloat distance = _trainPosition.x - _destinationX;
                //moveLeft: covers 500pt per unit of its argument
                // Finish the sweep a little inside the phase. Sized to land exactly on the
                // phase boundary, the crossing fell on the final frame before 1D disabled the
                // box - a one-frame hit window. The trailing time costs nothing now that the
                // box retires as soon as it is past him.
                const CGFloat travelFraction = 0.85f;
                CGFloat travelTime = DOOR_ATTACK_SWEEP_SECONDS * travelFraction;
                CGFloat neededRate = (distance > 0.0f)
                    ? (distance / (travelTime * 500.0f)) : 0.0f;

                // A step longer than the combined width of the two boxes could skip the
                // player between frames and land no hit at all. Cap it so an overlapping
                // frame is guaranteed. No realistic screen width reaches this cap; it is here
                // so the invariant survives future retuning.
                CGRect playerRect = GameCollisionRectForObject(_player);
                CGFloat span = playerRect.size.width + [_door getBoundingBox].size.width;
                CGFloat maxRate = (span * 60.0f) / 500.0f;      //one span per frame at 60fps

                _doorLungeRate = MAX(legacyRate, MIN(neededRate, maxRate));
                _waitToSwitch = (_doorLungeRate > 0.0f)
                    ? MAX(DOOR_ATTACK_SWEEP_SECONDS, distance / (_doorLungeRate * 500.0f))
                    : DOOR_ATTACK_SWEEP_SECONDS;
            }
            _phase = phase;
            [_door reset];
            break;
        case FINAL_BOSS_ATTACK_1D:
            [self changeToAnimationNamed:@"darkBossJimDoorAttack3" forSprite:_trainJim];
            _waitToSwitch = 0.4f;
            _phase = phase;
            [_door disable];
            break;
        case FINAL_BOSS_ATTACK_1E:
            [self changeToAnimationNamed:@"darkBossJimIdle1" forSprite:_trainJim];
            _destinationX = FinalBossStageX(TRAIN_BOMB_POSITION);
            _phase = phase;
            break;
            
            
        //bomb attack
        case FINAL_BOSS_ATTACK_2:
            if ([self canTrigger:FINAL_BOSS_ATTACK_2]) {
                [self changeToAnimationNamed:@"darkBossJimBombAttack1" forSprite:_trainJim];
                _waitToSwitch = 0.2f; 
                _hasThrownBomb = false;
                _phase = phase;
                _inAttack = true;
            }
            break;
        case FINAL_BOSS_ATTACK_2B:
            [self changeToAnimationNamed:@"darkBossJimBombAttack1Release" forSprite:_trainJim];
            [self throwBomb];
            _waitToSwitch = 0.25f;
            _phase = phase;
            break;
            
            
        //grape attack
        case FINAL_BOSS_ATTACK_3:
            if ([self canTrigger:FINAL_BOSS_ATTACK_3]) {
                [self changeToAnimationNamed:@"darkBossJimGrapeAttack1Show" forSprite:_trainJim];
                _waitToSwitch = 0.6; 
                _hasThrownBomb = false;
                _phase = phase;
                _inAttack = true;
            }
            break;
        case FINAL_BOSS_ATTACK_3B:
            [self changeToAnimationNamed:@"darkBossJimGrapeAttack2Eat" forSprite:_trainJim];
            _waitToSwitch = 1.6f;
            _phase = phase;
            break;
            
            
        //grape attack
        case FINAL_BOSS_ATTACK_4:
            if ([self canTrigger:FINAL_BOSS_ATTACK_4]) {
                [self changeToAnimationNamed:@"darkBossJimGrapeAttack1Show" forSprite:_trainJim];
                _waitToSwitch = 0.2; 
                _hasThrownBomb = false;
                _phase = phase;
                _inAttack = true;
            }
            break;
        case FINAL_BOSS_ATTACK_4B:
            [self changeToAnimationNamed:@"darkBossJimBombAttack1Release" forSprite:_trainJim];
            [self throwGrape];
            _waitToSwitch = 0.25f;
            _phase = phase;
            break;
            
            
        case FINAL_BOSS_DIE:
            break;
        case FINAL_BOSS_IDLE:
            _inAttack = false;
            _phase = phase;
            [self changeToAnimationNamed:@"darkBossJimIdle1" forSprite:_trainJim];
            [self triggerNextPhase];
            break;
        default:
            break;
    }
}

-(bool)canTrigger:(FinalBossPhase)phase
{
    if (!_inAttack) {
        return true;
    } else {
        [_queuedPhases addObject:[NSNumber numberWithInt:phase]];
        return false;
    }
}

-(void)triggerNextPhase
{
    FinalBossPhase phase;
    
    if ([_queuedPhases count] > 0) {
        if (_player.isTripping) {
            _waitUntilPlayerGetsBackUp = true;
        } else {
            phase = [[_queuedPhases objectAtIndex:0] intValue];
            [_queuedPhases removeObjectAtIndex:0];
            [self triggerAction:phase];
        }
    }
}

-(void)update:(float)dt
{
    float rate;
    
    if (_resetSpriteVisibility) {
        [self resetSpriteVisibility];
    }
    switch (_phase) {
        case FINAL_BOSS_MOVE_TO_LEFT:
            
            rate = 1.0f * dt;
            if ([[GameSettings shared] isIpad]) {
                rate *= 2.0f;
            }
            
            if ([self moveLeft:rate]) {
                [self finishedPhase];
            }

            break;
        case FINAL_BOSS_ATTACK_1:
        case FINAL_BOSS_ATTACK_1E:
        case FINAL_BOSS_MOVE_TO_BOMBING:
        case FINAL_BOSS_MOVE_TO_RIGHT:
            rate = 1.0f * dt;
            if ([[GameSettings shared] isIpad]) {
                rate *= 2.0f;
            }
            
            if([self moveRight:rate]) {
                [self finishedPhase];
            }
            break;
        case FINAL_BOSS_ATTACK_1B:
        case FINAL_BOSS_ATTACK_1D:
        case FINAL_BOSS_ATTACK_2:
        case FINAL_BOSS_ATTACK_2B:
        case FINAL_BOSS_ATTACK_2C:
        case FINAL_BOSS_ATTACK_3:
        case FINAL_BOSS_ATTACK_3B:
        case FINAL_BOSS_ATTACK_3C:
        case FINAL_BOSS_ATTACK_4:
        case FINAL_BOSS_ATTACK_4B:
        case FINAL_BOSS_ATTACK_4C:
        case FINAL_BOSS_ATTACK_4D:
            if ([self checkWait:dt]) {
                [self finishedPhase];
            }
            break;
        case FINAL_BOSS_ATTACK_1C:
            if ([self checkWait:dt]) {
                [self finishedPhase];
            }
            [self moveLeft:_doorLungeRate * dt];
        default:
            break;
    }
    
    //if we have queued attacks and the player has tripped, wait until
    //he's gotten back up before triggering the next action
    if (_waitUntilPlayerGetsBackUp && !_player.isTripping) {
        [self triggerNextPhase];
        _waitUntilPlayerGetsBackUp = false;
    }
    
    // Horizontal alignment with the door art is authored and kept as-is; the vertical
    // placement is derived from the player's collision band. See FinalBossDoorScreenY.
    CGPoint doorScreen = CGPointMake(_trainPosition.x + (IS_IPAD ? 250.0f : 0.0f),
                                     FinalBossDoorScreenY(_door));
    [_door setPosition:[[Camera sharedCamera] convertToWorldXY:doorScreen]];
    if ([_door getActive]) {
        // The hit IS the crossing. Once the sweep has carried the box past him there is
        // nothing left to strike with, and leaving it live is what let the box catch him a
        // second time: it finishes a few points to his left, and the player's screen x drifts
        // back as the camera converges, sliding his box onto a door that was still armed.
        if (CGRectGetMaxX(GameCollisionRectForObject(_door))
            < CGRectGetMinX(GameCollisionRectForObject(_player))) {
            [_door disable];
        } else {
            [self testCollisions:_door];
        }
    }
    
    [self updatePosition:_trainPosition];
    [_passengerCar updatePosition:_trainPosition];
    
    for (Projectile *bomb in _bombs) {
        [bomb update:dt];
        if (bomb.vy <= 0) {
            [self testCollisions:bomb];            
        }
    }
    
    for (Projectile *grape in _grapes) {
        [grape update:dt];
        [self testCollisions:grape];
    }
    
    
    if (_isOnScreen) {
        if (!_isPlayingTrain) {
            _isPlayingHorn = false;
            _waitToPlayHorn = 500.0f;
            _isPlayingTrain = true;
            _waitToPlayTrainSound = 0.0f;
        }
    } else {
        if (!_isPlayingHorn) {
            _isPlayingHorn = true;
            _waitToPlayHorn = 0.0f;
            _isPlayingTrain = false;
            _waitToPlayTrainSound = 500.0f;
        }
    }
    
    
    [self updateHorn:dt];
    [self updateTrainSound:dt];
}


-(bool)moveRight:(float)dt
{
    bool returnVal = false;
    
    _trainPosition.x += 400.0f * dt * _speedModifier;
    if (_trainPosition.x >= _destinationX) {
        _trainPosition.x = _destinationX;
        returnVal = true;
    }
    
    return returnVal;
}

-(bool)moveLeft:(float)dt
{
    bool returnVal = false;
    
    _trainPosition.x -= 500.0f * dt * _speedModifier;
    if (_trainPosition.x <= _destinationX) {
        _trainPosition.x = _destinationX;
        returnVal = true;
    }    
    
    return returnVal;
}



-(void)updatePosition:(CGPoint)position
{
    if ([[GameSettings shared] isIpad]) {
        [_train setScreenPosition:CGPointMake(position.x + 280.0f, position.y + 189.0f)];
        [_trainWheels setScreenPosition:CGPointMake(position.x - 257.0f,position.y - 43.0f)];
        [_trainJim setScreenPosition:CGPointMake(position.x - 257.0f,position.y - 48.0f)];   
    } else {
        [_train setScreenPosition:position];
        [_trainWheels setScreenPosition:CGPointMake(position.x - 268.0f,position.y - 118.0f)];
        [_trainJim setScreenPosition:CGPointMake(position.x - 268.0f,position.y - 118.0f)];
    }
}

-(void)changeToAnimationNamed:(NSString*)animName forSprite:(Sprite*)sprite
{
    [[AnimationController sharedController] replaceSprite:sprite withAnimationNamed:animName];
    [[sprite getAnimation] changeAnimationSpeed:_speedModifier];
}

-(void)updateHorn:(float)dt
{
    if (_isPlayingHorn) {
        _waitToPlayHorn-=dt;
        if (_waitToPlayHorn<=0.0f) {
            _hornSoundId = [[SoundEngine shared] playSoundGetId:@"bossFinalHorn"];
            _waitToPlayHorn = rand()%2 + 7;
        }
    }
}

-(void)updateTrainSound:(float)dt
{
    if (_isPlayingTrain) {
        _waitToPlayTrainSound -= dt;
        if (_waitToPlayTrainSound <= 0.0f) {
            _trainSoundId = [[SoundEngine shared] playSoundGetId:@"bossFinalTrain"];
            _waitToPlayTrainSound = 9.1f;
        }
    }
}

-(void)stopHornSound
{
    [[SoundEngine shared] stopSound:_hornSoundId];
    _waitToPlayHorn = 0.1f;
}

-(void)stopTrainSound
{
    [[SoundEngine shared] stopSound:_trainSoundId];
    _waitToPlayTrainSound = 0.1f;
}

-(void) reset
{
    if ([[GameSettings shared] isIpad]) {
        _trainPosition = ccp(-1800,TRAIN_Y_POSITION);        
    } else {
        _trainPosition = ccp(-1500,TRAIN_Y_POSITION);
    }
    _inAttack = false;
    [self updatePosition:_trainPosition];
    [_queuedPhases removeAllObjects];
    [self changeToAnimationNamed:@"darkBossJimIdle1" forSprite:_trainJim];
    [self triggerAction:FINAL_BOSS_IDLE];
    _resetSpriteVisibility = true;
    
    for (Projectile *bomb in _bombs) {
        [[bomb getCCSprite] setVisible:NO];
        [bomb setActive:NO];
    }
    
    for (Projectile *grape in _grapes) {
        [[grape getCCSprite] setVisible:NO];
        [grape setActive:NO];
    }
    
    [_door disable];
    _waitUntilPlayerGetsBackUp = false;
    _isOnScreen = false;
    //[self stopTrainSound];
    //[self stopHornSound];
}

-(void)restartLevel
{
    [self reset];
    [self triggerAction:FINAL_BOSS_IDLE];
    if([[GameSettings shared] isIpad]) {
        _trainPosition = ccp(-1800,165);        
    } else {
        _trainPosition = ccp(-1600,165);
    }
    [[_train getCCSprite] setVisible:YES];
}

-(void)dealloc
{
    [self stopHornSound];
    [self stopTrainSound];
    
    [_trainJim release];
    [_trainWheels release];
    
    for (Projectile *bomb in _bombs) {
        [bomb release];
        bomb = nil;
    }
    [_bombs release];
    
    for (Projectile *grape in _grapes) {
        [grape release];
        grape = nil;
    }
    [_grapes release];
    
    [_queuedPhases removeAllObjects];
    [_queuedPhases release];
    
    [_passengerCar release];
    
    [super dealloc];
}

@end
