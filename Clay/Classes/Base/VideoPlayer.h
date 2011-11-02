//
//  VideoPlayer.h
//  Clay
//
//  Created by Brian Cable on 9/26/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//
//  Simple wrapper for the CCVideoPlayer extension. So far only stores a few settings.

//TODO: Right now there's a major bug with CCVideoPlayer which we need to fix (see Github issue #59).

#import <Foundation/Foundation.h>
#import "CCVideoPlayer.h"
#import <MediaPlayer/MediaPlayer.h>

@class ComicManager;

@interface VideoPlayer : NSObject <CCVideoPlayerDelegate>
{
    ComicManager *_parent;
}

@property(nonatomic,retain) ComicManager *parent;

+(id)instance;

+(void)playMovie:(NSString*)file;
-(void)playMovie:(NSString*)file;

@end
