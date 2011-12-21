//
//  AnimationSequence.h
//  Clay
//
//  Created by Brian Cable on 12/20/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Animator;
@class Sprite;

@interface AnimationSequence : NSObject
{
    Animator *_parent;
    
    bool _looping;
    float _delay;
    bool _isActive;
    
    float _timer;
    float _divisor;
    
    Sprite *_sprite; //weak reference
    
    NSMutableArray *_animationFrames;
    
    NSString *_sequencePrefix;
    NSString *_frameList;
    
    int _frameNumber;
    int _totalFrames;
    int _currentFrame;
    
    bool _clearPreviousAnims;
    
    NSString *_name;
}

@property(nonatomic,assign)bool looping;
@property(nonatomic,assign)float delay;
@property(nonatomic,retain)NSString *name;
@property(nonatomic,assign)bool clearPreviousAnims;
@property(nonatomic,readonly) int currentFrame;
@property(nonatomic,readonly) int totalFrames;
@property(nonatomic,assign) bool isActive;
+(id)sequenceWithSettings:(NSDictionary*)settings Name:(NSString*)animName;
-(id)initWithSettings:(NSDictionary*)settings Name:(NSString*)name;
-(void)restart;
-(void)resetToFrame:(int)frame;
-(void)update:(float)dt;
-(void)setParent:(Animator*)parent;
-(void)setSprite:(Sprite*)sprite;
-(void)update:(float)dt;
-(void)createFramesWithSequence:(NSString*)sequence FrameList:(NSString*)framelist;
@end
