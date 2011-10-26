//
//  Projectile.h
//  Clay
//
//  Created by Brian Cable on 10/26/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Collidable.h"

@class GameObject;

typedef enum {
    PROJECTILE_BEHAVIOR_BULLET,
    PROJECTILE_BEHAVIOR_DISCO_BALL,
    PROJECTILE_BEHAVIOR_ZOMBIE_HEAD,
    PROJECTILE_BEHAVIOR_PLAYER_KICK
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
    bool _isActive;
}

@property(nonatomic,assign) CGRect boundingBox;

+(id) projectileWithBehavior:(ProjectileBehavior)behavior;
-(id) initWithBehavior:(ProjectileBehavior)behavior;

-(void) setAttachedTo:(GameObject*)object;
-(void) setPosition:(CGPoint)point;
-(void) setActive:(bool)isActive;
-(void) update:(float)dt;
-(void) reset;

@end
