//
//  Sprite.h
//  Clay
//
//  Created by Brian Cable on 8/25/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "cocos2d.h"

@class Animation;

@interface Sprite : NSObject
{
    CCSprite *sprite_cc;
    Animation *_animation;
}

+(id) spriteWithFile:(NSString *)filename toLayer:(id)layer;
+(id) spriteWithFile:(NSString *)filename rect:(CGRect)rect toLayer:(id)layer;

-(id) initWithFile:(NSString *)filename toLayer:(id)layer;
-(id) initWithFile:(NSString *)filename rect:(CGRect)rect toLayer:(id)layer;
-(void) setCentered;
-(void) setPositionAtX:(float)x Y:(float)y;
-(CCSprite*) getCCSprite;
-(void) initializeSpriteOnceLoaded;
-(float) getWidth;
-(float) getHeight;
-(void)setAnimation:(Animation*)animation Delay:(float)delay;
@end
