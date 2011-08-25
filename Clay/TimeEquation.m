//
//  TimeEquation.m
//  Clay
//
//  Created by Brian Cable on 8/25/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "TimeEquation.h"

@implementation TimeEquation

-(id) init
{
    if((self=[super init])) {
        _totalTime = 0;
    }
    return self;
}

-(void) addTime:(float)dt
{
    _totalTime += dt;
}

-(void) setTimeMultiplier:(float)multiple
{
    _multipleAmount = multiple;
}

//calculates the current state of the equation
//param: multiplyTimeAmount - value to multiply the time by during the equation
-(float) calculate:(EquationType)equation
{
    float returnVal = 0;
    
    float multipliedTime = _totalTime * _multipleAmount;
    
    switch (equation) {
        case kLogX:
            returnVal = logf(multipliedTime);
            break;
        case kSinX:
            returnVal = sinf(multipliedTime);
            break;
        default:
            break;
    }
    
    return returnVal;
}

@end
