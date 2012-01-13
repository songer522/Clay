//
//  EndLevelScene.m
//  Clay
//
//  Created by Song Yang on 1/13/12.
//  Copyright (c) 2012 XecuDev. All rights reserved.
//

#import "EndlevelScene.h"
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
#import "SoundEngine.h"

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
        
        
        [[LayerManager sharedLayers] setWorkingLayer:self];
        
        [[TextureManager shared] loadMemoryForKey:@"endGame"];
        [[TextureManager shared] loadMemoryForKey:@"chooseMode"];
        
        _endGame = [Sprite spriteFromFrameCacheWithName:@"Menu_Ending_Temp.png"];
        _bestTime = [Sprite spriteFromFrameCacheWithName:@"Menu_Ending_BestTime.png"];
        [_bestTime getCCSprite].position = ccp(350.0f, 145.0f);
        _timer = [TrackTimer instance];
        [_timer setupAnimationsAtX:232.0f Y:125.0f];
        
        _besttimer = [TrackTimer instance];
        [_besttimer setupAnimationsAtX:232.0f Y:145.0f];
        
        
        
        _startButton = [ActionButton actionButtonCustomGraphicsForIdle:@"UI_GameType_ButtonS_Blue.png" Selected:@"UI_GameType_ButtonS_Green.png"];
        [_startButton setInitialText:@"START"];
        [_startButton setPosition:ccp(430,18)];
        
        _backButton = [ActionButton actionButtonCustomGraphicsForIdle:@"UI_GameType_ButtonS_Blue.png" Selected:@"UI_GameType_ButtonS_Green.png"];
        [_backButton setInitialText:@"BACK"];
        [_backButton setPosition:ccp(50, 18)];
        
        
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



-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    
        NSSet *allTouches = [event allTouches];
        
        for(UITouch *touch in allTouches)
        {
            CGPoint position = [self convertTouchToNodeSpace:touch];
                           
                if([_startButton checkIfSelected:position]) {
                    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[MainMenuScene scene]]];

                    //_waitToSwitch = 0.25f;
                   // _isTransitioning = true;
                    //_backToMainMenu = false;
                    [[SoundEngine shared] playSound:@"buttonPressed"];
                }
                
                if([_backButton checkIfSelected:position]) {
                   // _waitToSwitch = 0.25f;
                    //_isTransitioning = true;
                    //_backToMainMenu = true;
                    [[SoundEngine shared] playSound:@"buttonPressed"];     
                }
                
            }
   
}

-(void)update:(ccTime)dt
{
    float rate = 2.0f * dt;
    NSString *difficulty = [[GameSettings shared] getGlobalForKey:@"gameDifficulty"];
    NSString *mode=[[GameSettings shared] getGlobalForKey:@"gameMode"];
    float finalTime = [[[GameSettings shared] getGlobalForKey:@"finalTime"] floatValue];
    
    if([difficulty isEqualToString:@"easy"] && [mode isEqualToString:@"story"])
    {
        [[GCHelper sharedInstance] reportLeaderboard:gcLeaderboardStoryEasy score:100*finalTime];
        if(![GCState sharedInstance].completeStoryEasy)
        {
            [GCState sharedInstance].completeStoryEasy = true;
            //[[GCState sharedInstance] save];
            [[GCHelper sharedInstance] reportAchievement:gcAchievementBeatStoryEasy percentComplete:100.0];
        }
    }
    else if([difficulty isEqualToString:@"normal"] && [mode isEqualToString:@"story"])
    {
        [[GCHelper sharedInstance] reportLeaderboard:gcLeaderboardStoryNormal score:100*finalTime];
        if(![GCState sharedInstance].completeStoryNormal)
        {
            [GCState sharedInstance].completeStoryNormal = true;
            //[[GCState sharedInstance] save];
            [[GCHelper sharedInstance] reportAchievement:gcAchievementBeatStoryNormal percentComplete:100.0];
        }
    }
    else if([difficulty isEqualToString:@"hard"] && [mode isEqualToString:@"story"])
    {
        [[GCHelper sharedInstance] reportLeaderboard:gcLeaderboardStoryHard score:100*finalTime];
        if(![GCState sharedInstance].completeStoryHard)
        {
            [GCState sharedInstance].completeStoryHard = true;
            //[[GCState sharedInstance] save];
            [[GCHelper sharedInstance] reportAchievement:gcAchievementBeatStoryHard percentComplete:100.0];
        }
    }
    if(![GCState sharedInstance].completeStoryAll && [GCState sharedInstance].completeStoryEasy && [GCState sharedInstance].completeStoryNormal && [GCState sharedInstance].completeStoryHard)
    {
        [GCState sharedInstance].completeStoryAll = true;
        //[[GCState sharedInstance] save];
        [[GCHelper sharedInstance] reportAchievement:gcAchievementBeatStoryAll percentComplete:100.0];
    }
    
    
    
    
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
    
    [_endGame release];
    [_bestTime release];
    [_timer release];
    [_besttimer release];
    [[TextureManager shared] unloadMemoryForKey:@"endGame"];
      [[TextureManager shared] unloadMemoryForKey:@"chooseMode"];
}


@end
