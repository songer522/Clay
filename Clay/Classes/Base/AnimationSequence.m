//
//  AnimationSequence.m
//  Clay
//
//  Created by Brian Cable on 12/20/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "cocos2d.h"
#import "AnimationSequence.h"
#import "Animator.h"
#import "Sprite.h"

@interface AnimationSequence()

-(void)endOfAnimation;

@end

@implementation AnimationSequence

@synthesize delay = _delay;
@synthesize looping = _looping;
@synthesize totalFrames = _totalFrames;
@synthesize clearPreviousAnims = _clearPreviousAnims;
@synthesize name = _name;
@synthesize currentFrame = _currentFrame;

-(void)restart
{
    _timer = 0;
    _isActive = true;

}

-(void)resetToFrame:(int)frame
{
    _timer = frame * _delay;
}

+(id)sequenceWithSettings:(NSDictionary*)settings Name:(NSString*)animName
{
    return [[self alloc] initWithSettings:settings Name:animName];
}


-(id)initWithSettings:(NSDictionary*)settings Name:(NSString*)name
{
    if ((self = [super init])) {
        
        _animationFrames = [[NSMutableArray alloc] initWithCapacity:10];
        
        _delay = [[settings objectForKey:@"delay"] floatValue];
        _looping = [[settings objectForKey:@"looping"] boolValue];
        
        _sequencePrefix = [settings objectForKey:@"sequencePrefix"];
        _frameList = [settings objectForKey:@"animationFrames"];
        
        _clearPreviousAnims = [[settings objectForKey:@"clearPreviousAnims"] boolValue];
        
        _name = name;
        _isActive = false;
        
        [self createFramesWithSequence:_sequencePrefix FrameList:_frameList];
    }
    return self;    
}

-(void)createFramesWithSequence:(NSString*)sequence FrameList:(NSString*)framelist
{
    
    NSArray *animationFrameNumbers = [framelist componentsSeparatedByString:@","];
    
    for (NSString *frameNumber in animationFrameNumbers) {
        
        NSString *frameName = [sequence stringByAppendingFormat:@"%@.png",frameNumber];
        
        [_animationFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName]];
    }
}

-(void)setParent:(Animator*)parent
{
    _parent = parent;
}

-(void)setSprite:(Sprite*)sprite
{
    _sprite = sprite;
}

-(void)update:(float)dt
{
    if (!_isActive) { return; }

    _timer += dt;
    
    int frame = floor(_timer * _delay);
    frame = frame % _totalFrames;
    
    if (frame != _currentFrame) {
        if (frame < _currentFrame) {
            [self endOfAnimation];
        }
        
        CCSpriteFrame *frame = (CCSpriteFrame*)[_animationFrames objectAtIndex:(uint)frame];
        if(frame) {
            [[_sprite getCCSprite] setDisplayFrame:frame];
        }
    }
    
    _currentFrame = frame;
}

-(void)endOfAnimation
{
    if (_looping) {
        _timer = _timer - (_totalFrames * _delay);
    } else {
        _isActive = false;
        [_parent reportAnimationFinished];
    }
}

@end
