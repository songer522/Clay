//
//  ContinueGameManager.m
//  Clay
//
//  Created by Brian Cable on 12/12/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "ContinueGameManager.h"
#import "GameSettings.h"

@implementation ContinueGameManager

+(bool)isAbleToContinueGame
{
    if (![[self getContinueGameDifficulty] isEqualToString:@""] && ![[self getContinueGameLevel] isEqualToString:@""])
    {
        return true;
    }
        
    return false;
}

+(NSString*)getContinueGameDifficulty
{
    NSString *difficulty = [[GameSettings shared] getGlobalForKey:@"storyModeDifficulty"];
    
    if ([difficulty isEqualToString:@"easy"] || [difficulty isEqualToString:@"medium"] || [difficulty isEqualToString:@"hard"]) {
        return [NSString stringWithString:difficulty];
    }
    
    return @"";
}

+(NSString*)getContinueGameLevel
{
    NSString *level = [[GameSettings shared] getGlobalForKey:@"storyModeCurrentLevel"];

    
    NSLog(@"SUBSTRING: %@",[level substringToIndex:5]);
    
    if ([[level substringToIndex:5] isEqualToString:@"level"] && [[level substringFromIndex:5] intValue] > 0) {
        return [NSString stringWithString:level];        
    }
    
    return @"";
    
}


@end
