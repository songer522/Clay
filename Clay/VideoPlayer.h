//
//  VideoPlayer.h
//  Clay
//
//  Created by Brian Cable on 9/26/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

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
