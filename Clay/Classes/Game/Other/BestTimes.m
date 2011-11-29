//
//  BestTimes.m
//  Clay
//
//  Created by Brian Cable on 11/28/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "BestTimes.h"
#import "Database.h"

@implementation BestTimes


static BestTimes *_shared = nil;

+(BestTimes*)shared
{
	if (!_shared) {
        _shared = [[self alloc] init];
        NSDictionary *levelData = loadData(@"levelData");
        if(levelData!=nil) {
            NSLog(@"dictionary loaded");
        }
	}
	return _shared;
}

-(id)init
{
    if ((self=[super init])) {
        _bestTimeData = [[NSMutableDictionary alloc] initWithCapacity:20];        
    }
    return self;
}

-(void)reportTime:(float)time forLevel:(NSString*)levelName
{
    float currentBestTime = [self getBestTimeForLevelName:levelName];
    if (time < currentBestTime) {
        [self storeNewBestTime:time forLevelNamed:levelName];
    }
}

-(float)getBestTimeForLevelName:(NSString*)name
{
    float time = [[_bestTimeData objectForKey:name] floatValue];;
    return time;
}

-(void)storeNewBestTime:(float)time forLevelNamed:(NSString*)levelName
{
    NSString *timeString = [NSString stringWithFormat:@"%f",time];
    [_bestTimeData setObject:timeString forKey:levelName];
}

@end
