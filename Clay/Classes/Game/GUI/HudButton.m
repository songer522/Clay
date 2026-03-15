//
//  HudButton.m
//  Clay
//
//  Created by Brian Cable on 10/28/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "HudButton.h"
#import "BaseClasses.h"
#import "GameSettings.h"
#import "PlayerActionFactory.h"

#define HUD_LAYER_BUTTON_OPACITY 135
#define HUD_LAYER_BUTTON_Y 30
#define HUD_LAYER_JUMP_X 34
#define HUD_LAYER_ACTION_X 383
#define HUD_LAYER_SPRINT_X 445
#define HUD_LAYER_BUTTON_SIZE 62
#define LEGACY_PHONE_WIDTH 480.0f
#define LEGACY_PHONE_HEIGHT 320.0f

#define BUTTON_OPACITY 255
#define BUTTON_SCALE 0.85f

#define HUD_LAYER_NUMBER_OF_OVERLAY_FRAMES 7

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define MULTIPLIERX (IS_IPAD ? 2.133 : 1)
#define MULTIPLIERY (IS_IPAD ? 2.4 : 1)

static float HudButtonPhoneVerticalOffset(void)
{
    if (IS_IPAD) {
        return 0.0f;
    }
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    return MAX((winSize.height - LEGACY_PHONE_HEIGHT) * 0.5f, 0.0f);
}

static float HudButtonX(HudButtonType type)
{
    if (IS_IPAD) {
        switch (type) {
            case HUD_BUTTON_JUMP:
                return HUD_LAYER_JUMP_X * MULTIPLIERX;
            case HUD_BUTTON_ACTION:
                return HUD_LAYER_ACTION_X * MULTIPLIERX;
            case HUD_BUTTON_SPRINT:
                return HUD_LAYER_SPRINT_X * MULTIPLIERX;
            default:
                return 0.0f;
        }
    }
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    switch (type) {
        case HUD_BUTTON_JUMP:
            return HUD_LAYER_JUMP_X;
        case HUD_BUTTON_ACTION:
            return winSize.width - (LEGACY_PHONE_WIDTH - HUD_LAYER_ACTION_X);
        case HUD_BUTTON_SPRINT:
            return winSize.width - (LEGACY_PHONE_WIDTH - HUD_LAYER_SPRINT_X);
        default:
            return 0.0f;
    }
}

static float HudButtonY(void)
{
    if (IS_IPAD) {
        return HUD_LAYER_BUTTON_Y * MULTIPLIERY;
    }
    
    return HUD_LAYER_BUTTON_Y + HudButtonPhoneVerticalOffset();
}

static CGRect HudButtonHitbox(CGPoint position, float size)
{
    return CGRectMake(position.x - (0.5f * size),
                      position.y - (0.5f * size),
                      size,
                      size);
}
@implementation HudButton



+(id)buttonWithType:(HudButtonType)type Action:(NSString*)action
{
    return [[self alloc] initWithType:type Action:action];
}

-(id) initWithType:(HudButtonType)type Action:(NSString*)action
{
    if((self=[super init])){
        
        _scale = [GameSettings currentRenderScale];
        [self prepareButtonWithType:type Action:action];
     
        _initialized = true;
        _opacity = HUD_LAYER_BUTTON_OPACITY;
        _buttonScale = 1.0f;
        
        _overlayFrameNames = [[NSMutableArray alloc] initWithCapacity:8];
        for (int i=0; i<8; i++) {
            NSString *frameName = [NSString stringWithFormat:@"UI_Button_GreenLight_%d.png",i];
            [_overlayFrameNames addObject:frameName];
        }
        
        _currentOverlayFrame = 7;
    }
   return self;
}

-(void)prepareButtonWithType:(HudButtonType)type Action:(NSString*)action
{
    
    if (_initialized) {
        [self reset];
    }
    
    switch (type) {
        case HUD_BUTTON_JUMP:
        {
            [self createSpriteFromImage:@"UI_Button_Jumping.png"];
            CGPoint position = ccp(HudButtonX(type), HudButtonY());
            [self setPosition:position];
            float size = 200.0f;
            [self setHitbox:HudButtonHitbox(position, size)];
            break;
        }
        case HUD_BUTTON_SPRINT:
        {
            [self createSpriteFromImage:@"UI_Button_Sprinting.png"];
            CGPoint position = ccp(HudButtonX(type), HudButtonY());
            [self setPosition:position];
            [self setHitbox:HudButtonHitbox(position, HUD_LAYER_BUTTON_SIZE)];
            break;
        }
        case HUD_BUTTON_ACTION:
        {
            [self createSpriteFromAction:action];
            CGPoint position = ccp(HudButtonX(type), HudButtonY());
            [self setPosition:position];
            [self setHitbox:HudButtonHitbox(position, HUD_LAYER_BUTTON_SIZE)];
            break;
        }
        default:
            break;
    }
}


