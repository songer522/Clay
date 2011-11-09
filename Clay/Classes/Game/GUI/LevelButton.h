//
//  LevelButton.h
//  Clay
//
//  Created by Brian Cable on 11/8/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "Button.h"
#import "cocos2d.h"

@class Sprite;

@interface LevelButton : Button
{
    Sprite *_buttonGraphic;
    
    Sprite *_selector;
    Sprite *_trophy;
    
}

+(id)levelButtonWithCache:(CCSpriteFrameCache*)cache andId:(int)buttonId;

-(id)initWithCache:(CCSpriteFrameCache*)cache andId:(int)buttonId;

-(void)initButton;

-(void)setTrophy:(int)trophyId;

@end
