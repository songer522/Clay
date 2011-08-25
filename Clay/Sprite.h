//
//  Sprite.h
//  Clay
//
//  Created by Brian Cable on 8/25/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "cocos2d.h"

@interface Sprite : NSObject
{
    CCSprite *sprite_cc;
}

+(id) spriteWithFile:(NSString *)filename toScene:(id)scene;
-(id) initWithFile:(NSString *)filename toScene:(id)scene;
-(void) setCentered;
-(void) setPositionAtX:(float)x Y:(float)y;
-(CCSprite*) getCCSprite;

@end
