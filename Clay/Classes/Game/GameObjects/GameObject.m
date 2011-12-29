//
//  GameObject.m
//  Clay
//
//  Created by Brian Cable on 8/25/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "GameObject.h"

#import "Sprite.h"
#import "Collision.h"
#import "Camera.h"
#import "SoundEngine.h"
#import "LayerManager.h"
#import "AnimationController.h"
#import "GameLayer.h"
#import "Player.h"
#import "PlayerAction.h"
#import "Projectile.h"
#import "BossFactory.h"
#import "GameSettings.h"

#define GAME_OBJECT_DISTANCE_ONSCREEN 550.0f

#define MULTIPLIER_ANGLE_TO_RADS 0.1745328f //pre-calculation for Math.pi/180

@implementation GameObject

@synthesize sprite = _sprite;
@synthesize x = _x;
@synthesize y = _y;
@synthesize vx = _vx;
@synthesize vy = _vy;
@synthesize boundingBox = _boundingBox;
@synthesize collided = _collided;
@synthesize hasGravity = _hasGravity;
@synthesize isAggressive = _isAggressive;
@synthesize CurrentBehavior = _currentBehavior;
@synthesize isInMidAir = _isInMidAir;
@synthesize isFalling = _isFalling;
@synthesize isInvincible = _isInvincible;
@synthesize rotateLights = _rotateLights;
@synthesize beatsPlayerAction = _beatsPlayerAction;
@synthesize originalAnimation=_originalAnimation;
@synthesize magnitude = _magnitude;
@synthesize persistsBetweenRegions = _persistsBetweenRegions;
@synthesize slowTimeModifier = _slowTimeModifier;
@synthesize isHurdle = _isHurdle;
@synthesize hasAppeared = _hasAppeared;


+ (id) objectWithSprite:(Sprite*)sprite
{
    return [[self alloc] initWithSprite:sprite];
}

+ (id) instance
{
    return [[self alloc] init];
}

- (id)init
{
    self = [super init];
    if (self) {
        _isActive = true;
        _x = 0;
        _y = 0;
        _vx = 0;
        _vy = 0;
        _angle = 0;
        _alpha = 1.0f;
        _fadeout = false;
        _offsetX = 0;
        _rate = 1.0f;
        _offsetY = 0;
        _waitToTrigger = -1.0f;
        _hasTriggered= false;
        _boss = nil;
        _madeSound = false;
        _boundingBox = CGRectMake(0, 0, 0, 0);
        _collisionState = [[Collision collisionNode] retain];
        _currentBehavior = COLLISION_BEHAVIOR_STATIC;
        _isAggressive = false;
        _isFalling = false;
        _isInMidAir = false;
        _direction = 1;
        _isInvincible = false;
        _stopCurve=false;
        _slowTimeModifier = 1.0f;
        _projectile = nil;
        _reloading = 0;
        _aggressiveCanHit = false;
        _beatsPlayerAction = false;
        _persistsBetweenRegions = false;
        _magnitude = 0.0f;
        _hasAppeared=false;
        _isVisible = true;
        _isHurdle = false;
        _isStutterMode = [[GameSettings shared] isStutterMode];
        
        
    }
    
    return self;
}

-(id) initWithSprite:(Sprite*)initSprite
{
    if((self=[self init])) {
        _sprite = initSprite;

    }
    return self;
}


-(void) initialize:(NSString*)type
{
    if ([type isEqualToString:@"lighting"]) {
        _rotateLights = true;
        _angle = rand() % 50 - 25;
        _direction = 1;
        _isActive = true;
    }
}

-(CGPoint) getPosition
{
    return CGPointMake(_x, _y);
}

-(CGPoint) getPreviousPosition
{
    return _prevLocation;
}

-(void) setOffsetForX:(float)x Y:(float)y
{
    _offsetX = x;
    _offsetY = y;
}

-(void) setPosition:(CGPoint)position
{
    [self setPositionAtX:position.x Y:position.y];
}

-(void) move:(CGPoint)amount
{
    _x += amount.x;
    _y += amount.y;
    [_sprite move:amount];
}

-(void)setPositionAtX:(float)x Y:(float)y
{
    _x = x;
    _y = y;
    [_sprite setPositionAtX:x + _offsetX Y:y + _offsetY];
}

-(void) setStartingPosition:(CGPoint)position
{
    _startingPosition = CGPointMake(position.x, position.y);
}

-(PlayerEffect) startCollision
{
    if (_currentBehavior == COLLISION_BEHAVIOR_HEN_KICKED) { return PLAYER_EFFECT_NONE; }
    
    if(_playerEffect == PLAYER_EFFECT_COLLIDE) {
        _collided = true;
    }
    GameLayer *gameLayer = [[LayerManager sharedLayers] currentLayer];
    _currentBehavior = _collideBehavior;
    
    switch (_currentBehavior) {
        case COLLISION_BEHAVIOR_FALL_OVER:
            _fallVelocity = 425.0f;            
            break;
        case COLLISION_BEHAVIOR_HEN_DEAD:
            _hasGravity = false;
            _vy = -150.0f;
            _vx = rand()%40 + 15;
            _alpha = 1.5f;
            _fadeout = true;
            _collided = true;
            [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"henKicked"];
            [self setOriginalAnimation:@"henIdle"];
            [[SoundEngine shared] playSound:@"henKicked"];
            break;
        case COLLISION_BEHAVIOR_COW_COLLAPSE:
            [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"cowDied"];  
            [[SoundEngine shared] playSound:@"cowDied"];
            _alpha = 1.5f;
            _fadeout = true;
            break;
        case COLLISION_BEHAVIOR_DANCIN_MAN_COLLAPSE:
            [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"dancinManDied"];
            _alpha = 1.5f;
            _fadeout = true;
            
            [[gameLayer.player getThirdAction] setKilledEnemy:YES];
            break;
            
        case COLLISION_BEHAVIOR_CHARGE_AT_PLAYER_BD:
          
        
            [[gameLayer.player getThirdAction] setKilledEnemy:YES];

            
            break;
        case COLLISION_BEHAVIOR_CHARGE_AT_PLAYER_FAST_BD:
            
            
            [[gameLayer.player getThirdAction] setKilledEnemy:YES];
            
            
            break;
        case COLLISION_BEHAVIOR_ZOMBIE_HEADLESS:
            [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"femaleHeadlessZombieAnim"];
            _alpha = 1.5f;
            _fadeout = true;
            _projectile = [Projectile projectileWithBehavior:PROJECTILE_BEHAVIOR_ZOMBIE_HEAD];
            [_projectile reset];
            [_projectile setPosition:CGPointMake(_x, _y + 41)];
            [_projectile setBoundingBox:CGRectMake(15, 33, 14, 35)];
            [[[[LayerManager sharedLayers] getPlayer] getThirdAction] setKilledEnemy:YES];
            break;
        case COLLISION_BEHAVIOR_FIRE_DEMON:
            _alpha = 1.0f;
            _vy = -50.0f;
            _vx = 50.0f;
            _rate = 2.0f;
            _fadeout = true;
            [[[[LayerManager sharedLayers] getPlayer] getThirdAction] setKilledEnemy:YES];
            break;
        case COLLISION_BEHAVIOR_FIREBALL_START:
        case COLLISION_BEHAVIOR_FIREBALL_MOVING:
            _collided = false;
            break;
        case COLLISION_BEHAVIOR_FROG_SQUASH:
            [self.sprite setAnimationByName:@"rainyFrogSquashAnim"];
            [[SoundEngine shared] playSound:@"frogSquish"];
            _alpha = 1.2f;
            _fadeout = true;
            break;
        case COLLISION_BEHAVIOR_WATER_PUFFERFISH:
            _alpha = 1.2f;
            _fadeout = true;
            [[SoundEngine shared] playSound:@"waterPufferFish"];
            break;
        case COLLISION_BEHAVIOR_FIREBALL_LANDED:
        case COLLISION_BEHAVIOR_FIRE_DEMON_ARMOR:
        case COLLISION_BEHAVIOR_FIRE_DEMON_ARMOR_WAITTOSHOOT:
        case COLLISION_BEHAVIOR_ZOMBIE_FADE:
        case COLLISION_BEHAVIOR_ROLLING_HAYBALE:
        case COLLISION_BEHAVIOR_FADES:
        case COLLISION_BEHAVIOR_RAINY_SQUIRREL:
        case COLLISION_BEHAVIOR_COMPUTER_WORM:
            _alpha = 1.2f;
            _fadeout = true;
        default:
            break;
    }
    
    return _playerEffect;
}

