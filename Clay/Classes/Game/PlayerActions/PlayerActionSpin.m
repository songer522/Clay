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

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define MULTIPLIERY (IS_IPAD ? 2.4f : 1.0f)

// The end-of-swim floor test. Every other floor in the game scales: the player is grounded
// at 64*MULTIPLIERY (Player.m) and Level 10's underwater floor gate is 22*MULTIPLIERY, so a
// bare 64 matched neither on iPad and the anchor ran its full 10.75s duration instead of
// ending on contact. Scale it so the phone reproduces the legacy 64 exactly and iPad lands
// at the same point relative to its floor.
//
// The phone baseline itself is left at 64, which sits above the 22 underwater floor gate.
// That is the shipped feel; do not retune it without an overlay measurement.
#define SPIN_PLAYER_GROUND_Y (64.0f * MULTIPLIERY)

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
                if ([[GameSettings shared] isIpad]) {
                    [_player setVy:200.0f];
                } else {
                    [_player setVy:100.0f];
                }
            }
            
            if ([[GameSettings shared] isIpad]) {
                [_sprite setPlayerObjectPosition:CGPointMake(_player.x - 0.0f, _player.y + 155.0f)];                
                _player.vy += 20.0f * dt;
            } else {
                [_sprite setPlayerObjectPosition:CGPointMake(_player.x - 0.0f, _player.y + 45.0f)];
                _player.vy += 10.0f * dt;
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
