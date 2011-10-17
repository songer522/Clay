//
//  MapLayer.m
//  Clay
//
//  Created by Brian Cable on 10/17/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "MapLayer.h"

@implementation MapLayer

@synthesize layer = _layer;
@synthesize ratio = _ratio;

+(id)instance
{
    return [[self alloc] init];
}

-(id)init
{
    if ((self = [super init])) {
        //initialize
    }
    return self;
}

@end
