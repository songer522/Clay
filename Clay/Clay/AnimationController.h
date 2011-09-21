//
//  AnimationController.h
//  Clay
//
//  Created by Brian Cable on 9/6/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class Sprite;

@interface AnimationController : NSObject
{
    NSMutableDictionary *animations;
    
}

+(AnimationController*)sharedController;

-(void)loadAnimationsFromPlist:(NSString*)plist;

-(CCAnimationCache*)loadPlistForObjectName:(NSString*)objectName;
-(CCAnimation*)loadPlistForAnimationWithName:(NSString*)animationName andObjectName:(NSString*)objectName;

-(void)replaceSprite:(Sprite*)sprite withAnimationNamed:(NSString*)name;
-(void)replaceSprite:(Sprite*)sprite withAnimationNamed:(NSString*)name FrameNumber:(int)frameNumber;

@end
