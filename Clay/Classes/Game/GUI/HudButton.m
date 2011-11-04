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



+(id)instance;
{

    return [[self alloc] init];
}

-(id) init
{
    if((self=[super init])){
        
    }
   return self;
}

-(void)createSpriteFromImage:(NSString*)image
{
    _graphic = [Sprite spriteWithFile:image];
    [[_graphic getCCSprite] setOpacity:HUD_LAYER_BUTTON_OPACITY];
    [[_graphic getCCSprite] setScale:[[UIScreen mainScreen] scale] / 2.0f];
    [[_graphic getCCSprite] setAnchorPoint:ccp(0.5f, 0.5f)];
}

-(void)setPosition:(CGPoint)position
{
    [_graphic getCCSprite].position = position;

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

+(id)getJumpButton
{
    return [[self alloc] createJumpButton];
}

-(HudButton *)createJumpButton
{
    [[[LayerManager sharedLayers] currentLayer] removeChild:[self getCCSpriteForButton] cleanup:NO];
    self=nil;
    
    HudButton *button=[HudButton instance];
    [button createSpriteFromImage:@"UI_Button_Jumping.png"];
    [button setPosition:CGPointMake(HUD_LAYER_JUMP_X, HUD_LAYER_BUTTON_Y)];
    
    return button;
}
+(id)getJumpOverLay
{
    return [[self alloc] createJumpOverLay];
}

-(HudButton *)createJumpOverLay
{
    [[[LayerManager sharedLayers] currentLayer] removeChild:[self getCCSpriteForButton] cleanup:NO];
    self=nil;
    
    HudButton *button=[HudButton instance];
    [button createSpriteFromImage:@"UI_Button_GreenLight.png"];
    [button setPosition:CGPointMake(HUD_LAYER_JUMP_X, HUD_LAYER_BUTTON_Y)];
    
    return button;
}

+(id)getSprintButton
{
    return [[self alloc] createSprintButton];
}

-(HudButton *)createSprintButton
{
    [[[LayerManager sharedLayers] currentLayer] removeChild:[self getCCSpriteForButton] cleanup:NO];
    self=nil;
    
    HudButton *button=[HudButton instance];
    [button createSpriteFromImage:@"UI_Button_TurboBoost.png"];
    [button setPosition:CGPointMake(HUD_LAYER_SPRINT_X, HUD_LAYER_BUTTON_Y)];
    
    return button;
}

+(id)getActionButton:(NSString *)action
{
    return [[self alloc] createActionButton:action] ;
}

-(HudButton *)createActionButton:(NSString *)action
{
    [[[LayerManager sharedLayers] currentLayer] removeChild:[self getCCSpriteForButton] cleanup:NO];
    self=nil;
    
    HudButton *button=[HudButton instance];
    [button createSpriteFromAction:action];
    [button setPosition:CGPointMake(HUD_LAYER_ACTION_X, HUD_LAYER_BUTTON_Y)];
    [[button getCCSpriteForButton] setVisible:YES];
    return button;
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
