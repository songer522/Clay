//
//  LaserShow.m
//  Clay
//
//  Created by Brian Cable on 10/21/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "LaserShow.h"
#import "Sprite.h"
#import "Laser.h"

@implementation LaserShow

+(id)instance
{
    return [[self alloc] init];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
        _lasers = [[NSMutableArray alloc] initWithCapacity:4];
        
        for (int i=1; i<5; i++) {
            Laser *laser = [Laser laserWithId:i];
            [_lasers addObject:laser];
        }
    }
    
    return self;
}

-(void)update:(float)dt
{
    for (Laser *laser in _lasers) {
        [laser update:dt];
    }
}

-(void)dealloc
{
    for (Laser *laser in _lasers) {
        [laser release];
    }
    [_lasers removeAllObjects];
    [_lasers release];
    [super dealloc];
}

@end
