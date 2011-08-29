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

@interface Animation : NSObject
{
    NSMutableArray *_frames;                //the frames of the animation
    CCSpriteBatchNode *_spriteSheet;        //a reference to the spritesheet
    
    float _delay;                           //number of seconds between frames
    NSString *_firstFrameName;              //name of the first frame of the sequence
}

//constructor
+(id)animationFromPlist:(NSString*)name forSequence:(NSString*)sequence NumberOfFrames:(int)numberOfFrames onLayer:(id)layer;
-(id)initWithPlist:(NSString*)name forSequence:(NSString*)sequence NumberOfFrames:(int)numberOfFrames onLayer:(id)layer;


-(void)createFramesWithSequence:(NSString*)sequence NumberOfFrames:(int)numberOfFrames;
//called by constructor, populates the (_frames) array
//sequence = name of the sequence within the spritesheet (usually the image filenames it compiles)


-(void)useAnimationToReplaceSprite:(Sprite*)sprite;
//replaces the given sprite with this animation

@property(nonatomic,assign) float delay;


@end
