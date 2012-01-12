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

#define BOSS_FINAL_MAX_TRAIN_X 230.0f

#define TRAIN_OFFSCREEN_LEFT -600.0f
#define TRAIN_OFFSCREEN_RIGHT 1200.0f
#define TRAIN_BOMB_POSITION 250.0f
#define TRAIN_Y_POSITION 132.0f

@implementation BossFinal

-(void)startBoss
{
    _player = [[LayerManager sharedLayers] getPlayer];
    _resetSpriteVisibility = FALSE;
    _gameLayer = [[LayerManager sharedLayers] currentLayer];
    
    _queuedPhases = [[NSMutableArray alloc] initWithCapacity:10];
    
    _trainWheels = [Sprite spriteWithFile:@"blank.png" AddToLayer:NO];
    _trainJim = [Sprite spriteWithFile:@"blank.png" AddToLayer:NO];
    
    _speedModifier = 1.0f;
    _hasThrownBomb = false;
    
    _door = [Projectile projectileWithBehavior:PROJECTILE_BEHAVIOR_DARK_TRAIN_DOOR];
    [_door setBoundingBox:CGRectMake(20, 12, 14, 25)];
    [_door setActive:YES];
    
    _bomb = nil;
    
    _trainPosition = ccp(-800,165);
    [self updatePosition:_trainPosition];
    [self setVisible:YES];
}



-(void)addSpritesToLayer:(id)layer SpriteBatch:(CCSpriteBatchNode*)spriteBatch
{
    [layer addChild:[_trainWheels getCCSprite]];
    [[AnimationController sharedController] replaceSprite:_trainWheels withAnimationNamed:@"darkBossWheelAnim"];
    [layer addChild:[_trainJim getCCSprite]];
    [[AnimationController sharedController] replaceSprite:_trainJim withAnimationNamed:@"darkBossJimIdle1"];
}

-(NSMutableArray*)getProjectilesForDebugDraw
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:_door, nil];
    return array;
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
        case FINAL_BOSS_ATTACK_2B:
        case FINAL_BOSS_ATTACK_3B:
        case FINAL_BOSS_ATTACK_4C:
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
        case FINAL_BOSS_ATTACK_4B:
            [self triggerAction:FINAL_BOSS_ATTACK_4C];
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



