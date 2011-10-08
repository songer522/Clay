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

#define RUNNER_VELOCITY_RATE 14.0f
#define RUNNER_STARTING_X_POSITION 20

@implementation Runner

@synthesize state = _state;
@synthesize isRunning = _isRunning;
@synthesize isJumping = _isJumping;

+(id) runnerWithSprite:(Sprite*)sprite
{
    return [[self alloc] initWithSprite:(Sprite*)sprite];
}

-(id)initWithSprite:(Sprite *)sprite
{
    if ((self = [super init])) {
        // Initialization code here.
        [self changeToRunnerState:RUNNER_STATE_PRERACE];
        [self setPositionAtX:0 Y:0];
        [self setSprite:sprite];
        _speed = [RunningSpeed node];
        [[[self getSprite] getCCSprite] setAnchorPoint:ccp(0,1)];
        [self setOffsetForX:0 Y:-201];
        _ay = 0.0f;
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
    float rate = 30.0f * dt;
    
    [_speed update:dt];
    
    if (self.hasGravity) {
        _ay += 200.0f * dt;        
    }
    
    self.vx = RUNNER_VELOCITY_RATE * _speed.velocity;
    self.vy += _ay * rate;
    [super update:dt];
    
}

-(Sprite*)getSprite
{
    return self.sprite;
}

@end
