//
//  PlayerActionKick.m
//  Clay
//
//  Created by Brian Cable on 10/11/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "PlayerActionKick.h"
#import "AnimationController.h"
#import "RunningSpeed.h"
#import "Player.h"

#define kPlayerActionDodgeMoveX 20.0f
#define kPlayerActionDodgeFullDuration 0.4f;
#define kPlayerActionDodgeActiveWhileDurationLessThan 0.2f

@implementation PlayerActionKick

-(void)startAction
{
    if (!_inAction && _canTrigger) {
        _duration = kPlayerActionDodgeFullDuration;
        _madeNoise = false;
        _cooldown = 1.0f;
        [_parent endTurbo];
        [[AnimationController sharedController] replaceSprite:[_parent getSprite] withAnimationNamed:@"kickingAnim"];
    }
    [super startAction];
}

-(void)update:(float)dt
{
    if (_inAction) {
        if (_duration < kPlayerActionDodgeActiveWhileDurationLessThan) {
            _isActive = true;
            if (!_madeNoise) {
                _madeNoise = true;
                [[_parent getSpeed] startKick];
            }
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
    [_parent pushAfterAnimation:kPlayerActionDodgeMoveX];
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
