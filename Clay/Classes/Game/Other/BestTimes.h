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

-(void)reportTime:(float)time forLevel:(NSString*)levelName;

-(float)getBestTimeForLevelName:(NSString*)name;
-(void)storeNewBestTime:(float)time forLevelNamed:(NSString*)levelName;

@end
