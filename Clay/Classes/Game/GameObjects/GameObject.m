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
        _projectile = nil;
        _reloading = 0;
        _aggressiveCanHit = false;
        _beatsPlayerAction = false;
        _persistsBetweenRegions = false;
        _magnitude = 0.0f;
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
    if(_playerEffect == PLAYER_EFFECT_COLLIDE) {
        _collided = true;
    }
    
    _currentBehavior = _collideBehavior;
    
    if (_currentBehavior == COLLISION_BEHAVIOR_FALL_OVER) {
        _fallVelocity = 425.0f;
    } else if (_currentBehavior == COLLISION_BEHAVIOR_FLYING_SHURIKEN) {
        float magnitude = rand() % 500 + 600;
        _angle = rand() % 70 + 10;
        _rotationAmount = rand() % 10 * 200;
        _vx = magnitude * cosf((_angle * 3.14159)/180.0f);
        _vy = - magnitude * sinf((_angle * 3.14159)/180.0f);
        [[SoundEngine shared] playSound:@"collision"];
    } else if(_currentBehavior == COLLISION_BEHAVIOR_HEN_KICKED) {
        _hasGravity = false;
        _vy = -150.0f;
        _vx = rand()%40 + 15;
        _alpha = 1.5f;
        _fadeout = true;
        _collided = true;
        [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"henKicked"];
        [[SoundEngine shared] playSound:@"henKicked"];
    } else if(_currentBehavior == COLLISION_BEHAVIOR_COW_COLLAPSE) {
        [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"cowDied"];  
        [[SoundEngine shared] playSound:@"cowDied"];
        _alpha = 1.5f;
        _fadeout = true;
    } else if(_currentBehavior == COLLISION_BEHAVIOR_DANCIN_MAN_COLLAPSE) {
        [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"dancinManDied"];
        _alpha = 1.5f;
        _fadeout = true;
        GameLayer *gameLayer = [[LayerManager sharedLayers] currentLayer];
        [[gameLayer.player getThirdAction] setKilledEnemy:YES];
    } else if(_currentBehavior == COLLISION_BEHAVIOR_ZOMBIE_HEADLESS) {
        [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"femaleHeadlessZombieAnim"];
        _alpha = 1.5f;
        _fadeout = true;
        _projectile = [Projectile projectileWithBehavior:PROJECTILE_BEHAVIOR_ZOMBIE_HEAD];
        [_projectile reset];
        [_projectile setPosition:CGPointMake(_x, _y + 41)];
       // [_projectile setBoundingBox:CGRectMake(15, 33, 30, 30)];
        [_projectile setBoundingBox:CGRectMake(15, 33, 14, 40)];
        
        GameLayer *gameLayer = [[LayerManager sharedLayers] currentLayer];
        [[gameLayer.player getThirdAction] setKilledEnemy:YES];
    } else if(_currentBehavior == COLLISION_BEHAVIOR_ZOMBIE_FADE) {
        _alpha = 1.5f;
        _fadeout = true;
    } else if(_currentBehavior == COLLISION_BEHAVIOR_ROLLING_HAYBALE) {
        _alpha = 1.5f;
        _fadeout = true;
    } else if(_currentBehavior == COLLISION_BEHAVIOR_FIRE_DEMON) {
        _alpha = 1.0f;
        _vy = -50.0f;
        _vx = 50.0f;
        _rate = 2.0f;
        _fadeout = true;
        [[[[LayerManager sharedLayers] getPlayer] getThirdAction] setKilledEnemy:YES];
    } else if(_currentBehavior == COLLISION_BEHAVIOR_FIREBALL_MOVING || _currentBehavior == COLLISION_BEHAVIOR_FIREBALL_START) {
        _collided = false;
    } else if(_currentBehavior == COLLISION_BEHAVIOR_FIREBALL_LANDED) {
        _alpha = 1.2f;
        _fadeout = true;
    } else if(_currentBehavior == COLLISION_BEHAVIOR_FIRE_DEMON_ARMOR || _currentBehavior ==  COLLISION_BEHAVIOR_FIRE_DEMON_ARMOR_WAITTOSHOOT) {
        _alpha = 1.2f;
        _fadeout = true;
    } else if(_currentBehavior == COLLISION_BEHAVIOR_FROG_SQUASH) {
        [self.sprite setAnimationByName:@"rainyFrogSquashAnim"];
        [[SoundEngine shared] playSound:@"frogSquish"];
        _alpha = 1.2f;
        _fadeout = true;
    } else if(_currentBehavior == COLLISION_BEHAVIOR_RAINY_SQUIRREL) {
        _alpha = 1.2f;
        _fadeout = true;
    }
    
    return _playerEffect;
}

