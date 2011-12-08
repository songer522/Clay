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
#import "CCXAnimate.h"
#import "BaseClasses.h"

#define ANIMATION_DEFAULT_DELAY 0.1f
#define ANIMATION_DEFAULT_LOOPING true
#define ANIMATION_DEFAULT_CLEAR_OLD_ANIMS true

@implementation Animation

static NSString * const ANIMATION_GRAPHIC_EXTENSION = @".png";
static NSString * const ANIMATION_HD_SUFFIX = @"";
static NSString * const ANIMATION_SPRITE_CACHE_SUFFIX = @".plist";

@synthesize delay = _delay;
@synthesize looping = _looping;
@synthesize clearPreviousAnimations = _clearPreviousAnimations;
@synthesize name = _name;

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
        _clearPreviousAnimations = ANIMATION_DEFAULT_CLEAR_OLD_ANIMS;
        _sequence = [[NSString alloc] initWithString:sequence];
        _frameList = [[NSString alloc] initWithString:framelist];
        _currentDelayModifier = 1.0f;
        _speedAction = nil;
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
    [self useAnimationToReplaceSprite:sprite FrameName:_firstFrameName];
}

-(void)useAnimationToReplaceSprite:(Sprite*)sprite FrameNumber:(int)frameNumber
{
    NSString *frameName = [_sequence stringByAppendingFormat:@"%d%@%@",frameNumber, ANIMATION_HD_SUFFIX,ANIMATION_GRAPHIC_EXTENSION];
    [self useAnimationToReplaceSprite:sprite FrameName:frameName];
}


-(void)useAnimationToReplaceSprite:(Sprite*)sprite FrameName:(NSString*)frameName
{
    [[sprite getCCSprite] setBatchNode:_spriteSheet];
    [[sprite getCCSprite] setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName]];
    _anim = [CCAnimation animationWithFrames:_frames delay:_delay]; //memory leak from previous?
    
    _animateAction = [CCXAnimate actionWithAnimation:_anim restoreOriginalFrame:NO];
    
    if (_looping) {
        _speedAction = [CCRepeatForeverWithSpeed actionWithAction:_animateAction speed:1.0f];
    } else {
        _speedAction = [CCRepeat actionWithAction:_animateAction times:1]; //TODO: need to add speed to this too or else might cause changespeed issues
    }
    
    if (_clearPreviousAnimations) {
        [[sprite getCCSprite] stopAllActions];        
    }
    
    [[sprite getCCSprite] runAction:_speedAction];
}

-(int)getTotalFramesCount
{
    return _animateAction.totalFrames;
}

-(int)getCurrentFrameNumber
{
    return _animateAction.frame;
}

-(void)togglePauseAnimation
{
    if (_animateAction.paused) {
        _animateAction.paused = false;
    } else {
        _animateAction.paused = true;
    }
}

-(void)setStaticFrame:(int)frameNumber Sprite:(Sprite*)sprite
{
    NSString *frameName = [_sequence stringByAppendingFormat:@"%d%@%@",frameNumber, ANIMATION_HD_SUFFIX,ANIMATION_GRAPHIC_EXTENSION];
    [[sprite getCCSprite] setBatchNode:_spriteSheet];
    [[sprite getCCSprite] setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName]];
}

-(void)changeAnimationSpeed:(float)newSpeed
{
    //if looping, then it's a ccrepeatforever. otherwise it isn't and we don't want to call this.
    if (_looping) {
        [_animateAction changeSpeed:0.000f];        
    }
    /*
    if (_looping) {
        CCRepeatForeverWithSpeed *action = (CCRepeatForeverWithSpeed*)_speedAction;
        [action changeSpeed:newSpeed];        
    }*/
}

-(void)setFrame:(int)frame
{
    [_animateAction setFrame:frame];
}

-(NSString*)getSequence
{
    return _sequence;
}

-(NSString*)getFrameList
{
    return _frameList;
}

-(void)dealloc
{
    [_frames removeAllObjects];
    [_frames release];

    _spriteSheet = nil;
    
    [_firstFrameName release];
    [_sequence release];
    
    _animateAction = nil;
    
    [super dealloc];
}

@end
