//
//  VideoPlayer.m
//  Clay
//
//  Created by Brian Cable on 9/26/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "VideoPlayer.h"
#import "ComicManager.h"
#import "CCVideoPlayer.h"

@implementation VideoPlayer

@synthesize parent = _parent;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+(id)instance
{
    return [[self alloc] init];
}


+(void)playMovie:(NSString*)file
{
    [self playMovie:file];
}

-(void)playMovie:(NSString*)file
{
    [CCVideoPlayer setDelegate:self];
    [CCVideoPlayer setNoSkip:false];
    [CCVideoPlayer playMovieWithFile:file];
}

-(void)moviePlaybackFinished
{
    [_parent finishedAction];
}

-(void)movieStartsPlaying
{
    
}


@end
