//
//  Button.h
//  Clay
//
//  Created by Brian Cable on 10/24/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class GameLabel;

@interface Button : NSObject
{
    //NOTE: While the goal of this class is to be used for all buttons in the game eventually,
    //currently, this is only used by the choose level screen, and is NOT used by the HUD buttons or
    //the main menu
    
    int _buttonId;
    CGRect _hitbox;
    CGPoint _position;
    CCLabelBMFont *_buttonLabel;
    
    bool _usingRelativeHitbox;
    
    GameLabel *_gameLabel;
}

@property(nonatomic,assign) int buttonId;

#pragma mark - initialization
+(id)buttonWithText:(NSString*)text AtPoint:(CGPoint)point;
+(id)buttonWithText:(NSString*)text AtPoint:(CGPoint)point inLayer:(CCLayer *)layer;
+(id)buttonWithGameLabelText:(NSString*)text AtPoint:(CGPoint)point;

#pragma mark - accessors
-(CCLabelTTF*)getLabel;
-(GameLabel*)getGameLabel;
-(void)setPosition:(CGPoint)position;
-(void)setLabel:(NSString*)text;
-(void)setHitbox:(CGRect)rect;

#pragma mark - public methods
-(bool)testCollision:(CGPoint)position;

@end
