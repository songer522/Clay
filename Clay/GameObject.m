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

@implementation GameObject

@synthesize sprite = _sprite;
@synthesize x = _x;
@synthesize y = _y;
@synthesize vx = _vx;
@synthesize vy = _vy;
@synthesize boundingBox = _boundingBox;
@synthesize collided = _collided;


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
        _behavior = COLLISION_BEHAVIOR_STATIC;
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

-(void) startCollision
{
    _collided = true;
    _behavior = COLLISION_BEHAVIOR_FALL_OVER;
    _fallVelocity = 425.0f;
    if (_behavior == COLLISION_BEHAVIOR_FLYING_SHURIKEN) {
        float magnitude = rand() % 500 + 600;
        _angle = rand() % 70 + 10;
        _rotationAmount = rand() % 10 * 200;
        _vx = magnitude * cosf((_angle * 3.14159)/180.0f);
        _vy = - magnitude * sinf((_angle * 3.14159)/180.0f);
        [[SoundEngine shared] playSound:@"collision"];
    }
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
    
    
    if (_behavior == COLLISION_BEHAVIOR_FALL_OVER) {
        _angle += (_fallVelocity + 100.0f) * dt;
        if (_angle >= 90) {
            _angle = 90;
            _fallVelocity = -0.8f * _fallVelocity;
            _behavior = COLLISION_BEHAVIOR_STATIC;
        } else if(_angle <= 0) {
            _angle = 0;
            _fallVelocity = -0.8f * _fallVelocity;
        }
        [self getCCSprite].rotation = _angle;
    } else if(_behavior == COLLISION_BEHAVIOR_FLYING_SHURIKEN) {
        _angle += _rotationAmount * dt;
        [self getCCSprite].rotation = _angle;
        CGPoint position = [[Camera sharedCamera] convertToScreenXY:[self getPosition]];

        //hide the object if it's y or x position is high enough,
        //but give the object enough of a chance to clear the iphone screen
        if (position.y > 800.0f || position.x > 1200.0f) {
            [self switchToInactive];            
        }
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
    [self setPosition:_startingPosition];
    [self getCCSprite].visible = true;
    [self getCCSprite].rotation = _angle;
    _behavior = COLLISION_BEHAVIOR_STATIC;
    _collided = false;
}

-(Collision*) getCollision
{
    return _collisionState;
}


@end
