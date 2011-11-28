//
//  ComicManager.m
//  Clay
//
//  Created by Brian Cable on 9/26/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "ComicManager.h"
#import "ComicLayer.h"
#import "VideoPlayer.h"
#import "LevelManager.h"
#import "GameLayer.h"
#import "GameController.h"
#import "PListLoader.h"
#import "Player.h"
#import "SoundEngine.h"
#import "Camera.h"
#import "HudLayer.h"
#import "EndGameScene.h"
#import "GameSettings.h"
#import "TrackTimer.h"
#import "Appirater.h"

@implementation ComicManager

@synthesize loadNextLevel = _loadNextLevel;
@synthesize isActive = _isActive;

static ComicManager *_shared = nil;

+(ComicManager*)shared
{
	if (!_shared) {
        _shared = [[self alloc] init];
	}
	return _shared;
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
    }
    
    return self;
}

-(void)preload
{
    _videoPlayer = [VideoPlayer instance];
    _videoPlayer.parent = self;
    
    _comicLayer = [ComicLayer instance];
    _comicLayer.comicManager = self;
    
    _isActive = false;
    _showEndGame = false;
    _loadNextLevel = false;
    
    _videoList = [[NSDictionary alloc] initWithDictionary:[PListLoader loadPlistWithName:@"comics"]];    
}


-(void)startComic:(NSString*)comic
{
    [self startComic:comic StartPhase:COMIC_PHASE_BARS_IN];
}

-(void)startComic:(NSString*)comic StartPhase:(ComicPhase)phase
{
    if (!_isActive) {
        id result = [_videoList objectForKey:comic];
        
        NSAssert([result isKindOfClass:[NSString class]],@"Result is not a string or is null. Verify what you're asking for is in the plist.");

        
        _videoFileName = result;
        
        
        _introMovie = false;
        if ([_videoFileName compare:@"endGame"] == NSOrderedSame) {
            _showEndGame = true;            
        }
        
        _isActive = true;
        
        [self switchToPhase:phase];
    }
}

-(void)update:(ccTime)dt
{
    [_comicLayer update:dt];
}

-(void)switchToPhase:(ComicPhase)phase
{
    GameLayer *gameLayer = (GameLayer*)[[LayerManager sharedLayers] currentLayer];
    
    _phase = phase;
    if (_isActive) {
        switch (phase) {
            case COMIC_PHASE_BARS_IN:
                [_comicLayer startTransition:BLACKBOX_IN];
                [[SoundEngine shared] cueFadeOut];
                gameLayer.gameController.isInputEnabled = false;
                [Camera sharedCamera].trackingTarget = false;
                [gameLayer.player setHasGravity:true];
                [[gameLayer getHud] fadeOut];
                break;
            case COMIC_PHASE_STARTING_VIDEO:
                //basically we need to wait for the scene transition before calling playvideo
                [_comicLayer waitToPlayVideo:1.0f];
                break;
            case COMIC_PHASE_PLAY_VIDEO:
                if (_showEndGame) {
                    [self endTheGame];
                } else {
                    [_videoPlayer playMovie:_videoFileName];
                    [[CCDirector sharedDirector] stopAnimation];
                }
                break;
            case COMIC_PHASE_BARS_OUT:
                if(_loadNextLevel)
                {
                    [[LevelManager shared] loadNextLevel];
                }
                [Camera sharedCamera].trackingTarget = false;
                [[Camera sharedCamera] snapToTarget];
                [[SoundEngine shared] cueFadeIn];
                [gameLayer unpause];
                [gameLayer initForLevel];
                gameLayer.visible = true;
                [[CCDirector sharedDirector] startAnimation];
                
                [_comicLayer startTransition:BLACKBOX_OUT];
                gameLayer.gameController.isInputEnabled = false;
                [[gameLayer getHud] fadeIn];
                break;
            case COMIC_PHASE_PLAY_LEVEL:
                gameLayer.gameController.isInputEnabled = true;
                _phase = COMIC_PHASE_PLAY_LEVEL;
                _isActive = false;
                _loadNextLevel = false;
                break;
            default:
                break;
        }
    }
}

-(void)finishedAction
{
    if (_isActive) {
        switch (_phase) {
            case COMIC_PHASE_BARS_IN:
               // [Appirater appEnteredForeground:YES];
                [self switchToPhase:COMIC_PHASE_PLAY_VIDEO];
                break;
            case COMIC_PHASE_STARTING_VIDEO:
                [self switchToPhase:COMIC_PHASE_PLAY_VIDEO];
                break;
            case COMIC_PHASE_PLAY_VIDEO:
                [self switchToPhase:COMIC_PHASE_BARS_OUT];
                break;
            case COMIC_PHASE_BARS_OUT:
                [self switchToPhase:COMIC_PHASE_PLAY_LEVEL];
            default:
                break;
        }        
    }
}

-(void)resetComicLayer
{
    [_comicLayer resetLayer];
}

-(void)endTheGame
{
    GameLayer *gameLayer = (GameLayer*)[[LayerManager sharedLayers] currentLayer];
    
    //set the final total time for the end game screen
    float finalTime = [[[gameLayer getHud] getTrackTimer] getTime];
    [[GameSettings shared] setGlobal:[NSString stringWithFormat:@"%f", finalTime] ForKey:@"finalTime"];
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[EndGameScene scene]]];
    _showEndGame = false;
    _introMovie = false;
}

-(void)dealloc
{
    [_videoList release];
    [_videoPlayer release];
    [_comicLayer release];
    [_videoFileName release];
    [super dealloc];
}

@end
