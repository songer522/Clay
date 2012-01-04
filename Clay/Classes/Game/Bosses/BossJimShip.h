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
@class Projectile;

@interface BossJimShip : Boss
{
    Level *_level;
    
    Sprite *_sprite;
    Sprite *_cannonAnim;
    Sprite *_megaCannonAnim;
    CGPoint _velocity;
    CGRect _targetOnScreen;
    
    NSMutableArray *_bullets;
    Projectile *_megaCannonBullet;

    float _x;
    float _y;
    
    BossPhase _phase;
    
    CGPoint _target;
    

    int xthrust;
    int ythrust;
    
    bool _firstUpdate;
    
    CGPoint _thrust; //which directions the "thrusters" are going, -1,0,1 in X, or 1,0 in y
    
    float _waitToShoot;
    
    int _replaceProjectileId;
}

-(void)updateVelocity:(float)dt;
-(void)updateCannon:(float)dt;
-(void)updateMegaCannon:(float)dt;
-(void)updateBullets:(float)dt;
-(void)shootBullet;
-(void)shootMegaCannon;
-(void)switchToPhase:(BossPhase)phase;
@end
