//
//  BossFinalJim.h
//  Clay
//
//  Created by Brian Cable on 10/19/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "Boss.h"


@class Sprite;
@class Level;

typedef enum {
    JIM_PHASE_NOT_TRIGGERED,
    JIM_PHASE_CHASE_FAR,
    JIM_PHASE_CHASE_MIDDLE,
    JIM_PHASE_CHASE_CLOSE
} FinalBossPhase;

@interface BossFinalJim : Boss
{
    Level *_level;
    
    Sprite *_sprite;

    CGPoint _positionOnScreen;

    bool _firstUpdate;
    
    FinalBossPhase _phase;
    
    float _waitToAttack;
}

-(void)switchToPhase:(FinalBossPhase)phase;
-(void)triggerAttack;

@end