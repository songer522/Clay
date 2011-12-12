//
//  PlayerActionSlowTime.h
//  Clay
//
//  Created by Brian Cable on 11/30/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "PlayerAction.h"

@class Boss;

@interface PlayerActionSlowTime : PlayerAction
{
    float _slowdown;
    
    Boss *_boss;
}

-(void)updateSlowdown:(float)modifier;

@end
