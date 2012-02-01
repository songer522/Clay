//
//  ChooseModeScene.h
//  Clay
//
//  Created by Brian Cable on 12/13/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "CCLayer.h"
#import "cocos2d.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class Sprite;
@class ModePanel;
@class GameLabel;
@class ActionButton;
@class GameWindow;

typedef enum {
    GAMEMODE_STORY_EASY,
    GAMEMODE_STORY_NORMAL,
    GAMEMODE_STORY_HARD,
    GAMEMODE_TIMED_NORMAL,
    GAMEMODE_TIMED_INSANE,
    GAMEMODE_TIMED_DLC,
    GAMEMODE_EXTRAS_ALBUM,
    GAMEMODE_EXTRAS_WEB,
    GAMEMODE_EXTRAS_SUPPORT,
    GAMEMODE_NONE
}GameModeAction;

@interface ChooseModeScene : CCLayer<UIAlertViewDelegate>
{
    Sprite *_background;
    
    ModePanel *_storyModePanel;
    ModePanel *_timedModePanel;
    ModePanel *_extrasPanel;
    
    ModePanel *_currentPanel;
    
    
    ActionButton *_startButton;
    ActionButton *_backButton;
    
    GameLabel *_selectModeText;
    
    Sprite *_selectCursor;
    
    GameModeAction _action;
    GameModeAction _actionSwitchTo;
    
    float _waitToSwitch;
    float _backToMainMenu;
    
    bool _isTransitioning;
    bool _playTutorial;
    bool _isContinueButtonEnabled;
    GameWindow *_warningWindow;
    bool _warningWindowOpen;
}

@property(nonatomic,assign) bool isTransitioning;

+(CCScene*)scene;

-(void)load;
-(void)switchToAction;
-(void)switchToMainMenu;
-(void)switchToStartGame;
-(void)getDesiredAction;
-(void)updateLocked;
@end
