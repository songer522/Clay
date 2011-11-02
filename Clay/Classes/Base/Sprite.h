//
//  Sprite.h
//  Clay
//
//  Created by Brian Cable on 8/25/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//
//  A wrapper class that hides some of the ugly initialization of CCSprites into a single line of code (usually). Also allows for saving its position in the world, but displaying the sprite based on the current Camera position.

#import "cocos2d.h"

@class Animation;

@interface Sprite : NSObject
{
    CCSprite *sprite_cc;
    Animation *_animation;
    float _x;
    float _y;
    float _alpha;
}

@property (nonatomic,assign) float x;
@property (nonatomic,assign) float y;

+(id) spriteWithFile:(NSString *)filename;
+(id) spriteWithFile:(NSString *)filename AddToLayer:(bool)shouldAddToLayer;
-(id) initWithFile:(NSString *)filename AddToLayer:(bool)shouldAddToLayer;
-(void) setCentered;
-(void) setPositionAtX:(float)x Y:(float)y;
-(void) setPosition:(CGPoint)position;
-(CCSprite*) getCCSprite;
-(void) initializeSpriteOnceLoaded;
-(float) getWidth;
-(float) getHeight;
-(CGPoint) getPosition;
-(void)move:(CGPoint)amount;
-(int)getCurrentFrameNumber;

-(void)setAlpha:(float)alpha;

//modifies the alpha. if it's above the limit, it uses 1.0f on the sprite instead (full opacity)
//if it reaches the minimum, then let the parent know, so it can use that to trigger actions
-(bool)reachedMinAfterModifyAlpha:(float)amount;


-(void)setFrame:(int)frame;
-(int)getTotalFramesCount;
-(void)replaceSpriteWithFile:(NSString*)filename;
-(Animation*)getAnimation;
-(void)setAnimation:(Animation*)animation Delay:(float)delay;
-(void)setAnimation:(Animation*)animation Delay:(float)delay StartingFrameNumber:(int)frameNumber;
@end
