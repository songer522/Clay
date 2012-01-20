//
//  CCXAnimate.h
//  Clay
//
//  Created by Brian Cable on 9/21/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//
//  A modification of the cocos CCAnimate class so that the current frame can be checked.

//TODO: add ability to set the current frame of the animation, to make transitions between animations more fluid.

#import "CCActionInterval.h"

@interface CCXAnimate : CCAnimate
{
    int _frame;
    int _totalFrames;
    float _totalTime;
    bool _paused;
    bool _looping;
    float _speed;
}

@property(nonatomic,assign) int frame;
@property(nonatomic,assign) bool paused;
@property(nonatomic,assign) bool looping;
@property(nonatomic,readonly,assign) int totalFrames;

+(id) actionWithAnimation: (CCAnimation*)anim restoreOriginalFrame:(BOOL)b;
-(id) initWithAnimation: (CCAnimation*)anim restoreOriginalFrame:(BOOL) b;

-(void)update:(ccTime)t;
-(void)changeSpeed:(float)speed;
-(int)getCurrentFrame;

@end
