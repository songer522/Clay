//
//  HealthIcon.h
//  Clay
//
//  Created by Brian Cable on 12/21/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    HEALTHICON_POSITIVE,
    HEALTHICON_NEGATIVE
} HealthIconType;

typedef enum {
    HEALTHANIM_PLAYER_LOW_RIGHT = 0,
    HEALTHANIM_PLAYER_MID_LEFT = 1,
    HEALTHANIM_PLAYER_UP_RIGHT = 2,
    HEALTHANIM_INTO_BATTERY_1 = 3,
    HEALTHANIM_INTO_BATTERY_2 = 4,
    HEALTHANIM_INTO_BATTERY_3 = 5
} HealthAnimType;

@class Sprite;
@class Player;
@class Battery;

@interface HealthIcon : NSObject
{
    Sprite *_sprite;
    Player *_player;
    CGPoint _position;
    float _angle;
    
    int iconId;
    
    HealthAnimType _animType;
    float _waitToStart;
    float _duration;
    float _alpha;
    bool _animating;
    
    Battery *_battery;
}

+(id)instance;

-(void)setPlayer:(Player*)player;
-(void)setBattery:(Battery*)battery;
-(void)setHealthAnimTypeById:(int)number;

-(void)startHealthAnimWithSprite:(HealthIconType)healthType;



-(void)update:(float)dt;

@end
