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
@synthesize reportedVelocity = _reportedVelocity;
@synthesize velocityModifier = _velocityModifier;
@synthesize inTurbo = _inTurbo;
@synthesize parent = _player;
@synthesize isStopped = _isStopped;
@synthesize isSlowedDown = _isSlowedDown;
@synthesize atMax = _atMax;
@synthesize isUnderwater = _isUnderwater;

#define RUNNING_SPEED_UNDERWATER_MODIFIER 1.5f

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
        _velocityModifier = 1.0f;
        _isStopped = false;
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
    _velocityModifier = 1.0f;
    _acceleration = 0.0f;
    _turboLeft = 0.0f;
    _inTurbo = false;
    _isStopped = true;
    _isSlowedDown = false;
}

-(void)startCollision
{
    if (_player.isJumping && _inTurbo) {
        _acceleration = 1.0f;
    } else if(_player.isJumping) {
        _velocity = -0.9f * _velocity;
        _acceleration = 0.35f;      
        [self stop];
    } else {
        if (_inTurbo) {
            [_player endTurbo:false];            
        }
        _velocity = -0.5f * _velocity;
        _acceleration = 0.5f;
        [self stop];
    }
}

-(void)slowDown
{
    if(_player.isInMidAir) {
        if (_inTurbo) {
            if (_player.isWindy) {
                [_player endTurbo:false];
            } else {
                [_player endTurbo:true];                
            }
        }
    }
    
    _isSlowedDown = true;
}

-(void)startTurbo
{
    _inTurbo = true;
    _turboLeft = _turboDuration;
    _velocity = RUNNING_SPEED_MODIFIER_VELOCITY_MAX * _normalVelocityMax;
}

-(void)landFromHighJump
{
    _acceleration *= 0.1f;
    _velocity *= 0.1f;
    if (_inTurbo) {
        [_player endTurbo:true];
    }
}

-(void)endBlow
{
    _velocity = RUNNING_SPEED_MODIFIER_VELOCITY_MAX * 0.5f * _normalVelocityMax;
    _acceleration = RUNNING_SPEED_MODIFIER_ACCELERATION_MAX * 0.5f * _normalAccelerationMax;
}

-(void)endTurbo
{
    _inTurbo = false;
}

-(void)applyFriction:(float)friction Dt:(float)dt
{
    _velocity = (1 - (friction * dt)) * _velocity;
}

-(void)startJump
{
    if (_inTurbo) {
        _velocity += 5.0f;        
    } else {
        _velocity += 2.5f;
    }
}

-(void)startKick
{
    _velocity *= 0.1f;
    _acceleration *= 0.1f;
}

-(void)startBlow
{
    _velocity = 0.0f;
    _acceleration = 0.0f;
}

-(void)update:(float)dt
{
    float modifier;
    modifier = _velocityModifier;
    if (_isUnderwater && _player.isInMidAir && !_player.isNewUnderwaterPhysics) {
        modifier = 1.5f;
    }
    
    if (!_isStopped) {
        
        _atMax = false;
        
        if (_inTurbo)
        {
            if (!_player.isInMidAir || _isUnderwater) {
                _acceleration += _turboAcceleration * RUNNING_SPEED_MODIFIER_ACCELERATION * dt * modifier;
                if (_acceleration > (RUNNING_SPEED_MODIFIER_ACCELERATION_MAX * _turboAccelerationMax * modifier)) {
                    _acceleration = RUNNING_SPEED_MODIFIER_ACCELERATION_MAX * _turboAccelerationMax * modifier;
                }
                
                _velocity += _acceleration * dt;
                
                if (_isSlowedDown) {
                    [self applyFriction:2.5f Dt:dt];
                }

                if (_velocity > (RUNNING_SPEED_MODIFIER_VELOCITY_MAX * _turboVelocityMax * modifier)) {
                    _atMax = true;
                    _velocity = RUNNING_SPEED_MODIFIER_VELOCITY_MAX * _turboVelocityMax * modifier;
                }

                _turboLeft -= dt;
                if (_turboLeft <= 0.0f) {
                    [_player endTurbo:true];
                }

            }
        }
        else
        {
            if (!_player.isInMidAir || _isUnderwater) {
                _acceleration += _normalAcceleration * RUNNING_SPEED_MODIFIER_ACCELERATION * dt * modifier;
                if (_acceleration > (RUNNING_SPEED_MODIFIER_ACCELERATION_MAX * _normalAccelerationMax * modifier)) {
                    _acceleration = RUNNING_SPEED_MODIFIER_ACCELERATION_MAX * _normalAccelerationMax * modifier;
                }
                
                _velocity += _acceleration * dt;
                
                if (_isSlowedDown) {
                    [self applyFriction:5.0f Dt:dt];
                }
                
                if (_velocity > (RUNNING_SPEED_MODIFIER_VELOCITY_MAX * _normalVelocityMax * modifier)) {
                    _velocity = RUNNING_SPEED_MODIFIER_VELOCITY_MAX * _normalVelocityMax * modifier;
                    _atMax = true;
                }

            }
            
        }
        
        //NSLog(@"Velocity: %f",_velocity);

    } else {
        [self applyFriction:5.0f Dt:dt];
    }
    
    _reportedVelocity = _velocity;
    if (_reportedVelocity < 1.0f) {
        _reportedVelocity = roundf(_reportedVelocity);
    }
    
    [_player updateSlow:dt];
    _isSlowedDown = false;
    
}

-(void)dealloc
{
    [_player release];
    [super dealloc];
}



@end
