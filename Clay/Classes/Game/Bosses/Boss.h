//
//  Boss.h
//  Clay
//
//  Created by Brian Cable on 10/19/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>



@protocol BossProtocol <NSObject>

-(void)startBoss;

@end


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
@end
