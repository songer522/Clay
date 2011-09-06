//
//  TimeEquation.h
//  Clay
//
//  Created by Brian Cable on 8/25/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//
//  This class is used in order to do programmatic animations based on equations.
//  The class can be given time to add to its running total, and then use that as the X
//  value to calculate and return the value of whatever equation it's set to do.
//  
//  For example, you can use this to give back a logarithmic value over time, which can be used
//  to give a value a quick movement, with slower and slower growth afterwards. I've seen this used
//  in the speeds of cars, where cars can accelerrate really fast at first, but eventually accelerate
//  slower and slower until it reaches their max speed. This class can be used to duplicate that
//  result.
//

#import <Foundation/Foundation.h>

typedef enum {
    kLogX,
    kSinX
} EquationType;

@interface TimeEquation : NSObject
{
    float _totalTime;               //the total amount of time given to the class so far
    float _multipleAmount;          //how much to multiply the equation by
}

#pragma mark - public methods

-(void) setTimeMultiplier:(float)multiple;
//set the multiplier for the time-based equations


-(void) addTime:(float)dt;
//add the given amount of time to the total

-(float) calculate:(EquationType)equation;
//


@end
