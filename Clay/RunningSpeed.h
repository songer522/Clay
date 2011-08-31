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
#define RUNNING_SPEED_PACE_RECOVERY 0.75f
#define RUNNING_SPEED_PACE_TURBO 2.0f
#define RUNNING_SPEED_MAX_STAMINA 20.0f

@class Player;

@interface RunningSpeed : NSObject
{
    bool _inTurbo;
    bool _atMax;
    
    float _velocity;
    float _acceleration;
    float _targetAcceleration;
    float _stamina;
    
    float _targetSpeed;                 //used when slowing down or speeding up
    
    float _timeToLockSpeedAtTarget;     //when positive, locks the speed at the target (when reached) until done
    
    float _pace;
    
    Player *_player;
    
    TimeEquation *_logCalculator;
    TimeEquation *_sinCalculator;
}

@property(readonly,nonatomic,assign) float velocity;

-(void)increaseSpeedTo:(float)target ForPeriod:(float)seconds;
-(void)startTurbo;
-(void)endTurbo;
-(void)update:(float)dt;
-(void)updateAcceleration:(float)dt;
-(void)updateStamina:(float)dt;
-(void)setPace:(float)modifier;
-(void)setPlayer:(Player*)player;

@end
