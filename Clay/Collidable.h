//
//  Collidable.h
//  Clay
//
//  Created by Brian Cable on 10/26/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

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
    COLLISION_BEHAVIOR_NONE
} CollisionBehavior;

@protocol Collidable <NSObject>

-(CGRect)getBoundingBox;
-(void)setBoundingBox:(CGRect)boundingBox;
-(CGPoint)getPosition;
-(void)startCollision;
-(bool)getActive;
-(bool)getAggressive;
-(bool)hasBeenHit;
-(CollisionBehavior)getCollisionBehavior;
-(CCSprite*)getCCSprite;
@end
