//
//  MapLayer.h
//  Clay
//
//  Created by Brian Cable on 10/17/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface MapLayer : NSObject
{
    CCTMXLayer *_layer;
    CGPoint _ratio;
}

+(id)instance;

@property(nonatomic,assign) CGPoint ratio;
@property(nonatomic,retain) CCTMXLayer *layer;

@end
