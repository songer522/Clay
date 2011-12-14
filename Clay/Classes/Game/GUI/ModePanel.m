//
//  ModePanel.m
//  Clay
//
//  Created by Brian Cable on 12/13/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "ModePanel.h"
#import "Sprite.h"
#import "ActionButton.h"
#import "ChooseModeScene.h"

#define PANEL_HEADER_INACTIVE_Y 160.0f
#define PANEL_HEADER_ACTIVE_Y 232.0f
#define PANEL_HEIGHT_DIFFERENCE 72.0f

#define PANEL_BUTTON_HEIGHT_WITH_GAP 35.5f
#define PANEL_DEVICE_CENTER_Y 128.0f

@interface ModePanel()

-(id)initAtPosition:(CGPoint)position;
-(void)setHeaderAlpha:(float)alpha Position:(CGPoint)position;
-(void)setPanelAlpha:(float)alpha;
-(void)setButtonTransitionAmount:(float)alpha;

@end

@implementation ModePanel

@synthesize isActive = _isActive;

+(id)panelAtPosition:(CGPoint)position
{
    return [[self alloc] initAtPosition:position];
}

-(id)initAtPosition:(CGPoint)position
{
    if((self=[super init])){
        _inactivePanel = [Sprite spriteCenteredWithFrame:@"UI_GameType_PanelGray.png" Position:position];
        _activePanel = [Sprite spriteCenteredWithFrame:@"UI_GameType_PanelColor.png" Position:position];
        [_activePanel setAlpha:0.0f];
        _phase = MODE_PANEL_INACTIVE;
        _position = position;
        _isActive = false;
        _isSelected = false;
        _buttons = [[NSMutableArray alloc] initWithCapacity:3];
        [self setHitbox:CGRectMake(position.x-71.5f, position.y-114.0f, 143, 228)];
        _wait = 1.0f;
    }
    return self;
}

-(void)addButtons:(NSArray*)buttonNames
{
    int count = [buttonNames count];
    float startY = PANEL_DEVICE_CENTER_Y + ((count * PANEL_BUTTON_HEIGHT_WITH_GAP) / 2.0f);
    
    int i = 0;
    for (NSString *name in buttonNames) {
        ActionButton *button = [[ActionButton actionButtonCustomGraphicsForIdle:@"UI_GameType_ButtonL_Blue.png" Selected:@"UI_GameType_ButtonL_Green.png"] retain];
        [button setInitialText:name];
        [button setPosition:ccp(_position.x,(startY - i * PANEL_BUTTON_HEIGHT_WITH_GAP))];
        [button setAlpha:0.0f];
        [_buttons addObject:button];
        i++;
    }
}

-(void)setButtonTransitionAmount:(float)amount
{
    int startSegment;
    int i;
    int count = [_buttons count];

    if (count == 2) {
        i = 1;
        startSegment = 3;
    } else {
        i = 2;
        startSegment = 2;
    }
    
    if (amount>0.6f) {
        amount = amount;
    }
    
    for (ActionButton *button in _buttons) {
        int currentSegment = floorf(amount * 10);
        
        float buttonAmount = 0.0f;
        float buttonStartSegment = (startSegment + (i * 2));
        
        //time segment
        if (currentSegment >= buttonStartSegment) {
            float startTime = buttonStartSegment / 8.0f;
            buttonAmount = MIN(startTime + 4.0f * (amount - startTime),1.0f);
        }
        
        i--;
        
        CGPoint position = [button getPosition];
        [button setPosition:ccp(_position.x - (1.0f - buttonAmount) * 5.0f,position.y)];
        [button setAlpha:buttonAmount];
    }
}

-(void)setHeaderFrame:(NSString*)activeName Inactive:(NSString*)inactiveName
{
    _inactiveHeader = [Sprite spriteCenteredWithFrame:inactiveName Position:ccp(_position.x,PANEL_HEADER_INACTIVE_Y)];
    _activeHeader = [Sprite spriteCenteredWithFrame:activeName Position:ccp(_position.x,PANEL_HEADER_INACTIVE_Y)];
    [_activeHeader setAlpha:0.0f];
}

-(void)setHeaderAlpha:(float)alpha Position:(CGPoint)position
{
    [_activeHeader setAlpha:alpha];
    [_activeHeader getCCSprite].position = position;
    [_inactiveHeader getCCSprite].position = position;
}

-(void)setPanelAlpha:(float)alpha
{
    [_activePanel setAlpha:alpha];
}

-(void)makeActive
{
    _phase = MODE_PANEL_ACTIVE;
    [self setPanelAlpha:1.0f];
    [self setHeaderAlpha:1.0f Position:ccp(_position.x,PANEL_HEADER_ACTIVE_Y)];
    
    for (ActionButton *button in _buttons) {
        [button setAlpha:1.0f];
    }
}

-(void)setParent:(ChooseModeScene*)scene
{
    _parentScene = scene;
}

-(bool)testCollision:(CGPoint)point
{
    bool didTouch = [super testCollision:point];
    return didTouch;
}

-(void)transitionToActive
{
    if (!_isActive) {
        _phase = MODE_PANEL_SWITCHTO_ACTIVE;
        _alpha = 0.0f;
        
        [_activeHeader setAlpha:0.0f];    
        [_activePanel setAlpha:0.0f];
        
        for (ActionButton *button in _buttons) {
            [button setAlpha:0.0f];
        }        

    }
}

-(void)transitionToInactive
{
    if (_isActive) {
        _phase = MODE_PANEL_SWITCHTO_INACTIVE;
        _alpha = 1.0f;
        
        [_activeHeader setAlpha:1.0f];
        [_activePanel setAlpha:1.0f];
        
        for (ActionButton *button in _buttons) {
            [button setAlpha:1.0f];
        }        
    }
}

-(void)update:(float)dt
{
    if (_wait > 0.0f) {
        _wait -= dt;
        return;
    }
    
    switch (_phase) {
        case MODE_PANEL_SWITCHTO_ACTIVE:
            _alpha += 2.0f * dt;
            if (_alpha>=1.0f) {
                _alpha = 1.0f;
                _phase = MODE_PANEL_ACTIVE;
                _isActive = true;
                
            }
            [self setPanelAlpha:_alpha];
            [self setHeaderAlpha:_alpha Position:ccp(_position.x,PANEL_HEADER_INACTIVE_Y + (_alpha * PANEL_HEIGHT_DIFFERENCE))];
            [self setButtonTransitionAmount:_alpha];
            break;
        case MODE_PANEL_SWITCHTO_INACTIVE:
            _alpha -= 2.0f * dt;
            if (_alpha<= 0.0f) {
                _alpha = 0.0f;
                _phase = MODE_PANEL_INACTIVE;
                _isActive = false;
            }
            [self setPanelAlpha:_alpha];
            [self setHeaderAlpha:_alpha Position:ccp(_position.x,PANEL_HEADER_INACTIVE_Y + (_alpha * PANEL_HEIGHT_DIFFERENCE))];            
            [self setButtonTransitionAmount:_alpha];
            break;
        default:
            break;
    }
}


@end
