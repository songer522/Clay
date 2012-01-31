//
//  EndGameScene.m
//  Clay
//
//  Created by Brian Cable on 10/12/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "EndLevelScene.h"
#import "LayerManager.h"
#import "TrackTimer.h"
#import "Sprite.h"
#import "GameLayer.h"
#import "HudLayer.h"
#import "UserData.h"
#import "MainMenuScene.h"
#import "TextureManager.h"
#import "GameSettings.h"
#import "GCHelper.h"
#import "GCState.h"
#import "ActionButton.h"
#import "FBPrompt.h"
#import "SoundEngine.h"
#import "AppDelegate.h"
#import "GameLabel.h"
#import "Appirater.h"

@implementation EndLevelScene


+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	EndLevelScene *layer = [EndLevelScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

+(id)instance
{
    return [[self alloc] init];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
        
        _state = END_LEVEL_TRANSITION_IN;
        _alpha = 0.0f;
        _time = 0.0f;
        _openFacebook=false;
        _hasSwitch=false;
        _openTwitter=false;
        _rateWindowShowed=false;
        _tweetViewController = nil;
        _fbprompt = nil;
        _difficulty = [[GameSettings shared] getGlobalForKey:@"gameDifficulty"];
        _hasSwitched = true;
        
        //_description= [NSString stringWithFormat:@"story mode %@",_difficulty];
        
        [[LayerManager sharedLayers] setWorkingLayer:self];
        
        [[TextureManager shared] loadMemoryForKey:@"endGame"];
        
        
        _background = [Sprite spriteFromFrameCacheWithName:@"End_Background.png"];
        _finalTimePanel = [Sprite spriteFromFrameCacheWithName:@"End_BackBox_1.png"];
        _facebookAndTwitterPanel =[Sprite spriteFromFrameCacheWithName:@"End_BackBox_2.png"];
        _facebookIcon = [Sprite spriteFromFrameCacheWithName:@"End_Icon_Facebook.png"];
        _twitterIcon =[Sprite spriteFromFrameCacheWithName:@"End_Icon_Twitter.png"];
        _finalTimeHeader=[Sprite spriteFromFrameCacheWithName:@"End_Text_FinalTime.png"];
        
        
         if([_difficulty isEqualToString:@"easy"])
         {
             _difficultyHeader=[Sprite spriteFromFrameCacheWithName:@"End_Text_Easy.png"];
         }
        else if([_difficulty isEqualToString:@"normal"])
        {
            _difficultyHeader=[Sprite spriteFromFrameCacheWithName:@"End_Text_Normal.png"];
        }
        else if([_difficulty isEqualToString:@"hard"])
        {
            _difficultyHeader=[Sprite spriteFromFrameCacheWithName:@"End_Text_Hard.png"];
        }
        
        
        _menuButton = [ActionButton actionButtonInGameWithText:@"MENU"];
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        float centerX = winSize.width/2.0f;
        float centerY = winSize.height/2.0f;
        [_menuButton setPosition:ccp(centerX + 185.0f,centerY - 140.0f)];
        [_background getCCSprite].position=ccp(centerX-240,centerY-160);
        [_finalTimePanel getCCSprite].position=ccp(centerX-225,centerY+70);
        [_facebookAndTwitterPanel getCCSprite].position=ccp(centerX-225,centerY-85);
        [_finalTimeHeader getCCSprite].position=ccp(centerX-215,centerY+120);
        [_difficultyHeader getCCSprite].position=ccp(centerX+65,centerY+120);
        
        
        
        
       
        [_facebookIcon setScreenPosition:ccp(centerX-216,centerY-23)];
        [_twitterIcon setScreenPosition:ccp(centerX-216,centerY-72)];
        
        _facebookButton =[ActionButton actionButtonManualSetup];
        _facebookButton.facebookOrTwitterEndStroy=true;
        [_facebookButton setPosition:ccp(24,127)];
        [_facebookButton setEnabled:true];
        
        _twitterButton =[ ActionButton actionButtonManualSetup];
        _twitterButton.facebookOrTwitterEndStroy=true;
        [_twitterButton setPosition:ccp(24,82)];
        [_twitterButton setEnabled:true];

        
        
        [[LayerManager sharedLayers] forgetWorkingLayer];
        
         
        [_background setAlpha:0.0f];
        [_facebookIcon setAlpha:0.0f];
        [_twitterIcon setAlpha:0.0f];
        [_finalTimePanel setAlpha:0.0f];
        [_finalTimeHeader setAlpha:0.0f];
        [_difficultyHeader setAlpha:0.0f];
        [_facebookAndTwitterPanel setAlpha:0.0f];
        [_timeHeaderText setAlpha:0.0f];
        [_finalTimeText setAlpha:0.0f];
        [_facebookButton setAlpha:0.0f];
        [_twitterButton setAlpha:0.0f];
        [_menuButton setAlpha:0.0f];

        
        
       
        
        _initialized = false;
        
        [self scheduleUpdate];
        self.isTouchEnabled = true;
        
    }
    
    return self;
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
}



