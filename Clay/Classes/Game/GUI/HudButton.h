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

+(id)instance;
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

@end
