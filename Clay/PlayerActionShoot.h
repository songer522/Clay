//
//  PlayerActionShoot.h
//  Clay
//
//  Created by Brian Cable on 10/19/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "PlayerAction.h"

@interface PlayerActionShoot : PlayerAction
{
    NSArray *_bullets;
    int _currentBulletIndex;
}

-(void)createBullet;


@end
