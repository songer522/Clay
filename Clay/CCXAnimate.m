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
    
}

-(void)dealloc
{
    [super dealloc];
}

@end
