//
//  GameObjectFactory.m
//  Clay
//
//  Created by Brian Cable on 10/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GameObjectFactory.h"
#import "GameObject.h"
#import "ObstacleStatic.h"

@implementation GameObjectFactory

-(id<ObstacleProtocol>)build:(GameObjectType)type atPoint:(CGPoint)point
{
    id object;
    
    switch (type) {
        case OBSTACLE_GENERAL_STATIC:
            object = [ObstacleStatic instance];
            break;
            
        default:
            break;
    }
    
    if (object) {
        [object setPosition:point];        
    }
    
    return object;
}


@end
