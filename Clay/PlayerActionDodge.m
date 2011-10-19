//
//  PlayerActionDodge.m
//  Clay
//
//  Created by Brian Cable on 10/18/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "PlayerActionDodge.h"
#import "Sprite.h"
#import "AnimationController.h"
#import "Player.h"

#define kPlayerActionDodgeMoveX 20.0f
#define kPlayerActionDodgeFullDuration 0.4f;
#define kPlayerActionDodgeActiveWhileDurationLessThan 0.3f

@implementation PlayerActionDodge

-(void)startAction
{
    if (!_inAction) {
        _duration = kPlayerActionDodgeFullDuration;
        [_parent endTurbo];
        [[AnimationController sharedController] replaceSprite:[_parent getSprite] withAnimationNamed:@"dodgingAnim"];
    }
    [super startAction];
}

-(void)update:(float)dt
{
    if (_inAction) {
        if (_duration < kPlayerActionDodgeActiveWhileDurationLessThan) {
            _isActive = true;
            _parent.isInvincible = true;
        } else {
            _isActive = false;
        }
    }
    [super update:dt];    
}

-(void)cancelAction
{
    [[AnimationController sharedController] replaceSprite:[_parent getSprite] withAnimationNamed:@"runningAnim"];
    [super cancelAction];
}

-(void)endAction
{
    [super endAction];
}

-(bool)shouldTriggerPlayerHurtCollision
{
    if (_inAction) {
        return false;
    } else {
        return true;
    }
}

-(void)dealloc
{
    [super dealloc];
}

@end
