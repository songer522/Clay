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
            //below is temporary while i find a better way to do this
            [receiver reactToTouchAt:event.touchLocation];
            break;
            
        default:
            break;
    }
}


-(void)dealloc
{
    
    [super dealloc];
}


@end
