//
//  Stopwatch.m
//  Clay
//
//  Created by Brian Cable on 10/5/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "TrackTimer.h"
#import "LayerManager.h"

@implementation TrackTimer

+(TrackTimer*) instance
{
    return [[self alloc] init];    
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        _lowerDisplay = [CCLabelTTF labelWithString:@"Time: 00:00:00" fontName:@"Courier" fontSize:14];
        _lowerDisplay.position = ccp(80,290);
        _lowerDisplay.color = ccc3(0, 0, 0);
        
        [[[LayerManager sharedLayers] currentLayer] addChild:_lowerDisplay];
        
        _upperDisplay = [CCLabelTTF labelWithString:@"Time: 00:00:00" fontName:@"Courier" fontSize:14];
        _upperDisplay.position = ccp(79,291);
        _upperDisplay.color = ccc3(255, 255, 255);
        
        [[[LayerManager sharedLayers] currentLayer] addChild:_upperDisplay];
        
        _isStopped = false;
        
    }
    
    return self;
}

-(void)update:(float)dt
{
    if (!_isStopped) {
        _totalTime += dt;

        NSString *timeString = [self getTimeString];
        [_upperDisplay setString:timeString];
        [_lowerDisplay setString:timeString];
    }
}

-(NSString*)getTimeString
{
    int seconds = ((int)floorf(_totalTime)) % 60;
    int minutes = ((int)floorf(_totalTime)) / 60;
    int milliseconds = floor((_totalTime - (int)_totalTime) * 100);
    NSMutableString *time = [NSMutableString stringWithString:@"Time: "];
    if (minutes<10) {
        [time appendString:@"0"];
    }
    [time appendFormat:@"%d:",minutes];
    
    if (seconds<10) {
        [time appendString:@"0"];
    }
    [time appendFormat:@"%d:",seconds];
    
    if (milliseconds<10) {
        [time appendString:@"0"];
    }
    [time appendFormat:@"%d",milliseconds];
    
    return time;
}

-(void)dealloc
{
    [_lowerDisplay release];
    [_upperDisplay release];
    [super dealloc];
}

@end
