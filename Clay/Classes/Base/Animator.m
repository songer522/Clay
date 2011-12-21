//
//  Animator.m
//  Clay
//
//  Created by Brian Cable on 12/20/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "Animator.h"
#import "AnimationSequence.h"
#import "Sprite.h"

@implementation Animator


+(id)instance
{
    return [[self alloc] init];
}

-(id)init
{
    if ((self=[super init])) {
        _animations = [[NSMutableDictionary alloc] initWithCapacity:3];        
    }
    return self;
}

-(void)addAnimation:(AnimationSequence*)sequence forKey:(NSString*)key
{
    [_animations setObject:sequence forKey:key];
    [sequence setParent:self];
}

-(void)setCurrentAnimation:(NSString*)key
{
    AnimationSequence *_anim = [_animations objectForKey:key];
    if (_anim) {
        
        if (_anim.clearPreviousAnims) {
            [_animationQueue removeAllObjects];
        }
        
        [_animationQueue addObject:_anim];
        
        _currentAnimation = _anim;
    } else {
        CCLOG(@"ERROR! Animator.m - Animation named %@ not found!",key);
    }
}

-(void)setSprite:(Sprite*)sprite
{
    _sprite = sprite;
    for (AnimationSequence *sequence in _animations) {
        [sequence setSprite:_sprite];
    }
}

-(void)update:(float)dt
{
    [_currentAnimation update:dt];
}

-(void)reportAnimationFinished
{
    int count = [_animationQueue count];
    if (count > 1) {
        [_animationQueue removeObjectAtIndex:(count - 1)];
        _currentAnimation = [_animationQueue lastObject];
    }
}

@end
