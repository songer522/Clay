//
//  BossJimShip.h
//  Clay
//
//  Created by Brian Cable on 11/7/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Boss.h"

@class Sprite;
@class Level;

typedef enum {
    RETRO_HURDLE = 0,
    RETRO_PIG = 1,
    RETRO_BIRD = 2,
    RETRO_GARBAGE = 3,
    RETRO_ZOMBIE = 4
}RetroObstacleType;

@interface BossJimShip : Boss
{
    Level *_level;
    
    Sprite *_sprite;
    CGPoint _velocity;
    CGRect _targetOnScreen;
    
    NSMutableArray *_bullets;
    
    int xthrust;
    int ythrust;
    
    bool _firstUpdate;
    
    CGPoint _thrust; //which directions the "thrusters" are going, -1,0,1 in X, or 1,0 in y
    
    float _waitToShoot;
    
    int _replaceProjectileId;
}

-(void)updateVelocity:(float)dt;
-(void)shootBullet;
@end
