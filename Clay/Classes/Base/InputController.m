//
//  InputController.m
//  Clay
//
//  Created by Brian Cable on 8/29/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "InputController.h"
#import "GameController.h"

@implementation InputController

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+(id)inputController
{
    return [[self alloc] init];
}


-(void)interpretAndReactToInputEvent:(InputEvent*)event
{
    GameController *receiver = (GameController*)event.receiver;
    
    switch (event.type) {
        case INPUT_EVENT_TYPE_TOUCHES_BEGAN:
            _inputBeganEvent = event;
            [receiver reactToTouchAt:event.touchLocation InputType:INPUT_TOUCH_PRESSED TouchCount:event.totalTouches];
            [self schedule:@selector(reactMediumHold) interval:0.2f];
            break;
        case INPUT_EVENT_TYPE_TOUCHES_MOVED:
            break;
        case INPUT_EVENT_TYPE_TOUCHES_ENDED:
            [receiver reactToTouchAt:event.touchLocation InputType:INPUT_TOUCH_END TouchCount:event.totalTouches];
            [self unschedule:@selector(reactMediumHold)];
            break;
        default:
            break;
    }
}

-(void)reactMediumHold
{
    GameController *receiver = (GameController*)_inputBeganEvent.receiver;
    [receiver reactToTouchAt:_inputBeganEvent.touchLocation InputType:INPUT_TOUCH_HOLD_MEDIUM TouchCount:_inputBeganEvent.totalTouches];
    [self unschedule:@selector(reactMediumHold)];
}

-(void)dealloc
{
    [_inputBeganEvent release];
    [super dealloc];
}


@end
