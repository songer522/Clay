//
//  PlayerActionPump.m
//  Clay
//
//  Created by Brian Cable on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlayerActionPump.h"
#import "Player.h"
#import "RunningSpeed.h"
#import "SoundEngine.h"

@implementation PlayerActionPump

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
        [_parent setPlayerAnimation:PLAYER_ANIM_PUMP];
        //[[SoundEngine shared] playSound:@"wooAction"];
        if(!_isCheering)
        {
            [[_parent getSpeed] setVelocityModifier:0.8f];
        }
        
    }
}

-(void)endAction
{
    if(_isCheering)
    {
        [_parent changeHealth:2];
        _isCheering = false;
    } else {
        [_parent changeHealth:1];        
    }
    [[_parent getSpeed] setVelocityModifier:1.0f];
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
