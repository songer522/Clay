//
//  ObstacleStatic.h
//  Clay
//
//  Created by Brian Cable on 10/31/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//
//  Generic class for static obstacles (hurdles, stone chickens, haybales, etc.)

#import <Foundation/Foundation.h>
#import "Obstacle.h"

@interface ObstacleStatic : Obstacle
{
    float _fallingVelocity;
    float _angle;
}



@end
