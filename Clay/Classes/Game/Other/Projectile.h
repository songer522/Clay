//
//  Projectile.h
//  Clay
//
//  Created by Brian Cable on 10/26/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//
//  Handles any projectiles in the game. This has somewhat different behavior for every type, in particular when it is used for the player's kick to detect when the player has kicked something.

#import <Foundation/Foundation.h>

#import "Collidable.h"

@class GameObject;

typedef enum {
    PROJECTILE_BEHAVIOR_BULLET,
    PROJECTILE_BEHAVIOR_DISCO_BALL,
    PROJECTILE_BEHAVIOR_ZOMBIE_HEAD,
    PROJECTILE_BEHAVIOR_ZOMBIE_HEART,
    PROJECTILE_BEHAVIOR_PLAYER_KICK,
    PROJECTILE_BEHAVIOR_BOSS_SHIP_BULLET,
    PROJECTILE_BEHAVIOR_BOSS_SHIP_MEGACANNON,
    PROJECTILE_BEHAVIOR_PLAYER_BLOWING,
    PROJECTILE_BEHAVIOR_FIRE_DEMON_BULLET,
    PROJECTILE_BEHAVIOR_RAINY_SQUIRREL_NUT
}ProjectileBehavior;

@class Sprite;

@interface Projectile : NSObject<Collidable>
{
    Sprite *_sprite;
    
    ProjectileBehavior _behavior;
    
    GameObject *_attachedTo; //used if the projectile bases its position on what it's attached to (for example, the kick bounding box basing its position on the player's position)
    
    CGRect _boundingBox;
    float _x;
    float _y;
    float _vx;
    float _vy;
    float _alpha;
    float _angle;
    float _angularVelocity;
    float _offscreenPadding;
    float _offsetGroundDetectionY;
    bool _hasGravity;
    bool _isActive;
    bool _isAggressive;
    bool _fadeOut;
}

@property(nonatomic,assign) CGRect boundingBox;

#pragma mark - inits
+(id) projectileWithBehavior:(ProjectileBehavior)behavior;

#pragma mark - accessors
-(CGPoint) getPosition;
-(void) setActive:(bool)isActive;
-(void) setAttachedTo:(GameObject*)object;
-(void) setPosition:(CGPoint)point;

#pragma mark - public methods
-(bool) checkIfOnScreen:(CGPoint)position;
-(void) disable;
-(bool) isActive;
-(void) pointTowardPlayerMaxAngle:(float)maxAngle;
-(void) reset;
-(void) setInitialVelocity;
-(void) update:(float)dt;

@end