//called by player once it decides that the hen is actually kicked.
-(void)special_kickHen
{
    _fadeout = false;
    _alpha = 1.0f;
    _hasGravity = true;
    _collided = false;  //want it to remain aggressive
    _isAggressive = true;
    float magnitude = 555.0f;
    _angle = -20; //old was -30
    _rotationAmount = 75;
    _vx = magnitude * cosf((_angle * 3.14159)/180.0f);
    _vy = magnitude * sinf((_angle * 3.14159)/180.0f);
    _currentBehavior = COLLISION_BEHAVIOR_HEN_KICKED;
    [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"henKicked"];
    [[SoundEngine shared] playSound:@"henKicked"];
    [self setOriginalAnimation:@"henIdle"];
}


-(CCSprite*) getCCSprite
{
    return [_sprite getCCSprite];
}

-(void)setActive:(bool)active
{
    _isActive = active;
}

-(void)update:(float)dt
{
    
    if (!_isStutterMode && !_boss) {
        if ([[Camera sharedCamera ] isInVisualRange:_x]) {
            if (!_isVisible) {
                [[_sprite getCCSprite] setVisible:YES];
                [[_sprite getCCSprite] resumeSchedulerAndActions];
                _isVisible = true;
            }
        } else {
            if (_isVisible) {
                [[_sprite getCCSprite] setVisible:NO];
                [[_sprite getCCSprite] pauseSchedulerAndActions];
                _isVisible = false;
            }
            return; //don't bother with the rest of the update loop
        }
    }
    
    //if time is slowed down, modify the dt by the modifier
    //(must be called first because the rest relies on the dt value)
    if (_slowTimeModifier!= 1.0f) {
        dt = dt * _slowTimeModifier;
    }
    
    if (_boss!=nil) {
        [_boss update:dt];
        return; //don't want to do the rest, boss takes care of everything
    }

    //update projectile regardless if active
    if (_projectile !=nil) {
        [_projectile update:dt];
    }
    
    //guard
    if (!_isActive && _collideBehavior != COLLISION_BEHAVIOR_CHARGE_AT_PLAYER) { 
        
        
        return; }
    
    _prevLocation = CGPointMake(_x, _y);
    
    _x += _vx * dt;
    _y -= _vy * dt;
    
    _movedBy -= _vy * dt;
    
    [self setPositionAtX:_x Y:_y];

    [self updateFadeOut:dt];
    
    [self updateCollisionBehavior:dt];
    
    [self updateFlags];
    
    if (_isStutterMode) {
        [self updateLights:dt];        
    } else {
        //unneeded
    }
    
    
    
}
-(void) playerHasCheering:(bool) cheering 
{
    Player *player =  [[LayerManager sharedLayers] getPlayer];
    PlayerAction *action=  (PlayerAction *)[player getThirdAction];
    [action isCheering:cheering];
} 
-(void)updateFadeOut:(float)dt
{
    if (_fadeout) {
        float _setAlpha;
        _alpha -= 2.0f * _rate * dt;
        //TODO: build this into setAlpha method
        if (_alpha <= 0.0f) {
            _alpha = 0.0f;
            [self switchToInactive];
        }
        _setAlpha = _alpha;
        if (_setAlpha>=1.0f) {
            _setAlpha = 1.0f;
        }
        [_sprite setAlpha:_setAlpha];
    } 
}

