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
#import "SoundEngine.h"
#import "CreditsScene.h"

static CGPoint EndGameComicOrigin(CGSize comicSize)
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    return ccp(MAX(0.0f, floorf((winSize.width - comicSize.width) * 0.5f)),
               MAX(0.0f, floorf((winSize.height - comicSize.height) * 0.5f)));
}

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
        _shouldSwitch=false;
       
        [[LayerManager sharedLayers] setWorkingLayer:self];
         
        [[TextureManager shared] loadMemoryForKey:@"endGame"];
        
        _comic=[Sprite spriteWithFile:@"Comic_11-hd.png"];
        [_comic setScreenPosition:EndGameComicOrigin([_comic getCCSprite].contentSize)];
        
        difficulty = [[GameSettings shared] getGlobalForKey:@"gameDifficulty"];
        mode=[[GameSettings shared] getGlobalForKey:@"gameMode"];
        
        if([difficulty isEqualToString:@"hard"] && [mode isEqualToString:@"story"])
        {
            _BonusComic=[Sprite spriteWithFile:@"Comic_13-hd.png"];
            [_BonusComic setScreenPosition:EndGameComicOrigin([_BonusComic getCCSprite].contentSize)];
        }
        else if ([difficulty isEqualToString:@"normal"] && [mode isEqualToString:@"story"])
        {
            _BonusComic=[Sprite spriteWithFile:@"Comic_14-hd.png"];
            [_BonusComic setScreenPosition:EndGameComicOrigin([_BonusComic getCCSprite].contentSize)];
        }
        else
        {
            _BonusComic=[Sprite spriteWithFile:@"Comic_12-hd.png"];
            [_BonusComic setScreenPosition:EndGameComicOrigin([_BonusComic getCCSprite].contentSize)];
        }
        [[SoundEngine shared] cueFadeIn];
       [[SoundEngine shared] playMusic:@"credits"];
        [[GameSettings shared] setGlobal:@"YES" ForKey:@"creditsMusicStarted"];
      

        
                 _initialized = false;
        [self showTimers];
        
        
       


        [[LayerManager sharedLayers] forgetWorkingLayer];
        
        [_comic setAlpha:0.0f];
        
        [_BonusComic setAlpha:0.0f];
      
       
        
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
            if(![GCState sharedInstance].completeStoryAll)
            {
        [GCState sharedInstance].completeStoryAll = true;
        //[[GCState sharedInstance] save];
        [[GCHelper sharedInstance] reportAchievement:gcAchievementBeatStoryAll percentComplete:100.0];
            }
    }
    
    if([[[GCHelper sharedInstance] getAchievementByID:gcAchievementBeatStoryAll] isCompleted] && [[[GCHelper sharedInstance] getAchievementByID:gcAchievementAllGoldInIM] isCompleted] && [[[GCHelper sharedInstance] getAchievementByID:gcAchievementAllGoldInNM] isCompleted])
    {
        if(![GCState sharedInstance].beatStoryAndAllGold)
        {
        
        [GCState sharedInstance].beatStoryAndAllGold =true;
        [[GCHelper sharedInstance] reportAchievement:gcAchievementAllStoryAndAllGold percentComplete:100.0];
        }
    }
    
    /*
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
               _initialized = true;
    }
    */
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
            
            
                          
                _alpha=0;
                _state=END_GAME_TRANSITION_COMIC_BONUS;
                
        }
        
        if(_shouldExit)
        {
            [[GameSettings shared] setGlobal:@"endGame" ForKey:@"switchToCreditsFrom"];
              [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[CreditsScene scene]]];
        }
    }
}

-(void)update:(ccTime)dt
{
    float rate = 2.0f * dt;
    
    
       
    switch (_state) {
        case END_GAME_TRANSITION_IN:
            _alpha += 0.1*rate;
            if (_alpha >= 1.8f) {
                //[[_comic getCCSprite] setVisible:false];
                //_alpha = 0.0f;
                _state = END_GAME_TRANSITION_OUT;
            }
            [_comic setAlpha:_alpha];
            break;
        case END_GAME_TRANSITION_OUT:
            _alpha -= 0.15*rate;
            if (_alpha <= 0.0f) {
                [[_comic getCCSprite] setVisible:false];
                _alpha = 0.0f;
                _state = END_GAME_TRANSITION_COMIC_BONUS;
            }
            [_comic setAlpha:_alpha];
            break;
        case END_GAME_TRANSITION_OUT_BONUS:
            _alpha -= 0.3*rate;
            if (_alpha <= 0.0f) {
                _alpha=0.0f;
                if(!_shouldSwitch)
                {
                [[GameSettings shared] setGlobal:@"endGame" ForKey:@"switchToCreditsFrom"];
                [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[CreditsScene scene]]];
                    _shouldSwitch=true;
                }
            }
            [_BonusComic setAlpha:_alpha];
            break;    
        case END_GAME_TRANSITION_COMIC_BONUS:
            _alpha += 0.3*rate;
            if (_alpha >= 2.5f) {
                _state = END_GAME_TRANSITION_OUT_BONUS;
                               
            }
            
            [_BonusComic setAlpha:_alpha];
            //[_comic setAlpha:(1-_alpha)];
            
         _shouldExit=true;
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
    
    
    //[difficulty release];
    //[mode release];
    [[TextureManager shared] unloadMemoryForKey:@"endGame"];
}


@end
