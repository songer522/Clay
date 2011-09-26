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

@implementation ComicManager

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        _videoPlayer = [VideoPlayer instance];
        _comicLayer = [[ComicLayer alloc] init];
    }
    
    return self;
}

-(void)startComic:(NSString*)comic
{
    
    
}




@end
