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
#import "GameSettings.h"
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define MULTIPLIERX (IS_IPAD ? 2.133 : 1)
#define MULTIPLIERY (IS_IPAD ? 2.4 : 1)

@interface ActionButton()

-(id)initWithText:(NSString*)text ButtonImageName:(NSString*)buttonName ButtonPressedImageName:(NSString*)buttonPressedName;

@end


@implementation ActionButton

+(id)actionButtonWithText:(NSString*)text
{
    return [[self alloc] initWithText:text ButtonImageName:@"CL_Button.png" ButtonPressedImageName:@"CL_ButtonPressed.png"];
}

+(id)actionButtonInGameWithText:(NSString*)text
{
    return [[self alloc] initWithText:text ButtonImageName:@"Button.png" ButtonPressedImageName:@"ButtonPressed.png"];
}

-(id)initWithText:(NSString*)text ButtonImageName:(NSString*)buttonName ButtonPressedImageName:(NSString*)buttonPressedName
{
    if ((self=[super init])) {
        
        _buttonIdle = [Sprite spriteFromFrameCacheWithName:buttonName];
        [_buttonIdle getCCSprite].anchorPoint = ccp(0.5f,0.5f);
        _buttonSelected = [Sprite spriteFromFrameCacheWithName:buttonPressedName];
        [_buttonSelected getCCSprite].anchorPoint = ccp(0.5f,0.5f);
        
        _textLabel = [CCLabelBMFont labelWithString:text fntFile:@"GraphicFont.fnt"];
        if ([GameSettings usingHighResolutionGraphics]){
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
    [self setHitbox:CGRectMake(position.x - 48, position.y - 15, 95 * MULTIPLIERX, 30 * MULTIPLIERY)];
}

-(void)setAlpha:(float)alpha
{
    GLubyte opacity = floor(alpha * 255);
    [[_buttonIdle getCCSprite] setOpacity:opacity];
    [_textLabel setOpacity:opacity];
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