-(void)updateCollisionBehavior:(float)dt
{
    switch (_currentBehavior) {
            
        ///////////////////////////
        //MULTIPLE OBSTACLES
        ///////////////////////////
        case COLLISION_BEHAVIOR_FALL_OVER:
            _angle += (_fallVelocity + 100.0f) * dt;
            if (_angle >= 90) {
                _angle = 90;
                _fallVelocity = -0.8f * _fallVelocity;
                _currentBehavior = COLLISION_BEHAVIOR_STATIC;
            } else if(_angle <= 0) {
                _angle = 0;
                _fallVelocity = -0.8f * _fallVelocity;
            }            
            [self getCCSprite].rotation = _angle;
            break;
        case COLLISION_BEHAVIOR_CHARGE_AT_PLAYER:
            [self chaseAtDistance:GAME_OBJECT_DISTANCE_ONSCREEN DefaultSpeed:0.0f ChaseSpeed:-150.0f];
            break;
        case COLLISION_BEHAVIOR_CHARGE_AT_PLAYER_BD:
            [self chaseAtDistance:GAME_OBJECT_DISTANCE_ONSCREEN DefaultSpeed:0.0f ChaseSpeed:-150.0f];
            break;
        case COLLISION_BEHAVIOR_CHARGE_AT_PLAYER_FAST:
            [self chaseAtDistance:GAME_OBJECT_DISTANCE_ONSCREEN DefaultSpeed:0.0f ChaseSpeed:-200.0f];
            break;
        case COLLISION_BEHAVIOR_CHARGE_AT_PLAYER_FAST_BD:
            [self chaseAtDistance:GAME_OBJECT_DISTANCE_ONSCREEN DefaultSpeed:0.0f ChaseSpeed:-200.0f];
            break;
        case COLLISION_BEHAVIOR_CLAPPING_CROWD:
            if ([self closeToPlayer:400] )
                 {
                     if(!_hasTriggered)
                     {
                     [self playerHasCheering:true];
                         
                     }
                 }
            if([self checkIfOffScreen:[self getPosition]] )
            {
                [self playerHasCheering:false];
            }
            break;
            
        ///////////////////////////
        //LEVEL 2 - BARN RUN
        ///////////////////////////
        case COLLISION_BEHAVIOR_HEN_KICKED:
        case COLLISION_BEHAVIOR_HEN_DEAD:
            _angle += _rotationAmount * dt;
            [self getCCSprite].rotation = _angle;
            _vy += 500.0f * dt;
            break;
        case COLLISION_BEHAVIOR_PIG:
            [self chaseAtDistance:GAME_OBJECT_DISTANCE_ONSCREEN DefaultSpeed:0.0f ChaseSpeed:-100.0f ChaseSound:@"pigEnters"];
            break;

            
        
        ///////////////////////////
        //LEVEL 3 - TOWN RUN
        ///////////////////////////
        case COLLISION_BEHAVIOR_ROLLING_HAYBALE:
            [self chaseAtDistance:GAME_OBJECT_DISTANCE_ONSCREEN DefaultSpeed:0.0f ChaseSpeed:-150.0f];
            break;
        case COLLISION_BEHAVIOR_FLYER:
            [self chaseAtDistance:GAME_OBJECT_DISTANCE_ONSCREEN DefaultSpeed:0.0f ChaseSpeed:-250.0f ChaseSound:@"crowAppears"];
            break;
        
            
        ///////////////////////////
        //LEVEL 5 - CITY RUN
        ///////////////////////////
        case COLLISION_BEHAVIOR_MAD_DOG:
            [self chaseAtDistance:200.0f DefaultSpeed:0.0f ChaseSpeed:-150.0f ChaseSound:@"maddogBark" ChaseAnimation:@"madDogAnim" DefaultAnimation:@"dogAnim"];
            break;
        

        ///////////////////////////
        //LEVEL 6 - UNDEAD RUN
        ///////////////////////////
        case COLLISION_BEHAVIOR_ZOMBIE_WALK:
            [self chaseAtDistance:GAME_OBJECT_DISTANCE_ONSCREEN DefaultSpeed:0.0f ChaseSpeed:-40.0f ChaseSound:@"zombieMoan"];
            break;
        case COLLISION_BEHAVIOR_ZOMBIE_WALK_FAST:
            [self chaseAtDistance:GAME_OBJECT_DISTANCE_ONSCREEN DefaultSpeed:0.0f ChaseSpeed:-60.0f];
            break;            

                    
        ///////////////////////////
        //LEVEL 7 - COMPUTER RUN
        ///////////////////////////
        case COLLISION_BEHAVIOR_COMPUTER_MELISSA:
            [self chaseAtDistance:210.0f DefaultSpeed:-50.0f ChaseSpeed:-175.0f ChaseSound:@"" ChaseAnimation:@"computerMelissaFastAnim" DefaultAnimation:@"computerMelissaSlowAnim"];
            break;
        case COLLISION_BEHAVIOR_COMPUTER_WORM:
            if ([[_sprite getAnimation] getCurrentFrameNumber] == 1) {
                _vx = -50.0f;
            } else {
                _vx = 0.0f;
            }
            break;   
            
            
        ///////////////////////////
        //LEVEL 8 - VOLCANO RUN
        ///////////////////////////
        case COLLISION_BEHAVIOR_FIRE_DEMON:
            [self chaseAtDistance:GAME_OBJECT_DISTANCE_ONSCREEN DefaultSpeed:0.0f ChaseSpeed:-25.0f];
            _angle += _rotationAmount * dt;
            [self getCCSprite].rotation = _angle;
            break;
        case COLLISION_BEHAVIOR_FIRE_DEMON_ARMOR:
            _vx = 0.0f;
            break;
        case COLLISION_BEHAVIOR_FIRE_DEMON_ARMOR_WAITTOSHOOT:
            if (_reloading >=0.0f) {
                _reloading -= dt;
            } else {
                if(_waitToTrigger > 0.0f) {
                    _waitToTrigger -= dt;
                    if(_waitToTrigger<= 0.0f){
                        _reloading = 1.4f;
                        if(_projectile!=nil) {
                            [_projectile release];
                        }
                        _projectile = [Projectile projectileWithBehavior:PROJECTILE_BEHAVIOR_FIRE_DEMON_BULLET];
                        [_projectile reset];
                        [_projectile setPosition:CGPointMake(_x + 53, _y - 20 )];
                        [_projectile setBoundingBox:CGRectMake(-7, 12, 16, 16)];
                    } 
                } else {
                    if ([self closeToPlayer:300.0f]) {
                        [[AnimationController sharedController] replaceSprite:self.sprite withAnimationNamed:@"fireDemonWithArmorShooting"];
                        _waitToTrigger = 0.28f;
                    }
                    else if ([self closeToPlayer:GAME_OBJECT_DISTANCE_ONSCREEN]) {
                        _vx = -0.0f;
                    }
                    
                }
            }
            break;
        case COLLISION_BEHAVIOR_FIREBALL_START:
            if ([self closeToPlayer:GAME_OBJECT_DISTANCE_ONSCREEN]) {
                Player *player = [[LayerManager sharedLayers] getPlayer];
                CGPoint position = [player getPosition];
                [self setPositionAtX:(position.x - 100.0f) Y:350.0f];
                [self setPlayerEffect:@"none"];
                _currentBehavior = COLLISION_BEHAVIOR_FIREBALL_MOVING;
                _isInvincible = true;
                
            }
            break;
        case COLLISION_BEHAVIOR_FIREBALL_MOVING:
            _vx += 160.0f;
            _vy += 100.0f;
            if (_y <= 75.0f) {
                _vx = 0.0f;
                _vy = 0.0f;
                _x = _prevLocation.x;
                _y = 90.0f;
                _isInvincible = false;
                [self setPositionAtX:_x Y:_y];
                [[AnimationController sharedController] replaceSprite:self.sprite withAnimationNamed:@"fireballLandingAnim"];
                _currentBehavior = COLLISION_BEHAVIOR_FIREBALL_LANDED;
                _collideBehavior = COLLISION_BEHAVIOR_FIREBALL_LANDED;
                [self setPlayerEffect:@"collide"];
                [[SoundEngine shared] playSound:@"fireballLand"];
            }
            break;
            
            
        ///////////////////////////
        //LEVEL 9 - STORMY RUN
        ///////////////////////////
        case COLLISION_BEHAVIOR_UMBRELLA_FLY_UP:
            _vx = 0.0f;
            if ([self closeToPlayer:275]) {
                _angle+=200.0f*dt;
                if(_angle>-120.0f) {
                    _angle = -120.0f;
                }
                [_sprite getCCSprite].rotation = -30.0f + ((_angle + 180.0f) / (2.66667f));
                _vx = _magnitude * cosf((_angle * 3.14159)/180.0f);
                _vy = _magnitude * sinf((_angle * 3.14159)/180.0f);
                
            } else if ([self closeToPlayer:GAME_OBJECT_DISTANCE_ONSCREEN]) {
                _vx = -1 * _magnitude;
                _angle = -180.0f;
                [_sprite getCCSprite].rotation = -30.0f;
            }        
            break;
        case COLLISION_BEHAVIOR_PAPERPLANE:
            _vx = 0.0f;
            if ([self closeToPlayer:375]) {
                _angle+=110.0f*dt;
                if(_angle > -60.0f) {
                    _stopCurve=true;
                    _angle = - 60.0f;
                    
                    _vx = -1 * _magnitude;
                    _vy=0;
                }
                if(!_stopCurve)
                {
                    _vx = _magnitude * cosf((_angle * 3.14159)/180.0f);
                    _vy = -1*_magnitude * sinf((_angle * 3.14159)/180.0f);
                }
                
            }else if  ([self closeToPlayer:GAME_OBJECT_DISTANCE_ONSCREEN]) {
                _vx = -1 * _magnitude;
                _angle = -180;
            }            
            break;
            
        case COLLISION_BEHAVIOR_RAINY_SQUIRREL:
            if (_reloading >=0.0f)
            {
                _reloading -= dt;
            }
            else {
                if(_waitToTrigger > 0.0f && !_collided) {
                    _waitToTrigger -= dt;
                    if(_waitToTrigger<= 0.0f){
                        _reloading = 4.0f;
                        if(_projectile!=nil) {
                            [_projectile release];
                        }
                        _projectile = [Projectile projectileWithBehavior:PROJECTILE_BEHAVIOR_RAINY_SQUIRREL_NUT];
                        [_projectile reset];
                        [_projectile setPosition:CGPointMake(_x - 25.0f, _y + 19)];
                        [_projectile setBoundingBox:CGRectMake(5, 12, 16, 16)];
                        [_projectile setInitialVelocity];
                    } 
                } else {
                    if ([self closeToPlayer:400.0f]) {
                        _waitToTrigger = 0.28f;
                        _hasAppeared=true;
                    }
                    else if ([self closeToPlayer:GAME_OBJECT_DISTANCE_ONSCREEN]) {
                        _vx = 100.0f;
                        
                    }
                    
                }
            }
            if(_hasAppeared && [self checkIfOffScreen:[self getPosition]])
            {
                [self switchToInactive];
                _hasAppeared=false;
            }
            break;
   
            
        ///////////////////////////
        //LEVEL 10 - AQUARIUM RUN
        ///////////////////////////
        case COLLISION_BEHAVIOR_WATER_SEAHORSE:
            if ([self closeToPlayer:GAME_OBJECT_DISTANCE_ONSCREEN]) {
                _vy *= 0.955f;
                if (ABS(_vy) <= 0.1f) {
                    if (_direction == 1) {
                        _direction = -1;
                        _vy = -430.0f;
                        [[SoundEngine shared] playSound:@"waterSeaHorse"];
                    } else {
                        _direction = 1;
                        _vy = 430.0f;
                        [[SoundEngine shared] playSound:@"waterSeaHorse"];
                    }
                }
            }
            break;
        case COLLISION_BEHAVIOR_CHARGE_AT_PLAYER_SLOW:
            [self chaseAtDistance:GAME_OBJECT_DISTANCE_ONSCREEN DefaultSpeed:0.0f ChaseSpeed:-100.0f ChaseSound:@"waterAnglerFish"];
            break;
            
        
        ////////////////////////
        //LEVEL 11 - FINAL RUN
        ////////////////////////
        case COLLISION_BEHAVIOR_BAT:
            if  ([self closeToPlayer:GAME_OBJECT_DISTANCE_ONSCREEN])
            {
                if (!_madeSound) {
                    _madeSound = true;
                    [[SoundEngine shared] playSound:@"darkBats"];
                }
                _angle+=200*dt;
                _magnitude=300;
                _vx = -0.12*_magnitude;
                _vy =1.1*_magnitude * cosf((_angle * 3.14159)/180.0f);
            }
            break;
        case COLLISION_BEHAVIOR_DARK_SPIKES:
            if (_waitToTrigger>0) {
                _waitToTrigger-=dt;
                if(_waitToTrigger <= 0)
                {
                    _vy=-800;
                    if (!_madeSound) {
                        _madeSound = true;
                        [[SoundEngine shared] playSound:@"darkSpikes"];
                        _movedBy = 0.0f;
                        _initialPosition = _y;
                    }
                }
            }
            else if([self closeToPlayer:150] && !_hasTriggered)
            {
                _waitToTrigger=0.3f;
                _hasTriggered=true;
                
            }
            else if(_vy<0)
            {
                if (_movedBy > 65.0f) {
                    _movedBy = 65.0f;                
                    _y = _initialPosition + _movedBy;
                    _vy = 0.0f;
                }
            }
            break;
        case COLLISION_BEHAVIOR_GARGOYLE:
            _vx = 0.0f;
            if (_waitToTrigger >= 0) {
                _waitToTrigger -= dt;
                
                if(_waitToTrigger <= 0){
                    if(![self.originalAnimation isEqualToString:@"gargoyleOpenWings"])
                    {
                        [self setOriginalAnimation:@"gargoyleOpenWings"];
                        [[AnimationController sharedController] replaceSprite:self.sprite withAnimationNamed:@"gargoyleOpenWings"];
                    }
                }
            }
            
            else if ([self closeToPlayer:300] && !_hasTriggered){
                
                _waitToTrigger=0.4f;
                _hasTriggered = true;
            }
            else if([self.originalAnimation isEqualToString:@"gargoyleOpenWings"] && [[_sprite getAnimation] getCurrentFrameNumber]==6)
            {
                if(![self.originalAnimation isEqualToString:@"gargoyleOpened"])
                {
                    [self setOriginalAnimation:@"gargoyleOpened"];
                    [[AnimationController sharedController] replaceSprite:self.sprite withAnimationNamed:@"gargoyleOpened"];
                    [self setBoundingBox:CGRectMake(-45, 0, 25, 60)];
                }
            }
            break;
            
        default:
            break;
    }
}

