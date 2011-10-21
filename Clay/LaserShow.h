//
//  LaserShow.h
//  Clay
//
//  Created by Brian Cable on 10/21/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface LaserShow : NSObject
{
    NSMutableArray *_lasers;
}


+(id)instance;
-(void)update:(float)dt;

@end
