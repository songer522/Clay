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
    }
    
    return self;
}

-(void)startComic:(NSString*)comic
{
    [_comicLayer startTransition:BLACKBOX_IN];
    _gameLayer.gameController.isInputEnabled = false;
    _phase = COMIC_PHASE_BARS_IN;
}


-(void)finishedAction
{
    switch (_phase) {
        case COMIC_PHASE_BARS_IN:
            //[_gameLayer onExit];
            [[CCDirector sharedDirector] stopAnimation];
            [_videoPlayer playMovie:@"bait.m4v"];
            _phase = COMIC_PHASE_PLAY_VIDEO;
            break;
        case COMIC_PHASE_PLAY_VIDEO:
            //[_gameLayer onEnter];
            [[CCDirector sharedDirector] startAnimation];
            [_comicLayer startTransition:BLACKBOX_OUT];
            _phase = COMIC_PHASE_BARS_OUT;
        case COMIC_PHASE_BARS_OUT:
            _gameLayer.gameController.isInputEnabled = true;
            _phase = COMIC_PHASE_PLAY_LEVEL;
        default:
            break;
    }
}

@end
