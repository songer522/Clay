//
//  MainMenuScene.m
//  Clay
//
//  Created by Brian Cable on 10/7/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "MainMenuScene.h"
#import "AppDelegate.h"
#import "Sprite.h"
#import "LayerManager.h"
#import "ComicLayer.h"
#import "ComicManager.h"
#import "SoundEngine.h"
#import "GCHelper.h"
#import "ChooseLevelScreen.h"
#import "TextureManager.h"
#import "Appirater.h"
#import "ActionButton.h"
#import "SoundEngine.h"
#import "GameSettings.h"
#import "ContinueGameManager.h"
#import "GCHelper.h"
#import "ChooseModeScene.h"
#import "CreditsScene.h"
#import "AppDelegate.h"
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define MULTIPLIERX (IS_IPAD ? 2.133 : 1)
#define MULTIPLIERY (IS_IPAD ? 2.4 : 1)

#import "OptionsScene.h"
#import "Tutorial.h"
#import "GameLayer.h"
#import "InAppPurchaseManager.h"
#import "GCHelper.h"
#import "GCState.h"

static CGPoint MainMenuLegacyPhoneOffset(void)
{
    if (IS_IPAD) {
        return CGPointZero;
    }
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    return ccp(MAX(0.0f, floorf((winSize.width - 480.0f) / 2.0f)), 0.0f);
}

static CGPoint MainMenuPhonePoint(CGFloat x, CGFloat y)
{
    CGPoint offset = MainMenuLegacyPhoneOffset();
    return ccp(offset.x + x, offset.y + y);
}


@implementation MainMenuScene




