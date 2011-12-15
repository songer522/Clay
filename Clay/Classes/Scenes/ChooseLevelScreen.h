//
//  ChooseLevelScreen.h
//  Clay
//
//  Created by Brian Cable on 10/24/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//
//  The scene for choosing a level displayed after the main menu.

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCScrollLayer.h"


@class GameLabel;
@class Sprite;
@class ActionButton;
@class ChooseLevelPanel;

@interface ChooseLevelScreen : CCLayer
{
    NSMutableArray *_buttons;
    float _waitToSwitch;
    float _alpha;
    bool _backToMainMenu;
    bool _backToLevelSelect;
    bool _inTutorial;
    NSString *_levelToSwitchTo;
    
    NSString *_gameMode; //weak references
    NSString *_gameDifficulty; //weak references
    
    
    Sprite *_background;    
    Sprite *_selector;
    
    GameLabel *_levelSelectText;
    GameLabel *_bestLevelTimeText;
    
    ActionButton *_startButton;
    ActionButton *_backButton;
    
    ChooseLevelPanel *_frontPanel;
    
    int _selected;
}

+(CCScene*)scene;
+(id)layerWithScene:(CCScene*)scene;
-(id) initWithScene:(CCScene*)scene;

-(ChooseLevelPanel*)createInformationPanelForLevel:(int)levelNumber;
-(void)load;
-(void)loadMedals;

-(void)popAndSwitchToLevel:(NSString*)level;

-(void)switchToMainMenu;

-(void)transitionOut;
-(void)updateBestTimeTextWithLevel:(int)level;

-(void)unload;



@end
