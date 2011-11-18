//
//  ActionButton.m
//  Clay
//
//  Created by Brian Cable on 11/9/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "ActionButton.h"
#import "LayerManager.h"
#import "Sprite.h"
#import "SoundEngine.h"

@implementation ActionButton

+(id)actionButtonWithText:(NSString*)text
{
    return [[self alloc] initWithText:text];
}

-(id)initWithText:(NSString*)text
{
    if ((self=[super init])) {
        
        _buttonIdle = [Sprite spriteFromFrameCacheWithName:@"CL_Button.png"];
        [_buttonIdle getCCSprite].anchorPoint = ccp(0.5f,0.5f);
        _buttonSelected = [Sprite spriteFromFrameCacheWithName:@"CL_ButtonPressed.png"];
        [_buttonSelected getCCSprite].anchorPoint = ccp(0.5f,0.5f);
        
        _textLabel = [CCLabelBMFont labelWithString:text fntFile:@"GraphicFont.fnt"];
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2){
            [_textLabel setScale:0.65f];
        }
        else 
        {[_textLabel setScale:0.325f];
        }
        
        _textLabel.anchorPoint = ccp(0.5f,0.5f);
        [[[LayerManager sharedLayers] currentLayer] addChild:_textLabel];
        
        _selectedAlpha = 0.0f;
        
        [_buttonSelected setAlpha:0.0f];
    }        
    return self;    
}

-(void)setPosition:(CGPoint)position
{
    [_buttonIdle setScreenPosition:position];
    [_buttonSelected setScreenPosition:position];
    _textLabel.position = ccp(position.x,position.y - 3.0f);
    [self setHitbox:CGRectMake(position.x - 48, position.y - 15, 95, 30)];
}

-(bool)checkIfSelected:(CGPoint)touch
{
    if ([self testCollision:touch]) {
        [_buttonSelected setAlpha:1.0f];
        _selectedAlpha = 1.0f;
        return true;
    }
    return false;
}

-(void)update:(float)dt
{
    if (_selectedAlpha > 0.0f) {
        _selectedAlpha -= 10.0f * dt;
        if(_selectedAlpha <= 0.0f) {
            _selectedAlpha = 0.0f;
        }
        [_buttonSelected setAlpha:_selectedAlpha];
    }
}

-(void)dealloc
{
    [_buttonIdle release];
    [_buttonSelected release];
    [_textLabel release];    
    [super dealloc];
}

@end
