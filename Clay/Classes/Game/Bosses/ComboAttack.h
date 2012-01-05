//
//  ComboAttack.h
//  Clay
//
//  Created by Brian Cable on 1/4/12.
//  Copyright (c) 2012 Xecudev, LLC. All rights reserved.
//

#import "cocos2d.h"

@class Sprite;

@interface ComboAttack : NSObject
{
    Sprite *_sprite;
}

+(id)comboAttackWithId:(int)comboId;
-(id)initWithId:(int)comboId;

@end
