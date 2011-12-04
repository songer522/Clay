//
//  ObstacleChicken.h
//  Clay
//
//  Created by Brian Cable on 10/31/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//
//  Obstacle class for the chickens in the barn.

#import <Foundation/Foundation.h>
#import "Obstacle.h"

@interface ObstacleChicken : Obstacle
{
    bool _madeSound;
    
    float _angle;
    float _angularVelocity;
}

-(void)kickHen;

@end
