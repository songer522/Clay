//
//  PlayerActionWoo.m
//  Clay
//
//  Created by Brian Cable on 10/11/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "PlayerActionWoo.h"
#import "Player.h"
#import "LayerManager.h"
#import "AnimationController.h"
#import "SoundEngine.h"
#import "GameLayer.h"
#import "HudLayer.h"

@implementation PlayerActionWoo

-(void)initialize
{
    _cooldown = 0.0f;
    _canTrigger = true;
    _cooldownStart = 6.0f;
    _isCheering = false;
}

-(void)startAction
{
    if (!_inAction && _canTrigger) {
        [super startAction];
        _duration = 0.75f;
        [_parent endTurbo:false];
        [_parent setPlayerAnimation:PLAYER_ANIM_WOO];
        [[SoundEngine shared] playSound:@"wooAction"];
    }
}

-(void)endAction
{
    if(_isCheering)
    {
        [_parent changeHealth:2];
        _isCheering = false;
    }
    [_parent changeHealth:1];
       [super endAction];
}

-(void)cancelAction
{
    [_parent setPlayerAnimation:PLAYER_ANIM_RUNNING];
    [super cancelAction];
}


-(void)update:(float)dt
{
    [super update:dt];
}

-(void)dealloc
{
    [super dealloc];
}


@end
