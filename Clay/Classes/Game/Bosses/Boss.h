//
//  Boss.h
//  Clay
//
//  Created by Brian Cable on 10/19/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"


@protocol BossProtocol <NSObject>

-(void)startBoss;

@end

typedef enum {
    FINAL_BOSS_ATTACK_1,
    FINAL_BOSS_ATTACK_1B,
    FINAL_BOSS_ATTACK_1C,
    FINAL_BOSS_ATTACK_1D,
    FINAL_BOSS_ATTACK_1E,
    FINAL_BOSS_ATTACK_2,
    FINAL_BOSS_ATTACK_2B,
    FINAL_BOSS_ATTACK_2C,
    FINAL_BOSS_ATTACK_2D,
    FINAL_BOSS_ATTACK_3,
    FINAL_BOSS_ATTACK_3B,
    FINAL_BOSS_ATTACK_3C,
    FINAL_BOSS_ATTACK_3D,
    FINAL_BOSS_ATTACK_4,
    FINAL_BOSS_ATTACK_4B,
    FINAL_BOSS_ATTACK_4C,
    FINAL_BOSS_ATTACK_4D,
    FINAL_BOSS_ATTACK_4E,
    FINAL_BOSS_MOVE_TO_BOMBING,
    FINAL_BOSS_MOVE_TO_RIGHT,
    FINAL_BOSS_MOVE_TO_LEFT,
    FINAL_BOSS_IDLE,
    FINAL_BOSS_ENTER,
    FINAL_BOSS_DIE
}FinalBossPhase;

typedef enum {
    BOSS_PHASE_NOT_TRIGGERED = 0,
    BOSS_PHASE_CHASE_INIT = 1,
    BOSS_PHASE_CHASE_FAR = 2,
    BOSS_PHASE_CHASE_MIDDLE = 3,
    BOSS_PHASE_CHASE_CLOSE = 4,
    BOSS_PHASE_ENTERING = 5,
    BOSS_PHASE_EXITING = 6,
    BOSS_PHASE_ATTACKING = 7,
    BOSS_PHASE_IDLE = 8
} BossPhase;

@class Sprite;

@interface Boss : NSObject<BossProtocol>
{
    bool _isActive;
}

@property(nonatomic,assign)bool isActive;


+(id)instance;

-(void)changeAnimationSpeed:(float)modifier;
-(void)update:(float)dt;
-(void)reset;
-(void)restartLevel;
-(void)setSprite:(Sprite*)sprite;
-(void)startBoss;
-(void)switchToPhase:(BossPhase)phase;
-(void)triggerAttack;
-(void)triggerAttack2;
-(void)triggerAttack3;
-(void)triggerFallBack;
-(void)triggerGetCloser;
-(void)triggerAction:(FinalBossPhase)phase;
-(void)addSpritesToLayer:(id)layer SpriteBatch:(CCSpriteBatchNode*)spriteBatch;
-(NSMutableArray*)getProjectilesForDebugDraw;
@end
