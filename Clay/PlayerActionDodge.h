//
//  PlayerActionDodge.h
//  Clay
//
//  Created by Brian Cable on 10/18/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlayerAction.h"

@interface PlayerActionDodge : NSObject<PlayerAction>
{
    Player *_parent;
    bool _inAction;     //if currently executing the action
    bool _isActive;     //if true, then the action is currently "active", which means whatever
    //it can trigger will be triggered during this time (a kick will actually kick,
    //a "woo" will scare the background, etc.
    float _duration;
}
@end
