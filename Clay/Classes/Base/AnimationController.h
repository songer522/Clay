//
//  AnimationController.h
//  Clay
//
//  Created by Brian Cable on 9/6/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//
//  A singleton class that is used for loading animation data based on the property list (anims.plist). Can also be used by other classes to get an animation or to replace their CCSprite with an CCAnimate action (basically set up so we can tell a sprite object to load a particular animation based on its name in the anims.plist).


//TODO: add ability to load animations based on a given group, for better resource management

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class Sprite;
@class Animation;

@interface AnimationController : NSObject
{
    NSMutableDictionary *animations;
    
}

+(AnimationController*)sharedController;

-(void)loadAnimationsForGroup:(NSString*)group;

-(void)addAnimationForSkinFromFile:(NSString*)filename UsingBaseAnim:(NSString*)baseAnim ForSequence:(NSString*)sequence;


-(CCAnimationCache*)loadPlistForObjectName:(NSString*)objectName;
-(CCAnimation*)loadPlistForAnimationWithName:(NSString*)animationName andObjectName:(NSString*)objectName;

-(Animation*)getAnimationWithName:(NSString*)name;

-(void)replaceSprite:(Sprite*)sprite withAnimationNamed:(NSString*)name;
-(void)replaceSprite:(Sprite*)sprite withAnimationNamed:(NSString*)name FrameNumber:(int)frameNumber;

@end
