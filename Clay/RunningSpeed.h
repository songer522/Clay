//
//  RunningSpeed.h
//  Clay
//
//  Created by Brian Cable on 8/30/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseClasses.h"


#define RUNNING_SPEED_MODIFIER_VELOCITY_MAX 0.25f
#define RUNNING_SPEED_MODIFIER_ACCELERATION_MAX 20.0f
#define RUNNING_SPEED_MODIFIER_ACCELERATION 50.0f

@class Player;

@interface RunningSpeed : NSObject
{
    Player *_player;
    
    bool _isStopped;
    
    bool _inTurbo;
    
    float _velocity;
    float _acceleration;
    float _turboLeft;
    
    
    float _normalVelocityMax;
    float _normalAcceleration;
    float _normalAccelerationMax;
    
    float _turboAcceleration;
    float _turboAccelerationMax;
    float _turboDuration;
    float _turboVelocityMax;
    
    bool _isSlowedDown;
}

@property(nonatomic,assign) float velocity;
@property(readonly,nonatomic,assign) bool inTurbo;
@property(readonly,nonatomic,assign) bool isStopped;
@property(nonatomic,retain) Player *parent;
@property(nonatomic,assign) bool isSlowedDown;

#pragma mark - inits
+(id)node;
-(id) initWithSettings:(NSDictionary*)settings;

#pragma mark - controls
-(void)start;
-(void)stop;
-(void)reset;

#pragma mark - public methods
-(void)startCollision;
-(void)startTurbo;

-(void)startJump; //gives a slight boost to velocity in case they're not moving too fast, especially if they're slowed down by sand pits

-(void)slowDown;
-(void)endTurbo;
-(void)startKick;
-(void)applyFriction:(float)friction Dt:(float)dt;
-(void)landFromHighJump;
-(void)update:(float)dt;

@end
