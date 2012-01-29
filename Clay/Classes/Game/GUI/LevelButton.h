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
    Sprite *_cart;
    
    bool _unlocked;
    
}

+(id)levelButtonWithId:(int)buttonId;

-(id)initWithId:(int)buttonId;

-(void)initButton;

-(void)setTrophy:(int)trophyId;
-(void)setTrophyPosition;

-(void)setCursor:(Sprite*)cursor;

-(void)setPosition:(CGPoint)position;

-(bool)checkIfSelected:(CGPoint)touch;

-(void)setInitialPosition;

-(void)setSelected;

-(bool)isUnlocked;

-(void)setPurchased:(bool)isPurchased;

@end
