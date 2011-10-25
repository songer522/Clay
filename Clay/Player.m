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
        [factory initializeGameObject:self Name:@"player" AddToLayer:YES];
        
        _isJumping = false;
        _isDead = false;
        _isInMidAir = false;
        _waitToGetUp = 0.0f;
        
        _thirdAction = nil;
        
        _speed = [[RunningSpeed alloc] initWithSettings:settings];
        _speed.parent = self;
        [_speed start];
        [self changeToRunnerState:RUNNER_STATE_RUNNING];
        
        hitPoints = 4;
        
        _isHighJump = false;
        
        _waitToPlaySlowSound = 0.0f;
        
        _adjustX = 0.0f;
        
        _particleSystem = [ParticleSystem instance];
        
        
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
    
    CGPoint newPosition = [level checkCollisionForObject:self];    

    [self setPositionAtX:newPosition.x Y:newPosition.y];    //for some reason the y position jitters without
                                                            //having this twice.
    
    [[Camera sharedCamera] moveTowardsTarget:dt PlayerOnGround:false];   //used to be !_isInMidAir, but now we don't want it to move up so quickly when on the ledges, so we'll keep it false
    
    [self setPositionAtX:newPosition.x Y:newPosition.y];
    [_battery update:dt];
    //[_particleSystem update:dt];
    
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

-(void)updateSlow:(float)dt
{
    if (_speed.isSlowedDown && !_isTripping) {
        _waitToPlaySlowSound -= dt;
        if (_waitToPlaySlowSound<=0.0f) {
            [[SoundEngine shared] playSound:@"steppedInSand"];
            _waitToPlaySlowSound = 0.4f;
        }
    }
}

-(void)updateJump:(float)dt
{

    CollisionState state = [[self getCollision] currentState];

    _isInMidAir = false;
    
    if (state == COLLISION_STATE_MIDAIR) {
        _isInMidAir = true;
    } else if (state == COLLISION_STATE_GROUNDED || state == COLLISION_STATE_LEDGE) {
        
        if (_isJumping && !_isTripping) {                
            _isJumping = false;
            
            if (_speed.inTurbo) {
                [[AnimationController sharedController] replaceSprite:[self getSprite] withAnimationNamed:@"turboAnim" FrameNumber:8];
            } else {
                [[AnimationController sharedController] replaceSprite:[self getSprite] withAnimationNamed:@"runningAnim" FrameNumber:8];
            }
            
            //don't want high jump to execute if we're on the ledge, slows gameplay feel down too much
            //(see github issue #46)
            if (_isHighJump && state != COLLISION_STATE_LEDGE) {
                _isHighJump = false;
                [_speed landFromHighJump];
            }
            
            if (_speed.velocity < 0.0f) {
                _speed.velocity = 0.0f;
            }
            
            [[SoundEngine shared] playSound:@"jumpLand"];
        } else if (_isJumping && _isTripping) {
            _waitToGetUp = 1.5f;
            _isJumping = false;
            [[SoundEngine shared] playSound:@"timCollision"];
            [_speed stop];
        } else if(_waitToGetUp <=0.0f && !_isInMidAir && !_speed.inTurbo && !_isTripping && ![_thirdAction inAction] && [[_sprite getAnimation].name compare:@"runningAnim"]!=NSOrderedSame) {
            [[AnimationController sharedController] replaceSprite:[self getSprite] withAnimationNamed:@"runningAnim"];
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

-(bool)objectShouldReactToCollision
{
    return [_thirdAction shouldTriggerPlayerHurtCollision];
}

-(void)startCollision:(PlayerEffect)effect Obstacle:(GameObject*)obstacle
{
    if (!_isInvincible) {
        if (effect == PLAYER_EFFECT_ACTION_OR_COLLIDE) {
            if (!_isTripping && !_isDead) {
                if (![_thirdAction isActive]) {
                    if ([_thirdAction shouldTriggerPlayerHurtCollision]) {
                        [self private_StartPlayerCollision];                    
                    }
                } else {
                    [obstacle special_kickHen];
                }            
            }
        } else if (effect == PLAYER_EFFECT_COLLIDE) {
            if (!_isTripping && !_isDead) {
                [self private_StartPlayerCollision];    
            }
        } else if(effect == PLAYER_EFFECT_SLOWDOWN) {
            [_speed slowDown];
        }
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
    
    [[SoundEngine shared] playSound:@"timHurt"];
    
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
    _waitToPlaySlowSound = 0.0f;
    [[AnimationController sharedController] replaceSprite:[self getSprite] withAnimationNamed:@"runningAnim"];

}

-(void)startThirdAction
{
    if (!_isJumping && !_isInMidAir && !_isTripping && _waitToGetUp <=0.0f) {        
        [_thirdAction startAction];
    }
}

-(void)setThirdAction:(NSString*)action
{
    if (_thirdAction != nil) {
        _thirdAction = nil;
    }
    
    if ([action compare:@"woo"] == NSOrderedSame) {
        _thirdAction = [PlayerActionFactory buildPlayerAction:PLAYER_ACTION_WOO];
    } else if([action compare:@"kick"] == NSOrderedSame) {
        _thirdAction = [PlayerActionFactory buildPlayerAction:PLAYER_ACTION_KICK];
    } else if([action isEqualToString:@"dodge"]) {
        _thirdAction = [PlayerActionFactory buildPlayerAction:PLAYER_ACTION_DODGE];
    }
    
    [_thirdAction setParent:self];
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

-(id<PlayerActionProtocol>)getThirdAction
{
    return _thirdAction;
}

-(void)dealloc
{
    [_speed release];
    [_battery release];
    [_particleSystem release];
        
    [super dealloc];
}


@end
