//
//  InputEvent.h
//  Clay
//
//  Created by Brian Cable on 8/29/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//
//  A data structure for holding the interpreted touch data from the InputController to be passed to the receiver.

#import <Foundation/Foundation.h>

typedef enum {
    INPUT_EVENT_TYPE_TOUCHES_BEGAN,
    INPUT_EVENT_TYPE_TOUCHES_ENDED,
    INPUT_EVENT_TYPE_TOUCHES_MOVED
} InputEventType;

@interface InputEvent : NSObject
{
    InputEventType _eventType;
    CGPoint _touchLocation;
    float _timeOfEvent;
    id _receiver;
}

@property(nonatomic,assign) InputEventType type;
@property(nonatomic,assign) CGPoint touchLocation;
@property(nonatomic,assign) float timeOfEvent;
@property(nonatomic,retain) id receiver;

+(id) inputEventWithType:(InputEventType)type;

@end
