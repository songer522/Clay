//
//  BossFinalJim.m
//  Clay
//
//  Created by Brian Cable on 10/19/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "BossFinalJim.h"
#import "LevelManager.h"
#import "Sprite.h"
#import "Level.h"
#import "Animation.h"
#import "AnimationController.h"
#import "Camera.h"
#import "Calculator.h"
#import "SoundEngine.h"
#import "Player.h"
#import "RunningSpeed.h"

//IPAD FIX: the shadow's feet should be in line with tim's feet in the y position, and the shadow should follow behind tim at three different positions, as well as be completely offscreen, at different points.
#define SHADOW_YPOS 133.0f
#define SHADOW_XPOS_OFFSCREEN -50.0f
#define SHADOW_XPOS_FAR 15.0f
#define SHADOW_XPOS_MIDDLE 45.0f
#define SHADOW_XPOS_CLOSE 85.0f
#define SHADOW_TRANSITION_SPEED_SLOW 10.0f
#define SHADOW_TRANSITION_SPEED_FAST 20.0f
#define SHADOW_ATTACK_WAIT 1.5f

@implementation BossFinalJim


-(void)changeAnimationSpeed:(float)modifier
{
    [[_sprite getAnimation] changeAnimationSpeed:modifier];
}

-(void)setSprite:(Sprite *)sprite
{
    _sprite = sprite;
    [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"darkShadowTimAnim"];
}

-(void)startBoss
{
    _level = [[LevelManager shared] currentLevel];
    _firstUpdate = true;
    [_sprite setAlpha:1.0f];
    _player = [[LayerManager sharedLayers] getPlayer];
    [self restartLevel];
    
}


-(void)switchToPhase:(BossPhase)phase
{
    _phase = phase;
    switch (phase) {
        case BOSS_PHASE_CHASE_FAR:
            _targetXPos = SHADOW_XPOS_FAR;
            _transitionSpeed = SHADOW_TRANSITION_SPEED_FAST;
            _isTransitioning = true;
            break;
        case BOSS_PHASE_CHASE_MIDDLE:
            _targetXPos = SHADOW_XPOS_MIDDLE;
            _transitionSpeed = SHADOW_TRANSITION_SPEED_FAST;
            _isTransitioning = true;
            break;
        case BOSS_PHASE_CHASE_CLOSE:
            _targetXPos = SHADOW_XPOS_CLOSE;
            _transitionSpeed = SHADOW_TRANSITION_SPEED_FAST;
            _isTransitioning = true;
            break;
        case BOSS_PHASE_NOT_TRIGGERED:
            [[_sprite getCCSprite] setVisible:NO];
            _targetXPos = SHADOW_XPOS_OFFSCREEN;
            _xPos = SHADOW_XPOS_OFFSCREEN;
            _targetCameraXPos = 75.0f;
            _cameraXPos = 75.0f;
            _isActive = false;
            [[Camera sharedCamera] setCenter:CGPointMake(_cameraXPos, 22.0f)];
            break;
        case BOSS_PHASE_CHASE_INIT:
            [[_sprite getCCSprite] setVisible:YES];
            _transitionSpeed = SHADOW_TRANSITION_SPEED_SLOW;
            _phase = BOSS_PHASE_CHASE_FAR;
            _targetXPos = SHADOW_XPOS_FAR;
            _xPos = SHADOW_XPOS_OFFSCREEN;
            _isTransitioning = true;
            _isActive = true;
            _isMovingCamera = true;
            _targetCameraXPos = 125.0f;
            break;
        default:
            break;
    }
}

-(void)triggerAttack
{
    [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"darkShadowTimKickingAnim"];
    _waitToSwitchBack = 0.4f;
    _isKicking = true;
}

-(void)triggerFallBack
{
    switch (_phase) {
        case BOSS_PHASE_CHASE_MIDDLE:
            [self switchToPhase:BOSS_PHASE_CHASE_FAR];
            break;
        case BOSS_PHASE_CHASE_CLOSE:
            [self switchToPhase:BOSS_PHASE_CHASE_MIDDLE];
            break;
        default:
            break;
    }
}

-(void)triggerGetCloser
{
    switch (_phase) {
        case BOSS_PHASE_CHASE_FAR:
            [self switchToPhase:BOSS_PHASE_CHASE_MIDDLE];
            break;
        case BOSS_PHASE_CHASE_MIDDLE:
            [self switchToPhase:BOSS_PHASE_CHASE_CLOSE];
            _waitToAttack = SHADOW_ATTACK_WAIT;
            break;
        default:
            break;
    }
}