-(void)moveForward:(float)dt
{
    if(_trainPhase == TRAIN_PHASE_BRAKE) {
        _speed -= 90.0f * dt;
        _speed = MAX(0.0f, _speed);
    }
    
    _trainPosition.x += _speed * _speedModifier * dt;        
    [_train setPosition:_trainPosition];
    
    CGPoint position = [_train getCCSprite].position;
    float dx = position.x - BOSS_FINAL_MAX_TRAIN_X;
    if (dx > 0) {
        _trainPosition.x -= dx;
        _speed -= 40.0f * dt;
    } else {
        _speed += 40.0f * dt;
        /*
        if(_speed > 350.0f) {
            _speed = 350.0f;
        }*/
    }
    [self updatePosition:_trainPosition];
    
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
                _trainPosition = ccp(TRAIN_OFFSCREEN_LEFT,TRAIN_Y_POSITION);
                _destinationX = TRAIN_BOMB_POSITION;
                _phase = phase;
                _inAttack = true;
            }
            break;
        case FINAL_BOSS_MOVE_TO_LEFT:
            if ([self canTrigger:FINAL_BOSS_MOVE_TO_LEFT]) {
                _destinationX = TRAIN_OFFSCREEN_LEFT;
                _phase = phase;  
                _inAttack = true;
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
                _trainPosition = ccp(TRAIN_OFFSCREEN_RIGHT,TRAIN_Y_POSITION);
                _destinationX = TRAIN_BOMB_POSITION;
                _phase = phase;
            }
            break;
        case FINAL_BOSS_ATTACK_1B:
            [self changeToAnimationNamed:@"darkBossJimDoorAttack1" forSprite:_trainJim];
            _trainPhase = TRAIN_PHASE_BRAKE;
            _inAttack = true;
            _waitToSwitch = 0.4f;
            _speed = 120.0f;
            _phase = phase;
            break;
        case FINAL_BOSS_ATTACK_1C:
            [self changeToAnimationNamed:@"darkBossJimDoorAttack2" forSprite:_trainJim];
            _waitToSwitch = 1.7f;
            _phase = phase;
            //[_door setActive:YES];
            break;
        case FINAL_BOSS_ATTACK_1D:
            [self changeToAnimationNamed:@"darkBossJimDoorAttack3" forSprite:_trainJim];
            _waitToSwitch = 0.4f;
            _trainPhase = TRAIN_PHASE_ACCELERATE;
            _phase = phase;
            //[_door setActive:NO];
            break;
        case FINAL_BOSS_ATTACK_1E:
            _destinationX = -600;
            _phase = phase;
            break;
            
            
        //bomb attack
        case FINAL_BOSS_ATTACK_2:
            if ([self canTrigger:FINAL_BOSS_ATTACK_2]) {
                [self changeToAnimationNamed:@"darkBossJimBombAttack1" forSprite:_trainJim];
                _waitToSwitch = 1.6f; 
                _hasThrownBomb = false;
                _phase = phase;
            }
            break;
        case FINAL_BOSS_ATTACK_2B:
            if (_bomb!=nil) {
                [_bomb release];
            }
            [self changeToAnimationNamed:@"darkBossJimBombAttack1Release" forSprite:_trainJim];
            _bomb = [Projectile projectileWithBehavior:PROJECTILE_BEHAVIOR_DARK_BOMB];
            
            CGPoint position = [[Camera sharedCamera] convertToWorldXY:CGPointMake(_trainPosition.x - 62.0f, _trainPosition.y + 40.0f)];
            [_bomb throwBombFromPosition:position];
            _waitToSwitch = 0.4f;
            _phase = phase;
            break;
            
            
        //grape attack
        case FINAL_BOSS_ATTACK_3:
            if ([self canTrigger:FINAL_BOSS_ATTACK_3]) {
                [self changeToAnimationNamed:@"darkBossJimGrapeAttack1Show" forSprite:_trainJim];
                _waitToSwitch = 1.6f; 
                _hasThrownBomb = false;
                _phase = phase;
            }
            break;
        case FINAL_BOSS_ATTACK_3B:
            [self changeToAnimationNamed:@"darkBossJimGrapeAttack2Eat" forSprite:_trainJim];
            _waitToSwitch = 0.6f;
            _phase = phase;
            break;
            
            
            
            
        //fake grapes bomb attack
        case FINAL_BOSS_ATTACK_4:
            if ([self canTrigger:FINAL_BOSS_ATTACK_4]) {
                [self changeToAnimationNamed:@"darkBossJimGrapeAttack1Show" forSprite:_trainJim];
                _waitToSwitch = 1.6f; 
                _hasThrownBomb = false;
                _phase = phase;
            }
            break;
        case FINAL_BOSS_ATTACK_4B:
            [self changeToAnimationNamed:@"darkBossJimGrapeAttack3Bomb" forSprite:_trainJim];
            _waitToSwitch = 0.4f;
            _phase = phase;            
            break;
        case FINAL_BOSS_ATTACK_4C:
            if (_bomb!=nil) {
                [_bomb release];
            }
            [self changeToAnimationNamed:@"darkBossJimBombAttack1Release" forSprite:_trainJim];
            _bomb = [Projectile projectileWithBehavior:PROJECTILE_BEHAVIOR_DARK_BOMB];
            [_bomb throwBombFromPosition:CGPointMake(_trainPosition.x - 62.0f, _trainPosition.y + 40.0f)];
            _waitToSwitch = 0.4f;
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
        phase = [[_queuedPhases objectAtIndex:0] intValue];
        [_queuedPhases removeObjectAtIndex:0];
        [self triggerAction:phase];
    }
}

-(void)update:(float)dt
{
    if (_resetSpriteVisibility) {
        [self resetSpriteVisibility];
    }
    switch (_phase) {
        case FINAL_BOSS_MOVE_TO_LEFT:
            if ([self moveLeft:dt]) {
                [self finishedPhase];
            }
            break;
        case FINAL_BOSS_MOVE_TO_BOMBING:
        case FINAL_BOSS_MOVE_TO_RIGHT:
            if([self moveRight:dt]) {
                [self finishedPhase];
            }
            break;
        case FINAL_BOSS_ATTACK_1B:
        case FINAL_BOSS_ATTACK_1C:
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
            
        default:
            break;
    }
    
    [_bomb update:dt * _speedModifier];
    
    [_door setPosition:CGPointMake(_trainPosition.x, _trainPosition.y - 50.0f)];
    
    [self updatePosition:_trainPosition];
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

-(void)updateBossEntrance:(float)dt
{
}






-(void)updatePosition:(CGPoint)position
{
    [_train setScreenPosition:position];
    [_trainWheels setScreenPosition:CGPointMake(position.x - 268.0f,position.y - 118.0f)];
    [_trainJim setScreenPosition:CGPointMake(position.x - 268.0f,position.y - 118.0f)];
    
}

-(void)changeToAnimationNamed:(NSString*)animName forSprite:(Sprite*)sprite
{
    [[AnimationController sharedController] replaceSprite:sprite withAnimationNamed:animName];
    [[sprite getAnimation] changeAnimationSpeed:_speedModifier];
}


-(void) reset
{
    _trainPosition = ccp(-1500,TRAIN_Y_POSITION);
    [self triggerAction:FINAL_BOSS_IDLE];
    //[self changeToAnimationNamed:@"darkBossJimIdle1" forSprite:_trainJim];
    _resetSpriteVisibility = true;
}

@end
