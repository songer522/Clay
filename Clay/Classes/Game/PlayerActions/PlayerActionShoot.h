//
//  PlayerActionShoot.h
//  Clay
//
//  Created by Brian Cable on 10/19/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//
//  Used in the Zombie level (level 6) exclusively. The player will show an animation like he's shooting a gun with his fingers, and then a bullet will come out of his hands and shoot out across the screen, severing the heads from any zombie bodies in the process. If it severs a zombie head, you gain one health back.

#import "PlayerAction.h"

@interface PlayerActionShoot : PlayerAction
{
    NSArray *_bullets;
    bool _initialize;
    int _currentBulletIndex;
}

-(void)createBullet;
-(void)resetProjectile;



@end
