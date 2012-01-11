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
#import "Projectile.h"

#define BOSS_FINAL_MAX_TRAIN_X 230.0f

@implementation BossFinal

-(void)startBoss
{
    _player = [[LayerManager sharedLayers] getPlayer];
    _resetSpriteVisibility = FALSE;
    _gameLayer = [[LayerManager sharedLayers] currentLayer];
    
    _trainWheels = [Sprite spriteWithFile:@"blank.png" AddToLayer:NO];
    _trainJim = [Sprite spriteWithFile:@"blank.png" AddToLayer:NO];
    
    _speedModifier = 1.0f;
    _hasThrownBomb = false;
    
    _door = [Projectile projectileWithBehavior:PROJECTILE_BEHAVIOR_DARK_TRAIN_DOOR];
    [_door setBoundingBox:CGRectMake(20, 12, 14, 25)];
    
    _bomb = nil;
    
    [self setVisible:NO];
}

-(void)setSprite:(Sprite *)sprite
{
    _train = sprite;
}


-(void)triggerAction:(FinalBossPhase)phase
{    
    
    switch (phase) {
            
        //door attack
        case FINAL_BOSS_ATTACK_1:
            if (!_inAttack) {
                [[AnimationController sharedController] replaceSprite:_trainJim withAnimationNamed:@"darkBossJimDoorAttack1"];
                _trainPhase = TRAIN_PHASE_BRAKE;
                _inAttack = true;
                _waitToSwitch = 0.4f;
                _speed = 120.0f;
                _phase = phase;
            }
            break;
        case FINAL_BOSS_ATTACK_1B:
            [[AnimationController sharedController] replaceSprite:_trainJim withAnimationNamed:@"darkBossJimDoorAttack2"];
            _waitToSwitch = 1.7f;
            _phase = phase;
            break;
        case FINAL_BOSS_ATTACK_1C:
            [[AnimationController sharedController] replaceSprite:_trainJim withAnimationNamed:@"darkBossJimDoorAttack3"];
            _waitToSwitch = 0.4f;
            _trainPhase = TRAIN_PHASE_ACCELERATE;
            _phase = phase;
            break;
            
            
        //bomb attack
        case FINAL_BOSS_ATTACK_2:
            if (!_inAttack) {
                [[AnimationController sharedController] replaceSprite:_trainJim withAnimationNamed:@"darkBossJimBombAttack1"];
                _waitToSwitch = 1.6f; 
                _hasThrownBomb = false;
                _phase = phase;
            }
            break;
        case FINAL_BOSS_ATTACK_2B:
            if (_bomb!=nil) {
                [_bomb release];
            }
            [[AnimationController sharedController] replaceSprite:_trainJim withAnimationNamed:@"darkBossJimBombAttack1Release"];
            _bomb = [Projectile projectileWithBehavior:PROJECTILE_BEHAVIOR_DARK_BOMB];
            [_bomb throwBombFromPosition:CGPointMake(_trainPosition.x - 62.0f, _trainPosition.y + 40.0f)];
            _waitToSwitch = 0.4f;
            _phase = phase;
            break;
            
            
        //grape attack
        case FINAL_BOSS_ATTACK_3:
            if (!_inAttack) {
                [[AnimationController sharedController] replaceSprite:_trainJim withAnimationNamed:@"darkBossJimGrapeAttack1Show"];
                _waitToSwitch = 1.6f; 
                _hasThrownBomb = false;
                _phase = phase;
            }
            break;
        case FINAL_BOSS_ATTACK_3B:
            [[AnimationController sharedController] replaceSprite:_trainJim withAnimationNamed:@"darkBossJimGrapeAttack2Eat"];
            _waitToSwitch = 0.6f;
            _phase = phase;
            break;
            
            
        //fake grapes bomb attack
        case FINAL_BOSS_ATTACK_4:
            if (!_inAttack) {
                [[AnimationController sharedController] replaceSprite:_trainJim withAnimationNamed:@"darkBossJimGrapeAttack1Show"];
                _waitToSwitch = 1.6f; 
                _hasThrownBomb = false;
                _phase = phase;
            }
            break;
        case FINAL_BOSS_ATTACK_4B:
            [[AnimationController sharedController] replaceSprite:_trainJim withAnimationNamed:@"darkBossJimGrapeAttack3Bomb"];
            _waitToSwitch = 0.4f;
            _phase = phase;            
            break;
        case FINAL_BOSS_ATTACK_4C:
            if (_bomb!=nil) {
                [_bomb release];
            }
            [[AnimationController sharedController] replaceSprite:_trainJim withAnimationNamed:@"darkBossJimBombAttack1Release"];
            _bomb = [Projectile projectileWithBehavior:PROJECTILE_BEHAVIOR_DARK_BOMB];
            [_bomb throwBombFromPosition:CGPointMake(_trainPosition.x - 62.0f, _trainPosition.y + 40.0f)];
            _waitToSwitch = 0.4f;
            _phase = phase;
            break;
            
            
        //others
        case FINAL_BOSS_ENTER:
            _trainPosition = CGPointMake(_player.x - 900,165); //230,135
            [self updatePosition:_trainPosition];
            [self setVisible:YES];
            _trainPhase = TRAIN_PHASE_ACCELERATE;
            _speed = 200.0f;
            _inAttack = false;
            _phase = phase;
            break;
        case FINAL_BOSS_DIE:
            break;
        case FINAL_BOSS_IDLE:
            _trainPhase = TRAIN_PHASE_ACCELERATE;
            
            //in case it's moving too slow when finished, speed it back up again
            if (_speed < 250.0f) {
                _speed = 250.0f;                
            }
            _inAttack = false;
            _phase = phase;

            break;
        default:
            break;
    }
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
            [[AnimationController sharedController] replaceSprite:_trainJim withAnimationNamed:@"darkBossJimIdle1"];
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
        default:
            break;
    }
}

