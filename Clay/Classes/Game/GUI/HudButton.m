//
//  HudButton.m
//  Clay
//
//  Created by Brian Cable on 10/28/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "HudButton.h"
#import "BaseClasses.h"
#define HUD_LAYER_BUTTON_OPACITY 170 //tian's suggestion: 204
#define HUD_LAYER_BUTTON_Y 29
#define HUD_LAYER_JUMP_X 32
#define HUD_LAYER_ACTION_X 390
#define HUD_LAYER_SPRINT_X 450
#define HUD_LAYER_BUTTON_SIZE 55

#define BUTTON_OPACITY 255
#define BUTTON_SCALE 0.85f
@implementation HudButton



+(id)buttonWithType:(HudButtonType)type Action:(NSString*)action
{
    return [[self alloc] initWithType:type Action:action];
}

-(id) initWithType:(HudButtonType)type Action:(NSString*)action
{
    if((self=[super init])){
        
        _greenOverlay = [Sprite spriteWithFile:@"UI_Button_GreenLight.png"];
        [[_greenOverlay getCCSprite] setOpacity:HUD_LAYER_BUTTON_OPACITY];
        [[_greenOverlay getCCSprite] setScale:[[UIScreen mainScreen] scale] / 2.0f];
        [[_greenOverlay getCCSprite] setAnchorPoint:ccp(0.5f, 0.5f)];
        
        [self prepareButtonWithType:type Action:action];
        
        _initialized = true;
    }
   return self;
}

-(void)prepareButtonWithType:(HudButtonType)type Action:(NSString*)action
{
    
    if (_initialized) {
        [self reset];
    }
    
    switch (type) {
        case HUD_BUTTON_JUMP:
            [self createSpriteFromImage:@"UI_Button_Jumping.png"];
            [self setPosition:ccp(HUD_LAYER_JUMP_X, HUD_LAYER_BUTTON_Y)];
            break;
        case HUD_BUTTON_SPRINT:
            [self createSpriteFromImage:@"UI_Button_Sprinting.png"];
            [self setPosition:ccp(HUD_LAYER_SPRINT_X, HUD_LAYER_BUTTON_Y)];
            break;
        case HUD_BUTTON_ACTION:
            [self createSpriteFromAction:action];
            [self setPosition:ccp(HUD_LAYER_ACTION_X, HUD_LAYER_BUTTON_Y)];
            break;
        default:
            break;
    }
}


-(void)createSpriteFromImage:(NSString*)image
{
    _graphic = [Sprite spriteWithFile:image];
    [[_graphic getCCSprite] setOpacity:HUD_LAYER_BUTTON_OPACITY];
    [[_graphic getCCSprite] setScale:[[UIScreen mainScreen] scale] / 2.0f];
    [[_graphic getCCSprite] setAnchorPoint:ccp(0.5f, 0.5f)];
    [[_greenOverlay getCCSprite] setOpacity:HUD_LAYER_BUTTON_OPACITY];

}

-(void)setPosition:(CGPoint)position
{
    [_graphic getCCSprite].position = position;
    [_greenOverlay getCCSprite].position = position;
}

-(void)createSpriteFromAction:(NSString*)action
{
    NSString *buttonImage;
    if ([action isEqualToString:@"woo"]) {
        buttonImage = @"UI_Button_Woo.png";
    } else if([action isEqualToString:@"kick"]) {
        buttonImage = @"UI_Button_Kicking.png";
    } else if([action isEqualToString:@"dodge"]) {
        buttonImage = @"UI_Button_Dodging.png";
    } else if([action isEqualToString:@"shoot"]) {
        buttonImage = @"UI_Button_Kicking.png";
    }
    
    [self createSpriteFromImage:buttonImage];
}

-(void)reset
{
    [[[LayerManager sharedLayers] currentLayer] removeChild:[_graphic getCCSprite] cleanup:NO];
    [_graphic release];
    _graphic = nil;
}

-(CCSprite*)getCCSpriteForButton
{
    return [_graphic getCCSprite];
}
-(CCSprite*)getCCSpriteForOverlay
{
    return [_greenOverlay getCCSprite];
}

-(void)setOpacityAndScale
{
    [[_graphic getCCSprite] setOpacity:BUTTON_OPACITY];
    [[_graphic getCCSprite] setScale:BUTTON_SCALE * [[UIScreen mainScreen] scale] / 2.0f]; 
}

-(float)getButtonOpacity
{
    return [[_graphic getCCSprite] opacity];
}
-(float)getButtonScale
{
      return [[_graphic getCCSprite] scale];
}

-(void)setButtonOpacity:(float)opacity
{
    [[_graphic getCCSprite] setOpacity:opacity];
}
-(void)setButtonScale:(float)scale
{
    [[_graphic getCCSprite] setScale:scale];
}

@end
