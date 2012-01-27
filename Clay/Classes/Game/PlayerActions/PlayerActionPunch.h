//
//  PlayerActionPunch.h
//  Clay
//
//  Created by Brian Cable on 1/26/12.
//  Copyright (c) 2012 Xecudev, LLC. All rights reserved.
//

#import "PlayerAction.h"

@class Projectile;
@class Level;

@interface PlayerActionPunch : PlayerAction
{
    Projectile *_punch;
    bool _madePunchProjectile;
    
    //weak references
    Level *_level;
}

-(void)testPunchCollisions;
-(void)updateBoundingBox;

@end
