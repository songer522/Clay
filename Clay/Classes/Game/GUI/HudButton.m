//
//  HudButton.m
//  Clay
//
//  Created by Brian Cable on 10/28/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "HudButton.h"

#define HUD_LAYER_BUTTON_OPACITY 170 //tian's suggestion: 204


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
