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
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define MULTIPLIERX (IS_IPAD ? 2.133 : 1)
#define MULTIPLIERY (IS_IPAD ? 2.4 : 1)



@implementation MainMenuScene

@synthesize facebook;


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
        _rain1 = [Sprite spriteFromFrameCacheWithName:@"Menu_Rain_01.png"];
        _rain2 = [Sprite spriteFromFrameCacheWithName:@"Menu_Rain_02.png"];
        _logo = [Sprite spriteCenteredWithFrame:@"Menu_Logo.png" Position:ccp(240,258)]; //final y: 262
        _copyright = [Sprite spriteCenteredWithFrame:@"Menu_Copyright.png" Position:ccp(240,24)]; //final y: 20
        
        //check whether we can continue the game
        _isContinueButtonEnabled = [ContinueGameManager isAbleToContinueGame];        
        
        //play button with position determined on whether we can continue
        _playButton = [ActionButton actionButtonCustomGraphicsForIdle:@"Menu_PlayBlue.png" Selected:@"Menu_PlayGreen.png"];
        
        if (_isContinueButtonEnabled) {
            [_playButton setPosition:ccp(240,115)];            
        } else {
            [_playButton setPosition:ccp(240,142)];                        
        }
        [_playButton setHitboxBySize:CGSizeMake(319, 71)];
       
        
        _logo = [Sprite spriteFromFrameCacheWithName:@"Menu_Logo.png"];
        [_logo setAlpha:0.0f];
        [_logo getCCSprite].anchorPoint = ccp(0.5f, 0.5f);
        [_logo getCCSprite].position = ccp(240 * MULTIPLIERX, 258 * MULTIPLIERY); //final 240, 262
        
        _playButtonBlue = [Sprite spriteFromFrameCacheWithName:@"Menu_PlayBlue.png"];
        [_playButtonBlue setAlpha:0.0f];
        [_playButtonBlue getCCSprite].anchorPoint = ccp(0.5f,0.5f);
        [_playButtonBlue getCCSprite].position = ccp(240 * MULTIPLIERX, 142 * MULTIPLIERY);
        
        _playButtonOrange = [Sprite spriteFromFrameCacheWithName:@"Menu_PlayOrange.png"];
        [_playButtonOrange getCCSprite].anchorPoint = ccp(0.5f, 0.5f);
        [_playButtonOrange getCCSprite].position = ccp(240 * MULTIPLIERX,142 * MULTIPLIERY);
        [[_playButtonOrange getCCSprite] setVisible:NO];
        
        _copyright = [Sprite spriteFromFrameCacheWithName:@"Menu_Copyright.png"];
        [_copyright setAlpha:0.0f];
        [_copyright getCCSprite].anchorPoint = ccp(0.5f, 0.5f);
        [_copyright getCCSprite].position = ccp(240 * MULTIPLIERX,24 * MULTIPLIERY); //final 240,20
        /*
         _tutorialButton = [ActionButton actionButtonWithText:@"TUTORIAL"];
         [_tutorialButton setPosition:ccp(50, 18)];
         
        _tutorial=[Tutorial TutorialWithinLayer:self];
        */
        
        [[LayerManager sharedLayers] forgetWorkingLayer];
        
        
        //initial values
        _totalTime = 0.0f;
        _time = 0.0f;
        _transition = MAINMENU_TRANSITION_IN;
        _switchSceneTriggered = false;
        _reinit = false;
        
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
                _selectedButton = _playButton;
                shouldStart = true;
            } else if ([_leaderboardsButton testCollision:position]) {
                _switchToChoice = MENU_SWITCHTO_LEADERBOARDS;
                _selectedButton = _leaderboardsButton;
                [self switchToChoice];
            } else if ([_achievementsButton testCollision:position]) {
                _switchToChoice = MENU_SWITCHTO_ACHIEVEMENTS;
                _selectedButton = _achievementsButton;
                [self switchToChoice];
            } else if ([_optionsButton testCollision:position]) {
                _switchToChoice = MENU_SWITCHTO_OPTIONS;
                _selectedButton = _optionsButton;
                shouldStart = true;
            } else if(_isContinueButtonEnabled && [_continueButton testCollision:position]) {
                _switchToChoice = MENU_SWITCHTO_CONTINUE;
                _selectedButton = _continueButton;
                shouldStart = true;
            }
        }
        
        if (shouldStart) {
            [self switchToTransitionOut];
            [[SoundEngine shared] playSound:@"menuPlayButton"];
        }
    }
}

-(void)setAlphaForAll:(float)alpha includingButtons:(bool)alphaButtons andButtonSelection:(bool)alphaSelected
{
    [_rain1 setAlpha:alpha];
    [_rain2 setAlpha:alpha];
    
    [_logo setAlpha:alpha];
    
    if (alphaButtons) {
        [_playButton setAlpha:alpha];
        [_optionsButton setAlpha:alpha];
        [_leaderboardsButton setAlpha:alpha];
        [_achievementsButton setAlpha:alpha];
        
        if(_isContinueButtonEnabled) {
            [_continueButton setAlpha:alpha];
        }
    }
    
    if(alphaSelected) {
        [_playButton setSelectedAlpha:alpha];
        [_leaderboardsButton setSelectedAlpha:alpha];
        [_achievementsButton setSelectedAlpha:alpha];
        [_optionsButton setSelectedAlpha:alpha];
        
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


-(void)switchToTransitionOut
{
    _time = 0.0f;
    _transition = MAINMENU_TRANSITION_OUT;
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
    
    //oscillate between two image files
    float rainFrame = sinf(2.0f * _totalTime);
    if (rainFrame > 0.0f) {
        [[_rain1 getCCSprite] setVisible:YES];
        [[_rain2 getCCSprite] setVisible:NO];
    } else {
        [[_rain1 getCCSprite] setVisible:NO];
        [[_rain2 getCCSprite] setVisible:YES];
    }
    
    switch (_transition) {
        case MAINMENU_TRANSITION_IN:
            if (_time>=1.0f) {
                _time = 1.0f;
                _transition = MAINMENU_TRANSITION_IDLE;
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
        default:
            break;
    }
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown && interfaceOrientation != UIInterfaceOrientationPortrait);
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


-(void)switchToChoice
{
    //FBPrompt *prompt;
    

    switch (_switchToChoice) {
        case MENU_SWITCHTO_CHOOSELEVEL:            
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[ChooseModeScene scene]]];
            break;
        case MENU_SWITCHTO_LEADERBOARDS:
            [[GCHelper sharedInstance] showLeaderboards];
            //prompt = [FBPrompt promptWithAppId:@"264174546971482" andDelegate:self];
            //[prompt showFacebookDialogWithDescription:@"Hello!" andPicture:@"http://fbrell.com/f8.jpg"];
           break;
        case MENU_SWITCHTO_ACHIEVEMENTS:
            [[GCHelper sharedInstance] showAchievements];
           // [self sendEasyTweet:@"hello"];
           break;
        case MENU_SWITCHTO_OPTIONS:
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[OptionsScene node]]];
            //[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[CreditsScene node]]];
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
    //NSLog(@"Dealloc: MainMenuScene");
    
    //sprites
    [_trackBackground release];
    [_rain1 release];
    [_rain2 release];
    [_logo release];
    [_copyright release];

    //buttons
    [_playButton release];
    [_continueButton release];
    [_achievementsButton release];
    [_leaderboardsButton release];
    [_optionsButton release];
    
    [[TextureManager shared] unloadMemoryForKey:@"mainMenu"];
    [super dealloc];
}

@end
