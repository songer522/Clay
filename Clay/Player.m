//
//  Player.m
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
#define PLAYER_VELOCITY_MULTIPLIER 2

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
        
        [self setSprite:[Sprite spriteWithFile:PLAYER_SPRITE_FILE]];
        [self setPositionAtX:PLAYER_STARTING_X_POSITION Y:PLAYER_STARTING_Y_POSITION];
        
        _speed = [[RunningSpeed alloc] init];
        [_speed setPace:RUNNING_SPEED_PACE_ENDURANCE];
        [_speed setPlayer:self];
        [_speed start];
        [self changeToRunnerState:RUNNER_STATE_RUNNING];
        
        [[[self getSprite] getCCSprite] setAnchorPoint:ccp(0.5,0.5)];
        self.boundingBox = CGRectMake(-22, -65, 50, 120);

    }
    
    return self;
}

-(void)update:(float)dt Level:(Level *)level
{
    [super update:dt];
    if (_isJumping) {
        _jumpAcceleration += 12.0f;
        _vy += _jumpAcceleration * dt;
    }
    
    [self updateJump:dt];
    CGPoint newPosition = [level checkCollisionForObject:self];    

    [self setPositionAtX:newPosition.x Y:newPosition.y];    //for some reason the y position jitters without
                                                            //having this twice.
    
    [[Camera sharedCamera] moveTowardsTarget:dt];   //need this here, because the camera needs to be
                                                    //based on the new player position, but the player
                                                    //sprite can't be drawn on screen without the updated
                                                    //camera position. will cause jitteriness otherwise
    
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

        _jumpAcceleration = 0;
        _vy = 0;
    }
}

-(void)startJump:(RunnerJump)height
{
    _firstFrameJumping = true;
    _vy = -250.0f * height;
    _y += 2.0f;
    _jumpAcceleration = 0;
    _isJumping = true;
    [[AnimationController sharedController] replaceSprite:[self getSprite] withAnimationNamed:@"jumpingAnim"];
    [[self getCollision] processNewCollisionState:COLLISION_STATE_MIDAIR];
    [self setPositionAtX:_x Y:_y];
}

-(void)startTurbo
{
    [_speed startTurbo];
}

-(bool)getIsTurbo {
    return _speed.inTurbo;
}

-(void)startCollision
{
    [_speed startCollision];
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
