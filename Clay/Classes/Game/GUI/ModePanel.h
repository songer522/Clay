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

@interface ModePanel : Button
{
    Sprite *_activePanel;
    Sprite *_inactivePanel;
    
    ModePanelPhase _phase;
    
    bool _isActive;
}

@property(nonatomic,assign) bool isActive;


+(id)instance;

-(void)switchToActive;
-(void)switchToInactive;

@end