-(void)update:(float)dt
{
    //have to reposition for now because the position gets set like three times in gameobject, but for the time being we need to call it
    //so we can put it under the right layers
    
    if (_firstUpdate) {
        _firstUpdate = false;
        [_sprite setScreenPosition:ccp(-50,50)];        
    }

    if (_isTransitioning) {
        [self updateTransition:dt];
    }
    
    if (_isMovingCamera) {
        [self shiftCamera:dt];
    }
    
    float screenY = [[Camera sharedCamera] convertToScreenY:SHADOW_YPOS];
    
    CGPoint position = CGPointMake(_xPos, screenY);
    [_sprite setScreenPosition:position];
    
    [self updateKick:dt];
    [self updateLaugh:dt];
    
    if (_phase == BOSS_PHASE_CHASE_CLOSE) {
        //if the player is moving, prepare to attack him. if he's currently fallen or
        //has recently started the slow time, though, reset the wait instead
        if ([_player isMoving] && !_isTransitioning) {
            _waitToAttack -= dt;
            if (_waitToAttack<=0.0f) {
                [self triggerAttack];
                _waitToAttack = SHADOW_ATTACK_WAIT;
            }
        } else {
            _waitToAttack = SHADOW_ATTACK_WAIT;
        }
    }
    
}

-(void)updateTransition:(float)dt
{
    _xPos = [Calculator modifyFloat:_xPos towardsTargetValue:_targetXPos atSpeed:(_transitionSpeed * dt)];
    if (_xPos == _targetXPos) {
        _isTransitioning = false;
    }
}

-(void)updateKick:(float)dt
{
    if (_isKicking) {
        _waitToSwitchBack-=dt;
        if(_waitToSwitchBack<=0.0f) {
            _isKicking = false;
            
            //force the player to be knocked down if they are NOT in turbo (i.e. running away)
            if (![[_player getSpeed] inTurbo]) {
                [_player startPlayerCollision:YES];
                _wasKnockedDown = true;
                [self startLaugh];
            } else {
                [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"darkShadowTimAnim"];
            }
        }
    }
}

-(void)startLaugh
{
    [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"darkShadowTimLaughingAnim"];
    [[SoundEngine shared] playSound:@"darkShadowLaugh"];
    _isLaughing = true;
}

-(void)shiftCamera:(float)dt
{
    _cameraXPos = [Calculator modifyFloat:_cameraXPos towardsTargetValue:_targetCameraXPos atSpeed:(8.0f * dt)];
    if (_cameraXPos == _targetCameraXPos) {
        _isMovingCamera = false;
    }
    [[Camera sharedCamera] setCenter:CGPointMake(_cameraXPos, 22.0f)];
}

-(void)updateLaugh:(float)dt
{
    if (_isLaughing) {
        if ([_player isMoving] && !_player.isInMidAir) {
            //end laugh if player starts moving again
            [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"darkShadowTimAnim"];
            if (_wasKnockedDown) {
                [self switchToPhase:BOSS_PHASE_CHASE_FAR];
                _wasKnockedDown = false;
            }
            _isLaughing = false;
        }
    } else {
        if (![_player isMoving]) {
            [self startLaugh];
        }
    }
}

-(void)reset
{
    if (_phase == BOSS_PHASE_NOT_TRIGGERED) {
        //if hasn't been triggered, do nothing
    } else {
        _xPos = SHADOW_XPOS_OFFSCREEN;
        [self switchToPhase:BOSS_PHASE_CHASE_FAR];
        if(_isKicking||_isLaughing) {
            [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"darkShadowTimAnim"];
            _isLaughing = false;
            _isKicking = false;
            _wasKnockedDown = false;
        }
    }
}

-(void)restartLevel
{
    //only want to do this when restarting level and if the boss has been triggered already, not starting level
    if (!_firstUpdate && _phase != BOSS_PHASE_NOT_TRIGGERED) {
        [[SoundEngine shared] playMusic:@"darkness"];        
    }
    
    _waitToAttack = 5.0f;
    _isTransitioning = false;
    _xPos = 0.0f;
    _targetXPos = 0.0f;
    _isMovingCamera = false;
    _isKicking = false;
    _isLaughing = false;
    _wasKnockedDown = false;
    [[_sprite getCCSprite] setVisible:NO];
    [self switchToPhase:BOSS_PHASE_NOT_TRIGGERED];
    [_sprite setScreenPosition:ccp(-50,50)];
    

}

-(void)dealloc
{
    _level = nil;
    [_sprite release];
    [super dealloc];
}

@end
