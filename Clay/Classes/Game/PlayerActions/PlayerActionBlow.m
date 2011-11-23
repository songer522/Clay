//
//  PlayerActionBlow.m
//  Clay
//
//  Created by Brian Cable on 11/22/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "PlayerActionBlow.h"
#import "Sprite.h"
#import "Skin.h"
#import "Projectile.h"
#import "Player.h"
#import "AnimationController.h"

@implementation PlayerActionBlow
-(void)initialize
{
    _cooldown = 0.0f;
    _wind = [Sprite spriteWithFile:@"blank.png"];
    _windProjectile = [Projectile projectileWithBehavior:PROJECTILE_BEHAVIOR_PLAYER_BLOWING];
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2)
    {
        [_windProjectile setBoundingBox:CGRectMake(0, 0, 35, 35)];
    }
    else
    {
        [_windProjectile setBoundingBox:CGRectMake(0, 35, 35, 35)];
    }
    [super initialize];    
}

-(void)startAction
{
    if (!_inAction && _canTrigger) {
        [super startAction];
        
        
        [[AnimationController sharedController] replaceSprite:_wind withAnimationNamed:@"blowingWindAnim"];
        
        [[_wind getCCSprite] setVisible:YES];
        
        CGPoint position = [_parent getPosition];
        [_wind setPosition:CGPointMake(position.x + 2, position.y + 15)];

        [_parent setPlayerAnimation:PLAYER_ANIM_BLOW];
        [_parent endTurbo];

        _duration = 0.45f;
        _cooldown = 0.4f;
    }
}

-(void)endAction
{
    [[_wind getCCSprite] setVisible:NO];
    [super endAction];
}

-(void)cancelAction
{
    [_parent setPlayerAnimation:PLAYER_ANIM_RUNNING];
    _cooldown = 0.4f;
    [[_wind getCCSprite] setVisible:NO];
    [super cancelAction];
}


-(void)update:(float)dt
{
    if (!_inAction) {
        if (_cooldown > 0.0f) {
            _cooldown -= dt;
        }
        _isActive = false;
    } else {
        _isActive = true;
        
        CGPoint position = [_parent getPosition];
        [_wind setPosition:CGPointMake(position.x + 5, position.y + 30)];
    }
    [super update:dt];
}

-(bool)canStartInMidAir
{
    return false;
}

-(void)dealloc
{
    [_wind release];
    [super dealloc];
}

@end
