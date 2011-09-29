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
#import "ParticleSystem.h"
#import "Camera.h"
#import "Bandages.h"

#define PLAYER_SPRITE_FILE @"player_idle_01.png"
#define PLAYER_STARTING_VELOCITY 0
#define PLAYER_STARTING_Y_POSITION 40
#define PLAYER_STARTING_X_POSITION 0
#define PLAYER_VELOCITY_MULTIPLIER 2

@implementation Player

@synthesize isJumping = _isJumping;
@synthesize isDead = _isDead;

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
        _isDead = false;
        
        _speed = [[RunningSpeed alloc] initWithSettings:settings];
        _speed.parent = self;
        [_speed start];
        [self changeToRunnerState:RUNNER_STATE_RUNNING];
        
        hitPoints = 3;
        _bandages = [Bandages instance];
        _bandages.parent = self;
        
        _particleSystem = [ParticleSystem instance];

    }
    
    return self;
}

-(void)changeHealth:(int)amount
{
    if (amount > 0 && hitPoints<3) {
        hitPoints+=1;
        [_bandages setFrame:(4-hitPoints)];
    } else if(amount < 0 && hitPoints >= 0) {
        hitPoints-=1;
        [_bandages setFrame:(4-hitPoints)];
    }
    
    if (hitPoints <=0) {
        _isDead = true;
        [[SoundEngine shared] playSound:@"dead"];
    } else {
        [[SoundEngine shared] playSound:@"collision"];
    }
}

-(void)update:(float)dt Level:(Level *)level
{
    
    [super update:dt];
    //_jumpAcceleration += 10000.0f * dt;
    //self.vy += _jumpAcceleration * dt;
    
    
    [self updateJump:dt];
    CGPoint newPosition = [level checkCollisionForObject2:self];    

    [self setPositionAtX:newPosition.x Y:newPosition.y];    //for some reason the y position jitters without
                                                            //having this twice.
    
    [[Camera sharedCamera] moveTowardsTarget:dt];   //need this here, because the camera needs to be
                                                    //based on the new player position, but the player
                                                    //sprite can't be drawn on screen without the updated
                                                    //camera position. will cause jitteriness otherwise
    
    [self setPositionAtX:newPosition.x Y:newPosition.y];
    [_bandages update:dt];
    [_particleSystem update:dt];

}



-(void)updateJump:(float)dt
{

    CollisionState state = [[self getCollision] currentState];

    if (state == COLLISION_STATE_GROUNDED) {
        if (_isJumping) {                
            _isJumping = false;
            
            if (_speed.inTurbo) {
                [[AnimationController sharedController] replaceSprite:[self getSprite] withAnimationNamed:@"turboAnim" FrameNumber:8];
            } else {
                [[AnimationController sharedController] replaceSprite:[self getSprite] withAnimationNamed:@"runningAnim" FrameNumber:8];
            }
            
            float x = _x + 60.0f;
            float y = _y + 23.0f;
            [_particleSystem addDustImpactAtPosition:CGPointMake(x, y)];
            [[SoundEngine shared] playSound:@"jumpLand"];
        }

        _jumpAcceleration = 0;
        _vy = 0;
        _ay = 0;
    } else if(state == COLLISION_STATE_BUMPED_WALL) {
        _vx = 0;
        _vy = 0;
    }
}

-(void)startJump:(RunnerJump)height
{
    _firstFrameJumping = true;
    _vy = -175.0f * height;
    _y += 2.0f;
    _jumpAcceleration = 0;
    _isJumping = true;
    [[AnimationController sharedController] replaceSprite:[self getSprite] withAnimationNamed:@"jumpingAnim"];
    [[self getCollision] processNewCollisionState:COLLISION_STATE_MIDAIR];
    [self setPositionAtX:_x Y:_y];
    [[SoundEngine shared] playSound:@"jumpStart"];
}

-(void)startTurbo
{
    if (hitPoints > 1) {
        [_speed startTurbo];
        [[SoundEngine shared] playSound:@"turboStart"];
        [[AnimationController sharedController] replaceSprite:[self getSprite] withAnimationNamed:@"turboAnim"];
        hitPoints -=1;
        [_bandages setFrame:(4 - hitPoints)];        
    }

}

-(bool)getIsTurbo {
    return _speed.inTurbo;
}

-(void)endTurbo
{
    [[AnimationController sharedController] replaceSprite:[self getSprite] withAnimationNamed:@"runningAnim"];
    [_speed endTurbo];
    
}

-(void)startCollision
{
    if(_speed.inTurbo) {
        [self endTurbo];
    }
    
    [_speed startCollision];
    
    [self changeHealth:-1];
}

//used by background layers for scrolling
-(float)getVelocityX
{
    return _speed.velocity;
}

-(void)reset
{
    hitPoints = 3;
    [_bandages reset];
    [self resetSprite:[[LayerManager sharedLayers] currentLayer]];
}



-(void)resetSprite:(CCLayer*)layer
{
    CCSprite *playerSprite = [self getCCSprite];
    CCSprite *bandageSprite = [_bandages getCCSprite];
    [layer removeChild:playerSprite cleanup:NO];
    [layer removeChild:bandageSprite cleanup:NO];
    [layer addChild:playerSprite];
    [layer addChild:bandageSprite];
}

-(void)rechargeBattery
{
    [_bandages startRecharge];
}



-(void)dealloc
{
    [_speed release];
    [_bandages release];
    [_particleSystem release];
    [super dealloc];
}


@end
