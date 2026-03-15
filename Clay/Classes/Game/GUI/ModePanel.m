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
#import "SoundEngine.h"


//IPAD FIX: positions for the header text inside the panel when the panel is active and inactive
#define PANEL_HEADER_INACTIVE_Y 370.0f
#define PANEL_HEADER_ACTIVE_Y 510.0f
#define PANEL_HEIGHT_DIFFERENCE 144.0f
#define PANEL_BUTTON_START_Y 110.0f

#define PANEL_BUTTON_HEIGHT_WITH_GAP 71.0f
#define PANEL_DEVICE_CENTER_Y 310.0f
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define MULTIPLIERX (IS_IPAD ? 2.133 : 1)
#define MULTIPLIERY (IS_IPAD ? 2.4 : 1)

@interface ModePanel()

-(id)initAtPosition:(CGPoint)position PanelType:(ModePanelType)panelType;
-(void)setHeaderAlpha:(float)alpha Position:(CGPoint)position;
-(void)setPanelAlpha:(float)alpha;
-(void)setButtonTransitionAmount:(float)alpha;

@end

@implementation ModePanel

@synthesize isActive = _isActive;
@synthesize selectedIndex = _selectedIndex;

+(id)panelAtPosition:(CGPoint)position PanelType:(ModePanelType)panelType
{
    return [[self alloc] initAtPosition:position PanelType:panelType];
}

-(id)initAtPosition:(CGPoint)position PanelType:(ModePanelType)panelType
{
    if((self=[super init])){
        _inactivePanel = [Sprite spriteCenteredWithFrame:@"UI_GameType_PanelGray.png" Position:position];
        _activePanel = [Sprite spriteCenteredWithFrame:@"UI_GameType_PanelColor.png" Position:position];
        [_activePanel setAlpha:0.0f];
        _phase = MODE_PANEL_INACTIVE;
        _position = position;
        _isActive = false;
        _isSelected = false;
        _panelType = panelType;
        _selectedIndex = 0;
        _buttons = [[NSMutableArray alloc] initWithCapacity:3];
        
        //IPAD FIX: hitbox centered on the button the size of the button graphic
        [self setHitbox:CGRectMake(position.x-71.5f * MULTIPLIERX, position.y-114.0f * MULTIPLIERY, 143 * MULTIPLIERX, 228 * MULTIPLIERY)];
        
        _wait = 1.0f;
    }
    return self;
}

-(void)addButtons:(NSArray*)buttonNames
{
    int count = [buttonNames count];
    float startY;
    if (IS_IPAD) {
        startY = (PANEL_DEVICE_CENTER_Y + ((count * PANEL_BUTTON_HEIGHT_WITH_GAP) / 2.0f));
    } else {
        startY = (PANEL_BUTTON_START_Y + ((count * PANEL_BUTTON_HEIGHT_WITH_GAP) / 2.0f));
    }
    int i = 0;
    for (NSString *name in buttonNames) {
        ActionButton *button = [ActionButton actionButtonCustomGraphicsForIdle:@"UI_GameType_ButtonL_Blue.png" Selected:@"UI_GameType_ButtonL_Green.png"];
        [button setInitialText:name];
        [button setPosition:ccp(_position.x,(startY - i * PANEL_BUTTON_HEIGHT_WITH_GAP))];
        [button setAlpha:0.0f];
        [_buttons addObject:button];
        i++;
    }
}

-(ActionButton*)getButtonWithIndex:(int)index
{
    ActionButton *returnVal = [_buttons objectAtIndex:index];
    return returnVal;
}

-(void)makeActive
{
    _phase = MODE_PANEL_ACTIVE;
    _isActive = true;
    [self setPanelAlpha:1.0f];
    [self setHeaderAlpha:1.0f Position:ccp(_position.x, PANEL_HEADER_ACTIVE_Y)];
    
    for (ActionButton *button in _buttons) {
        [button setAlpha:1.0f];
    }
}

