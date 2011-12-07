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

#define SPIN_PLAYER_GROUND_Y 64

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
        [_parent setPlayerAnimation:PLAYER_ANIM_SPIN];
        [_parent setPlayerAnimation:PLAYER_ANIM_SPIN_UP];
        _duration = 10.75f;
    }
}

-(void)endAction
{
    if(_player.inVaccuum) {
        _player.inVaccuum = false;
    } else {
        [_parent setPlayerAnimation:PLAYER_ANIM_RUNNING];
        [_parent setPlayerAnimation:PLAYER_ANIM_SPIN_UP];
    }
    _duration = 0.0f;
    [super endAction];    
}

-(void)cancelAction
{
    [_parent setPlayerAnimation:PLAYER_ANIM_RUNNING];
    _duration = 0.0f;
    [super cancelAction];
}


-(void)update:(float)dt
{
    if (!_inAction) {
        _isActive = false;
    } else {
        _isActive = true;

        //IPAD FIX: check when on the ground
        if (_player.y <= SPIN_PLAYER_GROUND_Y) {
            [self endAction];
        } else {
            [_player setVelocity:30.0f];
            [_player setVy:50.0f];
        }
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
