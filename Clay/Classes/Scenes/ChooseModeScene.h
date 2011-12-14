//
//  ChooseModeScene.h
//  Clay
//
//  Created by Brian Cable on 12/13/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "CCLayer.h"
#import "cocos2d.h"

@class Sprite;
@class ModePanel;
@class GameLabel;
@class ActionButton;

@interface ChooseModeScene : CCLayer
{
    Sprite *_background;
    
    ModePanel *_storyModePanel;
    ModePanel *_timedModePanel;
    ModePanel *_extrasPanel;
    
    ActionButton *_startButton;
    ActionButton *_backButton;
    
    GameLabel *_selectModeText;
    
    float _waitToSwitch;
    float _backToMainMenu;
    
    bool _isTransitioning;
}

@property(nonatomic,assign) bool isTransitioning;

+(CCScene*)scene;

-(void)load;
-(void)switchToMainMenu;

@end
