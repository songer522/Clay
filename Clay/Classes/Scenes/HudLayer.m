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
#import "HudButton.h"
#import "GameSettings.h"
#import "LevelManager.h"

#define HUD_LAYER_BUTTON_OPACITY 135 //old 170

#define HUD_LAYER_BUTTON_Y 30
#define HUD_LAYER_JUMP_X 32
#define HUD_LAYER_ACTION_X 372
#define HUD_LAYER_SPRINT_X 442
#define HUD_LAYER_BUTTON_SIZE 110
#define LEGACY_PHONE_HEIGHT 320.0f
#define LEGACY_IPAD_HEIGHT 768.0f
#define HUD_TIMER_X 40.0f
#define HUD_TIMER_Y 287.0f
#define HUD_PAUSE_X 10.0f
#define HUD_PAUSE_Y 287.0f

static float HudLayerPhoneVerticalOffset(void)
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 0.0f;
    }

    CGSize winSize = [[CCDirector sharedDirector] winSize];
    return MAX((winSize.height - LEGACY_PHONE_HEIGHT) * 0.5f, 0.0f);
}

static float HudLayerIpadVerticalOffset(void)
{
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        return 0.0f;
    }

    CGSize winSize = [[CCDirector sharedDirector] winSize];
    return MAX(winSize.height - LEGACY_IPAD_HEIGHT, 0.0f);
}

static float HudLayerTopY(float legacyY)
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return legacyY + (HudLayerIpadVerticalOffset() / 2.4f);
    }
    
    return legacyY + HudLayerPhoneVerticalOffset();
}

static CGPoint HudLayerPausePosition(void)
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return ccp(9.0f, (HUD_PAUSE_Y * 2.4f) + HudLayerIpadVerticalOffset());
    }
    
    return ccp(HUD_PAUSE_X, HudLayerTopY(HUD_PAUSE_Y));
}

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
        _buttonScale = 1.0f;
        
        [[[LayerManager sharedLayers] currentScene] addChild:self];
        [[LayerManager sharedLayers] setWorkingLayer:self];
        
        _trackTimer = [TrackTimer instance];
        [_trackTimer setupAnimationsAtX:HUD_TIMER_X Y:HudLayerTopY(HUD_TIMER_Y)];
        
        _battery = [Battery instance];
        
        _pauseButton = [Sprite spriteFromFrameCacheWithName:@"Pause.png"];
        [_pauseButton getCCSprite].position = HudLayerPausePosition();
        
        _alpha = 0.0f;
        _currentTransition = HUD_TRANSITION_IDLE;
        _resetButtons = false;
        [self setOpacities:_alpha];
        
        [[LayerManager sharedLayers] forgetWorkingLayer];

        
    }
    
    return self;
}


-(HudButtonType)testInput:(CGPoint)point InputType:(InputType)type

