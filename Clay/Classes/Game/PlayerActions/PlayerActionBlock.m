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

@implementation PlayerActionBlock

-(void)initialize
{
    _cooldown = 0.0f;
    _shield = [Sprite spriteWithFile:@"blank.png"];
}

-(void)startAction
{
    if (!_inAction && _canTrigger) {
        [super startAction];
        
        [[AnimationController sharedController] replaceSprite:_shield withAnimationNamed:@"blockingAnim"];
        [[_shield getCCSprite] setVisible:YES];
        
        CGPoint position = [_parent getPosition];
        [_shield setPosition:CGPointMake(position.x + 2, position.y + 15)];
        
        _duration = 0.75f;
        _cooldown = 0.4f;
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
    _cooldown = 0.4f;
    [[_shield getCCSprite] setVisible:NO];
    [super cancelAction];
}


-(void)update:(float)dt
{

    
    if (!_inAction) {
        if (_cooldown > 0.0f) {
            _cooldown -= dt;
        }
    } else {
        Animation *_anim = [_shield getAnimation];
        int frame = [_anim getCurrentFrameNumber];
        if (frame == 3) {
            _isActive = true;
        } else {
            _isActive = false;
        }
        
        CGPoint position = [_parent getPosition];
        [_shield setPosition:CGPointMake(position.x + 2, position.y + 15)];
    }
    [super update:dt];
}

-(bool)canStartInMidAir
{
    return true;
}

-(void)dealloc
{
    //[_shield release];
    [super dealloc];
}


@end
