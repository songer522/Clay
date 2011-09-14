//
//  RunningSpeed.h
//  Clay
//
//  Created by Brian Cable on 8/30/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseClasses.h"

#define RUNNING_SPEED_MAX_VELOCITY 20.0f
#define RUNNING_SPEED_MAX_ACCELERATION 0.3f
#define RUNNING_SPEED_TURBO_VELOCITY 40.0f
#define RUNNING_SPEED_TURBO_PERIOD 7.0f
#define RUNNING_SPEED_PACE_ENDURANCE 1.0f
#define RUNNING_SPEED_PACE_RECOVERY 0.8f
#define RUNNING_SPEED_PACE_TURBO 2.0f
#define RUNNING_SPEED_MAX_STAMINA 20.0f
#define RUNNING_SPEED_MIN_VELOCITY 18.0f

@class Player;

@interface RunningSpeed : NSObject
{
    bool _isStopped;
    
    bool _inTurbo;
    
    float _velocity;
    float _acceleration;
    float _stamina;
    float _pace;
    
    Player *_player;
}

@property(readonly,nonatomic,assign) float velocity;
@property(readonly,nonatomic,assign) bool inTurbo;

#pragma mark - inits
+(id)node;

#pragma mark - controls
-(void)start;
-(void)stop;
-(void)reset;

#pragma mark - public methods
-(void)startTurbo;
-(void)endTurbo;
-(void)update:(float)dt;
-(void)setPace:(float)modifier;
-(void)setPlayer:(Player*)player;
-(void)startCollision;

@end
