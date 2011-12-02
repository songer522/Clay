//
//  RainyLevelEffects.h
//  Clay
//
//  Created by Brian Cable on 11/30/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Trigger.h"

@class Sprite;
@class Lightning;

@interface RainyLevelEffects : NSObject
{
    NSMutableArray *_raindrops;
    
    Sprite *_rainBehindTim;
    
    Lightning *_lightning;
    
    float _windDuration;
}

+(id)instance;
-(void)update:(float)dt;

-(void)triggerWind:(TriggerType)duration;
-(void)updateWind:(float)dt;

@end
