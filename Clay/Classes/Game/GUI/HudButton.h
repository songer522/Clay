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
  
} HudButtonType;

@interface HudButton : Button
{
    Sprite *_graphic;
    Sprite *_greenOverlay;
    bool _overlayVisible;
    int _currentOverlayFrame;
    
    float _scale;
    bool _initialized;
    
    NSMutableArray *_overlayFrameNames;
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

-(void)updateOverlayImageByPercentage:(float)percent; //0 to 1, not 0 to 100%

@end
