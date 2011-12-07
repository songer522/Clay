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

#define PLAYER_SPRINT_COOLDOWN 1.0

@implementation Player

@synthesize isJumping = _isJumping;
@synthesize isDead = _isDead;
@synthesize isTripping = _isTripping;
@synthesize hasDoubleJumped = _hasDoubleJumped;
@synthesize isWindy = _isWindy;
@synthesize battery = _battery;
@synthesize hadCollisionThisUpdate = _hadCollisionThisUpdate;
@synthesize inVaccuum = _inVaccuum;
@synthesize onLedge =_onLedge;



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
        _waitToTurbo=-1.0f;
        _onLedge = false;
        _offLedge=false;
        _isTurbo=false;
        _isCooldown=true;
        _timeLeftBeforeVulnerable = 2.0f;
        _isInvincible = false;
        _inVaccuum = false;
        
        _thirdAction = nil;
        
        _speed = [[RunningSpeed alloc] initWithSettings:settings];
        _speed.parent = self;
        [_speed start];
        [self changeToRunnerState:RUNNER_STATE_RUNNING];
        
        _hitPoints = 4;
        
        _isHighJump = false;
        
        _isWindy = false;
        _waitToPlaySlowSound = 0.0f;
        _soundFalling = false;
        _adjustX = 0.0f;
        
        _y = 120; //just so the fall into pit sound doesn't go off at very beginning
        
        _skin = [Skin instance];
        _playerOnledge=[Sprite spriteWithFile:@"blank.png"]; 
       
        _tempSprite=_sprite;
         //[[_tempSprite getCCSprite] setAnchorPoint:ccp(0,0)];
        //[_tempSprite getCCSprite].position=[_sprite getCCSprite].position;
        //[_tempSprite getCCSprite].anchorPoint=[_sprite getCCSprite].anchorPoint;
        
        //[_tempSprite setOffsetForX:0 Y:-201];
        //_ay = 0.0f;
        [self updateSkin:SKINTYPE_REGULAR];
      
    }
    
    return self;
}

-(void)changeHealth:(int)amount
{
    
    if (amount > 0 && _hitPoints<4) {
        _hitPoints+=amount; //POSSIBLE BUG: why is this +=1 instead of +=amount like the negative?
        [_battery setFrame:(5-_hitPoints)];
    } else if(amount < 0 && _hitPoints >= 0) {
        _hitPoints+=amount;
        [_battery setFrame:(5-_hitPoints)];
    }
     
    /*
    if(_hitPoints < 4 || _hitPoints >=0 )
    {
        _hitPoints+=amount;
        [_battery setFrame:(5-_hitPoints)];
    }
    */
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
    _waitToEndJump =0.2f;
   
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
    
    if (!_isTripping && _isInMidAir ) {
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
        _isTurbo=true;
        
        [[SoundEngine shared] playSound:@"turboStart"];
        [_skin setPlayerAnimation:PLAYER_ANIM_SPRINTING ForSprite:_sprite];
    }

}

-(bool)getIsTurbo {
    return _speed.inTurbo;
}

-(void)endTurbo
{
    [_skin setPlayerAnimation:PLAYER_ANIM_RUNNING ForSprite:_sprite];
    [_speed endTurbo];
    
    if(_isTurbo && _hitPoints>1 )
    {
        GameLayer *gameLayer = [[LayerManager sharedLayers] currentLayer];
        gameLayer.gameController.isSprintEnabled=false;
        [[gameLayer getHud] setEnabled:false ForButton:HUD_BUTTON_SPRINT];
        _waitToTurbo=PLAYER_SPRINT_COOLDOWN;
        _isTurbo=false;
    }
    /*
    else if(_isTurbo)
    {
        GameLayer *gameLayer = [[LayerManager sharedLayers] currentLayer];
        gameLayer.gameController.isSprintEnabled=false;
        [[gameLayer getHud] setEnabled:false ForButton:HUD_BUTTON_SPRINT];
        _waitToTurbo=-1;
        _isTurbo=false;
    }
     */
    
}

-(bool)objectShouldReactToCollision
{
    
    return ([_thirdAction shouldTriggerPlayerHurtCollision]); //CHANGED: used to be '&& _onLedge' to enable collisions on ledge again
}

