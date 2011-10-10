//
//  CCXAnimate.h
//  Clay
//
//  Created by Brian Cable on 9/21/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "CCActionInterval.h"

@interface CCXAnimate : CCAnimate
{
    int _frame;
    int _totalFrames;
    bool _paused;
}

@property(nonatomic,assign) int frame;
@property(nonatomic,assign) bool paused;
@property(nonatomic,readonly,assign) int totalFrames;

-(void)update:(ccTime)t;

@end
