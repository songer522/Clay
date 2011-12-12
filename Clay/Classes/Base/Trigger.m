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
@synthesize type = _type;
@synthesize triggered = _triggered;
@synthesize canBeReset = _canBeReset;
@synthesize disabled = _disabled;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        _triggered = false;
        _canBeReset = false;
        _disabled = false;
    }
    
    return self;
}

-(void) dealloc
{
    [super dealloc];
}

@end