//called by player once it decides that the hen is actually kicked.
-(void)special_kickHen
{
    GameLayer *gameLayer = [[LayerManager sharedLayers] currentLayer];
    [[gameLayer.player getThirdAction] setKilledEnemy:true];
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
    
    [self setPositionAtX:_x Y:_y];

    [self updateFadeOut:dt];
    
    [self updateCollisionBehavior:dt];
    
    [self updateFlags];
    
    [self updateLights:dt];
    
    
    
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
    if (_currentBehavior == COLLISION_BEHAVIOR_FALL_OVER) {
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
    } else if(_currentBehavior == COLLISION_BEHAVIOR_FLYING_SHURIKEN) {
        _angle += _rotationAmount * dt;
        [self getCCSprite].rotation = _angle;
        CGPoint position = [[Camera sharedCamera] convertToScreenXY:[self getPosition]];
        
        //hide the object if it's y or x position is high enough,
        //but give the object enough of a chance to clear the iphone screen
        if (position.y > 800.0f || position.x > 1200.0f) {
            [self switchToInactive];            
        }
    } else if(_currentBehavior == COLLISION_BEHAVIOR_HEN_KICKED) {
        _angle += _rotationAmount * dt;
        [self getCCSprite].rotation = _angle;
        _vy += 500.0f * dt;
        
    } else if(_currentBehavior == COLLISION_BEHAVIOR_CHARGE_AT_PLAYER) {
        _vx = 0.0f;
        if ([self closeToPlayer:GAME_OBJECT_DISTANCE_ONSCREEN]) {
            _vx = -150.0f;
        }
    } else if(_currentBehavior == COLLISION_BEHAVIOR_CHARGE_AT_PLAYER_FAST) {
        _vx = 0.0f;
        if ([self closeToPlayer:GAME_OBJECT_DISTANCE_ONSCREEN]) {
            _vx = -200.0f;
        }
    } else if(_currentBehavior == COLLISION_BEHAVIOR_MAD_DOG) {
        _vx = 0.0f;
        if ([self closeToPlayer:200.0f]) {
            if(![self.originalAnimation isEqualToString:@"madDogAnim"])
            {
                [[SoundEngine shared] playSound:@"maddogBark"];
                [self setOriginalAnimation:@"madDogAnim"];
                [[AnimationController sharedController] replaceSprite:self.sprite withAnimationNamed:@"madDogAnim"];
            }
            _vx = -150.0f;    
        }
    } else if(_currentBehavior == COLLISION_BEHAVIOR_RETRO_ZOMBIE) {
        _vx = 0.0f;
        if ([self closeToPlayer:100.0f]) {
            if(![self.originalAnimation isEqualToString:@"retroZombieAnim"])
            { 
                [self setOriginalAnimation:@"retroZombieAnim"];
                [[AnimationController sharedController] replaceSprite:self.sprite withAnimationNamed:@"retroZombieAnim"];
            }
        }
    } else if(_currentBehavior == COLLISION_BEHAVIOR_ZOMBIE_WALK) {
        _vx = 0.0f;
        if ([self closeToPlayer:GAME_OBJECT_DISTANCE_ONSCREEN]) {
            if (!_madeSound) {
                _madeSound = true;
                [[SoundEngine shared] playSound:@"zombieMoan"];
            }
            _vx = -40.0f;
        }
    } else if(_currentBehavior == COLLISION_BEHAVIOR_ZOMBIE_WALK_FAST) {
        _vx = 0.0f;
        if ([self closeToPlayer:GAME_OBJECT_DISTANCE_ONSCREEN]) {
            _vx = -60.0f;
        }
    } else if(_currentBehavior == COLLISION_BEHAVIOR_RETRO_SHOT_FROM_CANNON) {
        _vy += 500.0f * dt;
    } else if(_currentBehavior == COLLISION_BEHAVIOR_FLYER) {
        _vx = 0.0f;
        if ([self closeToPlayer:GAME_OBJECT_DISTANCE_ONSCREEN]) {
            if (!_madeSound) {
                _madeSound = true;
                [[SoundEngine shared] playSound:@"crowAppears"];
            }
            _vx = -250.0f;
        }
    } else if(_currentBehavior == COLLISION_BEHAVIOR_ROLLING_HAYBALE) {
        /*
        int frame = [[_sprite getAnimation] getCurrentFrameNumber];
        
        if (frame == 1) {
            _direction = -1;
        } else if(frame == 6) {
            _direction = 1;
        }
        _vx = _direction * 100.0f;        
    } */
        
            _vx = 0.0f;
            if ([self closeToPlayer:GAME_OBJECT_DISTANCE_ONSCREEN]) {
                _vx = -150.0f;
            }
    }
         else if(_currentBehavior == COLLISION_BEHAVIOR_FIRE_DEMON) {
        _vx = 0.0f;
        _angle += _rotationAmount * dt;
        [self getCCSprite].rotation = _angle;
        if ([self closeToPlayer:GAME_OBJECT_DISTANCE_ONSCREEN]) {
            _vx = -25.0f;
        }
    } else if(_currentBehavior == COLLISION_BEHAVIOR_FIRE_DEMON_ARMOR) {
        _vx = 0.0f;
    } else if(_currentBehavior == COLLISION_BEHAVIOR_FIREBALL_START) {
        if ([self closeToPlayer:GAME_OBJECT_DISTANCE_ONSCREEN]) {
            Player *player = [[LayerManager sharedLayers] getPlayer];
            CGPoint position = [player getPosition];
            [self setPositionAtX:(position.x - 100.0f) Y:350.0f];
            [self setPlayerEffect:@"none"];
            _currentBehavior = COLLISION_BEHAVIOR_FIREBALL_MOVING;
            _isInvincible = true;
            
        }
    } else if(_currentBehavior == COLLISION_BEHAVIOR_FIREBALL_MOVING) {
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
    } else if(_currentBehavior == COLLISION_BEHAVIOR_FIRE_DEMON_ARMOR_WAITTOSHOOT) {
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
    } else if(_currentBehavior == COLLISION_BEHAVIOR_UMBRELLA_FLY_UP) {
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
    } else if(_currentBehavior == COLLISION_BEHAVIOR_UMBRELLA_FLY_ACROSS) {
        if ([self closeToPlayer:GAME_OBJECT_DISTANCE_ONSCREEN]) {
            _vx = -1 * _magnitude;
            _angle = -180.0f;
            [_sprite getCCSprite].rotation = -30.0f;
        }
    }
    else if(_currentBehavior == COLLISION_BEHAVIOR_PAPERPLANE)
    {
        _vx = 0.0f;
        if ([self closeToPlayer:275]) {
            _angle-=180.0f*dt;
            if(_angle < -360.0f) {
                _stopCurve=true;
                _angle = - 360.0f;
                
               _vx = -1 * _magnitude;
            }
            //[_sprite getCCSprite].rotation = -30.0f + ((_angle + 180.0f) / (2.66667f));
            if(!_stopCurve)
            {
                _vx = _magnitude * cosf((_angle * 3.14159)/180.0f);
                _vy = _magnitude * sinf((_angle * 3.14159)/180.0f);
            }
            
        } else if ([self closeToPlayer:GAME_OBJECT_DISTANCE_ONSCREEN]) {
            _vx = -1 * _magnitude;
            _angle = -180;
            //[_sprite getCCSprite].rotation = -30.0f;
        }
    } else if(_currentBehavior == COLLISION_BEHAVIOR_RAINY_SQUIRREL) {
        if (_reloading >=0.0f) {
            _reloading -= dt;
        } else {
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
                    [_projectile setBoundingBox:CGRectMake(0, 12, 16, 16)];
                    [_projectile setInitialVelocity];
                } 
            } else {
                if ([self closeToPlayer:400.0f]) {
                    _waitToTrigger = 0.28f;
                }
                else if ([self closeToPlayer:GAME_OBJECT_DISTANCE_ONSCREEN]) {
                    _vx = 100.0f;
                }
                
            }
        }

        
        
        
        
        
        
        
        

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
    _reloading = 0.0f;
    if(self )
    _madeSound = false;
    [_sprite setAlpha:1.0f];
     
    if ([_originalAnimation compare:@"none"] != NSOrderedSame) {
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

    //reset aggressive
    if (_currentBehavior == COLLISION_BEHAVIOR_HEN_KICKED) {
        _isAggressive = false;
    }
    
    
    if (_currentBehavior == COLLISION_BEHAVIOR_ZOMBIE_HEADLESS ||  _currentBehavior == COLLISION_BEHAVIOR_ZOMBIE_WALK) {
        _currentBehavior = COLLISION_BEHAVIOR_ZOMBIE_WALK;
    }
    
    else if(_currentBehavior == COLLISION_BEHAVIOR_MAD_DOG) {
        _currentBehavior = COLLISION_BEHAVIOR_MAD_DOG;
        [self setOriginalAnimation:@"dogAnim"];
        [[AnimationController sharedController] replaceSprite:self.sprite withAnimationNamed:@"dogAnim"];
    }
    else if(_currentBehavior == COLLISION_BEHAVIOR_RETRO_ZOMBIE) {
        _currentBehavior = COLLISION_BEHAVIOR_RETRO_ZOMBIE;
        [self setOriginalAnimation:@"retroZombieStatic"];
        [[AnimationController sharedController] replaceSprite:self.sprite withAnimationNamed:@"retroZombieStatic"];
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
        _magnitude=200;
    }else if(_currentBehavior == COLLISION_BEHAVIOR_UMBRELLA_FLY_ACROSS) {
        _currentBehavior = COLLISION_BEHAVIOR_UMBRELLA_FLY_ACROSS;
    } else if(_currentBehavior == COLLISION_BEHAVIOR_RAINY_TREE_A) {
        _currentBehavior = COLLISION_BEHAVIOR_RAINY_TREE_A;
    } else if(_currentBehavior == COLLISION_BEHAVIOR_RAINY_TREE_B) {
        _currentBehavior = COLLISION_BEHAVIOR_RAINY_TREE_B;
    } else if(_currentBehavior == COLLISION_BEHAVIOR_RAINY_SQUIRREL) {
        _currentBehavior = COLLISION_BEHAVIOR_RAINY_SQUIRREL;
        _persistsBetweenRegions = true;
    } else if(_currentBehavior != COLLISION_BEHAVIOR_CHARGE_AT_PLAYER && _currentBehavior != COLLISION_BEHAVIOR_CHARGE_AT_PLAYER_FAST) {
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
    } else if([behavior compare:@"kicked"] == NSOrderedSame) {
        _collideBehavior = COLLISION_BEHAVIOR_HEN_KICKED;
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
    } else if([behavior isEqualToString:@"chargeAtPlayerFast"]) {
        _collideBehavior = COLLISION_BEHAVIOR_CHARGE_AT_PLAYER_FAST;
        _currentBehavior =COLLISION_BEHAVIOR_CHARGE_AT_PLAYER_FAST;
        _beatsPlayerAction = true;
    } else if([behavior isEqualToString:@"zombie"]) {
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
    } else if([behavior isEqualToString:@"retroStatic"]) {
        _collideBehavior = COLLISION_BEHAVIOR_RETRO_HURDLE;
        _currentBehavior = COLLISION_BEHAVIOR_RETRO_SHOT_FROM_CANNON;
    } else if([behavior isEqualToString:@"flyer"]) {
        _collideBehavior = COLLISION_BEHAVIOR_FLYER_DEAD;
        _currentBehavior = COLLISION_BEHAVIOR_FLYER;
    } else if([behavior isEqualToString:@"rolling"]) {
        _collideBehavior = COLLISION_BEHAVIOR_ROLLING_HAYBALE;
        _currentBehavior = COLLISION_BEHAVIOR_ROLLING_HAYBALE;
    } else if([behavior isEqualToString:@"madDog"]) {
        _collideBehavior = COLLISION_BEHAVIOR_MAD_DOG;
        _currentBehavior = COLLISION_BEHAVIOR_MAD_DOG;
    }else if([behavior isEqualToString:@"retroZombie"]) {
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

-(CollisionBehavior)getCollisionBehavior
{
    return _collideBehavior;
}

-(void)dealloc
{
    [_sprite release];
    [_collisionState release];
    [_boss release];
    
    [super dealloc];
}


@end
