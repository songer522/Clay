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

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        _velocity = 0.0f;
        _acceleration = 0.0f;
        _targetVelocity = 0;
        _targetAcceleration = 0;
        _stamina = 20.0f;
        _inTurbo = false;
    }
    
    return self;
}

-(void)increaseSpeedTo:(float)target ForPeriod:(float)seconds
{
    _targetVelocity = target;
    _timeToLockSpeedAtTarget = seconds;
}

-(void)setPace:(float)modifier
{
    _pace = modifier;
    _targetVelocity = RUNNING_SPEED_MAX_VELOCITY * modifier;
    _targetAcceleration = RUNNING_SPEED_MAX_ACCELERATION * modifier;
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
    [_player setIsTurbo:false];
    _inTurbo = false;
    _stamina = RUNNING_SPEED_MAX_STAMINA;
}

-(void) updateStamina:(float)dt
{
    if (_pace == RUNNING_SPEED_PACE_RECOVERY) {
        _stamina += 5.0f * dt;
        if (_stamina >= RUNNING_SPEED_MAX_STAMINA && _inTurbo) {
            [self endTurbo];
        }
    } else {
        if (_atMax) {
            _stamina -= 2.0f * dt;
        } else {
            _stamina -= 1.0f * dt;
        }
        
        if(_stamina <= 0.0f && _timeToLockSpeedAtTarget <= 0.0f) {
            [self setPace:RUNNING_SPEED_PACE_RECOVERY];
        }
    }    
}

-(void) updateAcceleration:(float)dt
{
    if(_velocity <= _targetVelocity) {
        [self updateAccelerationWhenBelowTargetVelocity:dt];
    } else {
        [self updateAccelerationWhenAboveTargetVelocity:dt];
    }
}

-(void) updateAccelerationWhenBelowTargetVelocity:(float)dt
{
    float baseRate = 0.01f;
    
    //don't let the guy get too slow
    if (_velocity <= RUNNING_SPEED_MIN_VELOCITY) {
        baseRate = baseRate * 6.0f;
        if (_pace == RUNNING_SPEED_PACE_RECOVERY) {
            _stamina = RUNNING_SPEED_MAX_STAMINA;
            [self setPace:RUNNING_SPEED_PACE_ENDURANCE];
        }
    }
    
    if (_pace == RUNNING_SPEED_PACE_TURBO) {
        _acceleration +=  3.0f * baseRate * dt;        
    } else if (_pace == RUNNING_SPEED_PACE_ENDURANCE) {
        _acceleration +=  baseRate * dt;
    } else if (_pace == RUNNING_SPEED_PACE_RECOVERY) {
        _acceleration -= 0.5f * baseRate * dt;
    }
    
    if (_acceleration >= _targetAcceleration) {
        _acceleration = _targetAcceleration;
    }
}

-(void) updateAccelerationWhenAboveTargetVelocity:(float)dt
{
    float baseRate = 0.01f;
    
    if (_pace == RUNNING_SPEED_PACE_TURBO) {
        _acceleration -=  baseRate * dt;        
    } else if (_pace == RUNNING_SPEED_PACE_ENDURANCE) {
        _acceleration -=  baseRate * dt;
    } else if (_pace == RUNNING_SPEED_PACE_RECOVERY) {
        _acceleration -= 0.5f * baseRate * dt;
    }
    
}

-(void) updateVelocity:(float)dt
{
    _velocity += _acceleration;
    if (_velocity >= _targetVelocity ) {
        _atMax = true;
        if(_acceleration > 0.01f) {
            _acceleration = 3.0f * (_acceleration / 4.0f);
        }
    }
    
    if(_velocity < 0) _velocity = 0.0f;
}

-(void)update:(float)dt
{
    _atMax = false;
    
    /*
    _timeToLockSpeedAtTarget -= dt;
    if(_inTurbo && _timeToLockSpeedAtTarget <= 0.0f) {
        [self endTurbo];
    }*/
    
    [self updateAcceleration:dt];
    [self updateVelocity:dt];
    [self updateStamina:dt];
    
    NSLog(@"VELOCITY: %f, ACCEL: %f, TARGETV: %f TARGETA: %f STAMINA: %f PACE: %f",_velocity,_acceleration,_targetVelocity,_targetAcceleration,_stamina,_pace);
}



@end