-(void) chaseAtDistance:(float)distance DefaultSpeed:(float)defaultSpeed ChaseSpeed:(float)chaseSpeed
{
    if(_chaseTriggered) {
        _vx = chaseSpeed;        
    } else {
        _vx = defaultSpeed;
        if ([self closeToPlayer:distance]) {
            _vx = chaseSpeed;
            _chaseTriggered = true;
        }
    }
}

-(void) chaseAtDistance:(float)distance DefaultSpeed:(float)defaultSpeed ChaseSpeed:(float)chaseSpeed ChaseSound:(NSString*)sound
{
    [self chaseAtDistance:distance DefaultSpeed:defaultSpeed ChaseSpeed:chaseSpeed ChaseSound:sound ChaseAnimation:@"" DefaultAnimation:@""];
}

-(void) chaseAtDistance:(float)distance DefaultSpeed:(float)defaultSpeed ChaseSpeed:(float)chaseSpeed ChaseSound:(NSString*)sound ChaseAnimation:(NSString*)chaseAnim DefaultAnimation:(NSString*)defaultAnim
{
    if (!_chaseTriggered) {
        [self chaseAtDistance:distance DefaultSpeed:defaultSpeed ChaseSpeed:chaseSpeed];
        if (_chaseTriggered) {
            if (![sound isEqualToString:@""]) {
                [[SoundEngine shared] playSound:sound];
            }
            
            if (![chaseAnim isEqualToString:@""]) {
                [self setOriginalAnimation:defaultAnim];
                [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:chaseAnim];
            }
        }
    } else {
        [self chaseAtDistance:distance DefaultSpeed:defaultSpeed ChaseSpeed:chaseSpeed];
    }
}



