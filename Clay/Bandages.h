//
//  Bandages.h
//  Clay
//
//  Created by Brian Cable on 9/21/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class Sprite;
@class Player;

@interface Bandages : NSObject
{
    Sprite *sprite;
    int _currentFrame;
    float _totalTime;
    float _wait;
    float _alpha;
    bool _isRecharging;
}

+(id)instance;

-(void) setFrame:(int)frameNumber;
-(void)update:(float)dt;

-(void)recharging:(float)dt;
-(void)lowBatteryWarning:(float)dt;
-(void)normalBattery:(float)dt;

-(void)startRecharge;

-(CCSprite*)getCCSprite;
-(void)reset;


@end
