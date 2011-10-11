//
//  HudLayer.m
//  Clay
//
//  Created by Brian Cable on 10/5/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "HudLayer.h"

#import "BaseClasses.h"
#import "TrackTimer.h"
#import "Battery.h"

#define HUD_LAYER_BUTTON_OPACITY 170 //tian's suggestion: 204

#define HUD_LAYER_BUTTON_Y 65
#define HUD_LAYER_JUMP_X 88
#define HUD_LAYER_ACTION_X 443
#define HUD_LAYER_SPRINT_X 503
#define HUD_LAYER_BUTTON_SIZE 55

@implementation HudLayer

+(id)instance
{
    return [[self alloc] init];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
        _buttonScale = [[UIScreen mainScreen] scale] / 2.0f;
        
        [[[LayerManager sharedLayers] currentScene] addChild:self];
        
        [[LayerManager sharedLayers] setWorkingLayer:self];
        
        _buttonJump = [self initButton:@"UI_Button_Jumping.png" Position:ccp(HUD_LAYER_JUMP_X,HUD_LAYER_BUTTON_Y)];
        _buttonAction = [self initButton:@"UI_Button_Kicking.png" Position:ccp(HUD_LAYER_ACTION_X,HUD_LAYER_BUTTON_Y)];
        _buttonSprint = [self initButton:@"UI_Button_TurboBoost.png" Position:ccp(HUD_LAYER_SPRINT_X,HUD_LAYER_BUTTON_Y)];

        
        _trackTimer = [TrackTimer instance];
        
        _battery = [Battery instance];
        
        [[LayerManager sharedLayers] forgetWorkingLayer];
        

        _alpha = 1.0f;
        _currentTransition = HUD_TRANSITION_IDLE;
        _resetButtons = false;
        
        
    }
    
    return self;
}

-(HudButton)testInput:(CGPoint)point InputType:(InputType)type
{
    //test jump button
    if ([self testButtonPosition:CGPointMake(HUD_LAYER_JUMP_X, HUD_LAYER_BUTTON_Y) Test:point]) {
        if (type == INPUT_TOUCH_PRESSED) {
            [[_buttonJump getCCSprite] setOpacity:255];
            [[_buttonJump getCCSprite] setScale:0.85f * _buttonScale];            
        }
        _resetButtons = true;
        return HUD_BUTTON_JUMP;
    }
    
    //test action button
    if ([self testButtonPosition:CGPointMake(HUD_LAYER_ACTION_X, HUD_LAYER_BUTTON_Y) Test:point]) {
        if (type == INPUT_TOUCH_PRESSED) {
            [[_buttonAction getCCSprite] setOpacity:255];
            [[_buttonAction getCCSprite] setScale:0.85f * _buttonScale];
            _resetButtons = true;
            return HUD_BUTTON_ACTION;            
        }
    }
    
    //test sprint button
    if ([self testButtonPosition:CGPointMake(HUD_LAYER_SPRINT_X, HUD_LAYER_BUTTON_Y) Test:point]) {
        if (type == INPUT_TOUCH_PRESSED) {
            [[_buttonSprint getCCSprite] setOpacity:255];
            [[_buttonSprint getCCSprite] setScale:0.85f * _buttonScale];
            _resetButtons = true;
            return HUD_BUTTON_SPRINT;            
        }
    }
    
    //otherwise no collision
    return HUD_BUTTON_NONE;
}

-(bool)testButtonPosition:(CGPoint)buttonPosition Test:(CGPoint)testPosition
{
    bool collision = false;
    
    float left = buttonPosition.x - 1.5f * HUD_LAYER_BUTTON_SIZE;
    float right = left + HUD_LAYER_BUTTON_SIZE;
    float bottom = buttonPosition.y - 1.5f * HUD_LAYER_BUTTON_SIZE + 25;
    float top = bottom + HUD_LAYER_BUTTON_SIZE;
    
    if (testPosition.x > left && testPosition.x < right && testPosition.y < top && testPosition.y > bottom){
        collision = true;
    }
    
    return collision;
}