-(bool) closeToPlayer:(float)closerThan
{
    Player *player = [[LayerManager sharedLayers] getPlayer];
    CGPoint position = [player getPosition];
    if (_x < (position.x + closerThan)) {
        return true;
    }
    
    return false;
}

               
                 
-(bool) checkIfOffScreen:(CGPoint)position
{
    CGPoint screenPosition = [[Camera sharedCamera] convertToScreenXY:position];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //float minAmount = 
        
        if (screenPosition.x + 100 < 0 ) {
            return true;
        }
    } else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (screenPosition.x + 100 < 0) {
            return true;
        }
    }
    return false;
}


-(void) updateFlags
{
    //only place isfalling gets updated
    _isFalling = false;
    if (_isInMidAir && _vy > 0) {
        _isFalling = true;
    }
}

-(void) updateLights:(float)dt
{
    if (_rotateLights) {
        float maxAngle = 25.0f;
        float rate = 90.0f * dt;
        if (_direction == 1) {
            _angle += rate;
            if (_angle >= maxAngle) {
                _angle = maxAngle;
                _direction = -1;
            }
        } else {
            _angle -= rate;
            if (_angle <= -maxAngle) {
                _angle = -maxAngle;
                _direction = 1;
            }
        }
        [_sprite getCCSprite].rotation = _angle;
    }
}

-(void) switchToInactive
{
    _isActive = false;
    [self getCCSprite].visible = false;
}

