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
#import "LevelManager.h"
#import "GameController.h"
#import "GameObjectController.h"
#import "PListLoader.h"
#import "Camera.h"
#import "Bandages.h"

#define PLAYER_SPRITE_FILE @"player_idle_01.png"
#define PLAYER_STARTING_VELOCITY 0
#define PLAYER_STARTING_Y_POSITION 40
#define PLAYER_STARTING_X_POSITION 0
#define PLAYER_VELOCITY_MULTIPLIER 2

@implementation Player

@synthesize isJumping = _isJumping;

+(id) instance
{
    return [[self alloc] init];
}

- (id)init
{
    if ((self=[super init])) {

        NSDictionary *settings = [PListLoader loadPlistWithName:@"player"];
        NSAssert(settings!=nil,@"Error loading player.plist");
        
        NSDictionary *cameraTracking = [settings objectForKey:@"cameraTracking"];
        int cameraX = [[cameraTracking objectForKey:@"x"] intValue];
        int cameraY = [[cameraTracking objectForKey:@"y"] intValue];
        [[Camera sharedCamera] setCenter:CGPointMake(cameraX, cameraY)];
        
        GameObjectController *factory = [LevelManager shared].gameObjectFactory;
        [factory initializeGameObject:self Name:@"player"];
        
        _isJumping = false;
        
        _speed = [[RunningSpeed alloc] initWithSettings:settings];
        [_speed start];
        [self changeToRunnerState:RUNNER_STATE_RUNNING];
        
        hitPoints = 2;
        _bandages = [Bandages instance];

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
    
    [_bandages update:dt Player:self];

}



-(void)updateJump:(float)dt
{

    CollisionState state = [[self getCollision] currentState];

    if (state == COLLISION_STATE_GROUNDED) {
        if (_isJumping) {                
            _isJumping = false;
            [[AnimationController sharedController] replaceSprite:[self getSprite] withAnimationNamed:@"runningAnim" FrameNumber:8];
        }

        _jumpAcceleration = 0;
        _vy = 0;
    } else if(state == COLLISION_STATE_BUMPED_WALL) {
        _vx = 0;
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
    hitPoints -= 1;
    if (hitPoints <=0) {
        hitPoints = 0;
    }
    [_bandages setFrame:(2 - hitPoints)];    
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