-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if (_state == END_LEVEL_TRANSITION_IDLE) {
        
            NSSet *allTouches = [event allTouches];
            for(UITouch *touch in allTouches) {
                CGPoint position = [self convertTouchToNodeSpace:touch];
                    
            if([_facebookButton checkIfSelected:position]) {
                
                _openFacebook = true;
                _selectedButton= _facebookButton;
                [[SoundEngine shared] playSound:@"buttonPressed"];     
            }
            else if([_twitterButton checkIfSelected:position]) {
            
                _openTwitter= true;
                _selectedButton= _twitterButton;
                [[SoundEngine shared] playSound:@"buttonPressed"];     
            }
                else if ([_menuButton checkIfSelected:position])
                {
                    _selectedButton=_menuButton;
                    _time=0.5f;
                    _state=END_LEVEL_TRANSITION_OUT;
                  
                }
            }
           }
}

-(void)update:(ccTime)dt
{
    float rate = 2.0f * dt;
    
    float finalTime = [[[GameSettings shared] getGlobalForKey:@"finalTime"] floatValue];
    
        NSString *_description= [NSString stringWithFormat:@"story mode %@",_difficulty];
    
    
    
    if (!_initialized) {
        
        if ([[UserData sharedInstance] bestTime] > finalTime)
        {
            [UserData sharedInstance].bestTime = finalTime;
            [[UserData sharedInstance] save];
        }
        else if ([[UserData sharedInstance] bestTime] == 0.0f)
        {
            [UserData sharedInstance].bestTime = finalTime;
            [[UserData sharedInstance] save];
        }
        NSString *timerText=[TrackTimer getTimeStringFromFloat:finalTime];
        [[LayerManager sharedLayers] setWorkingLayer:self];
        _finalTimeText = [GameLabel gameLabelWithText:timerText  Scale:1.0f Position:ccp(240,250)];
       
        [[LayerManager sharedLayers] forgetWorkingLayer];
        _initialized = true;
    }
    
    if(_openFacebook)
    {
        if (_fbprompt !=nil) {
            [_fbprompt release];
            _fbprompt = nil;
        }
        _timer=[TrackTimer getTimeStringFromFloat:finalTime];
        _fbprompt = [FBPrompt promptWithAppId:@"264174546971482" andDelegate:self];
        [_fbprompt showFacebookDialogWithDescription:[NSString stringWithFormat:@"Hey, here's my score for Track Lapse %@ : %@, see if you can beat me!!!",_description, _timer] andPicture:@"http://fbrell.com/f8.jpg"];
        _openFacebook =false;
        
        if(![GCState sharedInstance].facebook)
        {
            
            [GCState sharedInstance].facebook =true;
            [[GCHelper sharedInstance] reportAchievement:gcAchievementFacebookUs percentComplete:100.0];
        }
        
    } else if(_openTwitter)
    {
         _timer=[TrackTimer getTimeStringFromFloat:finalTime];
        [self sendEasyTweet:[NSString stringWithFormat:@"Hey, here's my score for Track Lapse %@ : %@, see if you can beat me!!!",_description, _timer]];
        _openTwitter =false;
        if(![GCState sharedInstance].twitter)
        {
            
            [GCState sharedInstance].twitter =true;
            [[GCHelper sharedInstance] reportAchievement:gcAchievementTwitterUs percentComplete:100.0];
        }
        
    }
    
    switch (_state) {
        case END_LEVEL_TRANSITION_IN:
            _alpha += rate;
            if (_alpha >= 1.0f) {
                _alpha = 1.0f;
                _state = END_LEVEL_TRANSITION_IDLE;
            }
            [_background setAlpha:_alpha];
            [_facebookIcon setAlpha:_alpha];
            [_twitterIcon setAlpha:_alpha];
            [_finalTimePanel setAlpha:_alpha];
            [_finalTimeHeader setAlpha:_alpha];
            [_difficultyHeader setAlpha:_alpha];
            [_facebookAndTwitterPanel setAlpha:_alpha];
            [_timeHeaderText setAlpha:_alpha];
            [_finalTimeText setAlpha:_alpha];
            [_facebookButton setAlpha:_alpha];
            [_twitterButton setAlpha:_alpha];
            [_menuButton setAlpha:_alpha];
            break;
        case END_LEVEL_TRANSITION_OUT:
            
            if (_time >0.0f)
            {
                _time -= 2.0f * dt;
                if (_time <=0.0f) {
                    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[MainMenuScene scene]]];
                    _hasSwitched = true;
                    if(!_rateWindowShowed)
                    {
                        [[Appirater sharedInstance] setShouldForceShowingWindow:YES];
                        _rateWindowShowed=true;
                    }                    
                }
            } 

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
    //NSLog(@"Dealloc: EndGameScene");
    if (_tweetViewController!=nil) {
        [_tweetViewController release];
        _tweetViewController = nil;
    }
    
    if (_fbprompt!=nil) {
        [_fbprompt release];
        _fbprompt = nil;
    }
    [_facebookIcon release];
    [_twitterIcon release];
    [_facebookButton release];
    [_twitterButton release];
   [_background release];
    _selectedButton=nil;
   
    [_finalTimePanel release];
    [_finalTimeHeader release];
    [_difficultyHeader release];
    [_facebookAndTwitterPanel release];
    [_timeHeaderText release];
    [_finalTimeText release];
    [_menuButton release];
    
    
    [[TextureManager shared] unloadMemoryForKey:@"endGame"];
}


@end
