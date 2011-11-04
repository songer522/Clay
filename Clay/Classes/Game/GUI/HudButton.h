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



@interface HudButton : Button
{
    Sprite *_graphic;
    Sprite *_greenOverlay;
    
    
}
+(id)buttonWithImage:(NSString*)image Position:(CGPoint)position;
-(HudButton*)initButton:(NSString*)image Position:(CGPoint)position;
-(void)setOpacityAndScale;
-(float)getButtonOpacity;
-(float)getButtonScale;
-(CCSprite*)getCCSpriteForButton;
-(void)setButtonOpacity:(float)opacity;
-(void)setButtonScale:(float)scale;
-(NSString *)setThirdAction:(NSString*)action;





@end
