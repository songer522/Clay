//
//  PlayerActionBlow.m
//  Clay
//
//  Created by Brian Cable on 11/22/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "PlayerActionBlow.h"
#import "Sprite.h"
#import "AnimationController.h"

@implementation PlayerActionBlow
-(void)initialize
{
    _cooldown = 0.0f;
    _wind = [Sprite spriteWithFile:@"blank.png"];
}

-(void)startAction
{
    if (!_inAction && _canTrigger) {
        [super startAction];
        
        [[AnimationController sharedController] replaceSprite:_wind withAnimationNamed:@"blowingWindAnim"];
        
        [[_wind getCCSprite] setVisible:YES];
        
        CGPoint position = [_parent getPosition];
        [_wind setPosition:CGPointMake(position.x + 2, position.y + 15)];
        
        _duration = 0.75f;
        _cooldown = 0.4f;
        //[[SoundEngine shared] playSound:@"shield"];
    }
}

-(void)endAction
{
    [[_wind getCCSprite] setVisible:NO];
    [super endAction];
}

-(void)cancelAction
{
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
        [_wind setPosition:CGPointMake(position.x + 2, position.y + 15)];
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
