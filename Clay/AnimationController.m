//
//  AnimationController.m
//  Clay
//
//  Created by Brian Cable on 9/6/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "AnimationController.h"
#import "Animation.h"
#import "Sprite.h"

@implementation AnimationController

static AnimationController *_sharedController = nil;

+(AnimationController*)sharedController
{
	if (!_sharedController) {
        _sharedController = [[self alloc] init];
	}
	return _sharedController;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        animations = [[[NSMutableDictionary alloc] initWithCapacity:20] retain];
        
        [self loadAnimationsFromPlist:@"anims"];
    }
    
    return self;
}

-(void)loadAnimationsFromPlist:(NSString*)plist
{
    NSString *path = [[NSBundle mainBundle] pathForResource:plist ofType:@"plist"];
    
    //read plist
    NSDictionary *plistDictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSAssert(plistDictionary!=nil,@"Error reading plist.");
    
    NSEnumerator *enumerator = [plistDictionary keyEnumerator];
    id animationName;
    while ((animationName = [enumerator nextObject])) {
        NSDictionary *animationSettings = [plistDictionary objectForKey:animationName];
        if (animationSettings == nil) {
            CCLOG(@"Could not locate AnimationWithName:%@", animationName);
        } else {
            // get animation delay
            float animationDelay = [[animationSettings objectForKey:@"delay"] floatValue];
            
            // add frames to animation
            NSString *spritesheetPlist = [animationSettings objectForKey:@"spritesheetPlist"];
            NSString *sequencePrefix = [animationSettings objectForKey:@"sequencePrefix"];
            NSString *animationFrames = [animationSettings objectForKey:@"animationFrames"];
            BOOL looping = [[animationSettings objectForKey:@"looping"] boolValue];
            BOOL clearPreviousAnimations = [[animationSettings objectForKey:@"clearPreviousAnims"] boolValue];
            
            Animation *anim = [[Animation animationFromPlist:spritesheetPlist forSequence:sequencePrefix FrameList:animationFrames] retain];
            anim.looping = looping;
            anim.delay = animationDelay;
            anim.clearPreviousAnimations = clearPreviousAnimations;
            
            [animations setValue:anim forKey:animationName];
        }
    }
}


-(void)replaceSprite:(Sprite*)sprite withAnimationNamed:(NSString*)name
{
    Animation *anim = (Animation*)[animations objectForKey:name];
    NSAssert(anim!=nil,@"Animation not loaded.");
    [sprite setAnimation:anim Delay:anim.delay];
}

-(void)replaceSprite:(Sprite*)sprite withAnimationNamed:(NSString*)name FrameNumber:(int)frameNumber
{
    Animation *anim = (Animation*)[animations objectForKey:name];
    NSAssert(anim!=nil,@"Animation not loaded.");
    [sprite setAnimation:anim Delay:anim.delay StartingFrameNumber:frameNumber];
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
