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

//IPAD FIX: the shadow's feet should be in line with tim's feet in the y position, and the shadow should follow behind tim at three different positions, as well as be completely offscreen, at different points.
#define SHADOW_YPOS 133.0f
#define SHADOW_XPOS_OFFSCREEN -50.0f
#define SHADOW_XPOS_FAR 15.0f
#define SHADOW_XPOS_MIDDLE 45.0f
#define SHADOW_XPOS_CLOSE 75.0f
#define SHADOW_TRANSITION_SPEED_SLOW 10.0f
#define SHADOW_TRANSITION_SPEED_FAST 20.0f
#define SHADOW_ATTACK_WAIT 2.0f

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
    
    [_sprite setAlpha:1.0f];
    [[_sprite getCCSprite] setVisible:YES];
    
    _firstUpdate = true;
    _waitToAttack = 5.0f;
    _isTransitioning = false;
    _xPos = 0.0f;
    _targetXPos = 0.0f;
    _isMovingCamera = false;
    
    [[_sprite getCCSprite] setVisible:NO];
    [self switchToPhase:BOSS_PHASE_NOT_TRIGGERED];
    
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
            _isTransitioning = true;
            _isActive = true;
            _isMovingCamera = true;
            [[SoundEngine shared] playMusic:@"darknessBoss"];
            _targetCameraXPos = 125.0f;
            break;
        default:
            break;
    }
}

-(void)triggerAttack
{
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
            _waitToAttack = 2.0f;
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
    
    
    if (_phase == BOSS_PHASE_CHASE_CLOSE) {
        //if the player is moving, prepare to attack him. if he's currently fallen or
        //has recently started the slow time, though, reset the wait instead
        if ([_player isMoving]) {
            _waitToAttack -= dt;
            if (_waitToAttack<=0.0f) {
                [self triggerAttack];
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

-(void)shiftCamera:(float)dt
{
    _cameraXPos = [Calculator modifyFloat:_cameraXPos towardsTargetValue:_targetCameraXPos atSpeed:(8.0f * dt)];
    if (_cameraXPos == _targetCameraXPos) {
        _isMovingCamera = false;
    }
    [[Camera sharedCamera] setCenter:CGPointMake(_cameraXPos, 22.0f)];
}

-(void)reset
{
    
}

-(void)dealloc
{
    _level = nil;
    [_sprite release];
    [super dealloc];
}

@end
