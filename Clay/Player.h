//
//  Player.h
//  Clay
//
//  Created by Brian Cable on 8/25/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//
//  The main player and runner in the game.

#import <Foundation/Foundation.h>
#import "BaseClasses.h"
#import "Runner.h"
#import "cocos2d.h"

typedef enum {
    JUMP_HIGH = 3,
    JUMP_MEDIUM = 2,
    JUMP_SHORT = 1
} RunnerJump;

@class  RunningSpeed;

@interface Player : Runner
{
    bool _isJumping;
    bool _firstFrameJumping;
    
    float _yPosition;
    float _jumpAcceleration;
}

+(id) instance;                                 //constructor

-(float)getVelocityX;                           //get the current velocity (read-only, for now)
-(void)update:(float)dt Level:(Level*)level;    //update, dt = seconds since last update

-(void)startJump:(RunnerJump)height;
-(void)updateJump:(float)dt;

-(void)startTurbo;
-(bool)getIsTurbo;

-(void)startCollision;

@property(nonatomic,assign) bool isJumping;

@end
