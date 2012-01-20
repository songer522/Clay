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
@synthesize looping = _looping;
@synthesize totalFrames = _totalFrames;


+(id) actionWithAnimation: (CCAnimation*)anim restoreOriginalFrame:(BOOL)b
{
	return [[[self alloc] initWithAnimation:anim restoreOriginalFrame:b] autorelease];
}

-(id) initWithAnimation: (CCAnimation*)anim restoreOriginalFrame:(BOOL) b
{
	NSAssert( anim!=nil, @"Animate: argument Animation must be non-nil");
    
	if( (self=[super initWithAnimation:anim restoreOriginalFrame:b]) ) {
        _totalTime = 0.0f;
        _speed = 1.0f;
        _frame = -1;
        _looping = false;
	}
	return self;
}

-(void)update:(ccTime)t
{
    if (_paused) { return; }
    
    NSArray *frames = [animation_ frames];
    NSUInteger numberOfFrames = [frames count];

    _totalFrames = numberOfFrames;
    
    //NSUInteger idx = t * _speed * numberOfFrames;
    NSUInteger idx = t * numberOfFrames;
    
    if (idx >= numberOfFrames) {
        idx = numberOfFrames - 1;
    }
    
    
    CCSprite *sprite = target_;
    
    
    if(_looping) {
        //this optimization seems to work only with looping
        if (idx!=_frame) {
            [sprite setDisplayFrame:[frames objectAtIndex:idx]];
        }
    } else {
        if (![sprite isFrameDisplayed:[frames objectAtIndex:idx]]) {
            [sprite setDisplayFrame:[frames objectAtIndex:idx]];            
        }
    }
    
    _frame = idx;
    
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

-(int)getCurrentFrame
{
    return _frame;
}

-(void)changeSpeed:(float)speed
{
    _speed = speed;
}

-(void)dealloc
{
    [super dealloc];
}

@end
