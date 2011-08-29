//
//  InputController.h
//  Clay
//
//  Created by Brian Cable on 8/29/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InputEvent.h"


typedef enum {
    INPUT_TOUCH_PRESSED,
    INPUT_TOUCH_RELEASE,
    INPUT_TOUCH_MOVE,
    INPUT_TOUCH_TAP,
    INPUT_TOUCH_PRESS_AND_HOLD,
    INPUT_TOUCH_MULTITOUCH,
    INPUT_GYRO_SHAKE,
    INPUT_GYRO_TILT,
    INPUT_GESTURE,
    INPUT_TEXT
} InputType;

@interface InputController : NSObject
{
    
}

+(id)inputController;

-(void)interpretAndReactToInputEvent:(InputEvent*)event;




@end
