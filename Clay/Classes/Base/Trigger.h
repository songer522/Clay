//
//  Trigger.h
//  Clay
//
//  Created by Brian Cable on 9/22/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//
//  A trigger for special events in the game, placed within the Tiled maps. So far, only three types supported: checkpoints, a trigger for switching to the next level, and spawn point for the player (which must always be 4,12 in the map or some things get positioned incorrectly). Supports triggering when the player has gone past a certain point in a given direction. Probably more complicated than it needs to be now. Originally this was designed for Tim to go any direction.

#import <Foundation/Foundation.h>

typedef enum {
    TRIGGER_CHECKPOINT,
    TRIGGER_NEXTLEVEL,
    TRIGGER_SPAWNPOINT,
    TRIGGER_BOSS_SHOOT,
    TRIGGER_WIND_SHORT,
    TRIGGER_WIND_MEDIUM,
    TRIGGER_WIND_LONG,
    TRIGGER_BOSS_FINALJIM_SPAWN,
    TRIGGER_SHIP_SHOOT_MEGACANNON,
    TRIGGER_SHIP_SHOOT_COMBO,
    TRIGGER_SHIP_ENTER,
    TRIGGER_SHIP_EXIT,
    TRIGGER_FINAL_BOSS_ENTER,
    TRIGGER_FINAL_BOSS_EXITS,
    TRIGGER_FINAL_BOSS_DIE,
    TRIGGER_FINAL_BOSS_ATTACK1,
    TRIGGER_FINAL_BOSS_ATTACK2,
    TRIGGER_FINAL_BOSS_ATTACK3,
    TRIGGER_FINAL_BOSS_ATTACK4
}TriggerType;

@interface Trigger : NSObject
{
    bool _triggered; //whether the trigger has been set off yet
    
    CGPoint _position;
    TriggerType _type;
    
    bool _canBeReset; //whether a trigger can normally be reset in the level
    bool _disabled; //means cannot be reset unless the game is restarted
}

@property(nonatomic,assign) bool triggered;
@property(nonatomic,assign) CGPoint position;
@property(nonatomic,assign) TriggerType type;
@property(nonatomic,assign) bool canBeReset;
@property(nonatomic,assign) bool disabled;
@end
