//
//  Calculator.h
//  Clay
//
//  Created by Brian Cable on 12/9/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Calculator : NSObject

+(float) increaseFloat:(float)variable byAmount:(float)amount untilAtMax:(float)max;
+(float) decreaseFloat:(float)variable byAmount:(float)amount untilAtMin:(float)min;
+(float) modifyFloat:(float)variable towardsTargetValue:(float)target atSpeed:(float)speed;

@end
