//
//  InputEvent.m
//  Clay
//
//  Created by Brian Cable on 8/29/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "InputEvent.h"

@implementation InputEvent

@synthesize touchLocation = _touchLocation;
@synthesize timeOfEvent = _timeOfEvent;
@synthesize receiver = _receiver;
@synthesize type = _eventType;
@synthesize totalTouches = _totalTouches;

- (id)init
{
    self = [super init];
    if (self) {
        //defaults
        _touchLocation = CGPointMake(0, 0);
        _timeOfEvent = 0;
        _receiver = nil;
        _eventType = INPUT_EVENT_TYPE_TOUCHES_BEGAN;
    }
    
    return self;
}

-(id) initInputEventWithType:(InputEventType)type
{
    if ((self=[self init])) {
        _eventType = type;
    }
    return self;
}

+(id) inputEventWithType:(InputEventType)type
{
    return [[self alloc] initInputEventWithType:type];
}

-(void)dealloc
{
    _receiver = nil;
    [super dealloc];
}

@end
