//
//  Sprite.m
//  Clay
//
//  Created by Brian Cable on 8/25/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "cocos2d.h"
#import "Sprite.h"

@implementation Sprite

- (id)init
{
    //super init already called within initWithFile under sprite
    if ((self=[super init])) {
        
    }    
    return self;
}

+ (id) spriteWithFile:(NSString*)filename toScene:(id)scene
{
    return [[self alloc] initWithFile:filename toScene:scene];
}

- (id) initWithFile:(NSString*) filename toScene:(id)scene
{
    NSAssert(filename!=nil, @"Invalid filename");
    NSAssert(scene!=nil, @"Invalid scene");
    
    if((self = [self init]))
    {
        sprite_cc = [[CCSprite spriteWithFile:filename] retain];
        sprite_cc.position = ccp(0,0);
        sprite_cc.anchorPoint = ccp(0,0);
        [scene addChild:sprite_cc];
    }
    return self;
}

-(void) setCentered
{
    sprite_cc.anchorPoint = ccp(0.5,0.5);
}

-(void) setPositionAtX:(float)x Y:(float)y
{
    sprite_cc.position = ccp(x,y);
}

-(CCSprite*) getCCSprite
{
    return sprite_cc;
}


@end
