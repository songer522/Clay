//
//  PlayerActionBlow.h
//  Clay
//
//  Created by Brian Cable on 11/22/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "PlayerAction.h"

@class Sprite;
@class Projectile;

@interface PlayerActionBlow : PlayerAction
{
    Projectile *_windProjectile;

    Sprite *_wind;
    bool _startedWindAnimation;
    CGFloat _windOffsetY; //cached at startAction so the plume doesn't bob between blow frames
}

-(void)testBlowCollisions;

@end
