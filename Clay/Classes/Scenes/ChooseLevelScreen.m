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
         _buttons = [[NSMutableArray alloc] initWithCapacity:4];        
        _levelToSwitchTo = @"level1";
        _buttons = [[NSMutableArray alloc] initWithCapacity:7];
        _alpha = 1.0f;
        _selected = 1;
        _backToChooseMode = false;
        _inTutorial=false;
        _openFacebook=false;
        _waitToSwitch = 0.0f;
        _hasSwitched = false;
        self.isTouchEnabled = YES;
        
        _gameMode = [[GameSettings shared] getGlobalForKey:@"gameMode"];
        _gameDifficulty = [[GameSettings shared] getGlobalForKey:@"gameDifficulty"];
        
        NSString *musicStarted = [[GameSettings shared] getGlobalForKey:@"titleMusicStarted"];
        if (![musicStarted isEqualToString:@"YES"]) {
            [[SoundEngine shared] cueFadeIn];
            [[SoundEngine shared] playMusic:@"title"];
            [[GameSettings shared] setGlobal:@"YES" ForKey:@"titleMusicStarted"];
        }
        
        NSDictionary *medalsDict = [PListLoader loadPlistWithName:@"medals"];
        _modeDict = [[NSDictionary alloc] initWithDictionary:[medalsDict objectForKey:_gameMode]];
      
        [self load];
       
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
        for (LevelButton *button in _buttons) {
            if([button checkIfSelected:position] && !_panelTransition) {

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
            }
        }
        
        if([_startButton checkIfSelected:position]) {
            _waitToSwitch = 0.25f;
            _backToChooseMode = false;
            [[SoundEngine shared] playSound:@"buttonPressed"];
        }
        
        if([_backButton checkIfSelected:position]) {
            _waitToSwitch = 0.25f;
            _backToChooseMode = true;
            [[SoundEngine shared] playSound:@"buttonPressed"];     
        }
        
        if([_facebookButton checkIfSelected:position]) {
            _waitToSwitch = 0.25f;
            _openFacebook = true;
            [[SoundEngine shared] playSound:@"buttonPressed"];     
        }
        if([_twitterButton checkIfSelected:position]) {
            _waitToSwitch = 0.25f;
            _openTwitter= true;
            [[SoundEngine shared] playSound:@"buttonPressed"];     
        }
        
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
    
    _facebookButton =[ ActionButton actionButtonManualSetup];
    _facebookButton.facebookOrTwitter=true;
    [_facebookButton setPosition:ccp(210, 120)];
    
    _twitterButton =[ ActionButton actionButtonManualSetup];
    _twitterButton.facebookOrTwitter=true;
    [_twitterButton setPosition:ccp(210, 80)];
    
    
    //load level buttons (init best level time text first because it gets set in here)
    for (int i=0; i<11; i++) {
        LevelButton *button = [LevelButton levelButtonWithId:i];
        [button setCursor:_selector];

        //by default have the first level selected
        if(i==0) {
            [button setSelected];
        }
        
        [_buttons addObject:button];
    }
    
    _levelSelectText = [GameLabel gameLabelWithText:@"LEVEL SELECT" Scale:0.75f Position:ccp(365.0f,282.0f)];
    
    //load any medals earned
    [self loadMedals];
    
    _frontPanel = [self createInformationPanelForLevel:1];
    
    
    [[LayerManager sharedLayers] forgetWorkingLayer];
    [self scheduleUpdate];
    self.isTouchEnabled = true;    
    
}

-(ChooseLevelPanel*)createInformationPanelForLevel:(int)levelNumber
{
    NSString *levelName = [NSString stringWithFormat:@"level%d",levelNumber];
    float bestTime = [[BestTimes shared] getBestTimeForLevelName:levelName forDifficulty:_gameDifficulty];
    _levelNumber=levelNumber;
    _bestTime= [self getTimestringForFloat:bestTime];
    ChooseLevelPanel *panel = [ChooseLevelPanel instance];
    [panel setBestTime:[self getTimestringForFloat:bestTime]];
    [panel setLevelDataByNumber:levelNumber];
    
    int medal = [self getMedalNumberForLevelNamed:levelName Time:bestTime];
    float requiredTime = [self getTimeForNextMedalForLevelNamed:levelName BestTime:bestTime];
    
    [panel setNextMedal:(medal+1) RequiredTime:[TrackTimer getTimeStringFromFloat:requiredTime]];
    [panel loadObjectsAfterDataInit:self];
    
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
    
    if (time<goldTime) {
        returnVal = goldTime;
    } else if(time<silverTime) {
        returnVal = silverTime;
    } else if(time<bronzeTime) {
        returnVal = bronzeTime;
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
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[GameLayer scene]]];
}


-(void)switchToChooseModeScreen
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[ChooseModeScene scene]]];
}

-(void)switchInfoPanelToLevel:(float)number
{
    _panelAlpha = 0.0f;
    _panelTransition = true;
    _backPanel = [self createInformationPanelForLevel:number];
    [_backPanel setAlpha:0.0f];
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
- (void)sendEasyTweet:(NSString*)tweet
{
    AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    // Set up the built-in twitter composition view controller.
    TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
    
    // Set the initial tweet text. See the framework for additional properties that can be set.
    [tweetViewController setInitialText:tweet];
    
    // Present the tweet composition view controller modally.
    NSString *reqSysVer = @"5.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
    {
        [appDelegate.viewController presentModalViewController:tweetViewController animated:YES];
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
        //[_frontPanel setAlpha:(1.0f - _panelAlpha)];
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
    FBPrompt *prompt;
   
    NSString *description=[self covertLevelname:_levelNumber];
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
                prompt = [FBPrompt promptWithAppId:@"264174546971482" andDelegate:self];
                [prompt showFacebookDialogWithDescription:[NSString stringWithFormat:@"Hey, here's my score for Track Lapse %@ : %@, see if you can beat me!!!",description, _bestTime] andPicture:@"http://fbrell.com/f8.jpg"];
                _openFacebook =false;
            } else if(_openTwitter)
            {
                [self sendEasyTweet:[NSString stringWithFormat:@"Hey, here's my score for Track Lapse %@ : %@, see if you can beat me!!!",description, _bestTime]];
                _openTwitter =false;
            }
            else {
                [self popAndSwitchToLevel:_levelToSwitchTo]; 
                _hasSwitched = true;
            }
        }
    }
}

-(void)dealloc
{
    CCLOG(@"Dealloc: ChooseLevelScreen");
        
    //[_buttons removeAllObjects];
    //[_buttons release];
    //_buttons = nil;
    [_modeDict release];
    [_levelToSwitchTo release];
    _gameMode = nil;
    _gameDifficulty = nil;
    [_bestTime release];
    [_background release];
    [_panelBackground release];
    [_selector release];
    
    [_levelSelectText release];
    [_bestLevelTimeText release];
    
    [_startButton release];
    [_backButton release];
    [_facebookButton release];
    [_twitterButton release];
    
    [_frontPanel release];
    if(_backPanel != nil) { //may or may not have been released during the transition
        [_backPanel release];
    }
    
    [[TextureManager shared] unloadMemoryForKey:@"chooseLevel"];
    
    [super dealloc];
}

@end
