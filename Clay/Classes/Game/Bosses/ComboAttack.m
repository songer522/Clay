//
//  ComboAttack.m
//  Clay
//
//  Created by Brian Cable on 1/4/12.
//  Copyright (c) 2012 Xecudev, LLC. All rights reserved.
//

#import "ComboAttack.h"
#import "Sprite.h"
#import "AnimationController.h"

@implementation ComboAttack

+(id)comboAttackWithId:(int)comboId
{
    return [[self alloc] initWithId:comboId];
}

-(id)initWithId:(int)comboId
{
    if ((self=[super init])) {
        _sprite = [Sprite spriteWithFile:@"blank.png"];
        [[_sprite getCCSprite] setVisible:NO];
        
        [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"computerComboAttackAnim"];
        
        _comboId = comboId;
        
        switch (comboId) {
            case 0:
                _initialPosition = ccp(0,-20);
                _attackPosition = ccp(400,250);
                _endAttackPosition = ccp(-50,-100);
                _waitToAttack = 0.25f;
                break;
            case 1:
                _initialPosition = ccp(-8,-30);
                _attackPosition = ccp(420,120);
                _endAttackPosition = ccp(-200,120);
                _waitToAttack = 1.5f;
                break;
            case 2:
                _initialPosition = ccp(8,-30);
                _attackPosition = ccp(420,80);
                _endAttackPosition = ccp(-200,80);
                _waitToAttack = 2.75f;
                break;
            default:
                break;
        }
        
        _isActive = false;
        
    }
    return self;    
}

-(void)startAttack
{
    [self switchToPhase:COMBO_FIRST_APPEAR];
}

-(void)startCollision
{
    
}

-(void)switchToPhase:(ComboPhase)phase
{
    _phase = phase;
    
    switch (_phase) {
        case COMBO_FIRST_APPEAR:
            _alpha = 0.0f;
            [_sprite setScreenPosition:_initialPosition];
            [[_sprite getCCSprite] setVisible:YES];
            [_sprite setAlpha:_alpha];
            break;
        case COMBO_MOVETO_ATTACK:
            _target = _attackPosition;
            break;
        case COMBO_WAIT_TO_ATTACK:
            _waitToAttack = _comboId * 1.25f + 0.25f;
            break;
        case COMBO_ATTACK:
            _target = _endAttackPosition;
            break;
        case COMBO_IDLE:
            [[_sprite getCCSprite] setVisible:NO];
            break;
        default:
            break;
    }
}

-(void)finishedPhase
{
    switch (_phase) {
        case COMBO_FIRST_APPEAR:
            [self switchToPhase:COMBO_MOVETO_ATTACK];
            break;
        case COMBO_MOVETO_ATTACK:
            [self switchToPhase:COMBO_WAIT_TO_ATTACK];
            break;
        case COMBO_WAIT_TO_ATTACK:
            [self switchToPhase:COMBO_ATTACK];
            break;
        case COMBO_ATTACK:
            [self switchToPhase:COMBO_IDLE];
            break;
        default:
            break;
    }
}

-(void)update:(float)dt
{
    switch (_phase) {
        case COMBO_FIRST_APPEAR:
            _alpha += 5.0f * dt;
            if (_alpha >= 1.0f) {
                _alpha = 1.0f;
                [self finishedPhase];
            }
            [_sprite setAlpha:_alpha];
            break;
        case COMBO_MOVETO_ATTACK:
        case COMBO_ATTACK:
            if([self moveWithEasing:dt]) {
                [self finishedPhase];
            }
            break;
        case COMBO_WAIT_TO_ATTACK:
            _waitToAttack -= dt;
            if (_waitToAttack<=0.0f) {
                [self finishedPhase];
            }
            break;
        default:
            break;
    }
}

// damping is in the range 0..1, with a typical value of 0.1 (which means 90% correction in one second)
// Source: http://forums.create.msdn.com/forums/p/15365/80653.aspx#80653
-(bool)moveWithEasing:(float)dt
{
    bool _atTarget = false;
    
    float damping = 0.1f;
    float px = _position.x;
    float py = _position.y;
    float tx = _target.x;
    float ty = _target.y;
    
    _position.x = tx + (tx - px) * (float)pow(damping, dt);
    _position.y = ty + (ty - py) * (float)pow(damping, dt);    
    
    if (_position.x == tx && _position.y == ty) {
        _atTarget = true;
    }
    
    [_sprite setScreenPosition:_position];
    
    return _atTarget;
}


-(CGRect)getBoundingBox
{
    return _boundingBox;
}

-(void)setBoundingBox:(CGRect)boundingBox
{
    _boundingBox = boundingBox;
}

-(CGPoint)getPosition
{
    return _position;
}

-(bool)getActive
{
    return _isActive;
}

-(void)reset
{
    _isActive = false;
}

-(bool)getAggressive
{
    return false;
}

-(bool)hasBeenHit
{
    return false;
}

-(CollisionBehavior)getCollisionBehavior
{
    return COLLISION_BEHAVIOR_NONE;
}

-(CCSprite*)getCCSprite
{
    return [_sprite getCCSprite];
}

-(void)setActive:(bool)active
{
    _isActive = active;
}

-(void)dealloc
{
    [_sprite release];
    [super dealloc];
}

@end
