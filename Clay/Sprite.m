//
//  Sprite.m
//  Clay
//
//  Created by Brian Cable on 8/25/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "cocos2d.h"
#import "Sprite.h"
#import "Animation.h"
#import "Camera.h"

@implementation Sprite

- (id)init
{
    //super init already called within initWithFile under sprite
    if ((self=[super init])) {
        sprite_cc = nil;
        _animation = nil;
        
    }    
    return self;
}

+(id) spriteWithFile:(NSString*)filename toLayer:(id)layer
{
    return [[self alloc] initWithFile:filename toLayer:layer];
}

+(id) spriteWithFile:(NSString *)filename rect:(CGRect)rect toLayer:(id)layer
{
    return [[self alloc] initWithFile:filename rect:rect toLayer:layer];
}

-(id) initWithFile:(NSString*) filename toLayer:(id)layer
{
    NSAssert(filename!=nil, @"Invalid filename");
    NSAssert(layer!=nil, @"Invalid layer");
    
    if((self = [self init]))
    {
        sprite_cc = [[CCSprite spriteWithFile:filename] retain];
        [self initializeSpriteOnceLoaded];
        [layer addChild:sprite_cc];
    }
    return self;
}

-(id) initWithFile:(NSString *)filename rect:(CGRect)rect toLayer:(id)layer
{
    NSAssert(filename!=nil, @"Invalid filename");
    NSAssert(layer!=nil, @"Invalid layer");
    
    if((self = [self init]))
    {
        sprite_cc = [[CCSprite spriteWithFile:filename] retain];
        [self initializeSpriteOnceLoaded];
        [layer addChild:sprite_cc];
    }
    return self;
}

-(void) initializeSpriteOnceLoaded
{
    NSAssert(sprite_cc!=nil, @"Do not call before sprite is loaded");
    sprite_cc.position = ccp(0,0);
    sprite_cc.anchorPoint = ccp(0,0);    
}
                     
-(void) setCentered
{
    sprite_cc.anchorPoint = ccp(0.5,0.5);
}

-(void) setPositionAtX:(float)x Y:(float)y
{
    CGPoint position = [[Camera sharedCamera] convertToScreenXY:CGPointMake(x, y)];
    sprite_cc.position = ccp(position.x,position.y);
}

-(CCSprite*) getCCSprite
{
    return sprite_cc;
}

-(float) getWidth
{
    return [sprite_cc boundingBox].size.width;
}

-(float) getHeight
{
    return [sprite_cc boundingBox].size.height;
}

-(void)setAnimation:(Animation*)animation Delay:(float)delay
{
    _animation = animation;
    _animation.delay = delay;
    [_animation useAnimationToReplaceSprite:self];
}


@end
