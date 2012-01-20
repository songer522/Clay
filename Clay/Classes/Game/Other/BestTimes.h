//
//  BestTimes.h
//  Clay
//
//  Created by Brian Cable on 11/28/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BestTimes : NSObject
{
    NSMutableDictionary *_bestTimeData;
}

+(BestTimes*)shared;

-(void)reportTime:(float)time forLevel:(NSString*)levelName forDifficulty:(NSString*)difficulty;

-(float)getBestTimeForLevelName:(NSString*)name forDifficulty:(NSString*)difficulty;

-(float)getBestTimeForLevelNumber:(int)number;

-(void)storeNewBestTime:(float)time forLevelNamed:(NSString*)levelName forDifficulty:(NSString*)difficulty;

-(void)saveData;

@end
