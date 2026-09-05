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
        _frameNames = [[NSMutableDictionary alloc] initWithCapacity:12];
        
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
        
        [_frameNames setObject:frameName forKey:[NSString stringWithFormat:@"%f",frameNumber]];
        
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
    NSString *frameName = [_frameNames objectForKey:[NSString stringWithFormat:@"%f",frameNumber]];
    [self useAnimationToReplaceSprite:sprite FrameName:frameName];
}


-(void)useAnimationToReplaceSprite:(Sprite*)sprite FrameName:(NSString*)frameName
{
    if (![[sprite getCCSprite] batchNode]) {
        [[sprite getCCSprite] setBatchNode:_spriteSheet];
    }
    [[sprite getCCSprite] setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName]];

    //These three are queried after this method returns (getCurrentFrameNumber, setFrame:,
    //togglePauseAnimation). The running action wrapper is owned by the sprite's action manager,
    //which frees it as soon as the action finishes or the sprite's actions are stopped, so we
    //have to own our own reference rather than borrow the action manager's.
    CCAnimation *newAnim = [CCAnimation animationWithFrames:_frames delay:_delay];
    CCXAnimate *newAnimateAction = [CCXAnimate actionWithAnimation:newAnim restoreOriginalFrame:NO];

    CCActionInterval *newSpeedAction;
    if (_looping) {
        newSpeedAction = [CCRepeatForeverWithSpeed actionWithAction:newAnimateAction speed:1.0f];
        newAnimateAction.looping = true;
    } else {
        newSpeedAction = [CCRepeat actionWithAction:newAnimateAction times:1]; //TODO: need to add speed to this too or else might cause changespeed issues
    }

    [newAnim retain];
    [newAnimateAction retain];
    [newSpeedAction retain];
    [_anim release];
    [_animateAction release];
    [_speedAction release];
    _anim = newAnim;
    _animateAction = newAnimateAction;
    _speedAction = newSpeedAction;
        
    if (_clearPreviousAnimations) {
        [[sprite getCCSprite] stopAllActions];        
    }
    
    [[sprite getCCSprite] runAction:_speedAction];
}

-(int)getTotalFramesCount
{
    if (_animateAction == nil) {
        return -1;
    }
    return _animateAction.totalFrames;
}

-(int)getCurrentFrameNumber
{
    //CCXAnimate reports -1 once it is no longer running, so callers that outlive the
    //animation (the punch hitbox, for one) see "no frame" instead of a stale frame number.
    if (_animateAction == nil) {
        return -1;
    }
    return [_animateAction getCurrentFrame];
}

-(void)togglePauseAnimation
{
    if (_animateAction.paused) {
        _animateAction.paused = false;
    } else {
        _animateAction.paused = true;
    }
}

-(void)unpause
{
    _animateAction.paused = false;
}

-(void)setStaticFrame:(int)frameNumber Sprite:(Sprite*)sprite
{
    @try {
        [[sprite getCCSprite] setDisplayFrame:[_frames objectAtIndex:(frameNumber - 1)]];
    }
    @catch (NSException *exception) {
        //NSLog(@"ERROR: setStaticFrame - (out of range) ... Frame Number: %d, Sprite: %@",frameNumber,sprite.name);
    }
}

-(void)changeAnimationSpeed:(float)newSpeed
{
    //if looping, then it's a ccrepeatforever. otherwise it isn't and we don't want to call this.
    if (_looping) {
        //[_animateAction changeSpeed:newSpeed];
        CCRepeatForeverWithSpeed *_speed = (CCRepeatForeverWithSpeed*)_speedAction;
        [_speed changeSpeed:newSpeed];
    }
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

    [_frameNames removeAllObjects];
    [_frameNames release];
    
    _spriteSheet = nil;
    
    [_firstFrameName release];
    [_sequence release];
    
    [_anim release];
    _anim = nil;
    [_animateAction release];
    _animateAction = nil;
    [_speedAction release];
    _speedAction = nil;
    
    [super dealloc];
}

@end
