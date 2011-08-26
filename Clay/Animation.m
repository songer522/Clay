//
//  Animation.m
//  Clay
//
//  Created by Brian Cable on 8/26/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "cocos2d.h"
#import "Sprite.h"
#import "Animation.h"

@implementation Animation

+(id)animationFromPlist:(NSString*)name forSequence:(NSString*)sequence withFrameCount:(int)count onLayer:(id)layer
{
    return [[self alloc] initWithPlist:name forSequence:sequence withFrameCount:count onLayer:layer];
}

-(id)initWithPlist:(NSString*)name forSequence:(NSString*)sequence withFrameCount:(int)count onLayer:(id)layer
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[name stringByAppendingString:@".plist"]];
        
        _spriteSheet = [CCSpriteBatchNode batchNodeWithFile:[name stringByAppendingString:@".png"]];
        
        [layer addChild:_spriteSheet];
        
        _frames = [NSMutableArray array];
        for (int i=1; i<=count; ++i) {
            [_frames addObject:
                [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[sequence stringByAppendingFormat:@"%d-hd.png",i]]];
        }

    }
    
    return self;
}

-(void)useAnimationToReplaceSprite:(Sprite*)sprite
{
    [[sprite getCCSprite] setBatchNode:_spriteSheet];
    [[sprite getCCSprite] setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"player_idle_01-hd.png"]];
    CCAnimation *_anim = [CCAnimation animationWithFrames:_frames delay:0.1f];
        
    CCAction *action = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:_anim restoreOriginalFrame:NO]];
    [[sprite getCCSprite] runAction:action];
    
    //[_spriteSheet addChild:[sprite getCCSprite]];
}
@end
