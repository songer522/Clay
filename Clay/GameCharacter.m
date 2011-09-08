//
//  GameCharacter.m
//  Clay
//
//  Created by Dustin Werner on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameCharacter.h"
#import "cocos2d.h"

@implementation GameCharacter

-(id) init {
    if((self=[super init])){
        
    }
    return self;
}

-(CCAnimationCache*)loadPlistForObjectName:(NSString*)objectName {
    CCAnimationCache *animationCacheToReturn = nil;
    NSString *fullFileName = [NSString stringWithFormat:@"%@.plist",objectName];
    NSString *plistPath;
    
    // Get the Path to the plist File
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    plistPath = [rootPath stringByAppendingPathComponent:fullFileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] pathForResource:objectName ofType:@"plist"];
    }
    
    // Read the plist File
    NSDictionary *plistDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    // verify file was found
    if (plistDictionary == nil) {
        CCLOG(@"Error reading plist: %@.plist", objectName);
        return nil;
    }
    
    // Loop through Animations of objectName
    NSEnumerator *enumerator = [plistDictionary keyEnumerator];
    id animationName;
    while ((animationName = [enumerator nextObject])) {
        CCAnimation *animationToAdd = nil;
        
        // get animation dictionary
        NSDictionary *animationSettings = [plistDictionary objectForKey:animationName];
        if (animationSettings == nil) {
            CCLOG(@"Could not locate AnimationWithName:%@", animationName);
            return nil;
        }
        
        // get animation delay
        float animationDelay = [[animationSettings objectForKey:@"delay"] floatValue];
        [animationToAdd setDelay:animationDelay];
        
        // add frames to animation
        NSString *animationNamePrefix = [animationSettings objectForKey:@"filenamePrefix"];
        NSString *animationFrames = [animationSettings objectForKey:@"animationFrames"];
        NSArray *animationFrameNumbers = [animationFrames componentsSeparatedByString:@","];
        
        for (NSString *frameNumber in animationFrameNumbers) {
            NSString *frameName = [NSString stringWithFormat:@"%@%@.png", animationNamePrefix, frameNumber];
            [animationToAdd addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName]];
        }        
        
        [animationCacheToReturn addAnimation:animationToAdd name:animationName];
    }
    
    return animationCacheToReturn;
}

-(CCAnimation*)loadPlistForAnimationWithName:(NSString*)animationName andObjectName:(NSString*)objectName {
    
    CCAnimation *animationToReturn = nil;
    NSString *fullFileName = [NSString stringWithFormat:@"%@.plist",objectName];
    NSString *plistPath;
    
    // Get the Path to the plist File
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    plistPath = [rootPath stringByAppendingPathComponent:fullFileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] pathForResource:objectName ofType:@"plist"];
    }
    
    // Read the plist File
    NSDictionary *plistDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    // verify file was found
    if (plistDictionary == nil) {
        CCLOG(@"Error reading plist: %@.plist", objectName);
        return nil;
    }
    
    // get animation dictionary
    NSDictionary *animationSettings = [plistDictionary objectForKey:animationName];
    if (animationSettings == nil) {
        CCLOG(@"Could not locate AnimationWithName:%@", animationName);
        return nil;
    }
    
    // get animation delay
    float animationDelay = [[animationSettings objectForKey:@"delay"] floatValue];
    [animationToReturn setDelay:animationDelay];
    
    // add frames to animation
    NSString *animationNamePrefix = [animationSettings objectForKey:@"filenamePrefix"];
    NSString *animationFrames = [animationSettings objectForKey:@"animationFrames"];
    NSArray *animationFrameNumbers = [animationFrames componentsSeparatedByString:@","];
    
    for (NSString *frameNumber in animationFrameNumbers) {
        NSString *frameName = [NSString stringWithFormat:@"%@%@.png", animationNamePrefix, frameNumber];
        [animationToReturn addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName]];
    }
    return animationToReturn;
}

@end