-(void)createSpriteFromImage:(NSString*)image
{
    _graphic = [Sprite spriteFromFrameCacheWithName:image];
    [[_graphic getCCSprite] setOpacity:BUTTON_OPACITY];
    [[_graphic getCCSprite] setScale:1.0f];
    
    _buttonScale = 1.0f;
    
    [[_graphic getCCSprite] setAnchorPoint:ccp(0.5f, 0.5f)];

    _greenOverlay = [Sprite spriteFromFrameCacheWithName:@"UI_Button_GreenLight_7.png"];
    [[_greenOverlay getCCSprite] setAnchorPoint:ccp(0.5f, 0.5f)];
    [[_greenOverlay getCCSprite] setOpacity:BUTTON_OPACITY];
    [[_greenOverlay getCCSprite] setScale:1.0f];

}


-(void)setPosition:(CGPoint)position
{
    [super setPosition:position];
    [_graphic getCCSprite].position = position;
    [_greenOverlay getCCSprite].position = position;
}

-(void)createSpriteFromAction:(NSString*)action
{
    NSString *buttonImage = [PlayerActionFactory getButtonImageForAction:action];    
    [self createSpriteFromImage:buttonImage];
}

-(void)reset
{
    if (_graphic!=nil) {
        [[[LayerManager sharedLayers] currentLayer] removeChild:[_graphic getCCSprite] cleanup:YES];
    }
    
    if (_greenOverlay!=nil) {
        [[[LayerManager sharedLayers] currentLayer] removeChild:[_greenOverlay getCCSprite] cleanup:YES];
    }
}

-(void)resettingWithDt:(float)dt TargetScale:(float)targetScale
{
    float rate = 100.0f * dt;
    float previousOpacity = _opacity;
    float previousScale = _buttonScale;
    
    if (_opacity > HUD_LAYER_BUTTON_OPACITY) {
        _opacity = (int)(_opacity - 1.5f * rate);
        if (_opacity < HUD_LAYER_BUTTON_OPACITY) {
            _opacity = HUD_LAYER_BUTTON_OPACITY;
        }
        
        if(previousOpacity!=_opacity) {
            [self setButtonOpacity:_opacity];            
        }
    }
    
    if (_buttonScale < targetScale) {
        _buttonScale += 0.01f * rate * targetScale;
        
        if (_buttonScale > targetScale) {
            _buttonScale = targetScale;
        }
        
        if (previousScale != _buttonScale) {
            [self setButtonScale:_buttonScale];            
        }
    }
    
    //NSLog(@"prevScale: %.2f butScale: %.2f",previousScale,_buttonScale);
    
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
    if ([self getCCSpriteForOverlay].visible && _currentOverlayFrame==7)
    
     {
         _opacity = BUTTON_OPACITY;
         _buttonScale = BUTTON_SCALE;
        [[_graphic getCCSprite] setOpacity:BUTTON_OPACITY];
        [[_graphic getCCSprite] setScale:_buttonScale]; 
     
    [[_greenOverlay getCCSprite] setOpacity:BUTTON_OPACITY];
    [[_greenOverlay getCCSprite] setScale:_buttonScale];
     }
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
   
    _opacity = opacity;
    [[_graphic getCCSprite] setOpacity:opacity];
    
}

-(void)setOverlayOpacity:(float)opacity
{
    
    [[_greenOverlay getCCSprite] setOpacity:opacity];
    
}

-(void)setButtonScale:(float)scale
{
    _buttonScale = scale;
    [[_graphic getCCSprite] setScale:scale];
    [[_greenOverlay getCCSprite] setScale:scale];
}

-(void)updateOverlayImageByPercentage:(float)percent
{
    //basically this sets which frame to display to represent to the player how long they need to wait until
    //the cooldown expires. if it's at the very beginning, we don't want to show anything, otherwise we want to show
    //the frame that represents the appropriate percentage of the cooldown    
    
    if (percent > 1.0f) {
        percent = 1.0f;
    } else if(percent < 0.0f) {
        percent = 0.0f;
    }
    
    int frameNumber = floor(percent * HUD_LAYER_NUMBER_OF_OVERLAY_FRAMES);
    if (frameNumber == 0) {
        [[_greenOverlay getCCSprite] setVisible:NO];
        _overlayVisible = false;
    } else if (_currentOverlayFrame != frameNumber) {
        
        @try {
            [_greenOverlay setImageByName:[_overlayFrameNames objectAtIndex:frameNumber]];
        }
        @catch (NSException *exception) {
            CCLOG(@"Error! HudButton.m - green overlay only has 7 frames. frame requested %d",frameNumber);
        }
        
        
        //set visible if not already
        if (!_overlayVisible) {
            _overlayVisible = true;
            [[_greenOverlay getCCSprite] setVisible:YES];
        }
        
        _currentOverlayFrame = frameNumber;
    }
}

-(void)dealloc
{
    [_graphic release];
    [_greenOverlay release];
    
    /*
    for (NSString *frameName in _overlayFrameNames) {
        [frameName release];
        frameName = nil;
    }*/
    [_overlayFrameNames release];

    [super dealloc];
}

@end
