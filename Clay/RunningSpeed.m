//
//  RunningSpeed.m
//  Clay
//
//  Created by Brian Cable on 8/30/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//
//
//
//  Logic for updating the acceleration, simplified:
//
//  if we're going below the target speed, we want to speed up:
//     if we're in turbo, we accelerate like normal
//     if we're in endurance, we accelerate like normal,
//     if we're in recovery, we don't accelerate, although we may switch pace if we get too slow.
//     if we stumbled, we could be slowing down or stopping altogether.
//
//  if we're above the target speed, we want to slow down
//     if we're in turbo, we don't decelerate, but stop accelerating
//     if we're in endurance, we decelerate by a good amount
//     if we're in recovery, we decelerate a little
//     if we stumbled, we either decelerate a lot, or we've stopped completely
//
///////////////////////////////////////////////////////////////////////////////////////////////////////

#import "RunningSpeed.h"
#import "Player.h"

@implementation RunningSpeed

@synthesize velocity = _velocity;
@synthesize inTurbo = _inTurbo;

+(id)node
{
    return [[self alloc] init];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        [self reset];
    }
    
    return self;
}

-(void)start
{
    _isStopped = false;
}

-(void)stop
{
    _isStopped = true;
}

-(void)reset
{
    _velocity = 4.0f;
    _acceleration = 0.0f;
    _stamina = 20.0f;
    _inTurbo = false;
    _isStopped = true;
    _pace = RUNNING_SPEED_PACE_ENDURANCE;
}

-(void)setPace:(float)modifier
{
    _pace = modifier;
}

-(void)setPlayer:(Player*)player
{
    _player = player;
}

-(void)startTurbo
{
    _inTurbo = true;
    _acceleration = RUNNING_SPEED_MAX_ACCELERATION;
    _stamina = RUNNING_SPEED_MAX_STAMINA;
    [self setPace:RUNNING_SPEED_PACE_TURBO];
}

-(void)endTurbo
{
    [self setPace:RUNNING_SPEED_PACE_ENDURANCE];
    _inTurbo = false;
    _stamina = RUNNING_SPEED_MAX_STAMINA;
}

-(void)startCollision
{
    _velocity = 0.0f;
    _acceleration = 0.1f;
    _stamina = 20.0f;
    _inTurbo = false;
    [self setPace:RUNNING_SPEED_PACE_ENDURANCE];
}


-(void)update:(float)dt
{
    if (!_isStopped) {
        float prevVelocity = _velocity;
        
        if (_acceleration < RUNNING_SPEED_MAX_ACCELERATION) {
            _acceleration += 0.5f * _pace * dt;
        }
        
        _velocity += _acceleration;
        
        if (_velocity > (RUNNING_SPEED_MAX_VELOCITY * _pace)) {
            _velocity = RUNNING_SPEED_MAX_VELOCITY * _pace;
        }
        
        if (_inTurbo) {
            _stamina -= 2.0f * dt;
            if (_stamina <= 0.0f) {
                [self setPace:RUNNING_SPEED_PACE_ENDURANCE];
            }
        }
    }
}



@end
