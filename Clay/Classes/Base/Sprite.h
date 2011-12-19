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
    NSString *_frameName;
    Animation *_animation;
    float _x;
    float _y;
    float _alpha;
}

@property (nonatomic,assign) float x;
@property (nonatomic,assign) float y;
@property (nonatomic,readonly) NSString *name;

+(id) instance;
+(id) spriteWithFile:(NSString *)filename;
+(id) spriteWithFile:(NSString *)filename AddToLayer:(bool)shouldAddToLayer;
+(id) spriteFromFrameCacheWithName:(NSString*)frameName;
+(id) spriteFromFrameCacheWithName:(NSString*)frameName AddToLayer:(bool)shouldAddToLayer;
+(id) spriteCenteredWithFrame:(NSString*)frame;
+(id) spriteCenteredWithFrame:(NSString*)frame AddToLayer:(bool)addToLayer;
+(id) spriteCenteredWithFrame:(NSString*)frame Position:(CGPoint)position;
+(id) spriteNotCenteredWithFrame:(NSString*)frame Position:(CGPoint)position;

-(id) initWithFile:(NSString *)filename AddToLayer:(bool)shouldAddToLayer;
-(id) initFromFrameCacheWithName:(NSString*)frameName AddToLayer:(bool)shouldAddToLayer;
-(id) initFromFrameCacheWithName:(NSString *)frameName AddToLayer:(_Bool)shouldAddToLayer Position:(CGPoint)position AnchorPoint:(CGPoint)anchorPoint;

-(void) setCentered;
-(void) setPositionAtX:(float)x Y:(float)y;
-(void) setPosition:(CGPoint)position;
-(void) setScreenPosition:(CGPoint)position;
-(CCSprite*) getCCSprite;
-(void) initializeSpriteOnceLoaded;
-(float) getWidth;
-(float) getHeight;
-(CGPoint) getPosition;
-(CGPoint) getScreenPosition;
-(void)move:(CGPoint)amount;
-(int)getCurrentFrameNumber;
-(void)setImageByName:(NSString*)frameName;

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
-(void)setAnimationByName:(NSString*)animName;

@end