-(bool)checkWait:(float)dt
{
    bool returnVal = false;
    if (_waitToSwitch>0) {
        _waitToSwitch-=dt;
        if (_waitToSwitch<=0.0f) {
            returnVal = true;
        }
    }
    return returnVal;
}

-(void)update:(float)dt
{
    if (_resetSpriteVisibility) {
        [self resetSpriteVisibility];
    }
    
    switch (_phase) {
        case FINAL_BOSS_ATTACK_1:
        case FINAL_BOSS_ATTACK_1B:
        case FINAL_BOSS_ATTACK_1C:
        case FINAL_BOSS_ATTACK_2:
        case FINAL_BOSS_ATTACK_2B:
        case FINAL_BOSS_ATTACK_3:
        case FINAL_BOSS_ATTACK_3B:
        case FINAL_BOSS_ATTACK_4:
        case FINAL_BOSS_ATTACK_4B:
        case FINAL_BOSS_ATTACK_4C:
            if ([self checkWait:dt]) {
                [self finishedPhase];
            }
            break;
        case FINAL_BOSS_ENTER:
            [self updateBossEntrance:dt];
            break;
            
        default:
            break;
    }
    
    [_bomb update:dt];
    
    [self moveForward:dt];
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

-(void)updateBossEntrance:(float)dt
{
}

-(void)setVisible:(_Bool)isVisible
{
    [[_train getCCSprite] setVisible:isVisible];
    [[_trainWheels getCCSprite] setVisible:isVisible];
    [[_trainJim getCCSprite] setVisible:isVisible];
}

-(void)setAlpha:(float)alpha
{
    [_train setAlpha:1.0f];
    [_trainWheels setAlpha:1.0f];
    [_trainJim setAlpha:1.0f];
}

-(void)changeAnimationSpeed:(float)modifier
{
    //[[_train getAnimation] changeAnimationSpeed:modifier];
    if (modifier < 1.0f) {
        _speedModifier = 0.5f * modifier;        
    } else {
        _speedModifier = 1.0f;
    }
    [[_trainWheels getAnimation] changeAnimationSpeed:modifier];
}

-(void)addSpritesToLayer:(id)layer SpriteBatch:(CCSpriteBatchNode*)spriteBatch
{
    [layer addChild:[_trainWheels getCCSprite]];
    [[AnimationController sharedController] replaceSprite:_trainWheels withAnimationNamed:@"darkBossWheelAnim"];
    [layer addChild:[_trainJim getCCSprite]];
    [[AnimationController sharedController] replaceSprite:_trainJim withAnimationNamed:@"darkBossJimIdle1"];
}

-(void)updatePosition:(CGPoint)position
{
    [_train setPosition:position];
    [_trainWheels setPosition:CGPointMake(position.x - 268.0f,position.y - 118.0f)];
    [_trainJim setPosition:CGPointMake(position.x - 268.0f,position.y - 118.0f)];
    
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

-(void) reset
{
    [self triggerAction:FINAL_BOSS_ENTER];
    [[AnimationController sharedController] replaceSprite:_trainJim withAnimationNamed:@"darkBossJimIdle1"];
    _resetSpriteVisibility = true;
}

@end
