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

@class Sprite;
@class HudButton;
@class TrackTimer;
@class Battery;

typedef enum {
    HUD_BUTTON_NONE,
    HUD_BUTTON_JUMP,
    HUD_BUTTON_SPRINT,
    HUD_BUTTON_ACTION
} HudButtons;

typedef enum {
    HUD_TRANSITION_IN,
    HUD_TRANSITION_OUT,
    HUD_TRANSITION_IDLE
}HudTransition;

@interface HudLayer : CCLayer
{
    //Sprite *_buttonJump;
    //Sprite *_buttonSprint;
    //Sprite *_buttonAction;
    HudButton *_buttonJump;
    HudButton *_buttonSprint;
    HudButton *_buttonAction;
    
    float _buttonScale;
    
    TrackTimer *_trackTimer;
    
    Battery *_battery;
    
    bool _resetButtons;
    
    float _alpha;
    float _delay;
    
    HudTransition _currentTransition;
    
}

+(id)instance;

//-(Sprite*)initButton:(NSString*)image Position:(CGPoint)position;

-(HudButtons)testInput:(CGPoint)point InputType:(InputType)type;
-(bool)testButtonPosition:(CGPoint)buttonPosition Test:(CGPoint)testPosition;

//-(void)resettingButton:(Sprite*)button TimePassed:(float)dt;
-(void)resettingButton:(HudButton*)button TimePassed:(float)dt;
-(void)update:(float)dt;
-(void)updateTransitions:(float)dt;

-(void)setOpacities:(float)alpha;

-(float)getCurrentTime;

-(void)setThirdAction:(NSString*)action;

-(void)fadeIn;
-(void)fadeOut;

-(Battery*)getBattery;
-(TrackTimer*)getTrackTimer;

-(void)reset;

//-(void)setEnabled:(bool)enabled ForButton:(HudButton)button;
-(void)setEnabled:(bool)enabled ForButton:(HudButtons)button;

@end
