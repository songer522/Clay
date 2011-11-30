//
//  BestTimes.m
//  Clay
//
//  Created by Brian Cable on 11/28/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "BestTimes.h"
#import "Database.h"
#import "GameSettings.h"

@implementation BestTimes


static BestTimes *_shared = nil;

+(BestTimes*)shared
{
	if (!_shared) {
        _shared = [[self alloc] init];
	}
	return _shared;
}

-(id)init
{
    if ((self=[super init])) {
        _bestTimeData = [[NSMutableDictionary alloc] initWithCapacity:20];
        NSDictionary *levelData = loadData(@"levelData");
        if(levelData!=nil) {
            NSLog(@"dictionary loaded");
            _bestTimeData = [[NSMutableDictionary alloc] initWithDictionary:levelData];
        }
    }
    return self;
}

-(float)getBestTimeForLevelNumber:(int)number
{
    NSString *levelName = [NSString stringWithFormat:@"level%d",number];
    NSString *difficulty = [[GameSettings shared] getGlobalForKey:@"gameDifficulty"];
    float time = [self getBestTimeForLevelName:levelName forDifficulty:difficulty];
    return time;
}

-(void)reportTime:(float)time forLevel:(NSString*)levelName forDifficulty:(NSString*)difficulty;
{
    float currentBestTime = [self getBestTimeForLevelName:levelName forDifficulty:difficulty];
    if ((time > 0.0f && time < currentBestTime) || currentBestTime == 0.0f) {
        [self storeNewBestTime:time forLevelNamed:levelName forDifficulty:difficulty];
    }
}

-(float)getBestTimeForLevelName:(NSString*)name forDifficulty:(NSString*)difficulty
{
    NSString *key = [NSString stringWithFormat:@"%@%@",difficulty,name];
    float time = [[_bestTimeData objectForKey:key] floatValue];
    return time;
}

-(void)storeNewBestTime:(float)time forLevelNamed:(NSString*)levelName forDifficulty:(NSString*)difficulty
{
    NSString *key = [NSString stringWithFormat:@"%@%@",difficulty,levelName];
    NSString *timeString = [NSString stringWithFormat:@"%f",time];
    [_bestTimeData setObject:timeString forKey:key];
}

-(void)saveData
{
    saveData(_bestTimeData, @"levelData");
}

@end
