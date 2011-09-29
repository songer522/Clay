//
//  RunningSpeed.m
//  Clay
//
//  Created by Brian Cable on 8/30/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//
///////////////////////////////////////////////////////////////////////////////////////////////////////

#import "RunningSpeed.h"
#import "Player.h"

@implementation RunningSpeed

@synthesize velocity = _velocity;
@synthesize inTurbo = _inTurbo;
@synthesize parent = _player;

+(id)node
{
    return [[self alloc] init];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        _normalVelocityMax = 10.0f;
        _normalAcceleration = 1.0f;
        _normalAccelerationMax = 1.0f;
        _turboAcceleration = 2.0f;
        _turboAccelerationMax = 2.0f;
        _turboVelocityMax = 2.0f;
        _turboDuration = 3.0f;
        [self reset];
    }
    
    return self;
}

-(id) initWithSettings:(NSDictionary*)settings
{
    self = [super init];
    if (self) {
        NSDictionary *normalBehavior = [settings objectForKey:@"normalBehavior"];
        NSAssert(normalBehavior!=nil,@"Error loading player settings (player.plist)");
        
        _normalAcceleration = [[normalBehavior objectForKey:@"acceleration"] floatValue];
        _normalVelocityMax = [[normalBehavior objectForKey:@"velocityMax"] floatValue];
        _normalAccelerationMax = [[normalBehavior objectForKey:@"accelerationMax"] floatValue];
        
        NSDictionary *turboBehavior = [settings objectForKey:@"turboBehavior"];
        NSAssert(turboBehavior!=nil,@"Error loading player settings (player.plist)");
        
        _turboAcceleration = [[turboBehavior objectForKey:@"acceleration"] floatValue];
        _turboAccelerationMax = [[turboBehavior objectForKey:@"accelerationMax"] floatValue];
        _turboDuration = [[turboBehavior objectForKey:@"duration"] floatValue];
        _turboVelocityMax = [[turboBehavior objectForKey:@"velocityMax"] floatValue];
        
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
    _turboLeft = 0.0f;
    _inTurbo = false;
    _isStopped = true;
}

-(void)startCollision
{
    _velocity = 1.0f;
    _acceleration = 0.5f;
    _inTurbo = false;
}

-(void)startTurbo
{
    _inTurbo = true;
    _turboLeft = _turboDuration;
    _velocity = RUNNING_SPEED_MODIFIER_VELOCITY_MAX * _normalVelocityMax;
}

-(void)endTurbo
{
    _inTurbo = false;
    [_player endTurbo];
}

-(void)update:(float)dt
{
    if (!_isStopped) {
        
        if (_inTurbo)
        {
            _acceleration += _turboAcceleration * RUNNING_SPEED_MODIFIER_ACCELERATION * dt;
            if (_acceleration > RUNNING_SPEED_MODIFIER_ACCELERATION_MAX * _turboAccelerationMax) {
                _acceleration = RUNNING_SPEED_MODIFIER_ACCELERATION_MAX * _turboAccelerationMax;
            }
            
            _velocity += _acceleration * dt;
            if (_velocity > RUNNING_SPEED_MODIFIER_VELOCITY_MAX * _turboVelocityMax) {
                _velocity = RUNNING_SPEED_MODIFIER_VELOCITY_MAX * _turboVelocityMax;
            }
            
            _turboLeft -= dt;
            if (_turboLeft <= 0.0f) {
                [self endTurbo];
            }
        }
        else
        {
            _acceleration += _normalAcceleration * RUNNING_SPEED_MODIFIER_ACCELERATION * dt;
            if (_acceleration > RUNNING_SPEED_MODIFIER_ACCELERATION_MAX * _normalAccelerationMax) {
                _acceleration = RUNNING_SPEED_MODIFIER_ACCELERATION_MAX * _normalAccelerationMax;
            }
            
            _velocity += _acceleration * dt;
            if (_velocity > RUNNING_SPEED_MODIFIER_VELOCITY_MAX * _normalVelocityMax) {
                _velocity = RUNNING_SPEED_MODIFIER_VELOCITY_MAX * _normalVelocityMax;
            }
        }
    }
}

-(void)dealloc
{
    [super dealloc];
}



@end
