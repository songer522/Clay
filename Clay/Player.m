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
@synthesize hasDoubleJumped = _hasDoubleJumped;
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
        _onLedge = false;
        
        _thirdAction = nil;
        
        _speed = [[RunningSpeed alloc] initWithSettings:settings];
        _speed.parent = self;
        [_speed start];
        [self changeToRunnerState:RUNNER_STATE_RUNNING];
        
        _hitPoints = 4;
        
        _isHighJump = false;
        
        _waitToPlaySlowSound = 0.0f;
        
        _adjustX = 0.0f;
        
    }
    
    return self;
}

-(void)changeHealth:(int)amount
{
    if (amount > 0 && _hitPoints<4) {
        _hitPoints+=1;
        [_battery setFrame:(5-_hitPoints)];
    } else if(amount < 0 && _hitPoints >= 0) {
        _hitPoints-=1;
        [_battery setFrame:(5-_hitPoints)];
    }
    
    if (_hitPoints <=0) {
        _isDead = true;
        [[SoundEngine shared] playSound:@"dead"];
    }
}


-(void)startJump:(RunnerJump)type
{
    //guard
    //if ay is too high, it 
    if (_isTripping || _isDead || [_thirdAction inAction]) { return; }
    self.hasGravity = false;
    _firstFrameJumping = true;
    _isHighJump = false;
    _vy = -115.0f;
    _y += 2.0f;
    _isJumping = true;
    [[AnimationController sharedController] replaceSprite:[self getSprite] withAnimationNamed:@"jumpingAnim"];
    [[self getCollision] processNewCollisionState:COLLISION_STATE_MIDAIR];
    [self setPositionAtX:_x Y:_y];
    [[SoundEngine shared] playSound:@"jumpStart"];
    
    [_speed startJump];
}

-(void)startDoubleJump
{
    if (_isTripping || _isDead || [_thirdAction inAction] || [_sprite getPosition].y <= 62) { return; }
    self.hasGravity = true;
    
    _vy = -250.0f;
    _ay = 0.0f;
    _isJumping = true;
    
    [[AnimationController sharedController] replaceSprite:[self getSprite] withAnimationNamed:@"jumpingAnim"];
    [[SoundEngine shared] playSound:@"doubleJump"];
    
    _hasDoubleJumped = true;
    _isHighJump = true;
    
    [_speed startJump];
}

-(void)boostJump:(RunnerJump)type
{
    if (_isJumping) {
        [self endJump];
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
    if (_isTripping || _isDead || [_thirdAction inAction] || _isInMidAir || _waitToGetUp > 0.f) { return; }
    
    if (_hitPoints > 1) {
        [_speed startTurbo];
        [[SoundEngine shared] playSound:@"turboStart"];
        [[AnimationController sharedController] replaceSprite:[self getSprite] withAnimationNamed:@"turboAnim"];
        _hitPoints -=1;
        [_battery setFrame:(5 - _hitPoints)];        
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
    
    return ([_thirdAction shouldTriggerPlayerHurtCollision] && _onLedge);
}

-(void)startCollision:(PlayerEffect)effect Source:(id<Collidable>)source
{
    if (!_isInvincible && !_onLedge) {
        if (effect == PLAYER_EFFECT_ACTION_OR_COLLIDE) {
            if (!_isTripping && !_isDead) {
                if (![_thirdAction isActive]) {
                    if ([_thirdAction shouldTriggerPlayerHurtCollision]) {
                        [self private_StartPlayerCollision];                    
                    }
                } else {
                    GameObject *object = (GameObject*)source;
                    [object special_kickHen];
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
    _hitPoints = 4;
    [_battery reset];
    [_speed reset];
    [_speed start];
    _isJumping = false;
    _isTripping = false;
    _isInMidAir = false;
    _hasDoubleJumped = false;
    _waitToGetUp = 0.0f;
    _timeLeftBeforeVulnerable = 2.0f;
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
    } else if([action isEqualToString:@"shoot"]) {
        _thirdAction = [PlayerActionFactory buildPlayerAction:PLAYER_ACTION_SHOOT];
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

-(void)addProjectile:(id<Collidable>)projectile
{
    [projectiles addObject:projectile];
}

-(void)removeProjectile:(id<Collidable>)projectile
{
    [projectiles removeObject:projectile];
}

-(void)endKick
{
    [_speed start];
}

-(id<PlayerActionProtocol>)getThirdAction
{
    return _thirdAction;
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
    
    //want it to follow slower on ledge
    if ([[self getCollision] currentState] == COLLISION_STATE_LEDGE) {
        _onLedge = true;
        [[Camera sharedCamera] moveTowardsTarget:dt PlayerOnGround:false];
    } else {
        _onLedge = false;
        [[Camera sharedCamera] moveTowardsTarget:dt PlayerOnGround:!_isInMidAir];
    }
    
    [self setPositionAtX:newPosition.x Y:newPosition.y];
    [_battery update:dt];
    
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
            if (_isHighJump) {
                _isHighJump = false;
                if (state != COLLISION_STATE_LEDGE) {
                    [_speed landFromHighJump];                    
                }
            }
            
            if (_speed.velocity < 0.0f) {
                _speed.velocity = 4.0f;                
            }
            
            _hasDoubleJumped = false;
            
            [[SoundEngine shared] playSound:@"jumpLand"];
        } else if (_isJumping && _isTripping) {
            _waitToGetUp = 1.5f;
            _isJumping = false;
            [[SoundEngine shared] playSound:@"timCollision"];
            [_speed stop];
        } else if(_waitToGetUp <=0.0f && !_isInMidAir && !_speed.inTurbo && !_isTripping && ![_thirdAction inAction] && [[_sprite getAnimation].name compare:@"runningAnim"]!=NSOrderedSame) {
            [[AnimationController sharedController] replaceSprite:[self getSprite] withAnimationNamed:@"runningAnim"];
        }
        
        _vy = 0;
        _ay = 0;
        
    } else if(state == COLLISION_STATE_BUMPED_WALL) {
        _vx = 0;
        _vy = 0;
    }
}


-(void)updateInvulnerable:(float)dt
{
    _totalTime += dt;
    
    //make character blink to show that they're invulnerable
    float blink = sinf(5.0f * _totalTime);
    if (blink > 0.7f) {
        [_sprite setAlpha:1.0f];
    } else {
        [_sprite setAlpha:0.4f];
    }
    
    
    if (_timeLeftBeforeVulnerable >=0.0f) {
        _timeLeftBeforeVulnerable -= dt;
        _isInvincible = true;
        
        if (_timeLeftBeforeVulnerable<=0.0f) {
            _isInvincible = false;
            [_sprite setAlpha:1.0f];
        }
    }
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


-(void)dealloc
{
    [_speed release];
    [_battery release];
        
    [super dealloc];
}


@end
