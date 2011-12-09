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

@implementation BossFinalJim

-(void)startBoss
{
    _level = [[LevelManager shared] currentLevel];
    
    [_sprite setAlpha:1.0f];
    [[_sprite getCCSprite] setVisible:YES];
    
    _firstUpdate = true;
    _waitToAttack = 10.0f;
}

-(void)setSprite:(Sprite *)sprite
{
    _sprite = sprite;
    [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"darkShadowTimAnim"];
}

-(void)switchToPhase:(FinalBossPhase)phase
{
    switch (phase) {
        case JIM_PHASE_CHASE_FAR:
            //[[_sprite getCCSprite] setColor:ccc3(255, 255, 255)];
            _xPosition = 20.0f;
            break;
        case JIM_PHASE_CHASE_MIDDLE:
            //[[_sprite getCCSprite] setColor:ccc3(122,122,122)];
            _xPosition = 35.0f;
            break;
        case JIM_PHASE_CHASE_CLOSE:
            //[[_sprite getCCSprite] setColor:ccc3(0, 0, 0)];
            _xPosition = 50.0f;
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
        [_sprite setScreenPosition:ccp(50,50)];        
    }
    
    
    //CGPoint position = [_sprite getPosition];
    
    //[_sprite setScreenPosition:CGPointMake(position.x + _velocity.x, position.y + _velocity.y)];
    
    if(_waitToAttack>0.0f) {
        _waitToAttack -= dt;
        if (_waitToAttack<=0.0f) {
            [self switchToPhase:JIM_PHASE_CHASE_MIDDLE];
        }
    }
}

-(void)reset
{
}

@end
