//
//  Calculator.m
//  Clay
//
//  Created by Brian Cable on 12/9/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "Calculator.h"

@implementation Calculator

+(float) increaseFloat:(float)variable byAmount:(float)amount untilAtMax:(float)max
{
    variable += amount;
    if (variable >= max) {
        variable = max;
    }

    return variable;
}

+(float) decreaseFloat:(float)variable byAmount:(float)amount untilAtMin:(float)min
{
    variable -= amount;
    if (variable <= min) {
        variable = min;
    }
    
    return variable;
}


+(float) modifyFloat:(float)variable towardsTargetValue:(float)target atSpeed:(float)speed
{
    if (variable<target) {
        variable = [Calculator increaseFloat:variable byAmount:speed untilAtMax:target];
    } else if(variable>target){
        variable = [Calculator decreaseFloat:variable byAmount:speed untilAtMin:target];
    }
    
    return variable;
}

@end
