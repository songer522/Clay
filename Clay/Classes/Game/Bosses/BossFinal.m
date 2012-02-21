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

#define BOSS_FINAL_MAX_TRAIN_X 230.0f

#define TRAIN_OFFSCREEN_LEFT -600.0f
#define TRAIN_OFFSCREEN_LEFT_IPAD -900.0f
#define TRAIN_OFFSCREEN_RIGHT 1200.0f
#define TRAIN_BOMB_POSITION 230.0f
#define TRAIN_DOOR_POSITION 310.0f
#define TRAIN_Y_POSITION 132.0f

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
    [_door setBoundingBox:CGRectMake(20, 12, 14, 25)];
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


-(void)triggerAction:(FinalBossPhase)phase
{    
    
    switch (phase) {
            
        //come from left side of screen to bomb position
        case FINAL_BOSS_MOVE_TO_BOMBING:
            if([self canTrigger:FINAL_BOSS_MOVE_TO_BOMBING]) {
                if ([[GameSettings shared] isIpad]) {
                    _trainPosition = ccp(TRAIN_OFFSCREEN_LEFT,TRAIN_Y_POSITION);
                } else {
                    _trainPosition = ccp(TRAIN_OFFSCREEN_LEFT_IPAD,TRAIN_Y_POSITION);
                }
                _destinationX = TRAIN_BOMB_POSITION;
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
                _destinationX = TRAIN_OFFSCREEN_RIGHT;
                _phase = phase;
                _inAttack = true;
            }
            break;
        
            
        //door attack
        case FINAL_BOSS_ATTACK_1:
            if ([self canTrigger:FINAL_BOSS_ATTACK_1]) {
                _destinationX = TRAIN_DOOR_POSITION;
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
            _waitToSwitch = 1.4f;
            if ([[GameSettings shared] isIpad]) {
                _destinationX = -180.0f;
            } else {
                _destinationX = 50.0f;
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
            _destinationX = TRAIN_BOMB_POSITION;
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
            if ([[GameSettings shared] isIpad]) {
                [self moveLeft:1.30f * dt];
            } else {
                [self moveLeft:0.65f * dt];
            }
        default:
            break;
    }
    
    //if we have queued attacks and the player has tripped, wait until
    //he's gotten back up before triggering the next action
    if (_waitUntilPlayerGetsBackUp && !_player.isTripping) {
        [self triggerNextPhase];
        _waitUntilPlayerGetsBackUp = false;
    }
    
    CGPoint position = [[Camera sharedCamera] convertToWorldXY:_trainPosition];
    if ([[GameSettings shared] isIpad]) {
        [_door setPosition:ccp(position.x + 250.0f , position.y - 15.0f)];        
    } else {
        [_door setPosition:ccp(position.x, position.y - 95.0f)];        
    }
    if ([_door getActive]) {
        [self testCollisions:_door];        
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
