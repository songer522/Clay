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

+(id)comboAttackWithId:(int)comboId Ship:(Sprite*)ship
{
    return [[self alloc] initWithId:comboId Ship:ship];
}

-(id)initWithId:(int)comboId Ship:(Sprite*)ship
{
    if ((self=[super init])) {
        _sprite = [Sprite spriteWithFile:@"blank.png"];
        [[_sprite getCCSprite] setVisible:NO];
        
        [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"computerComboAttackAnim"];
        
        _bossShip = ship;
        _comboId = comboId;
        
        switch (comboId) {
            case 0:
                _initialPosition = ccp(18,-70);
                _attackPosition = ccp(420,35);
                _endAttackPosition = ccp(-200,35);
                break;
            case 1:
                _initialPosition = ccp(-18,-70);
                _attackPosition = ccp(420,65);
                _endAttackPosition = ccp(-200,65);
                break;
            case 2:
                _initialPosition = ccp(0,-45);
                _attackPosition = ccp(380,220);
                _endAttackPosition = ccp(-150,0);
                break;
            default:
                break;
        }
        
        _isActive = false;
        [self switchToPhase:COMBO_IDLE];
        [self setBoundingBox:CGRectMake(12,12,24,24)];
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
    
    CGPoint shipPos = [_bossShip getScreenPosition];
    
    switch (_phase) {
        case COMBO_FIRST_APPEAR:
            _alpha = 0.0f;
            _position.x = shipPos.x + _initialPosition.x;
            _position.y = shipPos.y + _initialPosition.y;
            [_sprite setScreenPosition:_position];
            [[_sprite getCCSprite] setVisible:YES];
            [_sprite setAlpha:_alpha];
            _isActive = true;
            break;
        case COMBO_MOVETO_ATTACK:
            _target = _attackPosition;
            break;
        case COMBO_WAIT_TO_ATTACK:
            _waitToAttack = _comboId * 0.95f + 0.25f;
            if (_comboId == 2) {
                _waitToAttack += 0.25f;
            }
            break;
        case COMBO_ATTACK:
            _target = _endAttackPosition;
            break;
        case COMBO_IDLE:
            _isActive = false;
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
            _alpha += 1.5f * dt;
            if (_alpha >= 1.0f) {
                _alpha = 1.0f;
                [self finishedPhase];
            }
            [_sprite setAlpha:_alpha];
            break;
        case COMBO_MOVETO_ATTACK:
            if([self moveWithEasing:dt Magnitude:15.0f]) {
                [self finishedPhase];
            }
            break;
        case COMBO_ATTACK:
            if([self moveWithEasing:dt Magnitude:1.4f]) {
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

-(bool)moveWithEasing:(float)dt Magnitude:(float)magnitude
{
    bool _atTarget = false;
 
    float dx = (_target.x - _position.x);
    float dy = (_target.y - _position.y);
    float distance = sqrtf(dx*dx + dy*dy);

    float finalMagnitude = distance * magnitude * dt;
    
    if (distance > 0.1f) {
        _position.x += (finalMagnitude * (dx/distance));
        _position.y += (finalMagnitude * (dy/distance));
    } else {
        _position = _target;
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
    [[_sprite getCCSprite] setVisible:NO];
}

-(void)disable
{
    _isActive = false;
    [[_sprite getCCSprite] setVisible:NO];
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
