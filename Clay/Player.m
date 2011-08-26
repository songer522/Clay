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
#define PLAYER_LOGX_OFFSET 8.55
#define PLAYER_SINX_MULTIPLIER 1
#define PLAYER_VELOCITY_MULTIPLIER 2
#define PLAYER_LOGX_MAX_VALUE 2.2

@implementation Player

+(id) playerForLayer:(id)layer
{
    return [[self alloc] initWithLayer:layer];
}

- (id)initWithLayer:(id)layer
{
    if ((self=[super init])) {

        _isRunning = true;
        _velocity = PLAYER_STARTING_VELOCITY;
        _xposition = PLAYER_STARTING_X_POSITION;
        
        [self setSprite:[Sprite spriteWithFile:@"player_idle_01.png" toLayer:layer]];
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
        float sinValue = [_sinCalculator calculate:kSinX];

        _velocity = (PLAYER_LOGX_MAGNITUDE * logValue + PLAYER_LOGX_OFFSET);
        _xposition = PLAYER_STARTING_X_POSITION + PLAYER_VELOCITY_MULTIPLIER * _velocity + sinValue * 5;
        
        [_sprite setPositionAtX:_xposition Y:PLAYER_STARTING_Y_POSITION];
    }
}


//for now, the _xposition will represent the final velocity.
//TODO: make velocity a class, that way it can be more dynamic and not clutter up this class
-(float)getVelocity
{
    return _velocity;
}

@end