{
    //test jump button
    if ([_buttonJump testCollision:point]) {
        if (type == INPUT_TOUCH_PRESSED) {
            if([_buttonJump getCCSpriteForOverlay].visible)
            {[_buttonJump setOpacityAndScale];}
             
            
        }
        _resetButtons = true;
        return HUD_BUTTON_JUMP;
    }
    
    //test action button
    if ([_buttonAction testCollision:point]) {
        if (type == INPUT_TOUCH_PRESSED||(type == INPUT_TOUCH_END && [[[LevelManager shared] currentLevel] isLevelNumber:10])) {
            
              if([_buttonAction getCCSpriteForOverlay].visible)
              { [_buttonAction setOpacityAndScale];}
            
            _resetButtons = true;
            return HUD_BUTTON_ACTION;            
        }
    }
    
    //test sprint button
    if ([_buttonSprint testCollision:point]) {
        if (type == INPUT_TOUCH_PRESSED) {
             
              if([_buttonSprint getCCSpriteForOverlay].visible)
              {[_buttonSprint setOpacityAndScale];}
              
           
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
    
    float left = buttonPosition.x - 0.5f * HUD_LAYER_BUTTON_SIZE;
    float right = left + HUD_LAYER_BUTTON_SIZE;
    float bottom = buttonPosition.y - 0.5f * HUD_LAYER_BUTTON_SIZE;
    float top = bottom + HUD_LAYER_BUTTON_SIZE;
    
    if (testPosition.x > left && testPosition.x < right && testPosition.y < top && testPosition.y > bottom){
        collision = true;
    }
    
    return collision;
}



-(void)resettingButton:(HudButton*)button TimePassed:(float)dt
{
    float rate = 100.0f * dt;
    
    
    float opacity=[button getButtonOpacity];
    float scale=[button getButtonScale];
    
    if (opacity > HUD_LAYER_BUTTON_OPACITY) {
        opacity = (int)(opacity - 1.5f * rate);
        if (opacity < HUD_LAYER_BUTTON_OPACITY) {
            opacity = HUD_LAYER_BUTTON_OPACITY;
        }
        
       
        [button setButtonOpacity:opacity];
    }
    
    if (scale < _buttonScale) {
        scale += 0.01f * rate * _buttonScale;
        
        if (scale > _buttonScale) {
            scale = _buttonScale;
        }
        
        [button setButtonScale:scale];
        _resetButtons = true;
    }
}

-(Battery*)getBattery
{
    return _battery;
}

-(float)getCurrentTime
{
    return [_trackTimer getTime];
}

-(void)update:(float)dt
{
    /*
    _resetButtons = true;
    if (_resetButtons) {
        _resetButtons = false; //gets reset to true in reduceButtonOpacity if still need to transition
        [self resettingButton:_buttonAction TimePassed:dt];
        [self resettingButton:_buttonJump TimePassed:dt];
        [self resettingButton:_buttonSprint TimePassed:dt];  
        
    }*/
    
    [_buttonAction resettingWithDt:dt TargetScale:_buttonScale];
    [_buttonJump resettingWithDt:dt TargetScale:_buttonScale];
    [_buttonSprint resettingWithDt:dt TargetScale:_buttonScale];
    
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

    [_buttonJump setButtonOpacity:opacity];
    [_buttonAction setButtonOpacity:opacity];
    [_buttonSprint setButtonOpacity:opacity];
    //[_buttonJump setOverlayOpacity:opacity];
    //[_buttonAction setOverlayOpacity:opacity];
    //[_buttonSprint setOverlayOpacity:opacity];
    [[_battery getCCSprite] setOpacity:opacity];
    [_trackTimer setOpacity:opacity];
    [[_pauseButton getCCSprite] setOpacity:floor(0.5f * opacity)];
    
    if (_alpha == 0.0f) {
        [self setVisible:NO];
    } else {
        [self setVisible:YES];
    }
    
}

-(void)setHudButtonsAndThirdAction:(NSString*)action
{
    [[LayerManager sharedLayers] setWorkingLayer:self];
    
    /*
    [_buttonSprint reset];
    [_buttonJump reset];
    [_buttonAction reset];
    */
    
    if(_buttonJump !=nil) {
        [_buttonJump release];
        _buttonJump = nil;
    }
    
    if (_buttonAction !=nil) {
        [_buttonAction release];
        _buttonAction = nil;
    }
    
    if (_buttonSprint != nil) {
        [_buttonSprint release];
        _buttonSprint = nil;
    }
    
    _buttonSprint = [HudButton buttonWithType:HUD_BUTTON_SPRINT Action:@""];
    _buttonJump = [HudButton buttonWithType:HUD_BUTTON_JUMP Action:@""];
    _buttonAction = [HudButton buttonWithType:HUD_BUTTON_ACTION Action:action];

    
    [[_buttonAction getCCSpriteForButton] setVisible:YES];
    [[_buttonAction getCCSpriteForOverlay] setVisible:YES];
 
    [[LayerManager sharedLayers] forgetWorkingLayer];
}

-(HudButton*)getSprintButton
{
    return _buttonSprint;
}
-(HudButton*)getActionButton
{
    return _buttonAction;
}

-(TrackTimer*)getTrackTimer
{
    return _trackTimer;
}

-(void)setEnabled:(bool)enabled ForButton:(HudButtonType)button
{
    switch (button) {
        case HUD_BUTTON_JUMP:

             [[_buttonJump getCCSpriteForOverlay] setVisible:enabled];
            break;
        case HUD_BUTTON_ACTION:
            
      
             [[_buttonAction getCCSpriteForOverlay] setVisible:enabled];
            break;
        case HUD_BUTTON_SPRINT:
           
            
           [[_buttonSprint getCCSpriteForOverlay] setVisible:enabled];
   
        default:
            break;
    }
}

-(void)reset:(bool)isRestarting
{
    [self removeFromParentAndCleanup:NO];
    [[[LayerManager sharedLayers] currentScene] addChild:self];
    
    if (isRestarting) {
        [[self getTrackTimer] restartLevel];
    } else {
        [[self getTrackTimer] startLevel]; //reset level timer (but NOT total time)        
    }
}

-(void)dealloc
{
    [_buttonJump release];
    [_buttonSprint release];
    [_buttonAction release];
   
    [_pauseButton release];
    [_trackTimer release];
    [_battery release];
    [super dealloc];
}

@end
