//
//  Trigger.m
//  Clay
//
//  Created by Brian Cable on 9/22/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "Trigger.h"

@implementation Trigger

@synthesize position = _position;
@synthesize direction = _direction;
@synthesize type = _type;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

@end