-(void) reset
{
    if (_boss!=nil) { 
        [_boss reset];
        return;
    }
    _isActive = true;
    _angle = 0.0f;
    _vx = 0;
    _vy = 0;
    _alpha = 1.0f;
    _fadeout = false;
    _waitToTrigger = -1.0f;
    _slowTimeModifier = 1.0f;
    _reloading = 0.0f;
    _movedBy = 0.0f;
    _stopCurve=false;
    _hasAppeared=false;
    _chaseTriggered = false;
    if(self )
    _madeSound = false;
    [_sprite setAlpha:1.0f];
     
    if (![_originalAnimation isEqualToString:@"none"]) {
        [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:_originalAnimation];        
    }
    
    
    //for now just kill the projectile. we apparently can't add it on initialization of the object.
    if (_projectile !=nil) {
        [_projectile release];
        _projectile = nil;
    }
    
    [self setPosition:_startingPosition];
    [self getCCSprite].visible = true;
    [self getCCSprite].rotation = _angle;

    if(_currentBehavior == COLLISION_BEHAVIOR_CHARGE_AT_PLAYER_BD)
    {
        _currentBehavior = COLLISION_BEHAVIOR_CHARGE_AT_PLAYER;
    }
    if(_currentBehavior == COLLISION_BEHAVIOR_CHARGE_AT_PLAYER_FAST_BD)
    {
        _currentBehavior = COLLISION_BEHAVIOR_CHARGE_AT_PLAYER_FAST;
    }
    
    if (_currentBehavior == COLLISION_BEHAVIOR_HEN_KICKED || _currentBehavior == COLLISION_BEHAVIOR_HEN_STATIC || _currentBehavior == COLLISION_BEHAVIOR_HEN_DEAD) {
        _isAggressive = false;
        _currentBehavior = COLLISION_BEHAVIOR_HEN_STATIC;
    } else if (_currentBehavior == COLLISION_BEHAVIOR_ZOMBIE_HEADLESS ||  _currentBehavior == COLLISION_BEHAVIOR_ZOMBIE_WALK) {
        _currentBehavior = COLLISION_BEHAVIOR_ZOMBIE_WALK;
    } else if(_currentBehavior == COLLISION_BEHAVIOR_MAD_DOG) {
        _currentBehavior = COLLISION_BEHAVIOR_MAD_DOG;
        /*
        [self setOriginalAnimation:@"dogAnim"];
        [[AnimationController sharedController] replaceSprite:self.sprite withAnimationNamed:@"dogAnim"];
         */
    } else if(_currentBehavior ==COLLISION_BEHAVIOR_GARGOYLE) {
        
        _currentBehavior = COLLISION_BEHAVIOR_GARGOYLE;
        
        [self setOriginalAnimation:@"gargoyleSit"];
        [[AnimationController sharedController] replaceSprite:self.sprite withAnimationNamed:@"gargoyleSit"];
        [self setBoundingBox:CGRectMake(-45, 0, 20, 25)];
        _hasTriggered=false;
        [[_sprite getAnimation] changeAnimationSpeed:1];
    }
    else if(_currentBehavior == COLLISION_BEHAVIOR_ZOMBIE_WALK_FAST || _currentBehavior == COLLISION_BEHAVIOR_ZOMBIE_FADE) {
        _currentBehavior = COLLISION_BEHAVIOR_ZOMBIE_WALK_FAST;
    } else if(_currentBehavior == COLLISION_BEHAVIOR_FLYER_DEAD || _currentBehavior == COLLISION_BEHAVIOR_FLYER) {
        _currentBehavior = COLLISION_BEHAVIOR_FLYER;
    } else if(_currentBehavior == COLLISION_BEHAVIOR_ROLLING_HAYBALE) {
        _currentBehavior = COLLISION_BEHAVIOR_ROLLING_HAYBALE;
    } else if(_currentBehavior == COLLISION_BEHAVIOR_FIRE_DEMON) {
        _currentBehavior = COLLISION_BEHAVIOR_FIRE_DEMON;
    } else if(_currentBehavior == COLLISION_BEHAVIOR_FIREBALL_START || _currentBehavior == COLLISION_BEHAVIOR_FIREBALL_MOVING || _currentBehavior == COLLISION_BEHAVIOR_FIREBALL_LANDED) {
        _currentBehavior = COLLISION_BEHAVIOR_FIREBALL_START;
        [[AnimationController sharedController] replaceSprite:self.sprite withAnimationNamed:@"fireballMovingAnim"];
    } else if(_currentBehavior == COLLISION_BEHAVIOR_FIRE_DEMON_ARMOR_WAITTOSHOOT || _currentBehavior == COLLISION_BEHAVIOR_FIRE_DEMON_ARMOR) {
        _currentBehavior = COLLISION_BEHAVIOR_FIRE_DEMON_ARMOR_WAITTOSHOOT;
        [[AnimationController sharedController] replaceSprite:self.sprite withAnimationNamed:@"fireDemonWithArmorWalking"];
    } else if(_currentBehavior == COLLISION_BEHAVIOR_FROG_SQUASH) {
        _currentBehavior = COLLISION_BEHAVIOR_STATIC;
        [self.sprite setAnimationByName:@"rainyFrogIdleAnim"];
    } else if(_currentBehavior == COLLISION_BEHAVIOR_UMBRELLA_FLY_UP) {
        _currentBehavior = COLLISION_BEHAVIOR_UMBRELLA_FLY_UP;
    } 
    else if(_currentBehavior == COLLISION_BEHAVIOR_PAPERPLANE) {
        _currentBehavior = COLLISION_BEHAVIOR_PAPERPLANE;
    
    }
    else if(_currentBehavior == COLLISION_BEHAVIOR_PIG) {
        _currentBehavior = COLLISION_BEHAVIOR_PIG;
    }
    else if(_currentBehavior == COLLISION_BEHAVIOR_BAT) {
        _currentBehavior = COLLISION_BEHAVIOR_BAT;
        _angle=-180;
       // [self setOriginalAnimation:@"batHanging"];
        //[[AnimationController sharedController] replaceSprite:self.sprite withAnimationNamed:@"batHanging"];
    }
    else if(_currentBehavior == COLLISION_BEHAVIOR_UMBRELLA_FLY_ACROSS) {
        _currentBehavior = COLLISION_BEHAVIOR_UMBRELLA_FLY_ACROSS;
    } else if(_currentBehavior == COLLISION_BEHAVIOR_RAINY_TREE_A) {
        _currentBehavior = COLLISION_BEHAVIOR_RAINY_TREE_A;
    } else if(_currentBehavior == COLLISION_BEHAVIOR_RAINY_TREE_B) {
        _currentBehavior = COLLISION_BEHAVIOR_RAINY_TREE_B;
    } else if(_currentBehavior == COLLISION_BEHAVIOR_RAINY_SQUIRREL) {
        _currentBehavior = COLLISION_BEHAVIOR_RAINY_SQUIRREL;
        _persistsBetweenRegions = true;
        _hasAppeared=false;
    } else if(_currentBehavior == COLLISION_BEHAVIOR_FADES) {
        _currentBehavior = COLLISION_BEHAVIOR_STATIC;
        _collideBehavior = COLLISION_BEHAVIOR_FADES;
    } else if(_currentBehavior == COLLISION_BEHAVIOR_WATER_SEAHORSE) {
        _currentBehavior = COLLISION_BEHAVIOR_WATER_SEAHORSE;
        _direction = 1;
    } else if(_currentBehavior == COLLISION_BEHAVIOR_WATER_PUFFERFISH) {
        _currentBehavior = COLLISION_BEHAVIOR_WATER_PUFFERFISH;
    }else if(_currentBehavior == COLLISION_BEHAVIOR_DARK_SPIKES) {
        _currentBehavior = COLLISION_BEHAVIOR_DARK_SPIKES;
       
        _hasTriggered=false;
    } else if(_currentBehavior == COLLISION_BEHAVIOR_COMPUTER_MELISSA) {
        _currentBehavior = COLLISION_BEHAVIOR_COMPUTER_MELISSA;
        _hasTriggered = false;
    } else if(_currentBehavior == COLLISION_BEHAVIOR_COMPUTER_WORM) {
        _currentBehavior = COLLISION_BEHAVIOR_COMPUTER_WORM;
        _hasTriggered = false;
    }
    else if(_currentBehavior == COLLISION_BEHAVIOR_CLAPPING_CROWD) {
        _currentBehavior = COLLISION_BEHAVIOR_CLAPPING_CROWD;
        [self playerHasCheering:false];
        _hasTriggered=false;
    }
    else if(_currentBehavior != COLLISION_BEHAVIOR_CHARGE_AT_PLAYER && _currentBehavior != COLLISION_BEHAVIOR_CHARGE_AT_PLAYER_FAST && _currentBehavior != COLLISION_BEHAVIOR_CHARGE_AT_PLAYER_SLOW) {
        _currentBehavior = COLLISION_BEHAVIOR_STATIC;     
    }
    _collided = false;
}

