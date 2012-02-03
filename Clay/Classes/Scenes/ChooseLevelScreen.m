//
//  ChooseLevelScreen.m
//  Clay
//
//  Created by Brian Cable on 10/24/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "ChooseLevelScreen.h"
#import "Sprite.h"
#import "LevelManager.h"
#import "LayerManager.h"
#import "Button.h"
#import "ComicManager.h"
#import "LevelButton.h"
#import "ActionButton.h"
#import "Level.h"
#import "SoundEngine.h"
#import "TextureManager.h"
#import "GameSettings.h"
#import "GameLayer.h"
#import "Appirater.h"
#import "MainMenuScene.h"
#import "PListLoader.h"
#import "BestTimes.h"
#import "GameLabel.h"
#import "TrackTimer.h"
#import "BestTimes.h"
#import "ChooseModeScene.h"
#import "ChooseLevelPanel.h"
#import "FBPrompt.h"
#import "AppDelegate.h"
#import "GCState.h"
#import "GCHelper.h"
#import "DlcGameWindow.h"
#import "InAppPurchaseManager.h"


@implementation ChooseLevelScreen

//////////////////////
//BEGIN INIT METHODS
//////////////////////

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	ChooseLevelScreen *layer = [ChooseLevelScreen layerWithScene:scene];
    
    //[[LayerManager sharedLayers] setCurrentScene:scene];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

+(id)layerWithScene:(CCScene*)scene
{
    return [[self alloc] initWithScene:scene];
}

-(id) initWithScene:(CCScene*)scene
{
    
   
    if ((self = [super init])) {
        _buttons = [[NSMutableArray alloc] initWithCapacity:7];
        _alpha = 1.0f;
        _selected = 1;
        _backToChooseMode = false;
        _inTutorial=false;
        _openFacebook=false;
        _waitToSwitch = 0.0f;
        _hasSwitched = false;
        _bestTime = nil;
        _tweetViewController = nil;
        _fbprompt = nil;
        _inDLCMode = false;
        _allGoldMedalInNormal=false;
        _allGoldMedalInInsane=false;
        _openErrorCantConnectToStore=false;
        _openErrorCantConnectToStore=false;
        
        _lockedLevelWindowOpen=false;
        
        self.isTouchEnabled = YES;
        
        
        _gameMode = [[GameSettings shared] getGlobalForKey:@"gameMode"];
        _gameDifficulty = [[GameSettings shared] getGlobalForKey:@"gameDifficulty"];
        if([_gameDifficulty isEqualToString:@"normal"])
        {
            _allGoldMedalInNormal=true;
        }
        else if ([_gameDifficulty isEqualToString:@"hard"])
        {
            _allGoldMedalInInsane=true;
        }
        NSString *showDLC = [[GameSettings shared] getGlobalForKey:@"timedShowDLC"];
        if ([showDLC isEqualToString:@"YES"]) {
            _inDLCMode = true;
            _numberOfLevels = 2;
            _levelStartNumber = 11;
            _selected = 12;
            _levelToSwitchTo = [[NSString stringWithString:@"level12"] retain];
        } else {
            _inDLCMode = false;
            _numberOfLevels = 11;
            _levelStartNumber = 0;
            _selected = 1;
            _levelToSwitchTo = [[NSString stringWithString:@"level1"] retain];
        }
        
        /*
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isTrainingRunPurchased"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isDojoRunPurchased"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        */
        
        if(_inDLCMode) {
            [[InAppPurchaseManager shared] loadStoreWithDelegate:self];
        }
        
        
        
        //if timed mode had previously saved its selected level, we want to start with that one selected.
        //otherwise, we want it to start on the first level
        //we do not want to refer to this number if coming from choosemode
        NSString *previousScreen = [[GameSettings shared] getGlobalForKey:@"previousScreenName"];
        if(![previousScreen isEqualToString:@"chooseMode"]) {
            int selectedLevel = [[[GameSettings shared] getGlobalForKey:@"timedSelectedLevel"] intValue];
            if (selectedLevel > 0) {
                _selected = selectedLevel;
            } else {
                _selected = _levelStartNumber + 1;
            }
            _levelToSwitchTo = [[NSString stringWithFormat:@"level%d",_selected] retain];            
        }
        
        NSString *musicStarted = [[GameSettings shared] getGlobalForKey:@"titleMusicStarted"];
        if (![musicStarted isEqualToString:@"YES"]) {
            [[SoundEngine shared] cueFadeIn];
            [[SoundEngine shared] playMusic:@"title"];
            [[GameSettings shared] setGlobal:@"YES" ForKey:@"titleMusicStarted"];
        }
        
        NSDictionary *medalsDict = [PListLoader loadPlistWithName:@"medals"];
        _modeDict = [[NSDictionary alloc] initWithDictionary:[medalsDict objectForKey:_gameMode]];
      
        
        [self load];
        [self checkAllGold];
        [[BestTimes shared] saveData];

        [self updateDlcLevels];
        
    }
    return self;
}

