//
//  Collidable.h
//  Clay
//
//  Created by Brian Cable on 10/26/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//
//  Protocol (interface) for any objects that can be collided with (obstacles, player, projectiles). Currently collision behavior enum is in here as well, but it's probably not the best place for it.

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum {
    COLLISION_BEHAVIOR_FALL_OVER,
    COLLISION_BEHAVIOR_ALIEN_ABDUCTION,
    COLLISION_BEHAVIOR_FLYING_SHURIKEN,
    COLLISION_BEHAVIOR_HEN_KICKED,
    COLLISION_BEHAVIOR_PLAY_ANIMATION,
    COLLISION_BEHAVIOR_STATIC,
    COLLISION_BEHAVIOR_COW_COLLAPSE,
    COLLISION_BEHAVIOR_DANCIN_MAN_COLLAPSE,
    COLLISION_BEHAVIOR_CHARGE_AT_PLAYER,
    COLLISION_BEHAVIOR_ZOMBIE_HEADLESS,
    COLLISION_BEHAVIOR_ZOMBIE_WALK,
    COLLISION_BEHAVIOR_ZOMBIE_WALK_FAST,
    COLLISION_BEHAVIOR_ZOMBIE_FADE,
    COLLISION_BEHAVIOR_RETRO_HURDLE,
    COLLISION_BEHAVIOR_RETRO_PIG,
    COLLISION_BEHAVIOR_RETRO_GARBAGE,
    COLLISION_BEHAVIOR_RETRO_BIRD,
    COLLISION_BEHAVIOR_RETRO_ZOMBIE,
    COLLISION_BEHAVIOR_RETRO_SHOT_FROM_CANNON,
    COLLISION_BEHAVIOR_FLYER,
    COLLISION_BEHAVIOR_FLYER_DEAD,
    COLLISION_BEHAVIOR_NONE,
    COLLISION_BEHAVIOR_ROLLING_HAYBALE,
    COLLISION_BEHAVIOR_MAD_DOG
} CollisionBehavior;

@protocol Collidable <NSObject>

-(CGRect)getBoundingBox;
-(void)setBoundingBox:(CGRect)boundingBox;
-(CGPoint)getPosition;
-(void)startCollision;
-(bool)getActive;
-(void)reset;
-(bool)getAggressive;
-(bool)hasBeenHit;
-(CollisionBehavior)getCollisionBehavior;
-(CCSprite*)getCCSprite;
-(void)setActive:(bool)active;
@end
