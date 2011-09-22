//
//  Trigger.h
//  Clay
//
//  Created by Brian Cable on 9/22/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    TRIGGER_CHECKPOINT,
    TRIGGER_NEXTLEVEL
}TriggerType;

@interface Trigger : NSObject
{
    CGPoint _position;
    CGPoint _direction;
    TriggerType _type;
}

@property(nonatomic,assign) CGPoint position;
@property(nonatomic,assign) CGPoint direction;
@property(nonatomic,assign) TriggerType type;

@end
