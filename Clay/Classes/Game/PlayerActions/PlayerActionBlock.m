//
//  PlayerActionBlock.m
//  Clay
//
//  Created by Brian Cable on 11/10/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "PlayerActionBlock.h"
#import "Animation.h"
#import "AnimationController.h"
#import "Sprite.h"
#import "SoundEngine.h"
#import "Player.h"
#import "GameSettings.h"

static CGFloat BlockShieldOffsetY(Player *player)
{
    if ([[GameSettings shared] isIpad]) {
        return 110.0f;
    }

    CGFloat playerHeight = [[player getSprite] getHeight];
    if (playerHeight > 0.0f) {
        return MAX(44.0f, MIN(56.0f, floorf(playerHeight * 0.33f)));
    }

    if ([GameSettings currentRenderScale] >= 2.0f) {
        return 48.0f;
    }
    return 44.0f;
}

@implementation PlayerActionBlock

-(void)initialize
{
    _cooldown = 0.0f;
    _cooldownStart = 0.1f;
    _shield = [Sprite spriteWithFile:@"blank.png"];
}

-(void)startAction
{
    if (!_inAction && _canTrigger) {
        [super startAction];
        
        [[AnimationController sharedController] replaceSprite:_shield withAnimationNamed:@"blockingAnim"];
        [[_shield getCCSprite] setVisible:YES];
        
        CGPoint position = [_parent getPosition];
        [_shield setPosition:CGPointMake(position.x + 2, position.y + BlockShieldOffsetY(_parent))];
        
        _duration = 0.5f;
        [[SoundEngine shared] playSound:@"shield"];
    }
}

-(void)endAction
{
    [[_shield getCCSprite] setVisible:NO];
    [super endAction];
}

-(void)cancelAction
{
    [[_shield getCCSprite] setVisible:NO];
    [super cancelAction];
    
}


-(void)update:(float)dt
{
    if (!_inAction) {
        _isActive = false;
    } else {
        _isActive = true;
        
        CGPoint position = [_parent getPosition];
        [_shield setPosition:CGPointMake(position.x + 2, position.y + BlockShieldOffsetY(_parent))];
    }
    [super update:dt];
}

-(bool)canStartInMidAir
{
    return true;
}

-(bool)playerAllowedToJump
{
    return true;
}

-(void)dealloc
{
    [_shield release];
    [super dealloc];
}


@end
