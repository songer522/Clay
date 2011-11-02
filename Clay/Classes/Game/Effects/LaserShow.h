//
//  LaserShow.h
//  Clay
//
//  Created by Brian Cable on 10/21/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//
//  For the disco level, this is displayed as a layer over the level. Note: currently the LevelManager and GameLayer keeps track of this information, but eventually we should have per level classes to allow for special extras such as this (probably).

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface LaserShow : NSObject
{
    NSMutableArray *_lasers;
}


+(id)instance;
-(void)update:(float)dt;

@end
