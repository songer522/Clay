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
#import "GameObject.h"
#import "GameObjectController.h"
#import "PListLoader.h"
#import "ParticleSystem.h"
#import "PlayerActionFactory.h"
#import "Camera.h"
#import "Battery.h"

#define PLAYER_SPRITE_FILE @"player_idle_01.png"
#define PLAYER_STARTING_VELOCITY 0
#define PLAYER_STARTING_Y_POSITION 40
#define PLAYER_STARTING_X_POSITION 0
#define PLAYER_VELOCITY_MULTIPLIER 2

@implementation Player

@synthesize isJumping = _isJumping;
@synthesize isDead = _isDead;
@synthesize isTripping = _isTripping;
@synthesize isInMidAir = _isInMidAir;
@synthesize battery = _battery;

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
        _isInMidAir = false;
        _waitToGetUp = 0.0f;
        
        _speed = [[RunningSpeed alloc] initWithSettings:settings];
        _speed.parent = self;
        [_speed start];
        [self changeToRunnerState:RUNNER_STATE_RUNNING];
        
        hitPoints = 4;
        
        _isHighJump = false;
        
        _adjustX = 0.0f;
        
        _particleSystem = [ParticleSystem instance];
        
        _thirdAction = [PlayerActionFactory buildPlayerAction:PLAYER_ACTION_KICK];
        //_thirdAction = [PlayerActionFactory buildPlayerAction:PLAYER_ACTION_WOO];
        [_thirdAction setParent:self];    
        
    }
    
    return self;
}

-(void)changeHealth:(int)amount
{
    if (amount > 0 && hitPoints<4) {
        hitPoints+=1;
        [_battery setFrame:(5-hitPoints)];
    } else if(amount < 0 && hitPoints >= 0) {
        hitPoints-=1;
        [_battery setFrame:(5-hitPoints)];
    }
    
    if (hitPoints <=0) {
        _isDead = true;
        [[SoundEngine shared] playSound:@"dead"];
    }
}

-(void)update:(float)dt Level:(Level *)level
{
    
    [super update:dt];
    
    
    [self updateJump:dt];
    
    if (_adjustX != 0.0f) {
        self.x += _adjustX;
        _adjustX = 0.0f;
        [[AnimationController sharedController] replaceSprite:[self getSprite] withAnimationNamed:@"runningAnim" FrameNumber:8];

    }
    
    CGPoint newPosition = [level checkCollisionForObject2:self];    

    [self setPositionAtX:newPosition.x Y:newPosition.y];    //for some reason the y position jitters without
                                                            //having this twice.
    
    [[Camera sharedCamera] moveTowardsTarget:dt PlayerOnGround:!_isInMidAir];   //need this here, because the camera needs to be
                                                    //based on the new player position, but the player
                                                    //sprite can't be drawn on screen without the updated
                                                    //camera position. will cause jitteriness otherwise
    
    [self setPositionAtX:newPosition.x Y:newPosition.y];
    [_battery update:dt];
    [_particleSystem update:dt];
    
    if (_isTripping) {
        _waitToGetUp -= dt;
        if (_waitToGetUp <= 0.0f) {
            _isTripping = false;
            [self endTurbo];
            [_speed start];
            [[AnimationController sharedController] replaceSprite:[self getSprite] withAnimationNamed:@"runningAnim" FrameNumber:8];
        }
    }
    
    if(_speed.isStopped && !_isTripping) {
        _waitToGetUp -= dt;
        if (_waitToGetUp <= 0.0f) {
            [_speed start];
        }
    }
    
    [_thirdAction update:dt];

}



-(void)updateJump:(float)dt
{

    CollisionState state = [[self getCollision] currentState];

    _isInMidAir = false;
    
    if (state == COLLISION_STATE_MIDAIR) {
        _isInMidAir = true;
    } else if (state == COLLISION_STATE_GROUNDED) {
        
        if (_isJumping && !_isTripping) {                
            _isJumping = false;
            
            if (_speed.inTurbo) {
                [[AnimationController sharedController] replaceSprite:[self getSprite] withAnimationNamed:@"turboAnim" FrameNumber:8];
            } else {
                [[AnimationController sharedController] replaceSprite:[self getSprite] withAnimationNamed:@"runningAnim" FrameNumber:8];
            }
            
            if (_isHighJump) {
                _isHighJump = false;
                [_speed landFromHighJump];
            }
            
            float x = _x + 60.0f;
            float y = _y + 23.0f;
            
            if (_speed.velocity < 0.0f) {
                _speed.velocity = 0.0f;
            }
            
            [_particleSystem addDustImpactAtPosition:CGPointMake(x, y)];
            [[SoundEngine shared] playSound:@"jumpLand"];
        } else if (_isJumping && _isTripping) {
            _waitToGetUp = 1.5f;
            _isJumping = false;
            [_speed stop];
        }
        
        _jumpAcceleration = 0;
        _vy = 0;
        _ay = 0;
                
    } else if(state == COLLISION_STATE_BUMPED_WALL) {
        _vx = 0;
        _vy = 0;
    }
}

