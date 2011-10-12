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

@class RunningSpeed;
@class Battery;
@protocol PlayerAction;

@interface Player : Runner
{
    bool _isJumping;
    bool _isTripping;
    bool _firstFrameJumping;
    bool _isDead;
    bool _isInMidAir;
    
    float _yPosition;
    float _jumpAcceleration;
    float _waitToGetUp;
    
    bool _isHighJump;
    
    
    int hitPoints;
    Battery *_battery;
    
    ParticleSystem *_particleSystem;
    
    RunnerJump _jumpHeight;
    
    Sprite *_buttonJump;
    Sprite *_buttonKick;
    Sprite *_buttonSprint;
    
    id <PlayerAction> _thirdAction; //playeraction

}

@property(nonatomic,assign) bool isDead;
@property(nonatomic,assign) bool isTripping;
@property(nonatomic,assign) bool isInMidAir;
@property(nonatomic,assign) bool isJumping;
@property(nonatomic,retain) Battery *battery;

+(id) instance;                                 //constructor

-(float)getVelocityX;                           //get the current velocity (read-only, for now)
-(void)update:(float)dt Level:(Level*)level;    //update, dt = seconds since last update

-(void)startJump:(RunnerJump)type;
-(void)boostJump:(RunnerJump)type;
-(void)endJump;
-(void)updateJump:(float)dt;

-(void)startTurbo;
-(bool)getIsTurbo;

-(void)endTurbo;

-(void)startKick;

-(void)startThirdAction;

-(void)startCollision:(PlayerEffect)effect Obstacle:(GameObject*)obstacle;

-(void)changeHealth:(int)amount;

-(void)reset;
-(void)resetSprite:(CCLayer*)layer;
-(void)rechargeBattery;

-(void)setVelocity:(float)velocity;

-(void)private_StartPlayerCollision;

@end
