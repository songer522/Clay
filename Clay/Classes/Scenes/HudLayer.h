//
//  HudLayer.h
//  Clay
//
//  Created by Brian Cable on 10/5/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//
//  The hud layer that displays over the top of the game, which includes the battery, the track timer, and the hud buttons. Also manages them fading in, out, and any animations.

#import "cocos2d.h"
#import "CCLayer.h"
#import "InputController.h"
#import "HudButton.h"

@class Sprite;
@class TrackTimer;
@class Battery;

typedef enum {
    HUD_TRANSITION_IN,
    HUD_TRANSITION_OUT,
    HUD_TRANSITION_IDLE
}HudTransition;

@interface HudLayer : CCLayer
{
  
    HudButton *_buttonJump;
    HudButton *_buttonSprint;
    HudButton *_buttonAction;
 
    Sprite *_pauseButton;
    
    float _buttonScale;
    
    TrackTimer *_trackTimer;
    
    Battery *_battery;
    
    bool _resetButtons;
    
    float _alpha;
    float _buttonOpacity;

    float _delay;
    
    HudTransition _currentTransition;
    
}

+(id)instance;



-(HudButtonType)testInput:(CGPoint)point InputType:(InputType)type;
-(bool)testButtonPosition:(CGPoint)buttonPosition Test:(CGPoint)testPosition;


-(void)resettingButton:(HudButton*)button TimePassed:(float)dt;
-(void)update:(float)dt;
-(void)updateTransitions:(float)dt;

-(void)setOpacities:(float)alpha;

-(float)getCurrentTime;

-(void)setHudButtonsAndThirdAction:(NSString*)action;

-(void)fadeIn;
-(void)fadeOut;

-(HudButton*)getSprintButton;
-(HudButton*)getActionButton;


-(Battery*)getBattery;
-(TrackTimer*)getTrackTimer;

-(void)reset:(bool)isRestarting;

-(void)setEnabled:(bool)enabled ForButton:(HudButtonType)button;

@end
