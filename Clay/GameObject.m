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
        _offsetX = 0;
        _offsetY = 0;
        _boundingBox = CGRectMake(0, 0, 0, 0);
        _collisionState = [[Collision collisionNode] retain];
        _currentBehavior = COLLISION_BEHAVIOR_STATIC;
        _isAggressive = false;
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
        //hen always dies, but don't actually kick hen unless player decides it's been kicked
        _collided = true;
        [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"henKicked"];
         
    } else if(_currentBehavior == COLLISION_BEHAVIOR_COW_COLLAPSE) {
        [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"cowDied"];        
    }
    
    return _playerEffect;
}

//called by player once it decides that the hen is actually kicked.
-(void)special_kickHen
{
    _collided = false;  //want it to remain aggressive
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

-(void)update:(float)dt
{
    //guard
    if (!_isActive) { return; }
    
    _prevLocation = CGPointMake(_x, _y);
    
    _x += _vx * dt;    
    _y -= _vy * dt;
    
    [self setPositionAtX:_x Y:_y];
    
    
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
        
    }
}

-(void) switchToInactive
{
    _isActive = false;
    [self getCCSprite].visible = false;
}

-(void) reset
{
    _isActive = true;
    _angle = 0.0f;
    _vx = 0;
    _vy = 0;
    
    if ([_originalAnimation compare:@"none"] != NSOrderedSame) {
        [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:_originalAnimation];        
    }
    
    [self setPosition:_startingPosition];
    [self getCCSprite].visible = true;
    [self getCCSprite].rotation = _angle;
    _currentBehavior = COLLISION_BEHAVIOR_STATIC;
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
        _collideBehavior = COLLISION_BEHAVIOR_COW_COLLAPSE;
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
    }
}

-(void) setOriginalAnimation:(NSString*)animation
{
    _originalAnimation = [NSString stringWithString:animation];
}

-(void)dealloc
{
    [_sprite release];
    [_collisionState release];
    [super dealloc];
}


@end
