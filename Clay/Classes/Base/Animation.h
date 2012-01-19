//
//  Animation.h
//  Clay
//
//  Created by Brian Cable on 8/26/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//
//  Animation class, for now a basic wrapper for what needs to be called by cocos2d to get an animation working,
//  using a spritesheet image and date made using Zwoptex. Will make more robust later.

#import "cocos2d.h"
#import <Foundation/Foundation.h>

@class Sprite;
@class CCXAnimate;
@class CCActionInterval;
@class CCAction;

@interface Animation : NSObject
{
    NSMutableArray *_frames;                //the frames of the animation
    CCSpriteBatchNode *_spriteSheet;        //a reference to the spritesheet
    
    CCAnimation *_anim;
    Sprite *_currentSprite;                 //weak reference, keeping for delay modification
    
    float _delay;                           //number of seconds between frames
    float _currentDelayModifier;
    
    NSString *_name;
    
    NSString *_firstFrameName;              //name of the first frame of the sequence
    
    NSString *_sequence;
    NSString *_frameList;
    
    NSMutableDictionary *_frameNames;            //the names of the frames, used primarily to make
                                            //setStaticFrame for TrackTimer more efficient
    
    CCAction *_speedAnimation;
    
    CCXAnimate *_animateAction;             //extension of CCAnimate to allow to
                                            //read the current frame
    
    bool _looping;                          //does the animation loop (true), or play through once and stop (false)
    
    bool _clearPreviousAnimations;          //when adding the new animation, do we want to remove all the previous ones? usually this will be yes, but sometimes we want the animation to play and revert to the previous one (like when the character gets hurt)
    
    CCActionInterval *_speedAction;
}

#pragma mark - properties

@property(nonatomic,assign) float delay;
@property(nonatomic,assign) bool looping;
@property(nonatomic,assign) bool clearPreviousAnimations;
@property(nonatomic,retain) NSString *name;


#pragma mark - initializers
+(id)animationFromPlist:(NSString*)name forSequence:(NSString*)sequence FrameList:(NSString*)framelist;
-(id)initWithPlist:(NSString*)name forSequence:(NSString*)sequence FrameList:(NSString*)framelist;
//constructors

#pragma mark - public methods

-(void)useAnimationToReplaceSprite:(Sprite*)sprite;
-(void)useAnimationToReplaceSprite:(Sprite*)sprite FrameName:(NSString*)frameName;
-(void)useAnimationToReplaceSprite:(Sprite*)sprite FrameNumber:(int)frameNumber;
-(int)getCurrentFrameNumber;
-(int)getTotalFramesCount;
-(void)togglePauseAnimation;
-(void)setFrame:(int)frame;
-(void)setStaticFrame:(int)frame Sprite:(Sprite*)sprite;
-(NSString*)getSequence;
-(NSString*)getFrameList;
-(void)changeAnimationSpeed:(float)newSpeed; //0 to 1, 1 is default
-(void)unpause;

//replaces the given sprite with this animation

#pragma mark - private methods

-(void)createFramesWithSequence:(NSString*)sequence FrameList:(NSString*)framelist;
//called by constructor, populates the (_frames) array
//sequence = name of the sequence within the spritesheet (usually the image filenames it compiles)


@end
