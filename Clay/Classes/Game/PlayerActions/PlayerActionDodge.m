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
#import "RunningSpeed.h"

#define kPlayerActionDodgeMoveX 20.0f
#define kPlayerActionDodgeFullDuration 1.0f;
#define kPlayerActionDodgeActiveWhileDurationLessThan 0.9f

@implementation PlayerActionDodge

-(void)startAction
{
    if (!_inAction && _canTrigger) {
        _duration = kPlayerActionDodgeFullDuration;
        _cooldown = 0.7f;
        _parent.isInvincible = true;
        _preActionPlayerPosition = [_parent getPosition];
        [_parent endTurbo];
        [[AnimationController sharedController] replaceSprite:[_parent getSprite] withAnimationNamed:@"dodgingAnim"];
    }
    [super startAction];
}

-(void)update:(float)dt
{
    if (_inAction) {
        Animation *anim = [[_parent getSprite] getAnimation];
        
        //to move the player down in front of the obstacle later,
        //but this doesn't work with the collision, so it'll probably have to be an offset modifier
        //and make sure every movement is taking that offset into account.
        /*
        if (_duration >= 0.9f) {
            [_parent move:CGPointMake(0, -100.0f*dt)];
        } else if(_duration <= 0.1f) {
            [_parent move:CGPointMake(0, 100.0f*dt)];
        }*/
        
        
        int frame = 1;
        if ([anim.name isEqualToString:@"dodgingAnim"]) {
            frame = [anim getCurrentFrameNumber];
        }
        
        if (frame == 1 || frame == 3) {
            [_parent getSpeed].velocity = 13.0f;
        } else {
            [_parent getSpeed].velocity = 7.0f;
        }
        if (_duration < kPlayerActionDodgeActiveWhileDurationLessThan) {
            _isActive = true;
        } else {
            _isActive = false;
        }
    }
    [super update:dt];    
}

-(void)cancelAction
{

    [_parent setPlayerAnimation:PLAYER_ANIM_RUNNING];
    [[AnimationController sharedController] replaceSprite:[_parent getSprite] withAnimationNamed:@"runningAnim"];
    _parent.isInvincible = false;
    //[_parent setPosition:_preActionPlayerPosition];
    [super cancelAction];
}

-(void)endAction
{
    _parent.isInvincible = false;
    //[[_parent getSprite] setPosition:_preActionPlayerPosition];
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
