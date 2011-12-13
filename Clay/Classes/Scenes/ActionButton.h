//
//  ActionButton.h
//  Clay
//
//  Created by Brian Cable on 11/9/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "Button.h"

@class Sprite;

@interface ActionButton : Button
{
    Sprite *_buttonIdle;
    Sprite *_buttonSelected;
    CCLabelBMFont *_textLabel;
    float _selectedAlpha;
}

+(id)actionButtonWithText:(NSString*)text;
+(id)actionButtonInGameWithText:(NSString*)text;
+(id)actionButtonCustomGraphicsForIdle:(NSString*)idleName Selected:(NSString*)selectedName;
+(id)actionButtonManualSetup; //use this when you want to set everything yourself

-(void)setPosition:(CGPoint)position;
-(void)setAlpha:(float)alpha;
-(void)setSelectedAlpha:(float)alpha;

-(void)setIdleSpriteFrame:(NSString*)name;
-(void)setSelectedSpriteFrame:(NSString*)name;
-(void)setInitialText:(NSString*)text;
-(void)setRelativeHitbox:(CGRect)rect;
-(void)setHitboxBySize:(CGSize)size;
-(bool)checkIfSelected:(CGPoint)touch;

-(void)update:(float)dt;


@end
