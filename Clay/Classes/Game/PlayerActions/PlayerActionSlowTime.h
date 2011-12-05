//
//  PlayerActionSlowTime.h
//  Clay
//
//  Created by Brian Cable on 11/30/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "PlayerAction.h"

@interface PlayerActionSlowTime : PlayerAction
{
    float _slowdown;
}

-(void)updateSlowdown:(float)modifier;

@end
