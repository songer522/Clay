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
#define PLAYER_STARTING_Y_POSITION 40
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

@synthesize isJumping = _isJumping;

+(id) playerForLayer:(id)layer
{
    return [[self alloc] initWithLayer:layer];
}

- (id)initWithLayer:(id)layer
{
    if ((self=[super init])) {

        _isJumping = false;
        _vx = 0;
        _vy = 0;
        _yPosition = PLAYER_STARTING_Y_POSITION;
        
        [self setSprite:[Sprite spriteWithFile:PLAYER_SPRITE_FILE toLayer:layer]];
        [self setPositionAtX:PLAYER_STARTING_X_POSITION Y:PLAYER_STARTING_Y_POSITION];
        
        speed = [[RunningSpeed alloc] init];
        [speed setPace:RUNNING_SPEED_PACE_ENDURANCE];
        [speed setPlayer:self];
        [speed start];
        [self changeToRunnerState:RUNNER_STATE_RUNNING];
    }
    
    return self;
}

-(void)update:(float)dt
{

    if (_isRunning) {        
        [speed update:dt];
        
        float xposition = PLAYER_STARTING_X_POSITION + PLAYER_VELOCITY_MULTIPLIER * speed.velocity;
        
        [self updateJump:dt];
        
        [_sprite setPositionAtX:xposition Y:_yPosition];
    }
    
    
    
}

-(void)updateJump:(float)dt
{
    if (_isJumping) {
        _vy += 24.0f * dt;
        if(_vy > PLAYER_VELOCITY_Y_MAX) {
            _vy = PLAYER_VELOCITY_Y_MAX;
        }
        _y -= _vy;
        
        if (_y <= PLAYER_STARTING_Y_POSITION) {
            _y = PLAYER_STARTING_Y_POSITION;
            _isJumping = false;
        }
    }
}

-(void)startJump:(RunnerJump)height
{
    _vy = -3.0f * height;
    _isJumping = true;
}

-(void)startTurbo
{
    [speed startTurbo];
}

-(bool)getIsTurbo {
    return speed.inTurbo;
}


//used by background layers for scrolling
-(float)getVelocityX
{
    return speed.velocity;
}

-(void)dealloc
{
    [speed dealloc];
    [super dealloc];
}


@end