-(Collision*) getCollision
{
    return _collisionState;
}

-(void) setCollideBehavior:(NSString*)behavior
{
    
    if([behavior compare:@"static"] == NSOrderedSame) {
        _collideBehavior = COLLISION_BEHAVIOR_STATIC;
    } else if([behavior compare:@"falls"] == NSOrderedSame){
        _collideBehavior = COLLISION_BEHAVIOR_FALL_OVER;
    }else if([behavior compare:@"hurdles"] == NSOrderedSame){
        _collideBehavior = COLLISION_BEHAVIOR_FALL_OVER;
        _isHurdle = true;
    } 
    else if([behavior compare:@"kicked"] == NSOrderedSame) {
        _currentBehavior = COLLISION_BEHAVIOR_HEN_STATIC;
        _collideBehavior = COLLISION_BEHAVIOR_HEN_DEAD;
    } else if([behavior compare:@"anim"] == NSOrderedSame) {
        _collideBehavior = COLLISION_BEHAVIOR_PLAY_ANIMATION;
    } else if([behavior compare:@"cowCollapse"] == NSOrderedSame) {
        _currentBehavior = COLLISION_BEHAVIOR_STATIC;
        _collideBehavior = COLLISION_BEHAVIOR_COW_COLLAPSE;
        _aggressiveCanHit = true;
    } else if([behavior isEqualToString:@"dancinManCollapse"]) {
        _collideBehavior = COLLISION_BEHAVIOR_DANCIN_MAN_COLLAPSE;
    } else if([behavior isEqualToString:@"chargeAtPlayer"]) {
        _collideBehavior = COLLISION_BEHAVIOR_CHARGE_AT_PLAYER;
        _currentBehavior = COLLISION_BEHAVIOR_CHARGE_AT_PLAYER;
        _beatsPlayerAction = true;
    }
    else if([behavior isEqualToString:@"BDchargeAtPlayer"]) {
        _collideBehavior = COLLISION_BEHAVIOR_CHARGE_AT_PLAYER_BD;
        _currentBehavior = COLLISION_BEHAVIOR_CHARGE_AT_PLAYER;
        _beatsPlayerAction = true;
    }
    else if([behavior isEqualToString:@"chargeAtPlayerFast"]) {
        _collideBehavior = COLLISION_BEHAVIOR_CHARGE_AT_PLAYER_FAST;
        _currentBehavior =COLLISION_BEHAVIOR_CHARGE_AT_PLAYER_FAST;
        _beatsPlayerAction = true;
    }
    else if([behavior isEqualToString:@"BDchargeAtPlayerFast"]) {
        _collideBehavior = COLLISION_BEHAVIOR_CHARGE_AT_PLAYER_FAST_BD;
        _currentBehavior =COLLISION_BEHAVIOR_CHARGE_AT_PLAYER_FAST;
        _beatsPlayerAction = true;
    }
    else if([behavior isEqualToString:@"chargeAtPlayerSlow"]) {
        _collideBehavior = COLLISION_BEHAVIOR_CHARGE_AT_PLAYER_SLOW;
        _currentBehavior =COLLISION_BEHAVIOR_CHARGE_AT_PLAYER_SLOW;
        _beatsPlayerAction = true;
    } 
    else if([behavior isEqualToString:@"zombie"]) {
        _collideBehavior = COLLISION_BEHAVIOR_ZOMBIE_HEADLESS;
        _currentBehavior = COLLISION_BEHAVIOR_ZOMBIE_WALK;
        _aggressiveCanHit = true;
    } else if([behavior isEqualToString:@"headless"]) {
        _collideBehavior = COLLISION_BEHAVIOR_ZOMBIE_FADE;
        _currentBehavior = COLLISION_BEHAVIOR_ZOMBIE_WALK_FAST;
    } else if([behavior isEqualToString:@"bossShip"]) {
        _collideBehavior = COLLISION_BEHAVIOR_NONE;
        _boss = [BossFactory buildWithType:BOSS_SPACESHIP];
        [_boss setSprite:_sprite];
        [_boss startBoss];
    } else if([behavior isEqualToString:@"finalBoss"]) {
        _collideBehavior = COLLISION_BEHAVIOR_NONE;
        _boss = [BossFactory buildWithType:BOSS_FINAL_JIM];
        [_boss setSprite:_sprite];
        [_boss startBoss];
    } else if([behavior isEqualToString:@"retroStatic"]) {
        _collideBehavior = COLLISION_BEHAVIOR_RETRO_HURDLE;
        _currentBehavior = COLLISION_BEHAVIOR_RETRO_SHOT_FROM_CANNON;
    } else if([behavior isEqualToString:@"flyer"]) {
        _collideBehavior = COLLISION_BEHAVIOR_FLYER_DEAD;
        _currentBehavior = COLLISION_BEHAVIOR_FLYER;
    } else if([behavior isEqualToString:@"rolling"]) {
        _collideBehavior = COLLISION_BEHAVIOR_ROLLING_HAYBALE;
        _currentBehavior = COLLISION_BEHAVIOR_ROLLING_HAYBALE;
    }else if([behavior isEqualToString:@"clapping"]) {
        _collideBehavior = COLLISION_BEHAVIOR_CLAPPING_CROWD;
        _currentBehavior = COLLISION_BEHAVIOR_CLAPPING_CROWD;
    } 
    else if([behavior isEqualToString:@"madDog"]) {
        _collideBehavior = COLLISION_BEHAVIOR_MAD_DOG;
        _currentBehavior = COLLISION_BEHAVIOR_MAD_DOG;
    }
    else if([behavior isEqualToString:@"gargoyle"]) {
        _collideBehavior = COLLISION_BEHAVIOR_GARGOYLE;
        _currentBehavior = COLLISION_BEHAVIOR_GARGOYLE;
    }
    else if([behavior isEqualToString:@"retroZombie"]) {
        _collideBehavior = COLLISION_BEHAVIOR_RETRO_ZOMBIE;
        _currentBehavior = COLLISION_BEHAVIOR_RETRO_ZOMBIE;
    } else if([behavior isEqualToString:@"fireDemon"]) {
        _collideBehavior = COLLISION_BEHAVIOR_FIRE_DEMON;
        _currentBehavior = COLLISION_BEHAVIOR_FIRE_DEMON;
    } else if([behavior isEqualToString:@"fireDemonWithArmor"]) {
        _collideBehavior = COLLISION_BEHAVIOR_FIRE_DEMON_ARMOR;
        _currentBehavior = COLLISION_BEHAVIOR_FIRE_DEMON_ARMOR_WAITTOSHOOT;
    } else if([behavior isEqualToString:@"fireball"]) {
        _collideBehavior = COLLISION_BEHAVIOR_FIREBALL_MOVING;
        _currentBehavior = COLLISION_BEHAVIOR_FIREBALL_START;
    } else if([behavior isEqualToString:@"frogSquash"]) {
        _collideBehavior = COLLISION_BEHAVIOR_FROG_SQUASH;
        _currentBehavior = COLLISION_BEHAVIOR_STATIC;
    } else if([behavior isEqualToString:@"umbrellaFlyUp"]) {
        _collideBehavior = COLLISION_BEHAVIOR_UMBRELLA_FLY_UP;
        _currentBehavior = COLLISION_BEHAVIOR_UMBRELLA_FLY_UP;
        _magnitude = 200.0f;
    } else if([behavior isEqualToString:@"umbrellaFlyAcross"]) {
        _collideBehavior = COLLISION_BEHAVIOR_UMBRELLA_FLY_ACROSS;
        _currentBehavior = COLLISION_BEHAVIOR_UMBRELLA_FLY_ACROSS;
        _magnitude = 200.0f;
    } else if([behavior isEqualToString:@"rainyTreeA"]) {
        _collideBehavior = COLLISION_BEHAVIOR_RAINY_TREE_A;
        _currentBehavior = COLLISION_BEHAVIOR_RAINY_TREE_A;
    } else if([behavior isEqualToString:@"rainyTreeB"]) {
        _collideBehavior = COLLISION_BEHAVIOR_RAINY_TREE_B;
        _currentBehavior = COLLISION_BEHAVIOR_RAINY_TREE_B;
    } else if([behavior isEqualToString:@"rainySquirrel"]) {
        _collideBehavior = COLLISION_BEHAVIOR_RAINY_SQUIRREL;
        _currentBehavior = COLLISION_BEHAVIOR_RAINY_SQUIRREL;
        _persistsBetweenRegions = true;
    }
    else if([behavior isEqualToString:@"rainyPaperPlane"]) {
        _collideBehavior = COLLISION_BEHAVIOR_PAPERPLANE;
        _currentBehavior = COLLISION_BEHAVIOR_PAPERPLANE;
        _magnitude = 200.0f;
        _angle=180;
    } 
    else if([behavior isEqualToString:@"darkBat"]) {
        _collideBehavior = COLLISION_BEHAVIOR_BAT;
        _currentBehavior = COLLISION_BEHAVIOR_BAT;
        _magnitude = 200.0f;
        _angle=180;
    }
    else if([behavior isEqualToString:@"fades"]) {
        _collideBehavior = COLLISION_BEHAVIOR_FADES;
        _currentBehavior = COLLISION_BEHAVIOR_STATIC;
    } else if([behavior isEqualToString:@"seahorse"]) {
        _currentBehavior = COLLISION_BEHAVIOR_WATER_SEAHORSE;
        _collideBehavior = COLLISION_BEHAVIOR_WATER_SEAHORSE;
        _direction = 1;
    } else if([behavior isEqualToString:@"pufferfish"]) {
        _currentBehavior = COLLISION_BEHAVIOR_WATER_PUFFERFISH;
        _collideBehavior = COLLISION_BEHAVIOR_WATER_PUFFERFISH;
    } else if([behavior isEqualToString:@"spikes"]){
        _currentBehavior = COLLISION_BEHAVIOR_DARK_SPIKES;
        _collideBehavior = COLLISION_BEHAVIOR_DARK_SPIKES;
        
        _hasTriggered=false;
    } else if([behavior isEqualToString:@"computerMelissa"]){
        _currentBehavior = COLLISION_BEHAVIOR_COMPUTER_MELISSA;
        _collideBehavior = COLLISION_BEHAVIOR_COMPUTER_MELISSA;
    } else if([behavior isEqualToString:@"computerWorm"]) {
        _currentBehavior = COLLISION_BEHAVIOR_COMPUTER_WORM;
        _collideBehavior = COLLISION_BEHAVIOR_COMPUTER_WORM;
    } else if([behavior isEqualToString:@"pigCharge"]) {
        _currentBehavior = COLLISION_BEHAVIOR_PIG;
        _collideBehavior = COLLISION_BEHAVIOR_PIG;
    }
    else {
        _collideBehavior = COLLISION_BEHAVIOR_NONE;
    }
}

