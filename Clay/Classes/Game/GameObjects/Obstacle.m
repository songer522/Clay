//
//  Obstacle.m
//  Clay
//
//  Created by Brian Cable on 10/31/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "Obstacle.h"
#import "AnimationController.h"
#import "Sprite.h"
#import "Projectile.h"

@implementation Obstacle

+(id)instance
{
    return [[self alloc] init];
}

-(id)init
{
    if((self=[super init])) {
        _isActive = false;
        _hasBeenHit = false;
        _hasGravity = false;
        _isAggressive = false;
        _idleAnimName = @"";
        _collideAnimName = @"";
    }
    
    return self;
}


-(bool) isOnScreen
{
    //temporary
    return true;
}

-(void) reset
{
    _isActive = false;
    _hasBeenHit = false;
    [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:_idleAnimName];
}

-(void)disable
{
    _isActive = false;
    _hasBeenHit = false;
}

-(void) startCollision
{
    //for now, do nothing in base class
}


-(void) update:(float)dt
{
    if (_isActive && [self isOnScreen]) {
        //for now, do nothing
    }
}


-(void)updateMovement:(float)dt
{
    
}





/**********************************
 *  GETTERS and SETTERS
 **********************************/

-(bool) getActive
{
    return _isActive;
}

-(bool) getAggressive
{
    return _isAggressive;
}

-(CGRect) getBoundingBox
{
    return _boundingBox;
}

-(CCSprite*)getCCSprite
{
    return [_sprite getCCSprite];
}

-(CollisionBehavior)getCollisionBehavior
{
    return COLLISION_BEHAVIOR_NONE;
}

-(CGPoint) getPosition
{
    return _position;
}

-(Projectile*)getProjectile
{
    return nil;
}

-(bool) hasBeenHit
{
    return _hasBeenHit;
}

-(void) setActive:(bool)active
{
    _isActive = active;
}

-(void) setBoundingBox:(CGRect)boundingBox
{
    _boundingBox = boundingBox;
}

-(void) setOffset:(CGPoint)offset
{
    _offset = offset;
}

-(void) setSprite:(NSString *)filename
{
    _sprite = [Sprite spriteWithFile:filename];
}

-(void) setVelocity:(CGPoint)velocity
{
    _velocity = velocity;
}


@end
