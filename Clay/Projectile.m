//
//  Projectile.m
//  Clay
//
//  Created by Brian Cable on 10/26/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "Projectile.h"

#import "Sprite.h"
#import "Camera.h"
#import "LevelManager.h"

@implementation Projectile


@synthesize boundingBox = _boundingBox;


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
        _isActive = false;
        _behavior = behavior;
        
        switch (_behavior) {
            case PROJECTILE_BEHAVIOR_PLAYER_KICK:
                _sprite = nil;
                break;
            case PROJECTILE_BEHAVIOR_BULLET:
                _sprite = [Sprite spriteWithFile:@"bullet.png"];
                //[[_sprite getCCSprite] setScale:0.1f];
                [[_sprite getCCSprite] setVisible:NO];
                _vx = 800.0f;
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

-(void) setActive:(bool)isActive
{
    _isActive = isActive;
}

-(CGRect)getBoundingBox
{
    return _boundingBox;
}

-(void)setBoundingBox:(CGRect)boundingBox
{
    _boundingBox = boundingBox;
}

-(void) setPosition:(CGPoint)point
{
    _x = point.x;
    _y = point.y;
    if (_sprite!=nil) {
        [[_sprite getCCSprite] setPosition:[[Camera sharedCamera] convertToScreenXY:point]];
    }
}

-(CGPoint)getPosition
{
    return CGPointMake(_x, _y);
}

-(void)startCollision
{
    
}

-(void)reset
{
    [[_sprite getCCSprite] setVisible:YES];
    _isActive = true;
}



-(void) update:(float)dt
{
    if (_isActive) {        
        [self setPosition:CGPointMake(_x + _vx * dt, _y + _vy * dt)];
    }
}


@end
