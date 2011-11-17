//
//  Battery.h
//  Clay
//
//  Created by Brian Cable on 9/21/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//
//  Displays and handles the battery icon in the HudLayer during the game.
//  The battery represents the users health, and has four segments. It is mostly controlled by the player class and the player action classes, where it can tell the battery that health has been gained or lost based on collisions with obstacles or successful completion of player actions.

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class Sprite;
@class Player;

@interface Battery : NSObject
{
    Sprite *sprite;
    int _currentFrame;
    float _totalTime;
    float _wait;
    float _alpha;
    float _waitToIncrease;
    bool _isRecharging;
    bool _wasLowBattery;
    Player *_player;  //weak
}

@property(nonatomic,retain) Player *parent;

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
