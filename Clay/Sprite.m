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
#import "LayerManager.h"

@implementation Sprite

@synthesize x = _x;
@synthesize y = _y;

- (id)init
{
    //super init already called within initWithFile under sprite
    if ((self=[super init])) {
        sprite_cc = nil;
        _animation = nil;
        
    }    
    return self;
}

+(id) spriteWithFile:(NSString*)filename
{
    return [[self alloc] initWithFile:filename];
}

-(id) initWithFile:(NSString*) filename
{
    NSAssert(filename!=nil, @"Invalid filename");
    
    if((self = [self init]))
    {
        sprite_cc = [[CCSprite spriteWithFile:filename] retain];
        
        [self initializeSpriteOnceLoaded];
        [[[LayerManager sharedLayers] currentLayer] addChild:sprite_cc];
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
    _x = x;
    _y = y;
    CGPoint position = [[Camera sharedCamera] convertToScreenXY:CGPointMake((int)x, (int)y)];
    sprite_cc.position = ccp(position.x,position.y);
}

-(CGPoint) getPosition
{
    return CGPointMake(_x, _y);
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