+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MainMenuScene *layer = [MainMenuScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
        NSAutoreleasePool *myPool = [[NSAutoreleasePool alloc] init];
        
        
        //[self pause]; //paused so that the game center code can run first
        
        [[GCHelper sharedInstance] authenticateLocalUser];
    
        [[LayerManager sharedLayers] setWorkingLayer:self];
        
        //load textures, and sounds for main menu
        [[TextureManager shared] loadMemoryForKey:@"mainMenu"];
          
        //initialize sprites
        _trackBackground = [Sprite spriteFromFrameCacheWithName:@"Menu_Background.png"];
        [_trackBackground setScreenPosition:MainMenuLegacyPhoneOffset()];
        _logo = [Sprite spriteCenteredWithFrame:@"Menu_Logo.png" Position:MainMenuPhonePoint(240 * MULTIPLIERX,258 * MULTIPLIERY)]; //final y: 262
        _copyright = [Sprite spriteCenteredWithFrame:@"Menu_Copyright.png" Position:MainMenuPhonePoint(240 * MULTIPLIERX,24 * MULTIPLIERY)]; //final y: 20
        
        //check whether we can continue the game
        _isContinueButtonEnabled = [ContinueGameManager isAbleToContinueGame];        
        
        //play button with position determined on whether we can continue
        _playButton = [ActionButton actionButtonCustomGraphicsForIdle:@"Menu_PlayBlue.png" Selected:@"Menu_PlayGreen.png"];
        
        if (_isContinueButtonEnabled) {
            [_playButton setPosition:MainMenuPhonePoint(240 * MULTIPLIERX,115 * MULTIPLIERY)];
        } else {
            [_playButton setPosition:MainMenuPhonePoint(240 * MULTIPLIERX,142 * MULTIPLIERY)];
        }
        [_playButton setHitboxBySize:CGSizeMake(319 * MULTIPLIERX, 71 * MULTIPLIERY)];
       
        //continue button
        _continueButton = [ActionButton actionButtonCustomGraphicsForIdle:@"Menu_ContinueBlue.png" Selected:@"Menu_ContinueGreen.png"];
        [_continueButton setPosition:MainMenuPhonePoint(240 * MULTIPLIERX,158 * MULTIPLIERY)];
        [_continueButton setHitboxBySize:CGSizeMake(319 * MULTIPLIERX, 71 * MULTIPLIERY)];
        if (!_isContinueButtonEnabled) {
            [_continueButton setAlpha:0.0f];            
        }
        /*
        _logo = [Sprite spriteFromFrameCacheWithName:@"Menu_Logo.png"];
        [_logo setAlpha:0.0f];
        [_logo getCCSprite].anchorPoint = ccp(0.5f, 0.5f);
        [_logo getCCSprite].position = ccp(240 * MULTIPLIERX, 258 * MULTIPLIERY); //final 240, 262
         */
        
        //leaderboards button
        _leaderboardsButton = [ActionButton actionButtonCustomGraphicsForIdle:@"Menu_LeaderBoardBlue.png" Selected:@"Menu_LeaderBoardGreen.png"];
        [_leaderboardsButton setPosition:MainMenuPhonePoint(450 * MULTIPLIERX,24 * MULTIPLIERY)];
        [_leaderboardsButton setHitboxBySize:CGSizeMake(65 * MULTIPLIERX, 65 * MULTIPLIERY)];
        
        //achievements button
        _achievementsButton = [ActionButton actionButtonCustomGraphicsForIdle:@"Menu_AchievementBlue.png" Selected:@"Menu_AchievementGreen.png"];
        [_achievementsButton setPosition:MainMenuPhonePoint(405 * MULTIPLIERX,24 * MULTIPLIERY)];
        [_achievementsButton setHitboxBySize:CGSizeMake(65 * MULTIPLIERX, 65 * MULTIPLIERY)];        
        
        //options button
        _optionsButton = [ActionButton actionButtonCustomGraphicsForIdle:@"Menu_OptionsBlue.png" Selected:@"Menu_OptionsGreen.png"];
        [_optionsButton setPosition:MainMenuPhonePoint(30 * MULTIPLIERX,24 * MULTIPLIERY)];
        [_optionsButton setHitboxBySize:CGSizeMake(65 * MULTIPLIERX, 65 * MULTIPLIERY)];

        //gift button
        _giftButton = [ActionButton actionButtonCustomGraphicsForIdle:@"Menu_Gift_Blue.png" Selected:@"Menu_Gift_Green.png"];
        [_giftButton setPosition:MainMenuPhonePoint(75 * MULTIPLIERX,24* MULTIPLIERY)];
        [_giftButton setHitboxBySize:CGSizeMake(65 * MULTIPLIERX, 65* MULTIPLIERY)];

        [[InAppPurchaseManager shared] requestProductData];
        
        [[LayerManager sharedLayers] forgetWorkingLayer];
        //_hasCheckedAchievement=false;
        
        //initial values
        _totalTime = 0.0f;
        _time = 0.0f;
        _transition = MAINMENU_TRANSITION_IN;
        _switchSceneTriggered = false;
        _reinit = false;
        _hasCheckedAchievement=false;
        
        //make everything except track background transparent
        [self setAlphaForAll:0.0f includingButtons:YES andButtonSelection:YES];
        
        [self scheduleUpdate];
        self.isTouchEnabled = YES;
                
        
        //check to see if the title menu music is loaded. if not, play it.
        NSString *musicStarted = [[GameSettings shared] getGlobalForKey:@"titleMusicStarted"];
        if (![musicStarted isEqualToString:@"YES"]) {
            [[SoundEngine shared] playMusic:@"title"];
            [[GameSettings shared] setGlobal:@"YES" ForKey:@"titleMusicStarted"];
        }
        [myPool drain];

    }
   
   
    return self;
}

