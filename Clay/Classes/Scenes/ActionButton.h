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

-(id)initWithText:(NSString*)text;

-(void)setPosition:(CGPoint)position;

-(bool)checkIfSelected:(CGPoint)touch;

-(void)update:(float)dt;


@end
