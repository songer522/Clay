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
#import "SoundEngine.h"
#import "Camera.h"
#import "HudLayer.h"

@implementation ComicManager

@synthesize gameLayer = _gameLayer;
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
    _comicLayer.parent = self;
    
    _isActive = false;
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
    _phase = phase;
    if (_isActive) {
        switch (phase) {
            case COMIC_PHASE_BARS_IN:
                [_comicLayer startTransition:BLACKBOX_IN];
                [[SoundEngine shared] cueFadeOut];
                _gameLayer.gameController.isInputEnabled = false;
                [Camera sharedCamera].trackingTarget = false;
                [[_gameLayer getHud] fadeOut];
                break;
            case COMIC_PHASE_PLAY_VIDEO:
                _gameLayer.visible = false;
                [_videoPlayer playMovie:_videoFileName];
                [[CCDirector sharedDirector] stopAnimation];
                break;
            case COMIC_PHASE_BARS_OUT:
                if(_loadNextLevel) { [[LevelManager shared] loadNextLevel]; }
                [Camera sharedCamera].trackingTarget = false;
                [[Camera sharedCamera] snapToTarget];
                [[SoundEngine shared] cueFadeIn];
                if(_loadNextLevel)
                {
                    [[LevelManager shared] switchToNextLevel];
                    [_gameLayer initForLevel];
                    _gameLayer.visible = true;
                }
                [[CCDirector sharedDirector] startAnimation];
                
                [_comicLayer startTransition:BLACKBOX_OUT];
                _gameLayer.gameController.isInputEnabled = false;
                [[_gameLayer getHud] fadeIn];
                break;
            case COMIC_PHASE_PLAY_LEVEL:
                _gameLayer.gameController.isInputEnabled = true;
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

@end
