//
//  EndGameScene.m
//  Clay
//
//  Created by Brian Cable on 10/12/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "EndGameScene.h"
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


@implementation EndGameScene


+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	EndGameScene *layer = [EndGameScene node];
	
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
        
        
        _state = END_GAME_TRANSITION_IN;
        _alpha = 0.0f;
        _shouldExit=false;
        _bonusShowed = false;
        
        
        [[LayerManager sharedLayers] setWorkingLayer:self];
        
        [[TextureManager shared] loadMemoryForKey:@"endGame"];
        
             _comic=[Sprite spriteWithFile:@"Comic_11.png"];
        
        difficulty = [[GameSettings shared] getGlobalForKey:@"gameDifficulty"];
        mode=[[GameSettings shared] getGlobalForKey:@"gameMode"];
        
        if([difficulty isEqualToString:@"hard"] && [mode isEqualToString:@"story"])
        {
        _BonusComic=[Sprite spriteWithFile:@"Comic_12.png"];
        }
        else
        {
            _BonusComic=[Sprite spriteWithFile:@"Comic_13.png"];
        }
        
      

        
        _endGame = [Sprite spriteFromFrameCacheWithName:@"Menu_Ending_Temp.png"];
        _bestTime = [Sprite spriteFromFrameCacheWithName:@"Menu_Ending_BestTime.png"];
        [_bestTime getCCSprite].position = ccp(350.0f, 145.0f);
        _timer = [TrackTimer instance];
        [_timer setupAnimationsAtX:232.0f Y:125.0f];
        
        _besttimer = [TrackTimer instance];
        [_besttimer setupAnimationsAtX:232.0f Y:145.0f];
        
        [self showTimers];
        
        
       


        [[LayerManager sharedLayers] forgetWorkingLayer];
        
        [_comic setAlpha:0.0f];
        [_endGame setAlpha:0.0f];
        [_bestTime setAlpha:0.0f];
        [_timer setAlpha:0.0f];
        [_besttimer setAlpha:0.0f];
        [_BonusComic setAlpha:0.0f];
      
        _initialized = false;
        
        [self scheduleUpdate];
        self.isTouchEnabled = true;
          
    }
    
    return self;
}

-(void)showTimers

{
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
    
   if ([[[GCHelper sharedInstance] getAchievementByID:gcAchievementBeatStoryEasy] isCompleted] &&[[[GCHelper sharedInstance] getAchievementByID:gcAchievementBeatStoryNormal] isCompleted] &&[[[GCHelper sharedInstance] getAchievementByID:gcAchievementBeatStoryHard] isCompleted] && ![[[GCHelper sharedInstance] getAchievementByID:gcAchievementBeatStoryAll] isCompleted])
    
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

}


-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if (_state == END_GAME_TRANSITION_IDLE) {
        bool shouldStart = false;
        NSSet *allTouches = [event allTouches];
        for(UITouch *touch in allTouches) {
            shouldStart = true;
        }
        
        if (shouldStart && !_shouldExit) {
            
            
            if(!_bonusShowed)
            {
               
                _alpha=0;
                _state=END_GAME_TRANSITION_COMIC_BONUS;
                
            }
            else
            {
                _alpha=0;
                _state = END_GAME_TRANSITION_COMIC;
            }
        }
        
        if(_shouldExit)
        {
              [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[MainMenuScene scene]]];
        }
    }
}

-(void)update:(ccTime)dt
{
    float rate = 2.0f * dt;
    
    
       
    switch (_state) {
        case END_GAME_TRANSITION_IN:
            _alpha += rate;
            if (_alpha >= 1.0f) {
                _alpha = 1.0f;
                _state = END_GAME_TRANSITION_IDLE;
            }
            [_comic setAlpha:_alpha];
            break;
        case END_GAME_TRANSITION_COMIC:
            _alpha += rate;
            if (_alpha >= 1.0f) {
                _alpha = 1.0f;
                _state = END_GAME_TRANSITION_IDLE;
            }
            
             [_endGame setAlpha:_alpha];
             [_bestTime setAlpha:_alpha];
             [_timer setAlpha:_alpha];
            [_besttimer setAlpha:_alpha];
            [_comic setAlpha:(1-_alpha)];
            
            _shouldExit=true;
            break;
        case END_GAME_TRANSITION_COMIC_BONUS:
            _alpha += rate;
            if (_alpha >= 1.0f) {
                _alpha = 1.0f;
                _state = END_GAME_TRANSITION_IDLE;
            }
            
            [_BonusComic setAlpha:_alpha];
            [_comic setAlpha:(1-_alpha)];
            _bonusShowed =true;
        
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
    [difficulty release];
    [mode release];
    [[TextureManager shared] unloadMemoryForKey:@"endGame"];
}


@end
