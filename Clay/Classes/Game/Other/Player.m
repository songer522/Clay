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
#import "Skin.h"
#import "GameLayer.h"
#import "HudLayer.h"

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
       
        NSLog(@"spring is ");
        _timeLeftBeforeVulnerable = 2.0f;
        _isInvincible = false;
        
        _thirdAction = nil;
        
        _speed = [[RunningSpeed alloc] initWithSettings:settings];
        _speed.parent = self;
        [_speed start];
        [self changeToRunnerState:RUNNER_STATE_RUNNING];
        
        _hitPoints = 4;
        
        _isHighJump = false;
        
        _waitToPlaySlowSound = 0.0f;
        _soundFalling = false;
        _adjustX = 0.0f;
        
        _y = 120; //just so the fall into pit sound doesn't go off at very beginning
        
        _skin = [Skin instance];
        [self updateSkin:SKINTYPE_REGULAR];
    }
    
    return self;
}

-(void)changeHealth:(int)amount
{
    if (amount > 0 && _hitPoints<4) {
        _hitPoints+=1;
        [_battery setFrame:(5-_hitPoints)];
    } else if(amount < 0 && _hitPoints >= 0) {
        
            _hitPoints+=amount;
        
        [_battery setFrame:(5-_hitPoints)];
    }
    
    if (_hitPoints <=0) {
        _isDead = true;
        [[SoundEngine shared] playSound:@"dead"];
    }
}

