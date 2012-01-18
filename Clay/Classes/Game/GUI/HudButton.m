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

#define HUD_LAYER_BUTTON_OPACITY 140
#define HUD_LAYER_BUTTON_Y 30
#define HUD_LAYER_JUMP_X 34
#define HUD_LAYER_ACTION_X 383
#define HUD_LAYER_SPRINT_X 445
#define HUD_LAYER_BUTTON_SIZE 62

#define BUTTON_OPACITY 255
#define BUTTON_SCALE 0.85f

#define HUD_LAYER_NUMBER_OF_OVERLAY_FRAMES 7

@implementation HudButton



+(id)buttonWithType:(HudButtonType)type Action:(NSString*)action
{
    return [[self alloc] initWithType:type Action:action];
}

-(id) initWithType:(HudButtonType)type Action:(NSString*)action
{
    if((self=[super init]))
    {
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2)
        {
            _scale = 2.0f;
        }
        else
        {
            _scale = 1.0f;
        }
        [self prepareButtonWithType:type Action:action];
     
        _initialized = true;
        
        
        _overlayFrameNames = [[NSMutableArray alloc] initWithCapacity:8];
        for (int i=0; i<8; i++) {
            NSString *frameName = [[NSString stringWithFormat:@"UI_Button_GreenLight_%d.png",i] retain];
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
            [self createSpriteFromImage:@"UI_Button_Jumping.png"];
           [self setPosition:ccp(HUD_LAYER_JUMP_X, HUD_LAYER_BUTTON_Y)];
            float size = 200.0f;
            [self setHitbox:CGRectMake(HUD_LAYER_JUMP_X - 0.5f * size, HUD_LAYER_BUTTON_Y - 0.5F * size, size, size)];
            break;
        case HUD_BUTTON_SPRINT:
            [self createSpriteFromImage:@"UI_Button_Sprinting.png"];
            [self setPosition:ccp(HUD_LAYER_SPRINT_X, HUD_LAYER_BUTTON_Y)];
            [self setHitbox:CGRectMake(HUD_LAYER_SPRINT_X - 0.5f * HUD_LAYER_BUTTON_SIZE, HUD_LAYER_BUTTON_Y - 0.5F * HUD_LAYER_BUTTON_SIZE, HUD_LAYER_BUTTON_SIZE, HUD_LAYER_BUTTON_SIZE)];
            break;
        case HUD_BUTTON_ACTION:
            [self createSpriteFromAction:action];
            [self setPosition:ccp(HUD_LAYER_ACTION_X, HUD_LAYER_BUTTON_Y)];
            [self setHitbox:CGRectMake(HUD_LAYER_ACTION_X - 0.5f * HUD_LAYER_BUTTON_SIZE, HUD_LAYER_BUTTON_Y - 0.5F * HUD_LAYER_BUTTON_SIZE, HUD_LAYER_BUTTON_SIZE, HUD_LAYER_BUTTON_SIZE)];
            break;
        default:
            break;
    }
}


-(void)createSpriteFromImage:(NSString*)image
{
    _graphic = [Sprite spriteFromFrameCacheWithName:image];
    [[_graphic getCCSprite] setOpacity:BUTTON_OPACITY];
    [[_graphic getCCSprite] setScale:[[UIScreen mainScreen] scale] / _scale];
   
    [[_graphic getCCSprite] setAnchorPoint:ccp(0.5f, 0.5f)];

    _greenOverlay = [Sprite spriteFromFrameCacheWithName:@"UI_Button_GreenLight_7.png"];
    [[_greenOverlay getCCSprite] setAnchorPoint:ccp(0.5f, 0.5f)];
    [[_greenOverlay getCCSprite] setOpacity:BUTTON_OPACITY];
    [[_greenOverlay getCCSprite] setScale:[[UIScreen mainScreen] scale] / _scale];

}


-(void)setPosition:(CGPoint)position
{
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
        [[_graphic getCCSprite] setOpacity:BUTTON_OPACITY];
        [[_graphic getCCSprite] setScale:BUTTON_SCALE * [[UIScreen mainScreen] scale] / _scale]; 
     
    [[_greenOverlay getCCSprite] setOpacity:BUTTON_OPACITY];
    [[_greenOverlay getCCSprite] setScale:BUTTON_SCALE * [[UIScreen mainScreen] scale] / _scale];
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
   
    [[_graphic getCCSprite] setOpacity:opacity];
    
}

-(void)setOverlayOpacity:(float)opacity
{
    
    [[_greenOverlay getCCSprite] setOpacity:opacity];
    
}

-(void)setButtonScale:(float)scale
{
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
    [_overlayFrameNames removeAllObjects];
    [_overlayFrameNames release];
    [super dealloc];
}

@end
