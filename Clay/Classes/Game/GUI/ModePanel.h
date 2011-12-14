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
    
    ChooseModeScene *_parentScene;
    
    NSMutableArray *_buttons;
    
    ModePanelPhase _phase;
    
    float _alpha;
    float _wait;
    
    bool _isActive;
    bool _isSelected;
}

@property(nonatomic,assign) bool isActive;


+(id)panelAtPosition:(CGPoint)position;

-(void)setHeaderFrame:(NSString*)activeName Inactive:(NSString*)inactiveName;

-(void)makeActive;
-(void)transitionToActive;
-(void)transitionToInactive;

-(void)addButtons:(NSArray*)buttonNames;

-(void)update:(float)dt;

-(void)setParent:(ChooseModeScene*)scene;

-(bool)testCollision:(CGPoint)point;

@end
