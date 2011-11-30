//
//  ObstacleZombie.h
//  Clay
//
//  Created by Brian Cable on 11/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Obstacle.h"

@class Projectile;

@interface ObstacleZombie : Obstacle
{
    float _x;
    float _y;
    Projectile *_projectile;
    float _alpha;
}
@end
