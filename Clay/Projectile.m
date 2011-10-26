//
//  Projectile.m
//  Clay
//
//  Created by Brian Cable on 10/26/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "Projectile.h"

#import "Sprite.h"

@implementation Projectile





+(id) projectileWithBehavior:(ProjectileBehavior)behavior
{
    return [[self alloc] initWithBehavior:behavior];
}

-(id) initWithBehavior:(ProjectileBehavior)behavior
{
    if ((self = [super init])) {
        _x = 0.0f;
        _y = 0.0f;
        _vx = 0.0f;
        _vy = 0.0f;
        _sprite = nil;
        
        _behavior = behavior;
        switch (_behavior) {
            case PROJECTILE_BEHAVIOR_PLAYER_KICK:
                _sprite = nil;
                break;
            case PROJECTILE_BEHAVIOR_BULLET:
                _sprite = [Sprite spriteWithFile:@"bullet.png"];
                _vx = 100.0f;
                break;
            default:
                break;
        }        
    }
    
    return self;
}


-(void) setAttachedTo:(GameObject*)object
{
    _attachedTo = object;
}

-(void) setBoundingBox:(CGRect)rect
{
    _boundingBox = rect;
}

-(void) setPosition:(CGPoint)point
{
    _x = point.x;
    _y = point.y;
    if (_sprite!=nil) {
        [[_sprite getCCSprite] setPosition:point];
    }
}

-(void) update:(float)dt
{
    
}


@end
