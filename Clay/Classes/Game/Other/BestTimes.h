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
    NSMutableDictionary *bestTimeData;
}

+(BestTimes*)shared;


@end
