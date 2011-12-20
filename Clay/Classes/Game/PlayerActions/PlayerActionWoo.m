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
    //_canTrigger = true;
    _canTrigger = false;
    _cooldownStart = 3.0f;
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
    [_parent changeHealth:1];
    
       [super endAction];
  
    [self disableAction];
}

-(void)cancelAction
{
    [_parent setPlayerAnimation:PLAYER_ANIM_RUNNING];
     
    [super cancelAction];
    [self disableAction];
}


-(void)update:(float)dt
{
    if (_inAction) {
        _duration -= dt;
        
        if (_duration <= 0.0f) {
            [self endAction];
        }
        
        //[[[[[LayerManager sharedLayers] currentLayer] getHud] getActionButton] updateOverlayImageByPercentage:0.0f]; 
    }
    
    if (_cooldown>0.0f) {            
        _cooldown -= dt;
        if (_cooldown<=0.0f && !_canTrigger) {
            //[self enableAction];
            _cooldown = 0.0f;
        }
        
        //float percent = (_cooldownStart - _cooldown)/_cooldownStart;
        //[[[[[LayerManager sharedLayers] currentLayer] getHud] getActionButton] updateOverlayImageByPercentage:percent];
    }
    
    if (!_canTrigger)
    {
        [self disableAction];
    }
    else
    {
        [self enableAction];
    }
    
}

-(void)dealloc
{
    [super dealloc];
}


@end