-(void)startCollision:(PlayerEffect)effect Source:(id<Collidable>)source
{
    //update vaccuum effect
    if(effect == PLAYER_EFFECT_VACCUUM) {
        //don't want this set if in spin action
        if(!_thirdAction.inAction) {
            _speed.velocity *= 0.98f;
            self.vy = -20.0f;
        }
        [_speed stop];
        if (!_inVaccuum) {
            [self startVaccuum];
        }
    }
    
    if (!_isInvincible) {
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

-(void)startVaccuum
{
    _inVaccuum = true;
    self.hasGravity = false;
    [_skin setPlayerAnimation:PLAYER_ANIM_FLOATING ForSprite:_sprite];    
}
    
-(void)endVaccuum
{
    _inVaccuum = false;
    self.hasGravity = true;
    [_speed start];
    [_skin restorePreviousAnimation];
}

//right now this is only called by the falling animation, sinc tim actually
//moves forward in the graphic when he gets back up, so he should be in a different position
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
    
    if (_isJumping && [_speed inTurbo]) {
        [_skin setPlayerAnimation:PLAYER_ANIM_TRIPPING ForSprite:_sprite];
        _isTripping = true;
    } else {
        [_skin setPlayerAnimation:PLAYER_ANIM_HURTING ForSprite:_sprite];
        _vy = -250.0f;
        _y += 2.0f;
        _waitToGetUp = 0.3f;
    }
    
    if (_thirdAction.inAction) {
        [_thirdAction cancelAction];
    }
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
    [_boss reset];
    _waitToTurbo=-1;
    
    GameLayer *gameLayer = [[LayerManager sharedLayers] currentLayer];
    [[gameLayer getHud] setEnabled:true ForButton:HUD_BUTTON_JUMP];
    
    [[[[gameLayer getHud] getSprintButton] getCCSpriteForOverlay] setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"UI_Button_GreenLight_7.png"]];  
    _isJumping = false;
    _isTripping = false;
    _isInMidAir = false;
    _hasDoubleJumped = false;
    [self resetSprint];
    _waitToGetUp = 0.0f;
    _timeLeftBeforeVulnerable = 2.0f;
    _isDead = false;
    self.hasGravity = true;
    _firstFrameJumping = false;
    _isHighJump = false;
    _soundFalling = false;
    _inVaccuum = false;
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
        _thirdAction = (PlayerAction*)[PlayerActionFactory buildPlayerAction:PLAYER_ACTION_WOO];
    } else if([action compare:@"kick"] == NSOrderedSame) {
        _thirdAction = (PlayerAction*)[PlayerActionFactory buildPlayerAction:PLAYER_ACTION_KICK];
    } else if([action isEqualToString:@"dodge"]) {
        _thirdAction = (PlayerAction*)[PlayerActionFactory buildPlayerAction:PLAYER_ACTION_DODGE];
    } else if([action isEqualToString:@"shoot"]) {
        _thirdAction = (PlayerAction*)[PlayerActionFactory buildPlayerAction:PLAYER_ACTION_SHOOT];
    } else if([action isEqualToString:@"block"]) {
        _thirdAction = (PlayerAction*)[PlayerActionFactory buildPlayerAction:PLAYER_ACTION_BLOCK];
    } else if([action isEqualToString:@"blow"]) {
        _thirdAction = (PlayerAction*)[PlayerActionFactory buildPlayerAction:PLAYER_ACTION_BLOW];
    } else if([action isEqualToString:@"spin"]) {
        _thirdAction = (PlayerAction*)[PlayerActionFactory buildPlayerAction:PLAYER_ACTION_SPIN];
    } else if([action isEqualToString:@"slowtime"]) {
        _thirdAction = (PlayerAction*)[PlayerActionFactory buildPlayerAction:PLAYER_ACTION_SLOW_TIME];
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

-(void)setLedgeSprite:(CCLayer*)layer
{
    CCSprite *ledgeSprite=[_playerOnledge getCCSprite];
    [layer removeChild:ledgeSprite cleanup:NO];
    [layer addChild:ledgeSprite];

}

-(void)setCurrentSprite:(Sprite *)newSprite
{
        _sprite=newSprite;
     
    
}


-(void)rechargeBattery
{
    [_battery startRecharge];
    _hitPoints = 4;
}

-(void)resetSprint
{
    GameLayer *gameLayer = [[LayerManager sharedLayers] currentLayer];
    gameLayer.gameController.isSprintEnabled=true;
    [[gameLayer getHud] setEnabled:true ForButton:HUD_BUTTON_SPRINT];
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
-(int)getHitPoints
{
    return _hitPoints;
}

-(id<PlayerActionProtocol>)getThirdAction
{
    return _thirdAction;
}

-(void)update:(float)dt Level:(Level *)level
{
  
    [self updatePitFalling:dt]; //need to call before super so it can kill the x-velocity if falling into the pit

    [super update:dt];  
        [self updateTurbo:dt];

    [self updateJump:dt];
    
    [self updateInvulnerable:dt];

    if (_adjustX != 0.0f) {
        self.x += _adjustX;
        _adjustX = 0.0f;
        [_skin setPlayerAnimation:PLAYER_ANIM_RUNNING ForSprite:_sprite];
    }
    [self updatePlayerPosition:dt Level:level];
  

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

    [self updateLedge:dt];
    
    if(_speed.isStopped && !_isTripping) {
        _waitToGetUp -= dt;
        if (_waitToGetUp <= 0.0f) {
            [_speed start];
        }
    }
    if(_hitPoints<=1)
    {
        _isCooldown=false;
    }
    else
    {
        _isCooldown=true;
    }
    
    [_thirdAction update:dt];

}

-(void)updatePlayerPosition:(float)dt Level:(Level*)level
{
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
    
}

-(void)updateTurbo:(float)dt
{
    //wait for turbo
    if (_waitToTurbo > 0.0f) {
        GameLayer *gameLayer = [[LayerManager sharedLayers] currentLayer];
        
        _waitToTurbo -= dt;
        if (_waitToTurbo<=0.0f) {
            gameLayer.gameController.isSprintEnabled=true;
            [[gameLayer getHud] setEnabled:true ForButton:HUD_BUTTON_SPRINT];
        }
        
        float cooldownPercent = (PLAYER_SPRINT_COOLDOWN - _waitToTurbo)/PLAYER_SPRINT_COOLDOWN;
        [[[gameLayer getHud] getSprintButton] updateOverlayImageByPercentage:cooldownPercent];
        
        if(!_isCooldown)
        {
            [[[gameLayer getHud] getSprintButton] updateOverlayImageByPercentage:0];
        }
    }
}

-(void)updateLedge:(float)dt
{
 /*   
     if(_onLedge)
     {
     [[_playerOnledge getCCSprite] setAnchorPoint:ccp(0.5,0)];
     if(_isActive){
     
     [self switchToInactive];
     
     }
     
     [self setCurrentSprite:_playerOnledge];
     //[_playerOnledge getCCSprite].anchorPoint=[_sprite getCCSprite].anchorPoint;
     [_playerOnledge getCCSprite].visible =YES;
     
     [[Camera sharedCamera] setTarget:_playerOnledge];
     _offLedge=true;
     
     }
     else
     {
     
     
     if(_offLedge)
     {
     [_playerOnledge getCCSprite].visible=NO;
     
     _sprite=_tempSprite;
     [_sprite getCCSprite].visible=YES;
     //[[_sprite getCCSprite] setAnchorPoint:ccp(0,1)];
     _isActive=true;
     _offLedge=false;
     }
     [[Camera sharedCamera] setTarget:_sprite];
     }
   */  
     
}

-(void)updatePitFalling:(float)dt
{
    CollisionState state = [[self getCollision] currentState];

    if (state == COLLISION_STATE_DEATHPIT) {
        _vx = 0.0f; //if in the death pit he shouldn't move forward
        [_speed stop];
        [self dieIfFallenIntoPit]; //is it safe to put this under updateJump method?
    }
}

-(void)updateJump:(float)dt
{
    
    CollisionState state = [[self getCollision] currentState];
  
   
    _isInMidAir = false;
    
    if (state == COLLISION_STATE_DEATHPIT) {
        _isInMidAir = true;
    } else if (state == COLLISION_STATE_MIDAIR) {
        _isInMidAir = true;
        
        if (_isJumping && !_isTripping && !_hasDoubleJumped && _waitToEndJump>0.0f) {
            _waitToEndJump-=dt;
            if (_waitToEndJump<=0.0f) {
                [self endJump];
            }
        }
        
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
        }
        
    
         
        else if(![_skin isCurrentAnimationOfType:PLAYER_ANIM_RUNNING] && !_isInMidAir && !_speed.inTurbo && !_isTripping && !_inVaccuum && ![_thirdAction inAction] && _waitToGetUp <=0.0f) {
            [_skin setPlayerAnimation:PLAYER_ANIM_RUNNING ForSprite:_sprite];
            
            
        }
        /*
        else if(![_skin isCurrentAnimationOfType:PLAYER_ANIM_SPRINTING] && !_isInMidAir && _speed.inTurbo && !_isTripping &&  !_inVaccuum &&![_thirdAction inAction] && _waitToGetUp <=0.0f) {
            [_skin setPlayerAnimation:PLAYER_ANIM_SPRINTING ForSprite:_sprite];
            
            
        }   
         */
        _vy = 0;
        _ay = 0;
        
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
    //play the sound effect for walking in sand pit if slowed down (unless it's the wind level) and it's the wind
    //slowing tim down
    if (_speed.isSlowedDown && !_isTripping && !_isWindy) {
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
    [_skin release];
        
    [super dealloc];
}


@end
