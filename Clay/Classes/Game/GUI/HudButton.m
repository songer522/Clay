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
/*
- (id)init
{
    //super init already called within initWithFile under sprite
    if ((self=[super init])) {
        _graphic = nil;
        _greenOverlay = nil;
        
    }    
    return self;
}
*/


+(id)buttonWithImage:(NSString*)image Position:(CGPoint)position
{

    return [[self alloc] initButton:image Position:position];
}
-(HudButton*)initButton:(NSString*)image Position:(CGPoint)position
{
    Sprite *sprite = [Sprite spriteWithFile:image];
    [[sprite getCCSprite] setOpacity:HUD_LAYER_BUTTON_OPACITY];
    [[sprite getCCSprite] setScale:[[UIScreen mainScreen] scale] / 2.0f];
    [[sprite getCCSprite] setAnchorPoint:ccp(0.5f, 0.5f)];
    [sprite getCCSprite].position = position;
    _graphic=sprite;
    return self;
}
-(CCSprite*)getCCSpriteForButton
{
    return [_graphic getCCSprite];
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
-(NSString *)setThirdAction:(NSString*)action
{
    NSString *button;
    if ([action compare:@"woo"] == NSOrderedSame) {
        button = @"UI_Button_Woo.png";
    } else if([action compare:@"kick"] == NSOrderedSame) {
        button = @"UI_Button_Kicking.png";
    } else if([action isEqualToString:@"dodge"]) {
        button = @"UI_Button_Dodging.png";
    } else if([action isEqualToString:@"shoot"]) {
        button = @"UI_Button_Kicking.png";
    }
    return button;
}


@end