////////////////////
//END INIT METHODS
////////////////////


-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    for(UITouch *touch in allTouches) {
        CGPoint position = [self convertTouchToNodeSpace:touch];
        
        if(_errorWindowOpen) {
            WindowSelectionType type = [_errorWindow checkCollisionAtPoint:position];
            if (type == WIN_SELECT_OK) {
                [self closeErrorWindow];
                
                
            }
            break;
        }
        
        if(_lockedLevelWindowOpen)
        {
            WindowSelectionType type = [_errorWindow checkCollisionAtPoint:position];
            if (type == WIN_SELECT_OK) {
                [self closeErrorWindow];
                _lockedLevelWindowOpen=false;
               // [[SoundEngine shared] playSound:@"guiSelectionForward"];  
                

        }
         break;
        }
        for (LevelButton *button in _buttons) {
            if([button checkIfSelected:position] && !_panelTransition && [button isUnlocked]) {

                if (button.buttonId!=_selected) {
                    [[SoundEngine shared] playSound:@"chooseSelection"];
                    [self switchInfoPanelToLevel:button.buttonId];
                }
                
                _selected = button.buttonId;

                if(_levelToSwitchTo) {
                    [_levelToSwitchTo release];
                    _levelToSwitchTo = nil;
                }
                _levelToSwitchTo = [[NSString alloc] initWithFormat:@"level%d",_selected];
                
                [self updateStartButton];
            }
            else if([button checkIfTouched:position] && !_panelTransition && ![button isUnlocked])
            {
                [self openLockedLevelWindow];
                
            }
        }
        
        if([_startButton checkIfSelected:position]) {
            if (_inDLCMode) {
                if([self checkDlcLevelUnlocked:_selected]) {
                    [self prepareToPlayLevel];
                } else {
                    [self popupDlcWindow:_selected];
                }
            } else {
                [self prepareToPlayLevel];
            }
        }
        
        if([_backButton checkIfSelected:position]) {
            _waitToSwitch = 0.25f;
            _backToChooseMode = true;
            [[SoundEngine shared] playSound:@"guiSelectionBack"];
        }
        
        if([_facebookButton checkIfSelected:position]) {
            if ([self checkDlcLevelUnlocked:_frontPanel.levelId]) {
                _waitToSwitch = 0.25f;
                _openFacebook = true;
                [[SoundEngine shared] playSound:@"buttonPressed"];                
            }
        }
        if([_twitterButton checkIfSelected:position]) {
            if ([self checkDlcLevelUnlocked:_frontPanel.levelId]) {
                _waitToSwitch = 0.25f;
                _openTwitter= true;
                [[SoundEngine shared] playSound:@"buttonPressed"];     
            }
        }
        
    }
}

-(void)prepareToPlayLevel
{
    _waitToSwitch = 0.25f;
    _backToChooseMode = false;
    [[SoundEngine shared] playSound:@"buttonPressed"];
    [[InAppPurchaseManager shared] setDelegate:nil]; //if don't do this, error messages thrown by the inapppurchasemanager will try to access this released delegate
}

