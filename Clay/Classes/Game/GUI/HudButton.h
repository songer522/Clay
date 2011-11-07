//
//  HudButton.h
//  Clay
//
//  Created by Brian Cable on 10/28/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "Button.h"
#import "InputController.h"
#import "Sprite.h"

@class Sprite;

typedef enum {
    HUD_BUTTON_NONE,
    HUD_BUTTON_JUMP,
    HUD_BUTTON_SPRINT,
    HUD_BUTTON_ACTION,
    HUD_OVERLAY_ACTION,
    HUD_OVERLAY_SPRINT,
    HUD_OVERLAY_JUMP
} HudButtonType;

@interface HudButton : Button
{
    Sprite *_graphic;
    Sprite *_greenOverlay;
    
    bool _initialized;
}

+(id)buttonWithType:(HudButtonType)type Action:(NSString*)action;
-(id) initWithType:(HudButtonType)type Action:(NSString*)action;
-(void)prepareButtonWithType:(HudButtonType)type Action:(NSString*)action;
-(void)createSpriteFromImage:(NSString*)image;
-(void)createSpriteFromAction:(NSString*)action;
-(void)setOpacityAndScale;
-(float)getButtonOpacity;
-(float)getButtonScale;
-(CCSprite*)getCCSpriteForButton;
-(CCSprite*)getCCSpriteForOverlay;
-(void)setButtonOpacity:(float)opacity;
-(void)setButtonScale:(float)scale;
-(void)setPosition:(CGPoint)position;
-(void)reset;

@end
