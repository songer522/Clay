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
#import "AnimationController.h"
#import "Camera.h"
#import "Calculator.h"

//IPAD FIX: the shadow's feet should be in line with tim's feet in the y position, and the shadow should follow behind tim at three different positions, as well as be completely offscreen, at different points.
#define SHADOW_YPOS 133.0f
#define SHADOW_XPOS_OFFSCREEN -50.0f
#define SHADOW_XPOS_FAR 5.0f
#define SHADOW_XPOS_MIDDLE 20.0f
#define SHADOW_XPOS_CLOSE 30.0f
#define SHADOW_TRANSITION_SPEED_SLOW 10.0f
#define SHADOW_TRANSITION_SPEED_FAST 20.0f

@implementation BossFinalJim

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
    
    [[_sprite getCCSprite] setVisible:NO];
    [self switchToPhase:BOSS_PHASE_NOT_TRIGGERED];
    
    [[Camera sharedCamera] setCenter:CGPointMake(125.0f,22.0f)];
}

-(void)setSprite:(Sprite *)sprite
{
    _sprite = sprite;
    [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"darkShadowTimAnim"];
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
            _isActive = false;
            break;
        case BOSS_PHASE_CHASE_INIT:
            [[_sprite getCCSprite] setVisible:YES];
            _transitionSpeed = SHADOW_TRANSITION_SPEED_SLOW;
            _phase = BOSS_PHASE_CHASE_FAR;
            _targetXPos = SHADOW_XPOS_FAR;
            _isTransitioning = true;
            _isActive = true;
            break;
        default:
            break;
    }
}

-(void)triggerAttack
{
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
    
    float screenY = [[Camera sharedCamera] convertToScreenY:SHADOW_YPOS];
    
    CGPoint position = CGPointMake(_xPos, screenY);
    [_sprite setScreenPosition:position];
    
    
    if (_phase == BOSS_PHASE_CHASE_MIDDLE) {
        //[self triggerAttack];
    }
    
}

-(void)updateTransition:(float)dt
{
    _xPos = [Calculator modifyFloat:_xPos towardsTargetValue:_targetXPos atSpeed:(_transitionSpeed * dt)];
    if (_xPos == _targetXPos) {
        _isTransitioning = false;
    }
}

-(void)endTransition
{
    
}

-(void)reset
{
    
}

@end