-(Sprite*)initButton:(NSString*)image Position:(CGPoint)position
{
    Sprite *sprite = [Sprite spriteWithFile:image];
    [[sprite getCCSprite] setOpacity:HUD_LAYER_BUTTON_OPACITY];
    [[sprite getCCSprite] setScale:_buttonScale];
    [[sprite getCCSprite] setAnchorPoint:ccp(0.5f, 0.5f)];
    [sprite setPosition:position];
    return sprite;
}

-(void)resettingButton:(Sprite*)button TimePassed:(float)dt
{
    float rate = 100.0f * dt;
    
    float opacity = [[button getCCSprite] opacity];
    float scale = [[button getCCSprite] scale];
    
    if (opacity > HUD_LAYER_BUTTON_OPACITY) {
        opacity = (int)(opacity - 1.5f * rate);
        if (opacity < HUD_LAYER_BUTTON_OPACITY) {
            opacity = HUD_LAYER_BUTTON_OPACITY;
        }
        
        [[button getCCSprite] setOpacity:opacity];
        
        _resetButtons = true;
    }
    
    if (scale < _buttonScale) {
        scale += 0.01f * rate * _buttonScale;
        if (scale > _buttonScale) {
            scale = _buttonScale;
        }
        [[button getCCSprite] setScale:scale];
        _resetButtons = true;
    }
}

-(Battery*)getBattery
{
    return _battery;
}

-(void)update:(float)dt
{
    _resetButtons = true;
    if (_resetButtons) {
        _resetButtons = false; //gets reset to true in reduceButtonOpacity if still need to transition
        [self resettingButton:_buttonAction TimePassed:dt];
        [self resettingButton:_buttonJump TimePassed:dt];
        [self resettingButton:_buttonSprint TimePassed:dt];        
    }
    
    [self updateTransitions:dt];
    
    [_trackTimer update:dt];
}

-(void)fadeIn
{
    _delay = 1.0f;
    _alpha = 0.0f;
    _currentTransition = HUD_TRANSITION_IN;
    _trackTimer.isStopped = false;
}

-(void)fadeOut
{
    _delay = 0.0f;
    _alpha = 1.0f;
    _currentTransition = HUD_TRANSITION_OUT;
}


-(void)updateTransitions:(float)dt
{
    float rate = 2.0f * dt;
    
    switch (_currentTransition) {
        case HUD_TRANSITION_IN:
            _delay -= dt;
            if (_delay < 0.0f) {
                _alpha += rate;
                if (_alpha >= 1.0f) {
                    _alpha = 1.0f;
                    [self setOpacities:_alpha];
                    _currentTransition = HUD_TRANSITION_IDLE;
                }
            }
            
            [self setOpacities:_alpha];
            
            break;
        case HUD_TRANSITION_OUT:
            _delay -= dt;
            if (_delay < 0.0f) {
                _alpha -= 2.0f * rate;
                if (_alpha <= 0.0f) {
                    _alpha = 0.0f;
                    [self setOpacities:_alpha];
                    _currentTransition = HUD_TRANSITION_IDLE;
                    _trackTimer.isStopped = true;
                }
            }
            
            [self setOpacities:_alpha];
            
            break;
        default:
            break;
    }
    
}


-(void)setOpacities:(float)alpha
{
    int opacity = alpha * 255;
    [[_buttonJump getCCSprite] setOpacity:opacity];
    [[_buttonAction getCCSprite] setOpacity:opacity];
    [[_buttonSprint getCCSprite] setOpacity:opacity];    
    [[_battery getCCSprite] setOpacity:opacity];
    [_trackTimer setOpacity:opacity];
    
    if (_alpha == 0.0f) {
        [self setVisible:NO];
    } else {
        [self setVisible:YES];
    }
}

-(TrackTimer*)getTrackTimer
{
    return _trackTimer;
}

-(void)reset
{
    //[self removeChild:[_buttonJump getCCSprite] cleanup:NO];
    //[self addChild:[_buttonJump getCCSprite]];
}

-(void)dealloc
{
    [_buttonJump release];
    [_buttonSprint release];
    [_buttonAction release];
    [_trackTimer release];
    [_battery release];
    [super dealloc];
}

@end