-(void)dieIfFallenIntoPit
{
    if (!_soundFalling && _y < 10) {
        [[SoundEngine shared] playSound:@"fallingDeath"];
        _soundFalling = true;
    } else if(_y < -160) {
        _isDead = true;        
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
    [_skin setPlayerAnimation:PLAYER_ANIM_JUMPING ForSprite:_sprite];
    [[self getCollision] processNewCollisionState:COLLISION_STATE_MIDAIR];
    [self setPositionAtX:_x Y:_y];
    [[SoundEngine shared] playSound:@"jumpStart"];
   
    [_speed startJump];
   }

-(void)startDoubleJump
{
    if (_isTripping || _isDead || [_thirdAction inAction] || [_sprite getPosition].y <= 62) { 
        
        return; }
    self.hasGravity = true;
    
    _vy = -250.0f;
    _ay = 0.0f;
    _isJumping = true;
    
    [_skin setPlayerAnimation:PLAYER_ANIM_JUMPING ForSprite:_sprite];
    [[SoundEngine shared] playSound:@"doubleJump"];
    
    _hasDoubleJumped = true;
    _isHighJump = true;
    
    [_speed startJump];
    GameLayer *gameLayer = [[LayerManager sharedLayers] currentLayer];
    
    [[gameLayer getHud] setEnabled:false ForButton:HUD_BUTTON_JUMP];

}

-(void)boostJump:(RunnerJump)type
{
    if (_isJumping) {
        [self endJump];
    }
}



-(void)endJump
{
    GameLayer *gameLayer = [[LayerManager sharedLayers] currentLayer];
    
    [[gameLayer getHud] setEnabled:true ForButton:HUD_BUTTON_JUMP];
    if (!_isTripping && _isInMidAir) {
        [_skin setPlayerAnimation:PLAYER_ANIM_FALLING ForSprite:_sprite];
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
        [_skin setPlayerAnimation:PLAYER_ANIM_SPRINTING ForSprite:_sprite];
        
      
        
        
       
        //_hitPoints -=1;
        //[_battery setFrame:(5 - _hitPoints)];        
    }

}

-(bool)getIsTurbo {
    return _speed.inTurbo;
}

-(void)endTurbo
{
    [_skin setPlayerAnimation:PLAYER_ANIM_RUNNING ForSprite:_sprite];
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
    if(_speed.inTurbo)
    {
      
        [self changeHealth:-2];
       
    }
    else
    {
      
        [self changeHealth:-1];
    }
    [_speed startCollision];
    
    _waitToGetUp = 100.0f;
    
    [[SoundEngine shared] playSound:@"timHurt"];
    
    if (_isJumping) {
        [_skin setPlayerAnimation:PLAYER_ANIM_TRIPPING ForSprite:_sprite];
        _isTripping = true;
    } else {
        [_skin setPlayerAnimation:PLAYER_ANIM_HURTING ForSprite:_sprite];
        _vy = -250.0f;
        _y += 2.0f;
        _waitToGetUp = 0.3f;
    }
    NSLog(@"%d",_speed.inTurbo);
  
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
    _soundFalling = false;
    _waitToPlaySlowSound = 0.0f;
    [_skin setPlayerAnimation:PLAYER_ANIM_RUNNING ForSprite:_sprite];
}

-(void)startThirdAction
{
    if ((!_isJumping && !_isInMidAir) || [_thirdAction canStartInMidAir]){
        if(!_isTripping && _waitToGetUp <=0.0f) {        
            [_thirdAction startAction];
        }
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
    } else if([action isEqualToString:@"block"]) {
        _thirdAction = [PlayerActionFactory buildPlayerAction:PLAYER_ACTION_BLOCK];
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
    _hitPoints = 4;
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

-(void)setPlayerAnimation:(PlayerAnimation)animation
{
    [_skin setPlayerAnimation:animation ForSprite:_sprite];
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
    
    [self updateInvulnerable:dt];
    
    if (_adjustX != 0.0f) {
        self.x += _adjustX;
        _adjustX = 0.0f;
        [_skin setPlayerAnimation:PLAYER_ANIM_RUNNING ForSprite:_sprite];
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
    
    CGPoint screenPosition = [[Camera sharedCamera] convertToScreenXY:CGPointMake(newPosition.x,newPosition.y)];
    [_sprite getCCSprite].position = ccp(screenPosition.x + _offsetX, screenPosition.y + _offsetY);
    
    [_battery update:dt];
    
    if (_isTripping) {
        _waitToGetUp -= dt;
        if (_waitToGetUp <= 0.0f) {
            _isTripping = false;
            [self endTurbo];
            [_speed start];
            [_skin setPlayerAnimation:PLAYER_ANIM_RUNNING ForSprite:_sprite];
        }
    }
    
    if(_speed.isStopped && !_isTripping) {
        _waitToGetUp -= dt;
        if (_waitToGetUp <= 0.0f) {
            [_speed start];
        }
    }
    
    [_thirdAction update:dt];
    
    [self dieIfFallenIntoPit];
}

-(void)updateJump:(float)dt
{
    
    CollisionState state = [[self getCollision] currentState];
    
    _isInMidAir = false;
    
    if (state == COLLISION_STATE_MIDAIR) {
        _isInMidAir = true;
        
    } else if (state == COLLISION_STATE_GROUNDED || state == COLLISION_STATE_LEDGE) {

        _hasDoubleJumped = false;
        
        if (_isJumping && !_isTripping) {                
            _isJumping = false;
            
            if (_speed.inTurbo) {
                [_skin setPlayerAnimation:PLAYER_ANIM_SPRINTING ForSprite:_sprite];
            } else {
                [_skin setPlayerAnimation:PLAYER_ANIM_RUNNING ForSprite:_sprite];
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
            
            [[SoundEngine shared] playSound:@"jumpLand"];
            GameLayer *gameLayer = [[LayerManager sharedLayers] currentLayer];
            
            [[gameLayer getHud] setEnabled:true ForButton:HUD_BUTTON_JUMP];

        } else if (_isJumping && _isTripping) {
            _waitToGetUp = 1.5f;
            _isJumping = false;
            [[SoundEngine shared] playSound:@"timCollision"];
           
            [_speed stop];
            GameLayer *gameLayer = [[LayerManager sharedLayers] currentLayer];
            
            [[gameLayer getHud] setEnabled:true ForButton:HUD_BUTTON_JUMP];
        } else if(![_skin isCurrentAnimationOfType:PLAYER_ANIM_RUNNING] && !_isInMidAir && !_speed.inTurbo && !_isTripping && ![_thirdAction inAction] && _waitToGetUp <=0.0f) {
            [_skin setPlayerAnimation:PLAYER_ANIM_RUNNING ForSprite:_sprite];
           
            
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
    return; //temporarily don't want to do;
    
    _totalTime += dt;
    
    //make character blink to show that they're invulnerable
    float blink = sinf(8.0f * _totalTime);
    if (blink < 0.95f) {
        [_sprite setAlpha:1.0f];
        [[_sprite getCCSprite] setColor:ccc3(255, 255, 255)];

    } else {
        [_sprite setAlpha:1.0f];
        [[_sprite getCCSprite] setColor:ccc3(200, 200, 0)];
    }
    
    
    if (_timeLeftBeforeVulnerable >=0.0f) {
        _timeLeftBeforeVulnerable -= dt;
        _isInvincible = true;
        
        if (_timeLeftBeforeVulnerable<=0.0f) {
            _isInvincible = false;
            [[_sprite getCCSprite] setColor:ccc3(255, 255, 255)];
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

-(void)updateSkin:(SkinType)skin
{
    switch (skin) {
        case SKINTYPE_REGULAR:
            [_skin setSkin:@"regularTim"];
            break;
        case SKINTYPE_8BIT:
            [_skin setSkin:@"eightBitTim"];
            break;
        default:
            break;
    }
}

-(void)dealloc
{
    [_speed release];
    [_battery release];
        
    [super dealloc];
}


@end
