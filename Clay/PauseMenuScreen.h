//
//  PauseMenuScreen.h
//  Clay
//
//  Created by Brian Cable on 9/21/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class GameController;

@interface PauseMenuScreen : CCLayerColor
{
    float _alpha;
    GameController *_gameController;
    CCLabelTTF *_label;
}

@property(nonatomic,retain) GameController *gameController;

+(id)instance;
- (id)initWithColor:(ccColor4B)color;

@end
