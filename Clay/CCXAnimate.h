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
}

@property(nonatomic,assign) int frame;

-(void)update:(ccTime)t;

@end
