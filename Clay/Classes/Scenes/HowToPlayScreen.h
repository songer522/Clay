//
//  HowToPlayScreen.h
//  Clay
//
//  Created by Brian Cable on 12/20/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "cocos2d.h"
#import "CCLayer.h"

@class Tutorial;
@class Sprite;
@class ActionButton;
@class GameLabel;

@interface HowToPlayScreen : CCLayer
{
    Tutorial *_tutorial;
    Sprite *_background;
    GameLabel *_header;
    
    ActionButton *_backButton;
    ActionButton *_startButton;
    
    NSString *_startButtonText;
    
    bool _switchToGame;
    bool _hasSwitched;
    bool _enableBack;
    
    float _waitToSwitch;
    int _currentScreen;
    
    bool _canStart;
    
}

+(CCScene *) scene;
+(id)layerWithScene:(CCScene*)scene;
-(id) initWithScene:(CCScene*)scene;

-(void)switchToOptionsScreen;
-(void)switchToGameScreen;
-(void)nextPage;
-(void)cueStartAction;
-(void)updateStartButton;

@end
