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
#import "SoundEngine.h"
#import "Camera.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

// Legacy authoring space is 480x320 on phone and 1024x768 on iPad. The original code
// multiplied every position below by the iPad factors (2.133 / 4 / 3) with no IS_IPAD
// guard, so on a phone the attack staged ~900pt to the right and at a y above the top of
// the screen: attack 3 played its sound and was never visible. Scale only on iPad, and
// keep the iPad numbers byte-for-byte identical to what shipped.
static CGFloat ComboAttackX(CGFloat value)
{
    return IS_IPAD ? value * 2.133f : value;
}

// These y values are ABSOLUTE screen positions, but the camera shifts the whole world up by
// CameraPhoneVerticalOffset() on phones taller than the legacy 320pt design height. Without
// adding it back the attack sweeps below the player's feet - on an 844x390 phone the world
// moves up 35pt, which put combo 0 and 1 into the ground. Adding it restores the authored
// gap between the attack and the player. iPad offset is 0, so iPad is unaffected.
static CGFloat ComboAttackScreenY(CGFloat value, CGFloat ipadScale)
{
    CGFloat scaled = IS_IPAD ? value * ipadScale : value;
    return scaled + [Camera phoneVerticalOffset];
}

// Offsets relative to the ship, which is already positioned in the same screen space -
// these must NOT get the world offset added.
static CGFloat ComboAttackY(CGFloat value, CGFloat ipadScale)
{
    return IS_IPAD ? value * ipadScale : value;
}

// The attack stages just inside the right edge and then sweeps off to the left. Both edges
// were authored against the legacy width, so measure in from the live right edge instead of
// hardcoding an x. On a legacy 480 screen this reproduces the original 420, and on a legacy
// 1024 iPad it reproduces 896.
static CGFloat ComboAttackStageX(CGFloat legacyInsetFromRight)
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    return winSize.width - ComboAttackX(legacyInsetFromRight);
}

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
                _initialPosition = ccp(ComboAttackX(18),-ComboAttackY(70,4));
                _attackPosition = ccp(ComboAttackStageX(60),ComboAttackScreenY(45,4));
                _endAttackPosition = ccp(-ComboAttackX(200),ComboAttackScreenY(45,4));
                break;
            case 1:
                _initialPosition = ccp(-ComboAttackX(18),-ComboAttackY(70,4));
                _attackPosition = ccp(ComboAttackStageX(60),ComboAttackScreenY(70,4));
                _endAttackPosition = ccp(-ComboAttackX(200),ComboAttackScreenY(70,4));
                break;
            case 2:
                _initialPosition = ccp(0,-ComboAttackY(45,3));
                _attackPosition = ccp(ComboAttackStageX(100),ComboAttackScreenY(220,3));
                _endAttackPosition = ccp(-ComboAttackX(150),ComboAttackScreenY(-50,3));
                break;
            default:
                break;
        }
        
        _isActive = false;
        [self switchToPhase:COMBO_IDLE];
        // The origin was iPad-scaled while the 24x24 size was not, so GameCollisionRectForObject
        // produced a box sitting entirely up-and-left of the sprite. Scale both consistently.
        [self setBoundingBox:CGRectMake(ComboAttackX(12),ComboAttackY(12,2.4),
                                        ComboAttackX(24),ComboAttackY(24,2.4))];
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
            [[SoundEngine shared] playSound:@"comboAttackMove"];
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
