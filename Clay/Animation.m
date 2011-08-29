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

static NSString * const ANIMATION_GRAPHIC_EXTENSION = @".png";
static NSString * const ANIMATION_HD_SUFFIX = @"hd";
static NSString * const ANIMATION_SPRITE_CACHE_SUFFIX = @".plist";

@synthesize delay = _delay;

+(id)animationFromPlist:(NSString*)name forSequence:(NSString*)sequence NumberOfFrames:(int)numberOfFrames onLayer:(id)layer
{
    return [[self alloc] initWithPlist:name forSequence:sequence NumberOfFrames:numberOfFrames onLayer:layer];
}

-(id)initWithPlist:(NSString*)name forSequence:(NSString*)sequence NumberOfFrames:(int)numberOfFrames onLayer:(id)layer
{
    NSAssert(numberOfFrames>0,@"Number of frames must be 1 or greater.");
    
    self = [super init];
    if (self) {
        // Initialization code here.
        
        //default delay
        _delay = 0.1f;
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[name stringByAppendingString:ANIMATION_SPRITE_CACHE_SUFFIX]];
        
        _spriteSheet = [CCSpriteBatchNode batchNodeWithFile:[name stringByAppendingString:ANIMATION_GRAPHIC_EXTENSION]];
        
        [self createFramesWithSequence:sequence NumberOfFrames:numberOfFrames];
        
        [layer addChild:_spriteSheet];

    }
    
    return self;
}

-(void)createFramesWithSequence:(NSString*)sequence NumberOfFrames:(int)numberOfFrames
{
    _frames = [NSMutableArray array];
    for (int i=1; i<=numberOfFrames; ++i) {
        
        //builds frameName with format "(SEQUENCE_NAME)(FRAME_NUMBER)-(HD_SUFFIX)(EXTENTION)", for example "player_1-hd.png"
        NSString *frameName = [sequence stringByAppendingFormat:@"%d-%@%@",i, ANIMATION_HD_SUFFIX,ANIMATION_GRAPHIC_EXTENSION];
        
        if (i == 1) {
            _firstFrameName = [NSString stringWithString:frameName];
        }
        
        [_frames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName]];
    }
}
                                  
-(void)useAnimationToReplaceSprite:(Sprite*)sprite
{
    [[sprite getCCSprite] setBatchNode:_spriteSheet];
    [[sprite getCCSprite] setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:_firstFrameName]];
    CCAnimation *_anim = [CCAnimation animationWithFrames:_frames delay:_delay];
        
    CCAction *action = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:_anim restoreOriginalFrame:NO]];
    [[sprite getCCSprite] runAction:action];
}
@end
