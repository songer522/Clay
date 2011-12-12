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
    BOSS_PHASE_CHASE_CLOSE = 4
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
-(void)setSprite:(Sprite*)sprite;
-(void)startBoss;
-(void)switchToPhase:(BossPhase)phase;
-(void)triggerAttack;
-(void)triggerFallBack;
-(void)triggerGetCloser;
@end
