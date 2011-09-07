//
//  Runner.m
//  Clay
//
//  Created by Brian Cable on 8/30/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "Runner.h"
#import "RunningSpeed.h"
#import "GameObject.h"

#define RUNNER_VELOCITY_RATE 3.0f
#define RUNNER_STARTING_X_POSITION 20

@implementation Runner

@synthesize vx = _vx;
@synthesize vy = _vy;
@synthesize state = _state;
@synthesize isRunning = _isRunning;
@synthesize isJumping = _isJumping;

+(id) runnerWithSprite:(Sprite*)sprite Layer:(id)layer
{
    return [[self alloc] initWithSprite:(Sprite*)sprite Layer:(id)layer];
}

-(id)initWithSprite:(Sprite *)sprite Layer:(id)layer
{
    self = [super init];
    if (self) {
        // Initialization code here.
        _vx = 0.0f;
        _vy = 0.0f;
        [self changeToRunnerState:RUNNER_STATE_PRERACE];
        [self setPositionAtX:0 Y:0];
        [self setSprite:sprite];
        _speed = [RunningSpeed node];
        [_speed setPace:RUNNING_SPEED_PACE_ENDURANCE];
        [[[self getSprite] getCCSprite] setAnchorPoint:ccp(0,1)];
    }
    
    return self;
}


-(void)changeToRunnerState:(RunnerState)state
{
    switch (state) {
        case RUNNER_STATE_PRERACE:
            _isRunning = false;
            [_speed stop];
            break;
        case RUNNER_STATE_RUNNING:
            _isRunning = true;
            [_speed start];
        default:
            break;
    }
}

-(void)update:(float)dt
{
    float rate = RUNNER_VELOCITY_RATE * dt;
    float xposition = RUNNER_STARTING_X_POSITION + RUNNER_VELOCITY_RATE * _speed.velocity;
    [[self getSprite] setPositionAtX:xposition Y:_y];

    [_speed update:dt];
    
    _vx = _speed.velocity;
    
    if(_isRunning) {
        self.x += _vx * rate;
        self.y += _vy * rate;
    }
    
}

-(Sprite*)getSprite
{
    return self.sprite;
}

@end