-(void)pause
{
    [[CCDirector sharedDirector] pause];
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
        if (_transition == MAINMENU_TRANSITION_IDLE) 
    {
        bool shouldStart = false;
        NSSet *allTouches = [event allTouches];
        
        for(UITouch *touch in allTouches)
        {
            CGPoint position = [self convertTouchToNodeSpace:touch];
            
            if ([_playButton testCollision:position]) {
                _switchToChoice = MENU_SWITCHTO_CHOOSELEVEL;
                [[SoundEngine shared] playSound:@"menuPlayButton"];
                _selectedButton = _playButton;
                shouldStart = true;
            } else if ([_leaderboardsButton testCollision:position]) {
                _switchToChoice = MENU_SWITCHTO_LEADERBOARDS;
                _selectedButton = _leaderboardsButton;
                [self buttonTransition];
                [[SoundEngine shared] playSound:@"confirm"];
            } else if ([_achievementsButton testCollision:position]) {
                _switchToChoice = MENU_SWITCHTO_ACHIEVEMENTS;
                _selectedButton = _achievementsButton;
                [[SoundEngine shared] playSound:@"confirm"];
                [self buttonTransition];
            } else if ([_optionsButton testCollision:position]) {
                _switchToChoice = MENU_SWITCHTO_OPTIONS;
                [[SoundEngine shared] playSound:@"guiSelectionForward"];
                _selectedButton = _optionsButton;
                shouldStart = true;
            }else if ([_giftButton testCollision:position]) {
                _switchToChoice = MENU_SWITCHTO_GIFT;
                _selectedButton=_giftButton;
                [[SoundEngine shared] playSound:@"confirm"];
                [self buttonTransition];
               
            } 
            else if(_isContinueButtonEnabled && [_continueButton testCollision:position]) {
                _switchToChoice = MENU_SWITCHTO_CONTINUE;
                _selectedButton = _continueButton;
                [[SoundEngine shared] playSound:@"menuPlayButton"];
                shouldStart = true;
            }
        }
        
        if (shouldStart) {
            [self switchToTransitionOut];
        }
        
    }
}

-(void)setAlphaForAll:(float)alpha includingButtons:(bool)alphaButtons andButtonSelection:(bool)alphaSelected
{
    [_logo setAlpha:alpha];
    
    if (alphaButtons) {
        [_playButton setAlpha:alpha];
        [_optionsButton setAlpha:alpha];
        [_leaderboardsButton setAlpha:alpha];
        [_achievementsButton setAlpha:alpha];
        [_giftButton setAlpha:alpha];
        
        if(_isContinueButtonEnabled) {
            [_continueButton setAlpha:alpha];
        }
    }
    
    if(alphaSelected) {
        [_playButton setSelectedAlpha:alpha];
        [_leaderboardsButton setSelectedAlpha:alpha];
        [_achievementsButton setSelectedAlpha:alpha];
        [_optionsButton setSelectedAlpha:alpha];
        [_giftButton setSelectedAlpha:alpha];
        
        if (_isContinueButtonEnabled) {
            [_continueButton setSelectedAlpha:alpha];            
        }
    }
    
    [_copyright setAlpha:alpha];

}

-(void)setButtonAlphas:(float)alpha
{
    [_playButton setAlpha:alpha];
    [_optionsButton setAlpha:alpha];
    [_giftButton setAlpha:alpha];
    [_leaderboardsButton setAlpha:alpha];
    [_achievementsButton setAlpha:alpha];
    
    if (_isContinueButtonEnabled) {
        [_continueButton setAlpha:alpha];
    }
}

-(void)switchToTransitionIn
{
    _time = 0.0f;
    _totalTime = 0.0f;
    
    _transition = MAINMENU_TRANSITION_IN;
    
    [self setAlphaForAll:0.0f includingButtons:YES andButtonSelection:YES];
    
    [_trackBackground setAlpha:1.0f];
}
-(void)checkAchievement
{
    if([[[GameSettings shared] getGlobalForKey:@"RatedOurGame"] isEqualToString:@"YES"])
    {
        if(![GCState sharedInstance].rateOurGame)
        {
            [GCState sharedInstance].allGoldInNormal=true;
            [[GCHelper sharedInstance] reportAchievement:gcAchievementRateTheGame percentComplete:100];
            
            [[GameSettings shared] setGlobal:@"NO" ForKey:@"RatedOurGame"];
        }
        
    }

}
-(void)switchToTransitionOut
{
    _time = 0.0f;
    _transition = MAINMENU_TRANSITION_OUT;
}

-(void)buttonTransition
{
    _time=0.0f;
    _transition=MAINMENU_BUTTON_TRANSITION;
}

