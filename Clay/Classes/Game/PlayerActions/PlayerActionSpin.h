//
//  PlayerActionSpin.h
//  Clay
//
//  Created by Brian Cable on 11/30/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "PlayerAction.h"

@class Sprite;
@class Player;

@interface PlayerActionSpin : PlayerAction
{
    Player *_player; //weak reference
}

@end
