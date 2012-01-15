//
//  EndLevelLayer.h
//  Clay
//
//  Created by Brian Cable on 1/11/12.
//  Copyright (c) 2012 Xecudev, LLC. All rights reserved.
//


#import "cocos2d.h"

@class GameController;
@class Sprite;
@class GameLabel;
@class Button;
@class ActionButton;

typedef enum {
    END_LEVEL_REPLAY = 0,
    END_LEVEL_BACK = 1,
    END_LEVEL_NONE = 2
}EndLevelAction;
typedef enum {
    NO_TROPHY = 0,
    BRONZE_TROPHY = 1,
    SLIVER_TROPHY = 2,
    GOLD_TROPHY = 3,
        
}TrophyName;
@interface EndLevelLayer : CCLayer
{
    
    float _alpha;
    bool _buttonPressed;
    bool _isNewRecord;
    GameController *_gameController;
    
    ActionButton *_replayButton;
    ActionButton *_menuButton;
    
    Sprite *_trophyBack;
    Sprite *_trophyFront;
    Sprite *_starsAnim;
    Sprite *_finalTimePanel;
    
    GameLabel *_timeHeaderText;
    GameLabel *_finalTimeText;
    GameLabel *_trophyText;
    
    EndLevelAction _action;
    
    NSDictionary *_modeDict;
    NSDictionary *medalsDict;
    float _waitToSwitch;
    //NSString *_timer;
    float _timer;
}

@property(nonatomic,retain) GameController *gameController;
@property(assign)float timer;
@property(nonatomic,assign) bool isNewRecord;



+(id)instance;
-(void)showMedal;
-(void)showNewRecord;

@end
