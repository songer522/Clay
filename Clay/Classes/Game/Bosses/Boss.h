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
    BOSS_PHASE_NOT_TRIGGERED,
    BOSS_PHASE_CHASE_FAR,
    BOSS_PHASE_CHASE_MIDDLE,
    BOSS_PHASE_CHASE_CLOSE,
    BOSS_PHASE_CHASE_INIT
} BossPhase;

@class Sprite;

@interface Boss : NSObject<BossProtocol>
{
    bool _isActive;
}

@property(nonatomic,assign)bool isActive;


+(id)instance;

-(void)startBoss;
-(void)update:(float)dt;
-(void)setSprite:(Sprite*)sprite;
-(void)switchToPhase:(BossPhase)phase;
-(void)triggerAttack;
-(void)reset;
@end
