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

- (id)init
{
    self = [super init];
    if (self) {
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

-(void) setOffsetForX:(float)x Y:(float)y
{
    _offsetX = x;
    _offsetY = y;
}

-(void) setPosition:(CGPoint)position
{
    [self setPositionAtX:position.x Y:position.y];
}

-(void)setPositionAtX:(int)x Y:(int)y
{
    _x = x;
    _y = y;
    [_sprite setPositionAtX:x + _offsetX Y:y + _offsetY];
}

-(void) startCollision
{
    _collided = true;
    _behavior = COLLISION_BEHAVIOR_FALL_OVER;
}

-(CCSprite*) getCCSprite
{
    return [_sprite getCCSprite];
}

-(void)update:(float)dt
{
    _x += _vx * dt;
    _y -= _vy * dt;
    [self setPositionAtX:_x Y:_y];
    if (_behavior == COLLISION_BEHAVIOR_FALL_OVER) {
        _angle += 325.0f * dt;
        if (_angle >= 90) {
            _angle = 90;
            _behavior = COLLISION_BEHAVIOR_STATIC;
        }
        [self getCCSprite].rotation = _angle;
    }
}

-(Collision*) getCollision
{
    return _collisionState;
}


@end
