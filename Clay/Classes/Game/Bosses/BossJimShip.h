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

typedef enum {
    COMBO_ATTACK_PHASE_1,
    COMBO_ATTACK_PHASE_2,
    COMBO_ATTACK_PHASE_3
}ComboAttackPhase;

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

    ComboAttackPhase _comboPhase;
    
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
-(bool)testCollisionsWithSource:(Projectile*)source;
@end