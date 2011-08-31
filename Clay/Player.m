//
//  PlayerOnScreen.m
//  Clay
//
//  Created by Brian Cable on 8/25/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "Player.h"
#import "BaseClasses.h"
#import "cocos2d.h"

#define PLAYER_SPRITE_FILE @"player_idle_01.png"
#define PLAYER_STARTING_VELOCITY 0
#define PLAYER_STARTING_Y_POSITION 97
#define PLAYER_STARTING_X_POSITION 20
#define PLAYER_LOGX_MULTIPLIER 1
#define PLAYER_LOGX_MAGNITUDE 5
#define PLAYER_LOGX_OFFSET 8.55
#define PLAYER_SINX_MULTIPLIER 1
#define PLAYER_SINX_MAGNITUDE 5
#define PLAYER_VELOCITY_MULTIPLIER 2
#define PLAYER_LOGX_MAX_VALUE 2.2
#define PLAYER_VELOCITY_Y_MAX 10.0f

@implementation Player

@synthesize isRunning = _isRunning;
@synthesize isJumping = _isJumping;
@synthesize isTurbo = _isTurbo;

+(id) playerForLayer:(id)layer
{
    return [[self alloc] initWithLayer:layer];
}

- (id)initWithLayer:(id)layer
{
    if ((self=[super init])) {

        _isRunning = true;
        _isJumping = false;
        _isTurbo = false;
        //_velocityX = PLAYER_STARTING_VELOCITY;
        _velocityY = 0;
        _yPosition = PLAYER_STARTING_Y_POSITION;
        
        [self setSprite:[Sprite spriteWithFile:PLAYER_SPRITE_FILE toLayer:layer]];
        [self setPositionAtX:PLAYER_STARTING_X_POSITION Y:PLAYER_STARTING_Y_POSITION];
        
        //log equation to be used for calculating speed
        _logCalculator = [[TimeEquation alloc] init];
        [_logCalculator setTimeMultiplier:PLAYER_LOGX_MULTIPLIER];
        
        //sin equation to be used for calculating the extra sway when the max log is reached
        _sinCalculator = [[TimeEquation alloc] init];
        [_sinCalculator setTimeMultiplier:PLAYER_SINX_MULTIPLIER];
        
        
        speed = [[RunningSpeed alloc] init];
        [speed setPace:RUNNING_SPEED_PACE_ENDURANCE];
    }
    
    return self;
}

-(void)update:(float)dt
{

    if (_isRunning) {        
        float xposition = PLAYER_STARTING_X_POSITION + PLAYER_VELOCITY_MULTIPLIER * speed.velocity;
        
        [self updateJump:dt];
        
        [_sprite setPositionAtX:xposition Y:_yPosition];
    }
    
    [speed update:dt];
}

-(void)updateJump:(float)dt
{
    [speed update:dt];
    
    if (_isJumping) {
        _velocityY += 24.0 * dt;
        if(_velocityY > PLAYER_VELOCITY_Y_MAX) {
            _velocityY = PLAYER_VELOCITY_Y_MAX;
        }
        _yPosition -= _velocityY;
        
        if (_yPosition <= PLAYER_STARTING_Y_POSITION) {
            _yPosition = PLAYER_STARTING_Y_POSITION;
            _isJumping = false;
        }
    }
}

-(void)startJump:(RunnerJump)height
{
    _velocityY = -3.0f * height;
    _isJumping = true;
}

-(void)startTurbo
{
    [speed startTurbo];
    _isTurbo = true;
}


//TODO: make velocity a class, that way it can be more dynamic and not clutter up this class
-(float)getVelocityX
{
    //return _velocityX;
    return speed.velocity;
}

-(void)dealloc
{
    [_logCalculator release];
    [_sinCalculator release];
    [super dealloc];
}


@end
