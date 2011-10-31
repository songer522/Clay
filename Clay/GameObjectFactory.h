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
    BACKGROUND_OBJECT_STATIC,
    BACKGROUND_OBJECT_ANIMATED,
    BACKGROUND_OBJECT_REACTOR,
    OBSTACLE_GENERAL_STATIC,
    OBSTACLE_GENERAL_CHARGER,
    OBSTACLE_GENERAL_FLYER,
    OBSTACLE_BARN_CHICKEN,
    OBSTACLE_ZOMBIES_ZOMBIE
}GameObjectType;

@interface GameObjectFactory : NSObject
{
    
}

-(id<ObstacleProtocol>)build:(GameObjectType)type atPoint:(CGPoint)point;

@end