-(void)setRange:(CGRect)range
{
    _range = range;
}

-(void) setPlayerEffect:(NSString*)effect
{
    if([effect compare:@"collide"] == NSOrderedSame) {
        _playerEffect = PLAYER_EFFECT_COLLIDE;
    } else if([effect compare:@"slow"] == NSOrderedSame) {
        _playerEffect = PLAYER_EFFECT_SLOWDOWN;
    } else if([effect compare:@"actionOrCollide"] == NSOrderedSame) {
        _playerEffect = PLAYER_EFFECT_ACTION_OR_COLLIDE;
    } else if([effect isEqualToString:@"vaccuum"]) {
        //so far just used by water bubbles in underwater level (level 10)
        _playerEffect = PLAYER_EFFECT_VACCUUM;
    } else {
        _playerEffect = PLAYER_EFFECT_NONE;
    }
}

-(Boss*)getBoss
{
    NSAssert(_boss!=nil,@"Called before boss was set.");
    return _boss;
}

-(void) setOriginalAnimation:(NSString*)animation
{
    _originalAnimation = [NSString stringWithString:animation];
}

-(CGRect)getBoundingBox
{
    return _boundingBox;
}

-(void)setBoundingBox:(CGRect)boundingBox
{
    _boundingBox = boundingBox;
    _originalBoundingBox = boundingBox;
}

-(bool)getActive
{
    return _isActive;
}

-(bool)getAggressive
{
    return _isAggressive;
}

-(Projectile*)getProjectile
{
    return _projectile;
}

-(bool)hasBeenHit
{
    return _collided;
}

-(bool)canAggressiveHit
{
    return _aggressiveCanHit;
}

-(CollisionBehavior)getCurrentCollisionBehavior
{
    return _currentBehavior;
}

-(CollisionBehavior)getCollisionBehavior
{
    return _collideBehavior;
}

-(Sprite*) getSprite
{
    return _sprite;
}

-(void)dealloc
{
    [_sprite release];
    [_collisionState release];
    [_boss release];
    
    [super dealloc];
}


@end