-(bool)checkDlcLevelUnlocked:(int)levelNumber
{
    if (levelNumber == TRAINING_RUN) {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"isTrainingRunPurchased"] boolValue]) {
            return true;
        }        
    } else if (levelNumber == DOJO_RUN) {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"isDojoRunPurchased"] boolValue]) {
            return true;
        }        
    } else if(levelNumber<=11) {
        return true;
    }
    //NOTE: temporarily disabled for a build with unlocked dlc
    return false;
    //return true;
}

-(void)popupDlcWindow:(int)levelNumber
{
    if(_openErrorCantConnectToStore)
    {
        [self openErrorWindowCantConnectToStore];
          [[SoundEngine shared] playSound:@"windowOpenWarning"]; 
       // _openErrorCantConnectToStore=false;
        return;
    }
    if(_openErrorCantMakePurchases)
    {
        [self openErrorWindowCantMakePurchases];
          [[SoundEngine shared] playSound:@"windowOpenWarning"]; 
        //_openErrorCantMakePurchases=false;
        return;
    }
    
    
    
    switch (levelNumber) {
        case TRAINING_RUN:
            [[InAppPurchaseManager shared] purchaseProductId:kInAppPurchaseTrainingRunProductId Delegate:self];
            [[SoundEngine shared] playSound:@"guiSelectionForward"]; 
            break;
        case DOJO_RUN:
            [[InAppPurchaseManager shared] purchaseProductId:kInAppPurchaseDojoRunProductId Delegate:self];
            [[SoundEngine shared] playSound:@"guiSelectionForward"]; 
            break;
        default:
            break;
    }
}

-(void)updateDlcLevels
{
    [self updateStartButton];
    
    for (LevelButton *button in _buttons) {
        int levelNumber = button.buttonId;
        if ([self checkDlcLevelUnlocked:levelNumber]) {
            [button setPurchased:YES];
        } else {
            [button setPurchased:NO];
        }
    }

    int levelNumber = _frontPanel.levelId;
    if ([self checkDlcLevelUnlocked:levelNumber]) {
        [_frontPanel setUnlocked:YES];
    } else {
        [_frontPanel setUnlocked:NO];
    }
    
    levelNumber = _backPanel.levelId;
    if ([self checkDlcLevelUnlocked:levelNumber]) {
        [_backPanel setUnlocked:YES];
    } else {
        [_backPanel setUnlocked:NO];
    }
    
}
-(void)setCantConnectToStore:(BOOL)CantConnectToStore
{
    _openErrorCantConnectToStore=CantConnectToStore;
}
-(void)setCantMakePurchases:(BOOL)CantMakePurchases
{
    _openErrorCantMakePurchases=CantMakePurchases;
}

-(void)openErrorWindowCantConnectToStore
{
    if (!_errorWindowOpen) {
        _errorWindowOpen = true;
        _errorWindow = [GameWindow gameWindowWithHeader:@"ERROR!" Message:@"Cannot connect to the store at this time. Please try again later." Choices:WINDOW_CHOICE_OK Layer:self withBackground:@"MessageBox2.png"];        
    }
}


-(void)openLockedLevelWindow
{
    [[SoundEngine shared] playSound:@"windowOpenWarning"]; 
    if(!_lockedLevelWindowOpen)
    {
        _lockedLevelWindowOpen=true;
        
        if([_gameDifficulty isEqualToString:@"normal"])
        {
            _errorWindow=[GameWindow gameWindowWithHeader:@"NOTE" Message:@"Please beat a corresponding level in normal story mode to unlock this." Choices:WINDOW_CHOICE_OK Layer:self withBackground:@"MessageBox2.png"];
        }
        else if ([_gameDifficulty isEqualToString:@"hard"])
        {
            _errorWindow=[GameWindow gameWindowWithHeader:@"NOTE" Message:@"Please beat a corresponding level in normal timed mode to unlock this." Choices:WINDOW_CHOICE_OK Layer:self withBackground:@"MessageBox2.png"];
        }

        
    }
}

-(void)openErrorWindowCantMakePurchases
{
    if (!_errorWindowOpen) {
        _errorWindowOpen = true;
        _errorWindow = [GameWindow gameWindowWithHeader:@"ERROR!" Message:@"Cannot make purchase at this time. Please try again later or make sure to have in app purchases enabled in Settings>General>Restrictions." Choices:WINDOW_CHOICE_OK Layer:self withBackground:@"MessageBox2.png"];
    }
}

