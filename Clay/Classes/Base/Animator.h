//
//  Animator.h
//  Clay
//
//  Created by Brian Cable on 12/20/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AnimationSequence;
@class Sprite;

@interface Animator : NSObject
{
    NSMutableDictionary *_animations;
    
    Sprite *_sprite; //weak reference
    
    NSMutableArray *_animationQueue;
    AnimationSequence *_currentAnimation;
    
}
+(id)instance;
-(void)addAnimation:(AnimationSequence*)sequence forKey:(NSString*)key;
-(void)setCurrentAnimation:(NSString*)key;
-(void)reportAnimationFinished;
-(void)update:(float)dt;
-(void)setSprite:(Sprite*)sprite;

@end