-(void)startJump:(RunnerJump)type
{
    //guard
    if (_isTripping || _isDead || [_thirdAction inAction]) { return; }
    
    self.hasGravity = false;
    _firstFrameJumping = true;
    _isHighJump = false;
    _vy = -150.0f;
    _y += 2.0f;
    _jumpAcceleration = 0;
    _isJumping = true;
    [[AnimationController sharedController] replaceSprite:[self getSprite] withAnimationNamed:@"jumpingAnim"];
    [[self getCollision] processNewCollisionState:COLLISION_STATE_MIDAIR];
    [self setPositionAtX:_x Y:_y];
    [[SoundEngine shared] playSound:@"jumpStart"];
    
    [_speed startJump];
    
}

-(void)boostJump:(RunnerJump)type
{
    if (_isJumping) {
        _jumpHeight = type;
        
        if(type == JUMP_HIGH) {
            [self endJump];
            _isHighJump = true;
        }        
    }
}



-(void)endJump
{
    if (!_isTripping && _isInMidAir) {
        [[AnimationController sharedController] replaceSprite:[self getSprite] withAnimationNamed:@"fallingAnim"];        
    }
    self.hasGravity = true;
}


-(void)startTurbo
{
    //guard
    if (_isTripping || _isDead || [_thirdAction inAction]) { return; }
    
    if (hitPoints > 1) {
        [_speed startTurbo];
        [[SoundEngine shared] playSound:@"turboStart"];
        [[AnimationController sharedController] replaceSprite:[self getSprite] withAnimationNamed:@"turboAnim"];
        hitPoints -=1;
        [_battery setFrame:(5 - hitPoints)];        
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

-(void)startCollision:(PlayerEffect)effect Obstacle:(GameObject*)obstacle
{
    if (effect == PLAYER_EFFECT_ACTION_OR_COLLIDE) {
        if (![_thirdAction inAction]) {
            [self private_StartPlayerCollision];
        } else {
            [obstacle special_kickHen];
        }
    }
    if (effect == PLAYER_EFFECT_COLLIDE) {
        [self private_StartPlayerCollision];
    } else if(effect == PLAYER_EFFECT_SLOWDOWN) {
        [_speed slowDown];
    }
}

-(void)pushAfterAnimation:(float)xAmount
{
    _adjustX = xAmount;
}

-(void)private_StartPlayerCollision
{
    [_speed startCollision];
    
    _waitToGetUp = 100.0f;
    
    if (_isJumping) {
        [[AnimationController sharedController] replaceSprite:[self getSprite] withAnimationNamed:@"trippedAnim"];
        _isTripping = true;
    } else {
        [[AnimationController sharedController] replaceSprite:[self getSprite] withAnimationNamed:@"hurtAnim"];
        _vy = -250.0f;
        _y += 2.0f;
        _waitToGetUp = 0.3f;
    }
    
    [self changeHealth:-1];
}

//used by background layers for scrolling
-(float)getVelocityX
{
    return _speed.velocity;
}

-(void)reset
{
    hitPoints = 4;
    [_battery reset];
    [_speed reset];
    [_speed start];
    _isJumping = false;
    _isTripping = false;
    _isDead = false;
    self.hasGravity = true;
    _firstFrameJumping = false;
    _isHighJump = false;
    [[AnimationController sharedController] replaceSprite:[self getSprite] withAnimationNamed:@"runningAnim"];

}

-(void)startThirdAction
{
    if (!_isJumping && !_isInMidAir) {        
        [_thirdAction startAction];
    }
}

-(void)setThirdAction:(NSString*)action
{
    if ([action compare:@"woo"] == NSOrderedSame) {
        _thirdAction = [PlayerActionFactory buildPlayerAction:PLAYER_ACTION_KICK];
        //_thirdAction = [PlayerActionFactory buildPlayerAction:PLAYER_ACTION_WOO];
        [_thirdAction setParent:self];    
        
    } else if ([action compare:@"kick"] == NSOrderedSame) {
        
    }
}

-(void)setVelocity:(float)velocity
{
    _speed.velocity = velocity;
}

-(void)resetSprite:(CCLayer*)layer
{
    CCSprite *playerSprite = [self getCCSprite];
    [layer removeChild:playerSprite cleanup:NO];
    [layer addChild:playerSprite];
}

-(void)rechargeBattery
{
    [_battery startRecharge];
}

-(RunningSpeed*)getSpeed
{
    return _speed;
}

-(void)endKick
{
    [_speed start];
}


-(void)dealloc
{
    [_speed release];
    [_battery release];
    [_particleSystem release];
    
    [_buttonJump release];
    [_buttonKick release];
    [_buttonSprint release];
    
    [super dealloc];
}


@end
