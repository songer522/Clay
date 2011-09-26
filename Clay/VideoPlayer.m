//
//  VideoPlayer.m
//  Clay
//
//  Created by Brian Cable on 9/26/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "VideoPlayer.h"

@implementation VideoPlayer

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


+(void)playMovie:(NSString*)url
{
    MPMoviePlayerController *moviePlayer = [[MPMoviePlayerController alloc]
                                      initWithContentURL:[NSURL URLWithString:url]];
    [moviePlayer play];
}

@end
