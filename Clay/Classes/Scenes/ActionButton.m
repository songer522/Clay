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

+(id)actionButtonCustomGraphicsForIdle:(NSString*)idleName Selected:(NSString*)selectedName
{
    return [[self alloc] initWithText:@"" ButtonImageName:idleName ButtonPressedImageName:selectedName];
}

+(id)actionButtonManualSetup
{
    return [[self alloc] init];
}

-(id)initWithText:(NSString*)text ButtonImageName:(NSString*)buttonName ButtonPressedImageName:(NSString*)buttonPressedName
{
    if ((self=[super init])) {
        
        [self setIdleSpriteFrame:buttonName];
        [self setSelectedSpriteFrame:buttonPressedName];
        
        if (![text isEqualToString:@""]) {
            [self setInitialText:text];            
        }
        
    }        
    return self;    
}

-(void)setIdleSpriteFrame:(NSString*)name
{
    _buttonIdle = [Sprite spriteFromFrameCacheWithName:name];
    [_buttonIdle getCCSprite].anchorPoint = ccp(0.5f,0.5f);
}

-(void)setSelectedSpriteFrame:(NSString*)name
{
    _buttonSelected = [Sprite spriteFromFrameCacheWithName:name];
    [_buttonSelected getCCSprite].anchorPoint = ccp(0.5f,0.5f);    
    _selectedAlpha = 0.0f;    
    [_buttonSelected setAlpha:0.0f];
}

-(void)setInitialText:(NSString*)text
{
    _textLabel = [CCLabelBMFont labelWithString:text fntFile:@"GraphicFont.fnt"];
    
    if ([GameSettings usingHighResolutionGraphics]){
        [_textLabel setScale:0.65f];
    }
    else
    {
        [_textLabel setScale:0.325f];
    }
    
    _textLabel.anchorPoint = ccp(0.5f,0.5f);
    [[[LayerManager sharedLayers] currentLayer] addChild:_textLabel];    
}


-(void)setPosition:(CGPoint)position
{
    [_buttonIdle setScreenPosition:position];
    [_buttonSelected setScreenPosition:position];
    _textLabel.position = ccp(position.x,position.y - 3.0f);
    [self setHitbox:CGRectMake(position.x - 48, position.y - 15, 95, 30)];
}

-(void)setAlpha:(float)alpha
{
    GLubyte opacity = floor(alpha * 255);
    [[_buttonIdle getCCSprite] setOpacity:opacity];
    [_textLabel setOpacity:opacity];
}

-(void)setSelectedAlpha:(float)alpha
{
    GLubyte opacity = floor(alpha * 255);
    [[_buttonSelected getCCSprite] setOpacity:opacity];
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
