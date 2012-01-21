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
@synthesize facebookOrTwitter;

+(id)actionButtonWithText:(NSString*)text
{
    return [[self alloc] initWithText:text ButtonImageName:@"UI_GameType_ButtonS_Blue.png" ButtonPressedImageName:@"UI_GameType_ButtonS_Green.png"];
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

-(id)init
{
    if((self=[super init])) {
        _lockingGraphic = [Sprite spriteWithFile:@"blank.png"];
        [_lockingGraphic setCentered];
        _isEnabled = false;
    }
    
    return self;
}

-(id)initWithText:(NSString*)text ButtonImageName:(NSString*)buttonName ButtonPressedImageName:(NSString*)buttonPressedName
{
    if ((self=[super init])) {
        
        [self setIdleSpriteFrame:buttonName];
        [self setSelectedSpriteFrame:buttonPressedName];
        
        _usingRelativeHitbox = false; //default
        facebookOrTwitter = false;
        _isEnabled = true;
        _lockType = LOCKTYPE_NOT_ENABLED;
        
        _lockingGraphic = [Sprite spriteWithFile:@"blank.png"];
        [_lockingGraphic setCentered];
        
        if (![text isEqualToString:@""]) {
            [self setInitialText:text];            
        }
        
    }        
    return self;    
}

-(CCLabelBMFont*)getLabel
{
    return _textLabel;
}



-(void)setIdleSpriteFrame:(NSString*)name
{
    _buttonIdle = [Sprite spriteFromFrameCacheWithName:name];
    [_buttonIdle getCCSprite].anchorPoint = ccp(0.5f,0.5f);
}


-(void)setMultilineCentered
{
    _textLabel.alignment = UITextAlignmentCenter;
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
    [self setInitialMultilineText:text Width:1024];
}

-(void)setInitialMultilineText:(NSString*)text Width:(int)width
{
    _textLabel = [CCLabelBMFont labelWithString:text fntFile:@"GraphicFont.fnt" width:width alignment:UITextAlignmentLeft];
    
    if ([[GameSettings shared] usingHighResolutionGraphics]){
        [_textLabel setScale:0.65f];
    }
    else
    {
        [_textLabel setScale:0.325f];
    }
    
    _textLabel.anchorPoint = ccp(0.5f,0.5f);
    [[[LayerManager sharedLayers] currentLayer] addChild:_textLabel];    
    _hasText = true;
}


-(void)setPosition:(CGPoint)position
{
    _position = position;
    
    [_buttonIdle setScreenPosition:position];
    [_buttonSelected setScreenPosition:position];
    [super setPosition:position];
    _textLabel.position = ccp(position.x,position.y - 3.0f);
    [_lockingGraphic setScreenPosition:ccp(position.x + 45.0f, position.y + 11.0f)];
    
    if(!_usingRelativeHitbox) {
        [self setHitbox:CGRectMake(position.x - 48, position.y - 15, 95, 30)];
    }
    
    if(facebookOrTwitter)
    {
        [self setHitbox:CGRectMake(position.x - 48, position.y - 15, 30, 30)];
    }
}

-(void)setAlpha:(float)alpha
{
    if(_isEnabled) {
        GLubyte opacity = floor(alpha * 255);
        [[_buttonIdle getCCSprite] setOpacity:opacity];
        [_textLabel setOpacity:opacity];
        [[_lockingGraphic getCCSprite] setOpacity:opacity];
    }
}

-(void)setSelectedAlpha:(float)alpha
{
    GLubyte opacity = floor(alpha * 255);
    [[_buttonSelected getCCSprite] setOpacity:opacity];
    [_textLabel setOpacity:opacity];    
}

-(void)setRelativeHitbox:(CGRect)rect
{
    _usingRelativeHitbox = true;
    [self setHitbox:rect];        
}

-(void)setHitboxBySize:(CGSize)size
{
    [self setRelativeHitbox:CGRectMake(-1 * (size.width/2.0f), -1 * (size.height/2.0f), size.width, size.height)];
}

-(bool)checkIfSelected:(CGPoint)touch
{
    //guard
    if (_lockType == LOCKTYPE_LOCKED) { return false; }
    
    if (_isEnabled && [self testCollision:touch]) {
        [_buttonSelected setAlpha:1.0f];
        _selectedAlpha = 1.0f;
        return true;
    }
    return false;
}

-(void)update:(float)dt
{
    if (_isEnabled) {        
        if (_selectedAlpha > 0.0f) {
            _selectedAlpha -= 10.0f * dt;
            if(_selectedAlpha <= 0.0f) {
                _selectedAlpha = 0.0f;
            }
            [_buttonSelected setAlpha:_selectedAlpha];
        }
    }
}

-(void)setEnabled:(bool)isEnabled
{
    [[_buttonIdle getCCSprite] setVisible:isEnabled];
    [[_buttonSelected getCCSprite] setVisible:isEnabled];
    [_textLabel setVisible:isEnabled];

    if(isEnabled) {
        [self setAlpha:1.0f];
    } else {
        [self setAlpha:0.0f];
    }
    
    _isEnabled = isEnabled;
}

-(void)setLocked:(LockType)newType
{
    switch (newType) {
        case LOCKTYPE_LOCKED:
            [[_lockingGraphic getCCSprite] setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"UI_Locked.png"]];
            [[_lockingGraphic getCCSprite] setVisible:YES];
            _lockType = newType;
            break;
        case LOCKTYPE_UNLOCKED_NEW:
            [[_lockingGraphic getCCSprite] setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"UI_New.png"]];
            [[_lockingGraphic getCCSprite] setVisible:YES];
            _lockType = newType;
            break;
        case LOCKTYPE_UNLOCKED:
            [[_lockingGraphic getCCSprite] setVisible:NO];
            _lockType = newType;
            break;
        default:
            //should not have to revert back to not enabled
            break;
    }
}

-(void)dealloc
{
    [_buttonIdle release];
    [_buttonSelected release];
    [_lockingGraphic release];
    if(_hasText) {
        [_textLabel removeFromParentAndCleanup:NO];
        _textLabel = nil;
    }
    [super dealloc];
}

@end
