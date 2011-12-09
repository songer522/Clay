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

@implementation BossFinalJim

-(void)startBoss
{
    _level = [[LevelManager shared] currentLevel];
    
    [_sprite setAlpha:1.0f];
    [[_sprite getCCSprite] setVisible:YES];
    
    _firstUpdate = true;
    _waitToAttack = 5.0f;
    _transitionAmount = 0.0f;
    _isTransitioning = false;
    
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
            _xPosition = 5.0f;
            break;
        case BOSS_PHASE_CHASE_MIDDLE:
            _xPosition = 20.0f;
            break;
        case BOSS_PHASE_CHASE_CLOSE:
            _xPosition = 30.0f;
            break;
        case BOSS_PHASE_NOT_TRIGGERED:
            [[_sprite getCCSprite] setVisible:NO];
            _xPosition = -50.0f;
            _isActive = false;
            break;
        case BOSS_PHASE_CHASE_INIT:
            [[_sprite getCCSprite] setVisible:YES];
            _xPosition = 20.0f;
            _transitionAmount = 0.0f;
            _isTransitioning = true;
            _isActive = true;
            [self switchToPhase:BOSS_PHASE_CHASE_MIDDLE];
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
    
    CGPoint position = CGPointMake(_xPosition, 105.0f);
    [_sprite setScreenPosition:position];
    
    if (_phase == BOSS_PHASE_CHASE_MIDDLE) {
        //[self triggerAttack];
    }
    
}

-(void)updateTransition:(float)dt
{
    
}

-(void)endTransition
{
    
}

-(void)reset
{
    
}

@end
