//
//  Button.h
//  Clay
//
//  Created by Brian Cable on 10/24/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Button : NSObject
{
    //NOTE: While the goal of this class is to be used for all buttons in the game eventually,
    //currently, this is only used by the choose level screen, and is NOT used by the HUD buttons or
    //the main menu
    
    CGRect _hitbox;
    CGPoint _position;
    CCLabelTTF *_buttonLabel;
}

+(id)buttonWithText:(NSString*)text;
-(id)initWithText:(NSString*)text;

-(CCLabelTTF*)getLabel;
-(void)setHitbox:(CGRect)rect;

@end
