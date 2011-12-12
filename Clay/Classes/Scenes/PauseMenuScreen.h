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
@class GameLabel;
@class Button;
@class ActionButton;

typedef enum {
    PAUSE_ACTION_RESUME = 0,
    PAUSE_ACTION_RESTART = 1,
    PAUSE_ACTION_MENU = 2,
    PAUSE_ACTION_NONE = 3
}PauseAction;

@interface PauseMenuScreen : CCLayer
{
    float _alpha;
    GameController *_gameController;
        
    GameLabel *_pausedText;

    ActionButton *_resumeButton;
    ActionButton *_restartButton;
    ActionButton *_menuButton;
    
    PauseAction _action;
    float _waitToSwitch;
}

@property(nonatomic,retain) GameController *gameController;

+(id)instance;


@end
