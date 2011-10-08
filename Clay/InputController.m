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
            [receiver reactToTouchAt:event.touchLocation InputType:INPUT_TOUCH_PRESSED];
            [self schedule:@selector(reactMediumHold) interval:0.15f];
            [self schedule:@selector(reactLongHold) interval:0.3f];
            break;
        case INPUT_EVENT_TYPE_TOUCHES_MOVED:
            /*
            //if they've moved their finger enough, they didn't 
            if (ccpDistance(event.touchLocation, _inputBeganEvent.touchLocation) > 5.0f) {
                [self unschedule:@selector(reactMediumHold)];
                [self unschedule:@selector(reactLongHold)];
            }*/
            break;
        case INPUT_EVENT_TYPE_TOUCHES_ENDED:
            [receiver reactToTouchAt:event.touchLocation InputType:INPUT_TOUCH_END];
            [self unschedule:@selector(reactMediumHold)];
            [self unschedule:@selector(reactLongHold)];
            break;
        default:
            break;
    }
}

-(void)reactMediumHold
{
    GameController *receiver = (GameController*)_inputBeganEvent.receiver;
    [receiver reactToTouchAt:_inputBeganEvent.touchLocation InputType:INPUT_TOUCH_HOLD_MEDIUM];
    [self unschedule:@selector(reactMediumHold)];
}

-(void)reactLongHold
{
    GameController *receiver = (GameController*)_inputBeganEvent.receiver;
    [receiver reactToTouchAt:_inputBeganEvent.touchLocation InputType:INPUT_TOUCH_HOLD_LONG];
    NSLog(@"BEHOLD! IT'S THE LONG JUMP!");
    [self unschedule:@selector(reactLongHold)];
}

-(void)dealloc
{
    [_inputBeganEvent release];
    [super dealloc];
}


@end
