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
    if (!_isActive) {
        id result = [_videoList objectForKey:comic];
        
        NSAssert([result isKindOfClass:[NSString class]],@"Result is not a string or is null. Verify what you're asking for is in the plist.");

        _videoFileName = result;
        _isActive = true;
        [_comicLayer startTransition:BLACKBOX_IN];
        _gameLayer.gameController.isInputEnabled = false;
        _phase = COMIC_PHASE_BARS_IN;
    }
}


-(void)finishedAction
{
    if (_isActive) {
        switch (_phase) {
            case COMIC_PHASE_BARS_IN:
                [_videoPlayer playMovie:_videoFileName];
                [[CCDirector sharedDirector] stopAnimation];
                _phase = COMIC_PHASE_PLAY_VIDEO;
                break;
            case COMIC_PHASE_PLAY_VIDEO:
                [[CCDirector sharedDirector] startAnimation];
                [_comicLayer startTransition:BLACKBOX_OUT];
                _phase = COMIC_PHASE_BARS_OUT;
            case COMIC_PHASE_BARS_OUT:
                _gameLayer.gameController.isInputEnabled = true;
                _phase = COMIC_PHASE_PLAY_LEVEL;
                _isActive = false;
            default:
                break;
        }        
    }
}

@end
