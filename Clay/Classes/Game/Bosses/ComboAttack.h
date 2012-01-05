//
//  ComboAttack.h
//  Clay
//
//  Created by Brian Cable on 1/4/12.
//  Copyright (c) 2012 Xecudev, LLC. All rights reserved.
//

#import "cocos2d.h"
#import "Collidable.h"

@class Sprite;

typedef enum {
    COMBO_IDLE,
    COMBO_FIRST_APPEAR,
    COMBO_MOVETO_ATTACK,
    COMBO_WAIT_TO_ATTACK,
    COMBO_ATTACK
}ComboPhase;

@interface ComboAttack : NSObject<Collidable>
{
    Sprite *_bossShip; //weak reference
    
    Sprite *_sprite;
    
    CGPoint _initialPosition;
    CGPoint _attackPosition;
    CGPoint _endAttackPosition;
    CGPoint _position;
    CGPoint _target;
    
    ComboPhase _phase;
    
    CGRect _boundingBox;
    
    float _waitToAttack;
    float _alpha;
    int _comboId;
    bool _isActive;
}

+(id)comboAttackWithId:(int)comboId Ship:(Sprite*)ship;
-(id)initWithId:(int)comboId Ship:(Sprite*)ship;
-(void)startAttack;
-(void)finishedPhase;
-(void)switchToPhase:(ComboPhase)phase;
-(bool)moveWithEasing:(float)dt Magnitude:(float)magnitude;
-(void)update:(float)dt;
@end
