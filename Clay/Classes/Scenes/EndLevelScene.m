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
        _openFacebook=false;
        _openTwitter=false;
        _tweetViewController = nil;
        _fbprompt = nil;
        _difficulty = [[GameSettings shared] getGlobalForKey:@"gameDifficulty"];
       
        _description= [NSString stringWithFormat:@"story mode %@",_difficulty];
        
        [[LayerManager sharedLayers] setWorkingLayer:self];
        
        [[TextureManager shared] loadMemoryForKey:@"endGame"];
        
        _endGame = [Sprite spriteFromFrameCacheWithName:@"Menu_Ending_Temp.png"];
        _bestTime = [Sprite spriteFromFrameCacheWithName:@"Menu_Ending_BestTime.png"];
        [_bestTime getCCSprite].position = ccp(350.0f, 145.0f);
        _timer = [TrackTimer instance];
        [_timer setupAnimationsAtX:232.0f Y:125.0f];
        
        _besttimer = [TrackTimer instance];
        [_besttimer setupAnimationsAtX:232.0f Y:145.0f];
        
        _facebookIcon = [Sprite spriteCenteredWithFrame:@"Icon_Facebook.png"];
        _twitterIcon = [Sprite spriteCenteredWithFrame:@"Icon_Twitter.png"];
        [_facebookIcon setScreenPosition:ccp(280,79)];
        [_twitterIcon setScreenPosition:ccp(350,79)];
        _facebookButton =[ActionButton actionButtonManualSetup];
        _facebookButton.facebookOrTwitter=true;
        [_facebookButton setPosition:ccp(280, 80)];
        [_facebookButton setEnabled:true];
        
        _twitterButton =[ ActionButton actionButtonManualSetup];
        _twitterButton.facebookOrTwitter=true;
        [_twitterButton setPosition:ccp(350, 80)];
        [_twitterButton setEnabled:true];

        
        
        [[LayerManager sharedLayers] forgetWorkingLayer];
        
        
        [_endGame setAlpha:0.0f];
        [_bestTime setAlpha:0.0f];
        [_timer setAlpha:0.0f];
        [_besttimer setAlpha:0.0f];
        
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
                
                //_openFacebook = true;
                [[SoundEngine shared] playSound:@"buttonPressed"];     
            }
            else if([_twitterButton checkIfSelected:position]) {
            
                //_openTwitter= true;
                [[SoundEngine shared] playSound:@"buttonPressed"];     
            }
                else
                {
                   [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[MainMenuScene scene]]]; 
                }
            }
           }
}

-(void)update:(ccTime)dt
{
    float rate = 2.0f * dt;
    float finalTime = [[[GameSettings shared] getGlobalForKey:@"finalTime"] floatValue];
    
        
    
    
    
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
        [_timer setTime:finalTime];
        [_besttimer setTime:[[UserData sharedInstance] bestTime]];
        
        _initialized = true;
    }
    
    if(_openFacebook)
    {
        if (_fbprompt !=nil) {
            [_fbprompt release];
            _fbprompt = nil;
        }
        time=[TrackTimer getTimeStringFromFloat:finalTime];
        _fbprompt = [FBPrompt promptWithAppId:@"264174546971482" andDelegate:self];
        [_fbprompt showFacebookDialogWithDescription:[NSString stringWithFormat:@"Hey, here's my score for Track Lapse %@ : %@, see if you can beat me!!!",_description, time] andPicture:@"http://fbrell.com/f8.jpg"];
        _openFacebook =false;
        
        if(![GCState sharedInstance].facebook)
        {
            
            [GCState sharedInstance].facebook =true;
            [[GCHelper sharedInstance] reportAchievement:gcAchievementFacebookUs percentComplete:100.0];
        }
        
    } else if(_openTwitter)
    {
        
        [self sendEasyTweet:[NSString stringWithFormat:@"Hey, here's my score for Track Lapse %@ : %@, see if you can beat me!!!",_description, time]];
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
            [_endGame setAlpha:_alpha];
            [_bestTime setAlpha:_alpha];
            [_timer setAlpha:_alpha];
            [_besttimer setAlpha:_alpha];
            break;
        case END_LEVEL_TRANSITION_OUT:
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
    [_endGame release];
    [_bestTime release];
    [_timer release];
    [_besttimer release];
    [[TextureManager shared] unloadMemoryForKey:@"endGame"];
}


@end
