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

#define HUD_LAYER_BUTTON_OPACITY 170 //tian's suggestion: 204

#define HUD_LAYER_BUTTON_Y 34
#define HUD_LAYER_JUMP_X 32
#define HUD_LAYER_ACTION_X 380
#define HUD_LAYER_SPRINT_X 450
#define HUD_LAYER_BUTTON_SIZE 110

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
       if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2)
       {
        _buttonScale = [[UIScreen mainScreen] scale] / 2.0f;
       }
        else
        {
            _buttonScale = [[UIScreen mainScreen] scale];
        }
        
        [[[LayerManager sharedLayers] currentScene] addChild:self];
        
        [[LayerManager sharedLayers] setWorkingLayer:self];
        
        _trackTimer = [TrackTimer instance];
        //[_trackTimer setupAnimationsAtX:10.0f Y:288.5f];
        [_trackTimer setupAnimationsAtX:40.0f Y:287.0f];
        
        _battery = [Battery instance];
        
        _pauseButton = [Sprite spriteFromFrameCacheWithName:@"Pause.png"];
        //[_pauseButton getCCSprite].position = ccp(240,286);  
        [_pauseButton getCCSprite].position = ccp(9,287);  
        
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
        
        _resetButtons = true;
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

    [_buttonJump setButtonOpacity:opacity];
    [_buttonAction setButtonOpacity:opacity];
    [_buttonSprint setButtonOpacity:opacity];
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
    
    [_buttonSprint reset];
    [_buttonJump reset];
    [_buttonAction reset];
    
    
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
