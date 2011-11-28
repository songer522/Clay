//
//  BestTimes.m
//  Clay
//
//  Created by Brian Cable on 11/28/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "BestTimes.h"

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
        //_settings = [[NSMutableDictionary alloc] initWithCapacity:30];
        //[self loadFromSettingsPlist];
    }
    return self;
}

@end