-(void)closeErrorWindow
{
    [[SoundEngine shared] playSound:@"guiSelectionForward"];  
    _errorWindowOpen = false;
    [_errorWindow release];
    _errorWindow = nil;
}

-(void)updateStartButton
{
    if (_selected < 12 || [self checkDlcLevelUnlocked:_selected]) {
        [_startButton setText:@"START"];
    } else {
        [_startButton setText:@"BUY"];
    }
}

-(void)load
{
    [[LayerManager sharedLayers] setWorkingLayer:self];    

    [[TextureManager shared] loadMemoryForKey:@"chooseLevel"];
    
    _background = [Sprite spriteFromFrameCacheWithName:@"LevelSelector_Background.png"];
    [_background setScreenPosition:ccp(0,0)];
    
    //_panelBackground = [Sprite spriteCenteredWithFrame:@"LevelSelector_LevelInfo.png"];
    //[_panelBackground setScreenPosition:ccp(105,155)];
    
    
    _selector = [Sprite spriteFromFrameCacheWithName:@"LevelSelector_LevelSelected.png"];
    [_selector setPosition:ccp(0,0)];
    [[_selector getCCSprite] setVisible:NO];
    
    _startButton = [ActionButton actionButtonWithText:@"START"];
    [_startButton setPosition:ccp(430,18)];
    
    _backButton = [ActionButton actionButtonWithText:@"BACK"];
    [_backButton setPosition:ccp(50, 18)];
    
    _facebookButton =[ActionButton actionButtonManualSetup];
    _facebookButton.facebookOrTwitter=true;
    [_facebookButton setPosition:ccp(210, 120)];
    [_facebookButton setEnabled:true];
    
    _twitterButton =[ ActionButton actionButtonManualSetup];
    _twitterButton.facebookOrTwitter=true;
    [_twitterButton setPosition:ccp(210, 80)];
    [_twitterButton setEnabled:true];
    
    LevelButton *selectedButton=nil;
    //load level buttons (init best level time text first because it gets set in here)
    for (int i=_levelStartNumber; i<(_levelStartNumber + _numberOfLevels); i++) {
        LevelButton *button = [LevelButton levelButtonWithId:i];
        [button setCursor:_selector];

        //by default have the first level selected
        if((i+1)==_selected) {
            [button setSelected];
            selectedButton=button;
        }
        
        [_buttons addObject:button];
    }
    if ([selectedButton isUnlocked]) {
        //do nothing
    } else {
        for (LevelButton *button in _buttons) {
            if ([button isUnlocked]) {
                [button setSelected];
                _selected = button.buttonId;
                if(_levelToSwitchTo) {
                    [_levelToSwitchTo release];
                    _levelToSwitchTo = nil;
                }
                _levelToSwitchTo = [[NSString alloc] initWithFormat:@"level%d",_selected];
                
                break;
            }
        }
    }    
    if (_inDLCMode) {
        _levelSelectText = [GameLabel gameLabelWithText:@"BONUS LEVELS" Scale:0.75f Position:ccp(365.0f,282.0f)];
    } else {
        _levelSelectText = [GameLabel gameLabelWithText:@"LEVEL SELECT" Scale:0.75f Position:ccp(365.0f,282.0f)];
    }
    
    //load any medals earned
    [self loadMedals];
    
    _frontPanel = [self createInformationPanelForLevel:_selected];
    
    
    [[LayerManager sharedLayers] forgetWorkingLayer];
    [self scheduleUpdate];
    self.isTouchEnabled = true;    
    
}

