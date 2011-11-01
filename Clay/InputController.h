//
//  InputController.h
//  Clay
//
//  Created by Brian Cable on 8/29/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InputEvent.h"
#import "cocos2d.h"

typedef enum {
    INPUT_TOUCH_PRESSED,
    INPUT_TOUCH_RELEASE,
    INPUT_TOUCH_END,
    INPUT_TOUCH_MOVE,
    INPUT_TOUCH_TAP,
    INPUT_TOUCH_HOLD_MEDIUM,
    INPUT_TOUCH_HOLD_LONG,
    INPUT_TOUCH_MULTITOUCH,
    INPUT_GYRO_SHAKE,
    INPUT_GYRO_TILT,
    INPUT_GESTURE,
    INPUT_TEXT
} InputType;

@interface InputController : CCNode
{
    InputEvent *_inputBeganEvent;
    
}

+(id)inputController;

-(void)interpretAndReactToInputEvent:(InputEvent*)event;

-(void)reactMediumHold;


@end
