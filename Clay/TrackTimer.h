//
//  TrackTimer.h
//  Clay
//
//  Created by Brian Cable on 10/10/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TrackTimer : NSObject
{
    NSMutableArray *_timerAnimations;
    
    float _totalTime;
    bool _isStopped;
}

@property(nonatomic,assign) bool isStopped;

+(TrackTimer*) instance;

-(void)update:(float)dt;

-(void)setupAnimations;

-(void)setTimerSprites;

-(void)setSpriteAtIndex:(int)index withNumber:(int)number;

-(void)setOpacity:(int)opacity;

@end
