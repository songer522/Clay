//
//  PlayerActionDetonate.m
//  Clay
//
//  Created by Brian Cable on 1/12/12.
//  Copyright (c) 2012 Xecudev, LLC. All rights reserved.
//

#import "PlayerActionDetonate.h"
#import "PlayerActionSlowTime.h"
#import "LevelManager.h"
#import "Level.h"
#import "MapObject.h"
#import "GameObject.h"
#import "Sprite.h"
#import "Animation.h"
#import "Player.h"
#import "RunningSpeed.h"
#import "GameLayer.h"
#import "LayerManager.h"
#import "BossFinalJim.h"
#import "SoundEngine.h"


@implementation PlayerActionDetonate

-(void)initialize
{
    _cooldown = 0.0f;
    _cooldownStart = 0.2f;
    
    GameLayer *gameLayer = [[LayerManager sharedLayers] currentLayer];
    _boss = [gameLayer getBoss];
}

-(void)startAction
{
    if (!_inAction && _canTrigger) {
        
        [super startAction];        
        [_parent endTurbo:false];
        
        //[self updateSlowdown:0.2f];
        _duration = 0.2f;
        
        [_parent setPlayerAnimation:PLAYER_ANIM_SLOWTIME];
        
        _waitForDetonate = 0.15f;
        _playedDetonateSound = false;

    }
}

-(void)endAction
{
    //[self updateSlowdown:1.0f];
    //[[_parent getSpeed] setVelocityModifier:1.0f];
    
    [super endAction];
    
}

-(void)cancelAction
{
    //NOTE: for now, can't be cancelled
    //if this gets undone in the future, keep in mind you'll need to write an exception for
    //slowdowns, because they call 'startcollision' constantly, which calls cancelAction
    return;
}


-(void)update:(float)dt
{
    if (!_inAction) {
        _isActive = false;
    } else {
        _isActive = true;
        
        if (_waitForDetonate > 0.0f) {
            _waitForDetonate -= dt;
            if (_waitForDetonate<=0.1 && !_playedDetonateSound) {
                [[SoundEngine shared] playSound:@"bombDetonator"];
                _playedDetonateSound = true;
            }
            if (_waitForDetonate <= 0.0f) {
                [self pressDetonator];
            }
        }
    }
    [super update:dt];
}

-(void)pressDetonator
{
    [_boss detonateBombs];
}

-(bool)canStartInMidAir
{
    return true;
}

-(bool) playerAllowedToJump
{
    return true;
}

-(bool) playerAllowedToSprint
{
    return true;
}

-(void)dealloc
{
    _boss = nil;
    [super dealloc];
}

@end
