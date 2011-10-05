//
//  HudLayer.h
//  Clay
//
//  Created by Brian Cable on 10/5/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "cocos2d.h"
#import "CCLayer.h"

@class Sprite;
@class TrackTimer;

typedef enum {
    HUD_BUTTON_NONE,
    HUD_BUTTON_JUMP,
    HUD_BUTTON_SPRINT,
    HUD_BUTTON_ACTION
} HudButton;

@interface HudLayer : CCLayer
{
    Sprite *_buttonJump;
    Sprite *_buttonSprint;
    Sprite *_buttonAction;
    
    float _buttonScale;
    
    TrackTimer *_trackTimer;
    
    bool _resetButtons;
    
}

+(id)instance;

-(Sprite*)initButton:(NSString*)image Position:(CGPoint)position;

-(HudButton)testInput:(CGPoint)point;
-(bool)testButtonPosition:(CGPoint)buttonPosition Test:(CGPoint)testPosition;

-(void)resettingButton:(Sprite*)button TimePassed:(float)dt;

-(void)update:(float)dt;

@end
