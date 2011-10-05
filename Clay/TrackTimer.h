//
//  Stopwatch.h
//  Clay
//
//  Created by Brian Cable on 10/5/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface TrackTimer : NSObject
{
    CCLabelTTF *_lowerDisplay;
    CCLabelTTF *_upperDisplay;

    float _totalTime;
    bool _isStopped;
}

+(TrackTimer*) instance;

-(void)update:(float)dt;

-(NSString*)getTimeString;

@end
