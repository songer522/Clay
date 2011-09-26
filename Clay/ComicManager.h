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

@interface ComicManager : NSObject
{
    VideoPlayer *_videoPlayer;
    NSDictionary *_videoList;
    ComicLayer *_comicLayer;
}

-(void)startComic:(NSString*)comic;



@end
 