//
//  Lightning.m
//  Clay
//
//  Created by Brian Cable on 12/1/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "Lightning.h"
#import "Sprite.h"
#import "Animation.h"
#import "AnimationController.h"
#import "Camera.h"
#import "SoundEngine.h"

@implementation Lightning


+(id)instance
{
    return [[self alloc] init];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
        _sprite = [Sprite spriteWithFile:@"blank.png"];
        [self repositionSprite];
        [_sprite setAlpha:0.0f];
        
        _waitUntilNewStrike = 4.0f + rand()%5;
    }
    
    return self;
}


-(void)update:(float)dt
{
    if (_waitUntilNewStrike >0.0f) {
        _waitUntilNewStrike-=dt;
        if (_waitUntilNewStrike<=0.0f) {
            [self startStrike];
        }
    } else {
        _timeIntoAnimation+=dt;
        
        //full alpha until 0.7seconds, then 50% opacity for 0.1 seconds, then 100% opacity for 0.1 seconds, then 50% opacity for 0.1 seconds.
        
        if(_timeIntoAnimation>=1.0f) {
            [self endStrike];
        } else if (_timeIntoAnimation>=0.9f) {
            [_sprite setAlpha:0.5f];
        } else if (_timeIntoAnimation>=0.8f) {
            [_sprite setAlpha:1.0f];
        } else if (_timeIntoAnimation>=0.7f) {
            [_sprite setAlpha:0.5f];
        } 
    }
}

-(void)startStrike
{
    [[SoundEngine shared] playSound:@"lightning"];
    
    int lightningAnim = rand()%3;
    
    if (lightningAnim == 0) {
        [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"rainyLightning1Anim"];
    } else if(lightningAnim == 1) {
        [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"rainyLightning2Anim"];
    } else if(lightningAnim == 2) {
        [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"rainyLightning3Anim"];
    }
    
    [self repositionSprite];
    [_sprite setAlpha:1.0f];
    [[_sprite getCCSprite] setVisible:YES];
    _timeIntoAnimation = 0.0f;
    
}

-(void)endStrike
{
    [[_sprite getCCSprite] setVisible:NO];
    _waitUntilNewStrike = 6.0f + rand()%6;
}

-(void)repositionSprite
{
    //IPAD FIX: should be positioned at a random position in the background at a height where the top of the lightning bolt is just off the top of the screen
    [_sprite setScreenPosition:ccp(50 + rand()%330, 193)];
    
    
}

-(void)dealloc
{
    [_sprite release];
    [super dealloc];
}

@end