-(void)reinit
{
    [self switchToTransitionIn];    
    _reinit = false;
}

-(void)update:(ccTime)dt
{
    float rate = 12.0f * MULTIPLIERX * dt;
    _totalTime += rate;
    _time += dt;
    
    
    
    
    switch (_transition) {
        case MAINMENU_TRANSITION_IN:
            if (_time>=1.0f) {
                _time = 1.0f;
                _transition = MAINMENU_TRANSITION_IDLE;
                if(!_hasCheckedAchievement)
                {
                [self checkAchievement];
                    _hasCheckedAchievement=true;
                }
            }
            [_logo move:ccp(0, rate)];
            [_copyright move:ccp(0,-0.5f * rate)];
            
            [self setAlphaForAll:_time includingButtons:YES andButtonSelection:NO];
            
            break;
        case MAINMENU_TRANSITION_OUT:
            if (_time >=1.0f) {
                _time = 1.0f;
            }
            
            [self setAlphaForAll:(1.0f - _time) includingButtons:NO andButtonSelection:NO];
            [self setButtonAlphas:(MIN(1.0f,1.0f - 1.0f * _time))];
            
            [_selectedButton setSelectedAlpha:(MAX(1.0f - 8.0f * _time, 0.0f))];

            if (!_switchSceneTriggered) {
                if (_time >=1.0f) {
                    [self switchToChoice];
                    _switchSceneTriggered = true;
                }
            }
            break;
            
        case MAINMENU_BUTTON_TRANSITION:
            if (_time >=1.0f) {
                _time = 1.0f;
                _transition=MAINMENU_TRANSITION_IDLE;
                [self switchToChoice];
                
            }

            [_selectedButton setSelectedAlpha:(MAX(1.0f - 8.0f * _time, 0.0f))];
            
            
            break;
        default:
            break;
    }
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown && interfaceOrientation != UIInterfaceOrientationPortrait);
}


-(void)switchToChoice
{
    NSString *startingLevel = [[GameSettings shared] getGlobalForKey:@"storyModeCurrentLevel"];
    NSString *startingDifficulty = [[GameSettings shared] getGlobalForKey:@"storyModeDifficulty"];
    
    switch (_switchToChoice) {
        case MENU_SWITCHTO_CONTINUE:
            [[GameSettings shared] setGlobal:@"NO" ForKey:@"titleMusicStarted"];
            [[GameSettings shared] setGlobal:startingLevel ForKey:@"startingLevel"];
            [[GameSettings shared] setGlobal:startingDifficulty ForKey:@"gameDifficulty"];
            [[GameSettings shared] setGlobal:@"story" ForKey:@"gameMode"];
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[GameLayer scene]]];
            break;
        case MENU_SWITCHTO_CHOOSELEVEL:            
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[ChooseModeScene scene]]];
            break;
        case MENU_SWITCHTO_LEADERBOARDS:
            [[GCHelper sharedInstance] showLeaderboards];
           break;
        case MENU_SWITCHTO_ACHIEVEMENTS:
            [[GCHelper sharedInstance] showAchievements];
           break;
        case MENU_SWITCHTO_OPTIONS:
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[OptionsScene node]]];
            break;
        case MENU_SWITCHTO_GIFT:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/giftSongsWizard?gift=1&salableAdamId=473701533&productType=C&pricingParameter=STDQ"]];
            break;

        default:
            break;
    }
    
}

-(void)onExit
{    
    [self unscheduleUpdate];
    self.isTouchEnabled = false;
}


-(void)dealloc
{
    CCLOG(@"Dealloc: MainMenuScene");
    
    //sprites
    [_trackBackground release];
    [_logo release];
    [_copyright release];

    //buttons
    [_playButton release];
    [_continueButton release];
    [_achievementsButton release];
    [_leaderboardsButton release];
    [_optionsButton release];
    [_giftButton release];
    
    [[TextureManager shared] unloadMemoryForKey:@"mainMenu"];
    [super dealloc];
}

@end