-(void)makeCursorActive
{
    ActionButton *button = [_buttons objectAtIndex:_selectedIndex];
    [_selectCursor setScreenPosition:[button getPosition]];
    [_selectCursor setAlpha:1.0f];
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

-(void)setHeaderAlpha:(float)alpha Position:(CGPoint)position
{
    [_activeHeader setAlpha:alpha];
    [_activeHeader getCCSprite].position = position;
    [_inactiveHeader getCCSprite].position = position;
}

-(void)setHeaderFrame:(NSString*)activeName Inactive:(NSString*)inactiveName
{
    _inactiveHeader = [Sprite spriteCenteredWithFrame:inactiveName Position:ccp(_position.x,PANEL_HEADER_INACTIVE_Y)];
    _activeHeader = [Sprite spriteCenteredWithFrame:activeName Position:ccp(_position.x,PANEL_HEADER_INACTIVE_Y)];
    [_activeHeader setAlpha:0.0f];
}

-(void)setPanelAlpha:(float)alpha
{
    [_activePanel setAlpha:alpha];
}

-(void)setParent:(ChooseModeScene*)scene
{
    _parentScene = scene;
}

-(void)setSelectCursor:(Sprite *)selectCursor
{
    _selectCursor = selectCursor;
}

-(void)setSelectedIndex:(int)index
{
    int count = [_buttons count];
    if (index >= 0 && index < count) {
        _selectedIndex = index;        
    }
}

-(bool)testCollision:(CGPoint)point
{
    bool didTouch = [super testCollision:point];
    
    if(_isActive) {
        int i=0;
        for (ActionButton *button in _buttons) {
            if ([button getLocked] != LOCKTYPE_LOCKED && [button testCollision:point]) {
                if (i != _selectedIndex) {
                    if (_panelType == MODEPANEL_PANEL_EXTRAS ) {
                        [[SoundEngine shared] playSound:@"confirm"];
                    } else {
                        [[SoundEngine shared] playSound:@"guiSelectionForward"];
                    }
                }
                _selectedIndex = i;
                [self makeCursorActive];
                break;
            }
            
            else if ([button getLocked] == LOCKTYPE_LOCKED && [button testCollision:point])
            {
                if(_panelType==MODEPANEL_PANEL_STORY)
                {
                    //window for how to unlock hard
                    [_parentScene openWarningWindowLockedHardStory];
                      [[SoundEngine shared] playSound:@"windowOpenWarning"]; 
                    
                }
                else if(_panelType==MODEPANEL_PANEL_TIMED)
                {
                    if(i==0)
                    {
                        //window for how to unlock time normal
                        [_parentScene openWarningWindowLockedNormalTimed];
                          [[SoundEngine shared] playSound:@"windowOpenWarning"]; 
                    }
                    else if(i==1)
                    {
                        //window for how to unlock time insane
                        [_parentScene openWarningWindowLockedInsaneTimed];
                          [[SoundEngine shared] playSound:@"windowOpenWarning"]; 
                    }
                }
            }
            i++;
        }
    }
    
    return didTouch;
}

-(void)getNextSelected
{
    
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
        
        [self updateSelectableOption];
        
        _parentScene.isTransitioning = true;

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
            _alpha += 3.0f * dt;
            if (_alpha>=1.0f) {
                _alpha = 1.0f;
                _phase = MODE_PANEL_ACTIVE;
                _isActive = true;
                _parentScene.isTransitioning = false;
                [self makeCursorActive];
            }
            [self setPanelAlpha:_alpha];
            [self setHeaderAlpha:_alpha Position:ccp(_position.x,PANEL_HEADER_INACTIVE_Y + (_alpha * PANEL_HEIGHT_DIFFERENCE))];
            [self setButtonTransitionAmount:_alpha];
            break;
        case MODE_PANEL_SWITCHTO_INACTIVE:
            _alpha -= 3.0f * dt;
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

-(void)updateSelectableOption
{
    //if current selection is valid, keep it. otherwise, find the next unlocked option.
    
    int returnIndex = _selectedIndex;
    ActionButton *button = [_buttons objectAtIndex:_selectedIndex];
    
    if ([button getLocked] == LOCKTYPE_LOCKED) {
        int count = [_buttons count];
        for (int i=0; i<count; i++) {
            ActionButton *buttonCheck = [_buttons objectAtIndex:i];
            if ([buttonCheck getLocked] != LOCKTYPE_LOCKED) {
                returnIndex = i;
                break;
            }
        }
    }
    
    _selectedIndex = returnIndex;
}

-(void) dealloc
{
    for (ActionButton *button in _buttons) {
        [button release]; //need to reduce the retain count
    }
    [_buttons release];
    [_activePanel release];
    [_inactivePanel release];
    [_activeHeader release];
    [_inactiveHeader release];
    _selectCursor = nil;
    _parentScene = nil;
    [super dealloc];
}


@end
