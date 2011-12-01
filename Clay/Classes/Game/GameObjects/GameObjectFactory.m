//
//  GameObjectFactory.m
//  Clay
//
//  Created by Brian Cable on 10/30/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "GameObjectFactory.h"
#import "GameObject.h"
#import "ObstacleStatic.h"
#import "ObstacleChicken.h"
//#import "ObstacleZombie.h"

@implementation GameObjectFactory

+(id<ObstacleProtocol>)build:(GameObjectType)type atPoint:(CGPoint)point
{
    id object;
    
    switch (type) {
        case OBSTACLE_GENERAL_STATIC:
            object = [ObstacleStatic instance];
            break;
        case OBSTACLE_BARN_CHICKEN:
            object = [ObstacleChicken instance];
            break;
        case OBSTACLE_ZOMBIES_ZOMBIE:
            //object = [ObstacleZombie instance];
            break;
        default:
            object = nil;
            break;
    }
    
    if (object) {
        [object setPosition:point];        
    }
    
    return object;
}

+(id<ObstacleProtocol>)buildFromString:(NSString*)typeString atPoint:(CGPoint)point
{
    NSArray *typeArray = [NSArray arrayWithObjects:@"boStatic",@"boAnimated",@"boReactor",@"obStatic",@"obCharger",@"obFlyer",@"obChicken",@"obZombie",nil];
    
    GameObjectType type = [typeArray indexOfObject:typeString];
    
    id returnVal = [self build:type atPoint:point];
    
    NSAssert(returnVal!=nil, @"ERROR! GameObjectFactory -> created object is nil. verify that the typeString is in the array and the enum.");
    
    return returnVal;
}


@end
