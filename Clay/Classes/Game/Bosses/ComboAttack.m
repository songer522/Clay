//
//  ComboAttack.m
//  Clay
//
//  Created by Brian Cable on 1/4/12.
//  Copyright (c) 2012 Xecudev, LLC. All rights reserved.
//

#import "ComboAttack.h"
#import "Sprite.h"
#import "AnimationController.h"

@implementation ComboAttack

+(id)comboAttackWithId:(int)comboId
{
    return [[self alloc] initWithId:comboId];
}

-(id)initWithId:(int)comboId
{
    if ((self=[super init])) {
        _sprite = [Sprite spriteWithFile:@"blank.png"];
        [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"computerComboAttackAnim"];
        
    }
    return self;    
}

@end
