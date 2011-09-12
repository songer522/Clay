//
//  PlayerOnScreen.m
//  Clay
//
//  Created by Brian Cable on 8/25/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "cocos2d.h"
#import "BaseClasses.h"
#import "Player.h"
#import "RunningSpeed.h"

#define PLAYER_SPRITE_FILE @"player_idle_01.png"
#define PLAYER_STARTING_VELOCITY 0
#define PLAYER_STARTING_Y_POSITION 40
#define PLAYER_STARTING_X_POSITION 0
#define PLAYER_LOGX_MULTIPLIER 1
#define PLAYER_LOGX_MAGNITUDE 5
#define PLAYER_LOGX_OFFSET 8.55
#define PLAYER_SINX_MULTIPLIER 1
#define PLAYER_SINX_MAGNITUDE 5
#define PLAYER_VELOCITY_MULTIPLIER 2
#define PLAYER_LOGX_MAX_VALUE 2.2
#define PLAYER_VELOCITY_Y_MAX 900.0f

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
        
        [self setSprite:[Sprite spriteWithFile:PLAYER_SPRITE_FILE toLayer:layer]];
        [self setPositionAtX:PLAYER_STARTING_X_POSITION Y:PLAYER_STARTING_Y_POSITION];
        
        _speed = [[RunningSpeed alloc] init];
        [_speed setPace:RUNNING_SPEED_PACE_ENDURANCE];
        [_speed setPlayer:self];
        [_speed start];
        [self changeToRunnerState:RUNNER_STATE_RUNNING];
        
        [[[self getSprite] getCCSprite] setAnchorPoint:ccp(0.5,1)];
        [self setOffsetForX:0 Y:571];

    }
    
    return self;
}

-(void)update:(float)dt Level:(Level *)level
{
    if(_vy > PLAYER_VELOCITY_Y_MAX) {
        _vy = PLAYER_VELOCITY_Y_MAX;
    }
    
    [self updateJump:dt];
    [super update:dt];
    [self setPositionAtX:_x Y:_y];
    
    CGPoint newPosition = [level checkCollisionForObject:self AtPoint:[self getPosition]];

    [self setPositionAtX:newPosition.x Y:newPosition.y];
}



-(void)updateJump:(float)dt
{

    CollisionState state = [[self getCollision] currentState];

    if (state == COLLISION_STATE_GROUNDED) {
        if (_isJumping) {                
            _isJumping = false;
            [[AnimationController sharedController] replaceSprite:[self getSprite] withAnimationNamed:@"runningAnim"];
        }

        _vy = 0;
    }
}

-(void)startJump:(RunnerJump)height
{
    _firstFrameJumping = true;
    _vy = -220.0f * height;
    _y += 2.0f;
    _isJumping = true;
    [[AnimationController sharedController] replaceSprite:[self getSprite] withAnimationNamed:@"jumpingAnim"];
    [[self getCollision] processNewTile:@"" CollisionState:COLLISION_STATE_MIDAIR];
    [self setPositionAtX:_x Y:_y];
}

-(void)startTurbo
{
    [_speed startTurbo];
}

-(bool)getIsTurbo {
    return _speed.inTurbo;
}


//used by background layers for scrolling
-(float)getVelocityX
{
    return _speed.velocity;
}

-(void)dealloc
{
    [_speed dealloc];
    [super dealloc];
}


@end
