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



@class GameLabel;
@class Sprite;
@class ActionButton;
@class ChooseLevelPanel;
@class FBPrompt;

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
    FINAL_RUN = 11
   
}LevelName;

@interface ChooseLevelScreen : CCLayer <FBDialogDelegate,FBSessionDelegate>
{
    NSMutableArray *_buttons;
    
    NSDictionary *_modeDict;
    
    float _waitToSwitch;
    float _alpha;
    bool _backToChooseMode;
    bool _inTutorial;
    bool _openFacebook;
    bool _openTwitter;
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
    
    bool _panelTransition;
    bool _hasSwitched;
    float _panelAlpha;
    
    int _selected;
    
    TWTweetComposeViewController *_tweetViewController;
    FBPrompt *_fbprompt;
    
}

+(CCScene*)scene;
+(id)layerWithScene:(CCScene*)scene;
-(id) initWithScene:(CCScene*)scene;

-(ChooseLevelPanel*)createInformationPanelForLevel:(int)levelNumber;
-(int)getMedalNumberForLevelNamed:(NSString*)levelName Time:(float)time;
-(float)getTimeForNextMedalForLevelNamed:(NSString*)levelName BestTime:(float)time;
-(void)load;
-(void)loadMedals;

-(void)popAndSwitchToLevel:(NSString*)level;

-(void)switchToChooseModeScreen;

-(void)transitionOut;
-(NSString*)getTimestringForFloat:(float)time;

-(void)unload;
-(void)switchInfoPanelToLevel:(float)number;

-(void)updatePanelTransition:(float)dt;

@end
