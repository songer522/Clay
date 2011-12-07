//
//  TrackTimer.h
//  Clay
//
//  Created by Brian Cable on 10/10/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//
//  The track timer displayed on both the Hud and at the end of the game.

#import <Foundation/Foundation.h>

@interface TrackTimer : NSObject
{
    NSMutableArray *_timerAnimations;
    
    float _totalTime;
    float _totalTimeBeforeLevel;
    float _levelTime;
    bool _isStopped;
}

@property(nonatomic,assign) bool isStopped;

+(TrackTimer*) instance;

-(void)update:(float)dt;

-(void)setTimerSprites;

-(void)setSpriteAtIndex:(int)index withNumber:(int)number;

-(void)setOpacity:(int)opacity;

-(void)setTime:(float)time;
-(float)getTime;

-(void)setAlpha:(float)alpha;

-(void)startLevel;
-(float)getLevelTime;

-(void)restartLevel;

+(NSString*)getTimeStringFromFloat:(float)time;

-(void)setupAnimationsAtX:(float)x Y:(float)y;

@end
