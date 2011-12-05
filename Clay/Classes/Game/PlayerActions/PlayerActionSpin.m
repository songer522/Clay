//
//  PlayerActionSpin.m
//  Clay
//
//  Created by Brian Cable on 11/30/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "PlayerActionSpin.h"

#import "Animation.h"
#import "AnimationController.h"
#import "Sprite.h"
#import "SoundEngine.h"
#import "Player.h"

@implementation PlayerActionSpin


-(void)initialize
{
    _cooldown = 0.0f;
    _cooldownStart = 0.4f;
    _player = [[LayerManager sharedLayers] getPlayer];
}

-(void)startAction
{
    if (!_inAction && _canTrigger) {
        [super startAction];
        //[[AnimationController sharedController] replaceSprite:_shield withAnimationNamed:@"spinningAnim"];
        
        _duration = 0.75f;
    }
}

-(void)endAction
{
    [super endAction];
}

-(void)cancelAction
{
    [super cancelAction];
}


-(void)update:(float)dt
{
    if (!_inAction) {
        _isActive = false;
    } else {
        _isActive = true;
    }
    [super update:dt];
}

-(bool)canStartInMidAir
{
    return true;
}

-(void)dealloc
{
    [super dealloc];
}

@end
