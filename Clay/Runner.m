//
//  Runner.m
//  Clay
//
//  Created by Brian Cable on 8/30/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "Runner.h"

@implementation Runner

@synthesize vx = _vx;
@synthesize vy = _vy;
@synthesize x = _x;
@synthesize y = _y;
@synthesize state = _state;
@synthesize isRunning = _isRunning;
@synthesize isJumping = _isJumping;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        _vx = 0.0f;
        _vy = 0.0f;
        _x = 0;
        _y = 0;
        [self changeToRunnerState:RUNNER_STATE_PRERACE];
    }
    
    return self;
}

+(id) runnerForLayer:(id)layer
{
    return [[self alloc] init];
}

-(void)changeToRunnerState:(RunnerState)state
{
    switch (state) {
        case RUNNER_STATE_PRERACE:
            _isRunning = false;
            break;
            
        default:
            break;
    }
}



/*
- (id)initWithLayer:(id)layer
{
    if ((self=[super init])) {
        
        _isRunning = true;
        
        [self setSprite:[Sprite spriteWithFile:PLAYER_SPRITE_FILE toLayer:layer]];
        [self setPositionAtX:PLAYER_STARTING_X_POSITION Y:PLAYER_STARTING_Y_POSITION];
        
        //log equation to be used for calculating speed
        _logCalculator = [[TimeEquation alloc] init];
        [_logCalculator setTimeMultiplier:PLAYER_LOGX_MULTIPLIER];
        
        //sin equation to be used for calculating the extra sway when the max log is reached
        _sinCalculator = [[TimeEquation alloc] init];
        [_sinCalculator setTimeMultiplier:PLAYER_SINX_MULTIPLIER];
        
        
    }
    
    return self;
}*/


@end
