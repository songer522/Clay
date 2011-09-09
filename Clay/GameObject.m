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
        _offsetX = 0;
        _offsetY = 0;
        _collisionState = [Collision collisionNode];
        // Initialization code here.
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

-(void)setPositionAtX:(int)x Y:(int)y
{
    _x = x;
    _y = y;
    [_sprite setPositionAtX:x + _offsetX Y:y + _offsetY];
}

-(void)update:(float)dt
{
    _x += _vx * dt;
    _y -= _vy * dt;
    [self setPositionAtX:_x Y:_y];
}

-(Collision*) getCollision
{
    return _collisionState;
}


@end
