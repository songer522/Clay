//
//  GameObjectFactory.h
//  Clay
//
//  Created by Brian Cable on 10/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Obstacle.h"

typedef enum {
    BACKGROUND_OBJECT_STATIC = 0,
    BACKGROUND_OBJECT_ANIMATED = 1,
    BACKGROUND_OBJECT_REACTOR = 2,
    OBSTACLE_GENERAL_STATIC = 3,
    OBSTACLE_GENERAL_CHARGER = 4,
    OBSTACLE_GENERAL_FLYER = 5,
    OBSTACLE_BARN_CHICKEN = 6,
    OBSTACLE_ZOMBIES_ZOMBIE = 7
}GameObjectType;

@interface GameObjectFactory : NSObject
{
    
}

+(id<ObstacleProtocol>)build:(GameObjectType)type atPoint:(CGPoint)point;

+(id<ObstacleProtocol>)buildFromString:(NSString*)type atPoint:(CGPoint)point;

@end
