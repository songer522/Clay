//
//  Skin.h
//  Clay
//
//  Created by Brian Cable on 11/2/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    PLAYER_ANIM_RUNNING,
    PLAYER_ANIM_JUMPING,
    PLAYER_ANIM_SPRINTING,
    PLAYER_ANIM_TRIPPING,
    PLAYER_ANIM_HURTING,
    PLAYER_ANIM_FALLING,
    PLAYER_ANIM_WOO,
    PLAYER_ANIM_KICK,
    PLAYER_ANIM_DODGE,
    PLAYER_ANIM_SHOOT,
    PLAYER_ANIM_BLOW,
    PLAYER_ANIM_SPIN,
    PLAYER_ANIM_SLOWTIME
}PlayerAnimation;

@class Sprite;

@interface Skin : NSObject
{
    NSString *_filename;
    
    PlayerAnimation _currentAnimation;
    
    //animations
    NSString *_running;
    NSString *_jumping;
    NSString *_falling;
    NSString *_sprinting;
    NSString *_tripping;
    NSString *_hurting;
    
    //action animations
    NSString *_wooAction;
    NSString *_kickAction;
    NSString *_dodgeAction;
    NSString *_shootAction;
    NSString *_blowAction;
    NSString *_spinAction;
    NSString *_slowTimeAction;
}

+(id)instance;

-(bool)isCurrentAnimationOfType:(PlayerAnimation)type;

-(void)setSkin:(NSString*)name;

-(void)setPlayerAnimation:(PlayerAnimation)type ForSprite:(Sprite*)sprite;


@end
