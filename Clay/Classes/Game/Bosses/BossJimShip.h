//
//  BossJimShip.h
//  Clay
//
//  Created by Brian Cable on 11/7/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Boss.h"
#import "Collidable.h"

@class Sprite;
@class Level;
@class Projectile;

@interface BossJimShip : Boss
{
    Level *_level;
    
    Sprite *_sprite;
    Sprite *_cannonAnim;
    Sprite *_megaCannonAnim;
    Sprite *_comboAttackAnim;
    Sprite *_comboAttackWarningAnim;
    
    CGPoint _velocity;
    CGRect _targetOnScreen;
    
    NSMutableArray *_bullets;
    Projectile *_megaCannonBullet;
    NSMutableArray *_comboAttacks;
    
    float _x;
    float _y;
    
    BossPhase _phase;
    
    CGPoint _target;
    

    int xthrust;
    int ythrust;
    
    int _frame;
    
    bool _firstUpdate;
    
    CGPoint _thrust; //which directions the "thrusters" are going, -1,0,1 in X, or 1,0 in y
    
    float _waitToShoot;
    float _waitToMegaCannon;
    
    bool _hadReset; //need this because jim's ship gets set invisible on reset and setting it in reset function doesn't work
    
    int _replaceProjectileId;
}

-(void)updateVelocity:(float)dt;
-(void)updateCannon:(float)dt;
-(void)updateMegaCannon:(float)dt;
-(void)updateBullets:(float)dt;
-(void)updateMegaBullet:(float)dt;
-(void)shootMegaCannon;
-(void)shootComboAttack;
-(void)switchToPhase:(BossPhase)phase;
-(void)finishedPhase;
-(void)resetProjectiles;
//-(bool)testCollisionsWithSource:(Projectile*)source;
-(bool)testCollisionsWithSource:(id<Collidable>)source;
@end