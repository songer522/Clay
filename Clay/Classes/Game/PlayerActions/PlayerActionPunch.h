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
    
    bool _punch1SoundPlay;
    bool _punch1SoundCheck;
    bool _punch1SoundPlayed;
    
    bool _punch2SoundPlay;
    bool _punch2SoundCheck;
    bool _punch2SoundPlayed;
    
    //weak references
    Level *_level;
}

-(void)testPunchCollisions;
-(void)updateBoundingBox;

@end
