//
//  Utilities.m
//  Clay
//
//  Created by Brian Cable on 8/30/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

+(bool)clampFloatMax:(float)max Value:(float*)value
{
    bool returnVal = false;
    if (*value >= max) {
        *value = max;
        returnVal = true;
    }
    return returnVal;
}

+(bool)clampFloatMin:(float)min Value:(float*)value
{
    bool returnVal = false;
    if (*value <= min) {
        *value = min;
        returnVal = true;
    }
    return returnVal;
}


@end
