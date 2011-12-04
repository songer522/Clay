//
//  CCXAnimate.m
//  Clay
//
//  Created by Brian Cable on 9/21/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "CCXAnimate.h"
#import "cocos2d.h"

@implementation CCXAnimate

@synthesize frame = _frame;
@synthesize paused = _paused;
@synthesize totalFrames = _totalFrames;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void)update:(ccTime)t
{
    if (_paused) { return; }
    
    NSArray *frames = [animation_ frames];
    NSUInteger numberOfFrames = [frames count];
    
    _totalFrames = numberOfFrames;
    
    NSUInteger idx = t * numberOfFrames;
    
    if (idx >= numberOfFrames) {
        idx = numberOfFrames - 1;
    }
    
    _frame = idx;
    
    CCSprite *sprite = target_;
    if (![sprite isFrameDisplayed:[frames objectAtIndex:idx]]) {
        [sprite setDisplayFrame:[frames objectAtIndex:idx]];
    }
}

-(void)setFrame:(int)frame
{
    CCSprite *sprite = target_;
    
    NSArray *frames = [animation_ frames];
    
    if(![sprite isFrameDisplayed:[frames objectAtIndex:frame]]) {
        [sprite setDisplayFrame:[frames objectAtIndex:frame]];
        _frame = frame;
    }
}

-(void)dealloc
{
    [super dealloc];
}

@end
