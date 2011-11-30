//
//  PauseMenuScreen.h
//  Clay
//
//  Created by Brian Cable on 9/21/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//
//  The pause menu screen that displays over the GameLayer. Currently only lets you click to get out, but eventually have buttons to take you back to the main menu and maybe restart the level.

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class GameController;
@class Sprite;

@interface PauseMenuScreen : CCLayer
{
    float _alpha;
    GameController *_gameController;
    CCLabelTTF *_label;
}

@property(nonatomic,retain) GameController *gameController;

+(id)instance;
//- (id)initWithColor:(ccColor4B)color;

@end
