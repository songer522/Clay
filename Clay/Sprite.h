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
    float _x;
    float _y;
}

@property (nonatomic,assign) float x;
@property (nonatomic,assign) float y;

+(id) spriteWithFile:(NSString *)filename;

-(id) initWithFile:(NSString *)filename;
-(void) setCentered;
-(void) setPositionAtX:(float)x Y:(float)y;
-(CCSprite*) getCCSprite;
-(void) initializeSpriteOnceLoaded;
-(float) getWidth;
-(float) getHeight;
-(CGPoint) getPosition;
-(int)getCurrentFrameNumber;
-(void)setAnimation:(Animation*)animation Delay:(float)delay;
-(void)setAnimation:(Animation*)animation Delay:(float)delay StartingFrameNumber:(int)frameNumber;
@end
