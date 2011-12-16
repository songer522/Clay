//
//  ModePanel.h
//  Clay
//
//  Created by Brian Cable on 12/13/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "cocos2d.h"
#import "Button.h"

typedef enum {
    MODE_PANEL_ACTIVE,
    MODE_PANEL_INACTIVE,
    MODE_PANEL_SWITCHTO_ACTIVE,
    MODE_PANEL_SWITCHTO_INACTIVE
}ModePanelPhase;

@class Sprite;
@class ChooseModeScene;

@interface ModePanel : Button
{
    Sprite *_activePanel;
    Sprite *_inactivePanel;
    
    Sprite *_activeHeader;
    Sprite *_inactiveHeader;
    
    Sprite *_selectCursor; //weak reference
    
    ChooseModeScene *_parentScene;
    
    NSMutableArray *_buttons;
    int _selectedIndex;
    
    ModePanelPhase _phase;
    
    float _alpha;
    float _wait;
    
    bool _isActive;
    bool _isSelected;
}

@property(nonatomic,assign) bool isActive;
@property(nonatomic,assign) int selectedIndex;

+(id)panelAtPosition:(CGPoint)position;



-(void)addButtons:(NSArray*)buttonNames;
-(void)makeActive;
-(void)makeCursorActive;
-(void)setHeaderFrame:(NSString*)activeName Inactive:(NSString*)inactiveName;
-(void)setParent:(ChooseModeScene*)scene;
-(void)setSelectCursor:(Sprite*)selectCursor;
-(void)setSelectedIndex:(int)index;
-(bool)testCollision:(CGPoint)point;
-(void)transitionToActive;
-(void)transitionToInactive;
-(void)update:(float)dt;

@end
