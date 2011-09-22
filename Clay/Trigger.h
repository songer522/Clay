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
    TRIGGER_NEXTLEVEL,
    TRIGGER_SPAWNPOINT
}TriggerType;

@interface Trigger : NSObject
{
    bool _triggered;
    CGPoint _position;
    CGPoint _direction;
    TriggerType _type;
}

@property(nonatomic,assign) bool triggered;
@property(nonatomic,assign) CGPoint position;
@property(nonatomic,assign) CGPoint direction;
@property(nonatomic,assign) TriggerType type;

@end
