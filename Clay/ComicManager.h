//
//  ComicManager.h
//  Clay
//
//  Created by Brian Cable on 9/26/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class VideoPlayer;
@class ComicLayer;
@class GameLayer;

typedef enum {
    COMIC_PHASE_BARS_IN,
    COMIC_PHASE_PLAY_VIDEO,
    COMIC_PHASE_LOAD_LEVEL,
    COMIC_PHASE_BARS_OUT,
    COMIC_PHASE_PLAY_LEVEL
}ComicPhase;

@interface ComicManager : NSObject
{
    bool _isActive;
    
    GameLayer *_gameLayer;
    VideoPlayer *_videoPlayer;
    NSDictionary *_videoList;
    ComicLayer *_comicLayer;
    
    ComicPhase _phase;
    
    NSString *_videoFileName;
}

+(id)instance;

-(void)startComic:(NSString*)comic;

-(void)finishedAction;

@end
 