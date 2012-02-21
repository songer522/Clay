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
#import "GameSettings.h"

#define SPIN_PLAYER_GROUND_Y 64

@implementation PlayerActionSpin


-(void)initialize
{
    _cooldown = 0.0f;
    _cooldownStart = 0.05f;
    _player = [[LayerManager sharedLayers] getPlayer];
    _sprite = [Sprite spriteCenteredWithFrame:@"Level10_Anchor.png"];
    [[_sprite getCCSprite] setVisible:NO];
    _alpha = 0.0f;
}

-(void)startAction
{
    if([_parent.skin isCurrentAnimationOfType:PLAYER_ANIM_HURTING]){return;}
    if (!_inAction && _canTrigger) {
        [super startAction];
        //[_parent endTurbo:false];
        //[_parent setPlayerAnimation:PLAYER_ANIM_SPIN];
        //[_parent setPlayerAnimation:PLAYER_ANIM_SPIN_UP];
        
        [[SoundEngine shared] playSound:@"waterSwimAction"];
        [[_sprite getCCSprite] setVisible:YES];
        [_sprite setAlpha:0.0f];
        _duration = 10.75f;
    }
}

-(void)endAction
{
    if([_parent isInMidAir]) {
        [_parent setPlayerAnimation:PLAYER_ANIM_FALLING];            
    } else {
        [_parent setPlayerAnimation:PLAYER_ANIM_RUNNING];            
    }
    _duration = 0.0f;
    _parent.hasGravity=true;
    
    [[_sprite getCCSprite] setVisible:NO];
    
    [super endAction];    
}

-(void)cancelAction
{
    _parent.hasGravity=true;
    //[_player endVaccuum];
    _duration = 0.0f;
    
    if(![_parent isTripping]) {
        if ([_parent isInMidAir]) {
            [_parent setPlayerAnimation:PLAYER_ANIM_FALLING];            
        } else {
            [_parent setPlayerAnimation:PLAYER_ANIM_RUNNING];            
        }
    }
    [[_sprite getCCSprite] setVisible:NO];

    [super cancelAction];
}


-(void)update:(float)dt
{
    if (!_inAction) {
        _isActive = false;
        
        if(_alpha > 0.0f) {
            _alpha -= 10.0f * dt;
            if (_alpha <= 0.0f) {
                _alpha = 0.0f;
            }
            [_sprite setAlpha:_alpha];
        }
    } else {
        _isActive = true;

        if(_alpha < 1.0f) {
            _alpha += 4.0f * dt;
            if (_alpha >= 1.0f) {
                _alpha = 1.0f;
            }
            [_sprite setAlpha:_alpha];
        }
        
        //IPAD FIX: check when on the ground, also double-check the player velocities are accurate (should swim down right pretty quickly)
        if (_player.y <= SPIN_PLAYER_GROUND_Y) {
            [self endAction];
        } else {
            //[_player setVelocity:30.0f];
            if (_player.vy < 0) {
                [_player setVy:100.0f];
            }
            _player.vy += 10.0f * dt;
            
            if ([[GameSettings shared] isIpad]) {
                [_sprite setPlayerObjectPosition:CGPointMake(_player.x - 0.0f, _player.y + 155.0f)];                
            } else {
                [_sprite setPlayerObjectPosition:CGPointMake(_player.x - 0.0f, _player.y + 45.0f)];
            }
        }
    }
    [super update:dt];
}

-(bool)canStartInMidAir
{
    return true;
}

-(bool)canStartOnGround
{
    return false;
}

-(void)dealloc
{
    _player = nil;
    [super dealloc];
}

@end
