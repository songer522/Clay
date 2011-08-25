//
//  PlayerOnScreen.m
//  Clay
//
//  Created by Brian Cable on 8/25/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "Player.h"
#import "BaseClasses.h"
#import "cocos2d.h"

#define PLAYER_STARTING_VELOCITY 0
#define PLAYER_STARTING_Y_POSITION 95
#define PLAYER_STARTING_X_POSITION 20
#define PLAYER_LOGX_MULTIPLIER 1
#define PLAYER_LOGX_MAGNITUDE 5
#define PLAYER_LOGX_OFFSET 3.4
#define PLAYER_SINX_MULTIPLIER 5
#define PLAYER_VELOCITY_MULTIPLIER 2
#define PLAYER_LOGX_MAX_VALUE 3.2

@implementation Player

+(id) playerForScene:(id)scene
{
    return [[self alloc] initWithScene:scene];
}

- (id)initWithScene:(id)scene
{
    if ((self=[super init])) {

        _isRunning = true;
        _velocity = PLAYER_STARTING_VELOCITY;
        _xposition = PLAYER_STARTING_X_POSITION;
        
        [self setSprite:[Sprite spriteWithFile:@"player_idle_01.png" toScene:scene]];
        [self setPositionAtX:_xposition Y:PLAYER_STARTING_Y_POSITION];
        
        //log equation to be used for calculating speed
        _logCalculator = [[TimeEquation alloc] init];
        [_logCalculator setTimeMultiplier:PLAYER_LOGX_MULTIPLIER];
        
        //sin equation to be used for calculating the extra sway when the max log is reached
        _sinCalculator = [[TimeEquation alloc] init];
        [_sinCalculator setTimeMultiplier:PLAYER_SINX_MULTIPLIER];
        
        
    }
    
    return self;
}

-(void)updatePlayer:(float)dt
{

    if (_isRunning) {        
        [_logCalculator addTime:dt];
        float logValue = [_logCalculator calculate:kLogX];
        
        if (logValue >= PLAYER_LOGX_MAX_VALUE) {
            logValue = PLAYER_LOGX_MAX_VALUE;
            [_sinCalculator addTime:dt];
        }
        float sinValue = [_logCalculator calculate:kSinX];
        NSLog(@"LOG: %f, SIN: %f",logValue,sinValue);
        _velocity = (PLAYER_LOGX_MAGNITUDE * logValue + PLAYER_LOGX_OFFSET) + sinValue * 5;
        _xposition = PLAYER_STARTING_X_POSITION + PLAYER_VELOCITY_MULTIPLIER * _velocity;
        
        //NSLog(@"Position: %f",logValue);
        [_sprite setPositionAtX:_xposition Y:PLAYER_STARTING_Y_POSITION];
    }
}

@end
