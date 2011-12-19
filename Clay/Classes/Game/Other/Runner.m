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
#import "PlayerAction.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define MULTIPLIERX (IS_IPAD ? 2.133 : 1)
#define MULTIPLIERY (IS_IPAD ? 2.4 : 1)
#define RUNNER_VELOCITY_RATE  14.0f * MULTIPLIERX
#define RUNNER_STARTING_X_POSITION 20

@implementation Runner

@synthesize state = _state;
@synthesize isRunning = _isRunning;
@synthesize isJumping = _isJumping;
@synthesize isNewUnderwaterPhysics = _isNewUnderwaterPhysics;

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
        if (_isNewUnderwaterPhysics) {
            _ay += 20.0f * dt;            
        } else {
            _ay += 200.0f * dt;
        }
    }
    
    //underwater terminal velocity (except when swimming)
    if (_isNewUnderwaterPhysics && (!_thirdAction.inAction) && _vy > 50.0f) {
        _vy = 50.0f;
    }
    
    
    self.vx = RUNNER_VELOCITY_RATE * _speed.velocity * 45.0f * dt;    
    self.vy += _ay * rate;
    
    _x += _vx * dt;    
    _y -= _vy * dt;

    [self updateFlags]; //need to know if the player is falling

}

-(Sprite*)getSprite
{
    return self.sprite;
}

-(void)dealloc
{
    [_speed release];
    [super dealloc];
}

@end