-(ChooseLevelPanel*)createInformationPanelForLevel:(int)levelNumber
{
    NSString *levelName = [NSString stringWithFormat:@"level%d",levelNumber];
    float bestTime = [[BestTimes shared] getBestTimeForLevelName:levelName forDifficulty:_gameDifficulty];
    _levelNumber=levelNumber;
    
    if (_bestTime!=nil) {
        [_bestTime release];
        _bestTime = nil;
    }
    _bestTime= [self getTimestringForFloat:bestTime];
    ChooseLevelPanel *panel = [ChooseLevelPanel instance];
    [panel setBestTime:_bestTime];
    [panel setLevelDataByNumber:levelNumber];
    
    int medal = [self getMedalNumberForLevelNamed:levelName Time:bestTime];
    float requiredTime = [self getTimeForNextMedalForLevelNamed:levelName BestTime:bestTime];
    
    NSString *requiredTimeText = [TrackTimer getTimeStringFromFloat:requiredTime];
    [panel setNextMedal:(medal+1) RequiredTime:requiredTimeText];
    [panel loadObjectsAfterDataInit:self];
    
    [requiredTimeText release];
    
    return panel;
}


-(int)getMedalNumberForLevelNamed:(NSString*)levelName Time:(float)time
{
    int returnVal = 0;
    
    NSDictionary *levelDict = [_modeDict objectForKey:levelName];
    
    //get medal data based on the levels difficulty
    NSDictionary *medals = [levelDict objectForKey:_gameDifficulty];
    
    int bronzeTime = [[medals objectForKey:@"bronze"] intValue];
    int silverTime = [[medals objectForKey:@"silver"] intValue];
    int goldTime = [[medals objectForKey:@"gold"] intValue];
    
    
    //set trophy based on what player's best time is for that level
    if (time!=0) {
        if (time<goldTime) {
            returnVal = 3;
        } else if(time<silverTime) {
            returnVal = 2;
        } else if(time<bronzeTime) {
            returnVal = 1;
        } else {
            returnVal = 0;
        }
    }
    
    return returnVal;
}

-(float)getTimeForNextMedalForLevelNamed:(NSString*)levelName BestTime:(float)time
{
    int returnVal = 0;
    
    NSDictionary *levelDict = [_modeDict objectForKey:levelName];
    
    //get medal data based on the levels difficulty
    NSDictionary *medals = [levelDict objectForKey:_gameDifficulty];
    
    int bronzeTime = [[medals objectForKey:@"bronze"] intValue];
    int silverTime = [[medals objectForKey:@"silver"] intValue];
    int goldTime = [[medals objectForKey:@"gold"] intValue];
    
    if (time > bronzeTime || time <= 0.0f) {
        returnVal = bronzeTime;
    } else if(time > silverTime) {
        returnVal = silverTime;
    } else if(time > goldTime) {
        returnVal = goldTime;
    } else {
        returnVal = 0;
    }
    
    return returnVal;
}


-(void)loadMedals
{
    for (LevelButton *button in _buttons)
    {
        int i = button.buttonId;
        
        //get the level name for the button and get the data for that
        NSString *levelName = [NSString stringWithFormat:@"level%d",i];

        float bestTime = [[BestTimes shared] getBestTimeForLevelName:levelName forDifficulty:_gameDifficulty];
        
        int medal = [self getMedalNumberForLevelNamed:levelName Time:bestTime];
        if (medal>0 && medal<4) {
            [button setTrophy:medal];
        }
        
        if(medal!=3 && [_gameDifficulty isEqualToString:@"normal"])
        {
            _allGoldMedalInNormal=false;
                   }
        
        if(medal!=3 && [_gameDifficulty isEqualToString:@"hard"])
        {
            _allGoldMedalInInsane=false;
           
        }

            
    }
    
   }

-(void)checkAllGold
{
    if(_allGoldMedalInNormal && !_inDLCMode)
    { if(![GCState sharedInstance].allGoldInNormal)
      {
        [GCState sharedInstance].allGoldInNormal=true;
        [[GCHelper sharedInstance] reportAchievement:gcAchievementAllGoldInNM percentComplete:100];
      }
    }
    if(_allGoldMedalInInsane && !_inDLCMode)
    {
        if(![GCState sharedInstance].allGoldInInsane)
      {
          [GCState sharedInstance].allGoldInInsane=true;
        [[GCHelper sharedInstance] reportAchievement:gcAchievementAllGoldInIM percentComplete:100];
      }
    }
}


-(void)onExit
{
    [self release];
    [self unscheduleUpdate];
    self.isTouchEnabled = false;
}

