//
//  Collision.h
//  Clay
//
//  Created by Brian Cable on 9/9/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    COLLISION_STATE_MIDAIR = 0,
    COLLISION_STATE_GROUNDED = 1,
    COLLISION_STATE_BUMPED_OBJECT = 2,
    COLLISION_STATE_BUMPED_WALL = 3,
    COLLISION_STATE_LEDGE = 4
} CollisionState;

@interface Collision : NSObject
{
    CollisionState _currentState;
    NSString *_previousTile;
}

@property(nonatomic,assign) CollisionState currentState;


+(id)collisionNode;
-(void)processNewCollisionState:(CollisionState)state;

@end
