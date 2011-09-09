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
#import "BaseClasses.h"

#define ANIMATION_DEFAULT_DELAY 0.1f
#define ANIMATION_DEFAULT_LOOPING true

@implementation Animation

static NSString * const ANIMATION_GRAPHIC_EXTENSION = @".png";
static NSString * const ANIMATION_HD_SUFFIX = @"";
static NSString * const ANIMATION_SPRITE_CACHE_SUFFIX = @".plist";

@synthesize delay = _delay;

+(id)animationFromPlist:(NSString*)name forSequence:(NSString*)sequence FrameList:(NSString*)framelist
{
    return [[self alloc] initWithPlist:name forSequence:sequence FrameList:(NSString*)framelist];
}

-(id)initWithPlist:(NSString*)name forSequence:(NSString*)sequence FrameList:(NSString*)framelist
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
        //defaults
        _delay = ANIMATION_DEFAULT_DELAY;
        _looping = ANIMATION_DEFAULT_LOOPING;
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[name stringByAppendingString:ANIMATION_SPRITE_CACHE_SUFFIX]];
        
        _spriteSheet = [CCSpriteBatchNode batchNodeWithFile:[name stringByAppendingString:ANIMATION_GRAPHIC_EXTENSION]];
        
        [self createFramesWithSequence:sequence FrameList:(NSString*)framelist];
        
        
        [[[LayerManager sharedLayers] currentLayer] addChild:_spriteSheet];

    }
    
    return self;
}

-(void)createFramesWithSequence:(NSString*)sequence FrameList:(NSString*)framelist
{
    
    NSArray *animationFrameNumbers = [framelist componentsSeparatedByString:@","];
    
    bool isFirstFrame = true;
    _frames = [[NSMutableArray alloc] initWithCapacity:10];
    
    for (NSString *frameNumber in animationFrameNumbers) {
        
        //builds frameName with format "(SEQUENCE_NAME)(FRAME_NUMBER)-(HD_SUFFIX)(FILE_EXTENSION)", for example "player_1-hd.png"
        
        NSString *frameName = [sequence stringByAppendingFormat:@"%@%@%@",frameNumber, ANIMATION_HD_SUFFIX,ANIMATION_GRAPHIC_EXTENSION];
        
        //we want to know the name of the first frame, so we can switch sprites to it later
        if (isFirstFrame) {
            _firstFrameName = [[NSString alloc] initWithString:frameName];
            isFirstFrame = false;
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