-(void)popAndSwitchToLevel:(NSString*)level
{
    [[GameSettings shared] setGlobal:@"NO" ForKey:@"titleMusicStarted"];
    [[GameSettings shared] setGlobal:level ForKey:@"startingLevel"];
    [[GameSettings shared] setGlobal:[NSString stringWithFormat:@"%d",_selected] ForKey:@"timedSelectedLevel"];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[GameLayer scene]]];
}


-(void)switchToChooseModeScreen
{
    [[InAppPurchaseManager shared] setDelegate:nil]; //if don't do this, error messages thrown by the inapppurchasemanager will try to access this released delegate

    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[ChooseModeScene scene]]];
}

-(void)switchInfoPanelToLevel:(float)number
{
    _panelAlpha = 0.0f;
    _panelTransition = true;
    _backPanel = [self createInformationPanelForLevel:number];
    [_backPanel setAlpha:0.0f];
    [self updateDlcLevels];
}

-(void)transitionOut
{
}

-(void)unload
{
}

-(NSString*)getTimestringForFloat:(float)time
{
    return [TrackTimer getTimeStringFromFloat:time];
}

- (void)showTwitterSupportingAlert {
    [[CCDirector sharedDirector] pause];
	UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Sorry..."
														 message:@"We currently only support iOS 5.0+ for Twitter. If you want to tweet your time please upgrade your system."
														delegate:self
											   cancelButtonTitle:@"okay"
											   otherButtonTitles: nil] autorelease];
	_twitterSupportingAlert = alertView;
	[alertView show];
}


- (void)sendEasyTweet:(NSString*)tweet
{
    AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    // Set up the built-in twitter composition view controller.
    if(_tweetViewController !=nil) {
        [_tweetViewController release];
        _tweetViewController = nil;
    }
    
   _tweetViewController = [[TWTweetComposeViewController alloc] init];
    
    // Set the initial tweet text. See the framework for additional properties that can be set.
    [_tweetViewController setInitialText:tweet];
    
    // Present the tweet composition view controller modally.
    NSString *reqSysVer = @"5.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
    {
        [appDelegate.viewController presentModalViewController:_tweetViewController animated:YES];
    }
    
    else
    {
        [self showTwitterSupportingAlert];
    }
}
-(void)updatePanelTransition:(float)dt
{
    _panelAlpha += 3.0f * dt;
    if (_panelAlpha >= 1.0f) {
        _panelAlpha = 1.0f;
        _panelTransition = false;
        [_backPanel setAlpha:_panelAlpha];
        [_backPanel setPanelTransitionAmount:_panelAlpha];
        [_frontPanel setAlpha:0.0f];
        [_frontPanel release];
        _frontPanel = _backPanel;
        _backPanel = nil;
    } else {
        [_backPanel setAlpha:_panelAlpha];
        [_backPanel setPanelTransitionAmount:_panelAlpha];
    }
}

-(NSString *)covertLevelname:(LevelName)level
{
    NSString *levelName;
    switch (level) {
        case TRACK_RUN:
            levelName=[NSString stringWithFormat:@"Track Run"];
            break;
        case BARN_RUN:
            levelName=[NSString stringWithFormat:@"Barn Run"];
            break;
        case TOWN_RUN:
            levelName=[NSString stringWithFormat:@"Town Run"];
            break;
        case DISCO_RUN:
            levelName=[NSString stringWithFormat:@"Disco Run"];
            break;
        case CITY_RUN:
            levelName=[NSString stringWithFormat:@"City Run"];
            break;
        case UNDEAD_RUN:
            levelName=[NSString stringWithFormat:@"Undead Run"];
            break;
        case COMPUTER_RUN:
            levelName=[NSString stringWithFormat:@"Computer Run"];
            break;
        case VOLCANO_RUN:
            levelName=[NSString stringWithFormat:@"Volcano Run"];
            break;
        case STORMY_RUN:
            levelName=[NSString stringWithFormat:@"Stormy Run"];
            break;
        case AQUARIUM_RUN:
            levelName=[NSString stringWithFormat:@"Aquarium Run"];
            break;
        case FINAL_RUN:
            levelName=[NSString stringWithFormat:@"Final Run"];
            break;
        case TRAINING_RUN:
            levelName=[NSString stringWithFormat:@"Training Run"];
            break;
        case DOJO_RUN:
            levelName=[NSString stringWithFormat:@"Dojo Run"];
            break;
        default:
            break;
    }
    
    return levelName;
}

