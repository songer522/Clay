//
//  RunningSpeed.m
//  Clay
//
//  Created by Brian Cable on 8/30/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

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
        _targetSpeed = 0;
        _targetAcceleration = 0;
        _stamina = 20.0f;
        _inTurbo = false;
    }
    
    return self;
}

-(void)increaseSpeedTo:(float)target ForPeriod:(float)seconds
{
    _targetSpeed = target;
    _timeToLockSpeedAtTarget = seconds;
}

-(void)setPace:(float)modifier
{
    _pace = modifier;
    _targetSpeed = RUNNING_SPEED_MAX_VELOCITY * modifier;
    _targetAcceleration = RUNNING_SPEED_MAX_ACCELERATION * modifier;
}

-(void)setPlayer:(Player*)player
{
    _player = player;
}

-(void)startTurbo
{
    NSLog(@"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
    _inTurbo = true;
    _acceleration = RUNNING_SPEED_MAX_ACCELERATION;
    _stamina = RUNNING_SPEED_MAX_STAMINA;
    [self setPace:RUNNING_SPEED_PACE_TURBO];
}

-(void)endTurbo
{
    [self setPace:RUNNING_SPEED_PACE_ENDURANCE];
    _player.isTurbo = false;
    _inTurbo = false;
    _stamina = RUNNING_SPEED_MAX_STAMINA;
}

-(void) updateStamina:(float)dt
{
    if (_pace == RUNNING_SPEED_PACE_RECOVERY) {
        _stamina += 4.0f * dt;
        if (_stamina >= RUNNING_SPEED_MAX_STAMINA) {
            [self endTurbo];
        }
    } else {
        if (_atMax) {
            _stamina -= 3.0f * dt;
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
    if(_acceleration < (-1 * RUNNING_SPEED_MAX_ACCELERATION)) {
        _acceleration = 0;
    }
    if(_pace == RUNNING_SPEED_PACE_RECOVERY) {
        _acceleration -= 0.004f * dt;
    } else {
        if (_acceleration <= _targetAcceleration && _velocity < _targetSpeed) {
            _acceleration += 0.01f * _pace * dt;
        } else {
            _acceleration -= 0.01f * _pace * dt;
        }        
    }
}

-(void) updateVelocity:(float)dt
{
    _velocity += _acceleration;
    if (_velocity >= _targetSpeed ) {
        _atMax = true;
        if(_acceleration > 0.01f) {
            _acceleration = 3.0f * (_acceleration / 4.0f);
        }
    }
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
    
    NSLog(@"VELOCITY: %f, ACCEL: %f, TARGETV: %f TARGETA: %f STAMINA: %f PACE: %f",_velocity,_acceleration,_targetSpeed,_targetAcceleration,_stamina,_pace);
}



@end
