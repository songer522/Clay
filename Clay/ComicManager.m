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

@implementation ComicManager

@synthesize gameLayer = _gameLayer;

+(id)instance
{
    return [[self alloc] init];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        _videoPlayer = [VideoPlayer instance];
        _videoPlayer.parent = self;
        
        _comicLayer = [ComicLayer instance];
        _comicLayer.parent = self;
        
        _isActive = false;
        
        _videoList = [[NSDictionary alloc] initWithDictionary:[PListLoader loadPlistWithName:@"comics"]];
    }
    
    return self;
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

-(void)switchToPhase:(ComicPhase)phase
{
    _phase = phase;
    if (_isActive) {
        switch (phase) {
            case COMIC_PHASE_BARS_IN:
                [_comicLayer startTransition:BLACKBOX_IN];
                _gameLayer.gameController.isInputEnabled = false;
                break;
            case COMIC_PHASE_PLAY_VIDEO:
                [_videoPlayer playMovie:_videoFileName];
                [[CCDirector sharedDirector] stopAnimation];
                break;
            case COMIC_PHASE_BARS_OUT:
                [[CCDirector sharedDirector] startAnimation];
                [_comicLayer startTransition:BLACKBOX_OUT];
                _gameLayer.gameController.isInputEnabled = false;
                break;
            case COMIC_PHASE_PLAY_LEVEL:
                _gameLayer.gameController.isInputEnabled = true;
                _phase = COMIC_PHASE_PLAY_LEVEL;
                _isActive = false;
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
