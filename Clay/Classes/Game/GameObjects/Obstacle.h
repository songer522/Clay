//
//  Obstacle.h
//  Clay
//
//  Created by Brian Cable on 10/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
//  Base obstacle class that the other obstacles inherit from.

#import <Foundation/Foundation.h>
#import "Collidable.h"

@protocol ObstacleProtocol <NSObject,Collidable>

+(id)instance;
-(void)update:(float)dt;
-(void)setActive:(bool)active;
-(void)setSprite:(NSString*)filename;
-(void)setVelocity:(CGPoint)velocity;
-(void)setOffset:(CGPoint)offset;
-(bool)isOnScreen;

@end

@class Sprite;
@class Projectile;

@interface Obstacle : NSObject<ObstacleProtocol>
{
    
    Sprite *_sprite;

    bool _isActive;
    bool _hasGravity;
    bool _hasBeenHit; //formerly collided
    bool _isAggressive;
    
    CGPoint _position;
    CGPoint _velocity;
    CGPoint _offset;
    
    CGRect _boundingBox;
    
    //for resetting the object
    NSString *_idleAnimName;
    NSString *_collideAnimName;
    CGPoint _startingPosition;
    
}


-(void)updateMovement:(float)dt;
-(Projectile*) getProjectile;

@end
