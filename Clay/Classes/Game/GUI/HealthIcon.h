//
//  HealthIcon.h
//  Clay
//
//  Created by Brian Cable on 12/21/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Sprite;

typedef enum {
    HEALTHICON_POSITIVE,
    HEALTHICON_NEGATIVE
} HealthIconType;

typedef enum {
    HEALTHANIM_PLAYER_LOW_RIGHT,
    HEALTHANIM_PLAYER_MID_LEFT,
    HEALTHANIM_PLAYER_UP_RIGHT,
    HEALTHANIM_INTO_BATTERY,
    HEALTHANIM_IDLE
} HealthAnimType;

@class Player;

@interface HealthIcon : NSObject
{
    Sprite *_sprite;
    Player *_player;
    CGPoint _position;
    float _angle;
    
    HealthAnimType _animType;
    float _waitToStart;
    float _duration;
    float _alpha;
    bool _animating;
}

+(id)healthIconWithPlayer:(Player*)player;
-(id)initWithPlayer:(Player*)player;

-(void)startHealthAnimWithSprite:(HealthIconType)healthType AnimType:(HealthAnimType)healthAnimType;

-(void)update:(float)dt;

@end