-(void)update:(ccTime)dt
{
    if (![[GameSettings shared] isStutterMode]) {
        if (_hasSwitched) {
            return;
        }
    }
    
    [[SoundEngine shared] update:dt];

    [_startButton update:dt];
    [_backButton update:dt];
   
   
  
   
    
   
    if (_panelTransition) {
        [self updatePanelTransition:dt];
    }
    
    if (_waitToSwitch>0.0f) {
        _waitToSwitch-=dt;
        if(_waitToSwitch<=0.0f){
            _waitToSwitch = 0.0f;
            if (_backToChooseMode) {
                [self switchToChooseModeScreen];
                _hasSwitched = true;
            }else if(_openFacebook)
            {
                if (_fbprompt !=nil) {
                    [_fbprompt release];
                    _fbprompt = nil;
                }
                NSString *description=[self covertLevelname:_levelNumber];
                               _fbprompt = [FBPrompt promptWithAppId:@"382449345103856" andDelegate:self];
                [_fbprompt showFacebookDialogWithDescription:[NSString stringWithFormat:@"Here is my time for Track Lapse on %@: %@",description, _bestTime] andPicture:@"http://i1077.photobucket.com/albums/w480/xecudev/IconForFB_128.png"];
                _openFacebook =false;
                
                if(![GCState sharedInstance].facebook)
                {
                    
                    [GCState sharedInstance].facebook =true;
                    [[GCHelper sharedInstance] reportAchievement:gcAchievementFacebookUs percentComplete:100.0];
                }

            } else if(_openTwitter)
            {
               
                NSString *description=[self covertLevelname:_levelNumber];
                NSString *_url= [NSString stringWithFormat:@"http://itunes.apple.com/us/app/track-lapse/id473701533?ls=1&mt=8"];
                [self sendEasyTweet:[NSString stringWithFormat:@"Here is my time for Track Lapse on %@: %@ %@",description, _bestTime,_url]];
                _openTwitter =false;
                if(![GCState sharedInstance].twitter)
                {
                    
                    [GCState sharedInstance].twitter =true;
                    [[GCHelper sharedInstance] reportAchievement:gcAchievementTwitterUs percentComplete:100.0];
                }

            }
            else {
                [self popAndSwitchToLevel:_levelToSwitchTo]; 
                _hasSwitched = true;
            }
        }
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	
	switch (buttonIndex) {
		case 0:
		{
			// they don't want to rate it
            [[CCDirector sharedDirector] resume];
			break;
		}
		case 1:
		{
			// they want to rate it
			[[CCDirector sharedDirector] resume];
			break;
		}
        default:
			break;
	}
}


-(void)dealloc
{
    CCLOG(@"=============CHOOSE LEVEL SCREEN============");
    CCLOG(@"Dealloc: ChooseLevelScreen");
    
    for (LevelButton *button in _buttons) {
        [button release];
    }
    [_buttons release];
    _buttons = nil;
    
    


    [_modeDict release];
    [_levelToSwitchTo release];
    _gameMode = nil;
    _gameDifficulty = nil;
    [_background release];
    [_panelBackground release];
    [_selector release];
        [_levelSelectText release];
    [_bestLevelTimeText release];
    
    [_startButton release];
    [_backButton release];
    [_facebookButton release];
    [_twitterButton release];
    
    if (_bestTime !=nil) {
        [_bestTime release];
        _bestTime = nil;
    }
    
    if (_tweetViewController!=nil) {
        [_tweetViewController release];
        _tweetViewController = nil;
    }
    
    if (_fbprompt!=nil) {
        [_fbprompt release];
        _fbprompt = nil;
    }
    
    [_frontPanel release];
    if(_backPanel != nil) { //may or may not have been released during the transition
        [_backPanel release];
    }
    
    [[TextureManager shared] unloadMemoryForKey:@"chooseLevel"];
    
    [super dealloc];
}

@end
