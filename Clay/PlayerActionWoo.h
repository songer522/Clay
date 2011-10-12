//
//  PlayerActionWoo.h
//  Clay
//
//  Created by Brian Cable on 10/11/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlayerAction.h"

@interface PlayerActionWoo : NSObject <PlayerAction>
{
    Player *_parent;
    bool _inAction;
    bool _isActive;
    float _duration;
    float _cooldown;
}

@end
