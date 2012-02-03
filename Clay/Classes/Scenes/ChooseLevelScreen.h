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
#import "FBConnect.h"
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import <UIKit/UIKit.h>
#import "DlcLevelDelegate.h"

@class GameLabel;
@class Sprite;
@class ActionButton;
@class ChooseLevelPanel;
@class FBPrompt;
@class DlcGameWindow;
@class GameWindow;

typedef enum {
    TRACK_RUN = 1,
    BARN_RUN = 2,
    TOWN_RUN = 3,
    DISCO_RUN = 4,
    CITY_RUN = 5,
    UNDEAD_RUN = 6,
    COMPUTER_RUN = 7,
    VOLCANO_RUN = 8,
    AQUARIUM_RUN = 9,
    STORMY_RUN = 10,
    FINAL_RUN = 11,
    TRAINING_RUN = 12,
    DOJO_RUN = 13
   
}LevelName;

@interface ChooseLevelScreen : CCLayer <FBDialogDelegate,FBSessionDelegate,DlcLevelDelegate,UIAlertViewDelegate>
{
    NSMutableArray *_buttons;
    
    NSDictionary *_modeDict;
    
    float _waitToSwitch;
    float _alpha;
    bool _backToChooseMode;
    bool _inTutorial;
    bool _openFacebook;
    bool _openTwitter;
    
    bool _openErrorCantConnectToStore;
    bool _openErrorCantMakePurchases;
    NSString *_levelToSwitchTo;
    
    NSString *_gameMode; //weak references
    NSString *_gameDifficulty; //weak references
    
    int _levelNumber;
    NSString *_bestTime;
    
    Sprite *_background;
    Sprite *_panelBackground;
    Sprite *_selector;
    
    GameLabel *_levelSelectText;
    GameLabel *_bestLevelTimeText;
    
    ActionButton *_startButton;
    ActionButton *_backButton;
    ActionButton *_facebookButton;
    ActionButton *_twitterButton;

    
    ChooseLevelPanel *_frontPanel;
    ChooseLevelPanel *_backPanel;
    
    DlcGameWindow *_dlcWindow;
    bool _dlcWindowOpen;
    
    GameWindow *_errorWindow;
    bool _errorWindowOpen;
    bool _lockedLevelWindowOpen;
    
    bool _panelTransition;
    bool _hasSwitched;
    bool _inDLCMode;
    bool _allGoldMedalInNormal;
    bool _allGoldMedalInInsane;
    float _panelAlpha;
    
    int _selected;
    int _numberOfLevels;
    int _levelStartNumber;
    
    TWTweetComposeViewController *_tweetViewController;
    FBPrompt *_fbprompt;
    UIAlertView		*_twitterSupportingAlert;
    
}

+(CCScene*)scene;
+(id)layerWithScene:(CCScene*)scene;
-(id) initWithScene:(CCScene*)scene;

-(ChooseLevelPanel*)createInformationPanelForLevel:(int)levelNumber;
-(int)getMedalNumberForLevelNamed:(NSString*)levelName Time:(float)time;
-(float)getTimeForNextMedalForLevelNamed:(NSString*)levelName BestTime:(float)time;
-(void)load;
-(void)loadMedals;
-(void)checkAllGold;

-(void)popAndSwitchToLevel:(NSString*)level;

-(void)switchToChooseModeScreen;

-(void)transitionOut;
-(NSString*)getTimestringForFloat:(float)time;

-(void)unload;
-(void)switchInfoPanelToLevel:(float)number;

-(void)updatePanelTransition:(float)dt;

-(void)popupDlcWindow:(int)levelNumber;

-(bool)checkDlcLevelUnlocked:(int)levelNumber;

-(void)prepareToPlayLevel;
-(void)updateStartButton;

-(void)openErrorWindowCantConnectToStore;
-(void)openErrorWindowCantMakePurchases;
-(void)closeErrorWindow;
-(void)openLockedLevelWindow;


-(void)setCantConnectToStore:(BOOL)CantConnectToStore;
-(void)setCantMakePurchases:(BOOL)CantMakePurchases;

@end
