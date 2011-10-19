//
//  PlayerActionWoo.m
//  Clay
//
//  Created by Brian Cable on 10/11/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "PlayerActionWoo.h"
#import "Player.h"
#import "AnimationController.h"
#import "SoundEngine.h"

@implementation PlayerActionWoo

-(void)initialize
{
    _cooldown = 0.0f;    
}

-(void)startAction
{
    if (!_inAction && _cooldown<=0.0f) {
        [super startAction];
        _duration = 0.75f;
        _cooldown = 3.0f;
        [_parent endTurbo];
        [[AnimationController sharedController] replaceSprite:[_parent getSprite] withAnimationNamed:@"wooAnim"];
        [[SoundEngine shared] playSound:@"wooAction"];
    }
}

-(void)endAction
{
    [_parent changeHealth:1];
    [super endAction];
}

-(void)cancelAction
{
    [[AnimationController sharedController] replaceSprite:[_parent getSprite] withAnimationNamed:@"runningAnim"];
    _cooldown = 1.0f;
    [super cancelAction];
}


-(void)update:(float)dt
{
    if (!_inAction) {
        if (_cooldown > 0.0f) {
            _cooldown -= dt;
        }
    }
    [super update:dt];
}

-(void)dealloc
{
    [super dealloc];
}


@end
