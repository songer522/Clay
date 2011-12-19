//
//  TextureManager.m
//  Clay
//
//  Created by Brian Cable on 11/14/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "TextureManager.h"
#import "PListLoader.h"
#import "SoundEngine.h"
#import "AnimationController.h"
#import "GameSettings.h"
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@implementation TextureManager

static TextureManager *_shared = nil;

+(TextureManager*)shared
{
	if (!_shared) {
        _shared = [[self alloc] init];
        
	}
	return _shared;
}

-(id)init
{
    if((self=[super init])) {
        _memoryDictionary = [[NSDictionary alloc] initWithDictionary:[PListLoader loadPlistWithName:@"memory"]];
    }
    return self;
}


-(void)loadMemoryForKey:(NSString*)key
{
    NSDictionary *dict = [_memoryDictionary objectForKey:key];
    
    NSString *appendhd = @"";
    if (IS_IPAD && ((key == @"mainMenu") || (key == @"chooseLevel")))
    {
        appendhd = @"-ipad";
    }
    else if([GameSettings usingHighResolutionGraphics])
    {
        	appendhd = @"-hd";
    }
    else
    {
        appendhd = @"";
    }
        
    //NSLog(@"Loading memory for key: %@",key);
    
    //load textures
    NSString *textureList = [dict objectForKey:@"textures"];
    NSArray *textureArray = [NSArray arrayWithArray:[textureList componentsSeparatedByString:@","]];
    for (NSString *texture in textureArray) {
        if (![texture isEqualToString:@"none"]) {
            texture = [texture stringByAppendingString:appendhd];
            [self loadTexturesForFile:texture];            
        }
    }   
    
    //load animations
    NSString *animList = [dict objectForKey:@"animations"];	
    NSArray *animArray = [NSArray arrayWithArray:[animList componentsSeparatedByString:@","]];
    for (NSString *anim in animArray) {
        if (![anim isEqualToString:@"none"]) {
            [[AnimationController sharedController] loadAnimationsForGroup:anim];            
        }
    }
    
    //load sounds
    NSString *soundlist = [dict objectForKey:@"sounds"];
    NSArray *soundArray = [NSArray arrayWithArray:[soundlist componentsSeparatedByString:@","]];
    for (NSString *sound in soundArray) {
        if (![sound isEqualToString:@"none"]) {
            [[SoundEngine shared] loadSoundForKey:sound];            
        }
    }
    
    [[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
}


-(void)unloadMemoryForKey:(NSString*)key
{
    //NSLog(@"Unloading memory for key: %@",key);

    NSDictionary *dict = [_memoryDictionary objectForKey:key];
    NSString *appendhd = @"";
    if (IS_IPAD && ((key == @"mainMenu") || (key == @"chooseLevel")))
    {
        appendhd = @"-ipad";
    }
    else if([GameSettings usingHighResolutionGraphics])
    {
        appendhd = @"-hd";
    }
    else
    {
        appendhd = @"";
    }
    //unload textures
    NSString *textureList = [dict objectForKey:@"textures"];
    NSArray *textureArray = [NSArray arrayWithArray:[textureList componentsSeparatedByString:@","]];
    for (NSString *texture in textureArray) {
        if (![texture isEqualToString:@"none"]) {
            texture = [texture stringByAppendingString:appendhd];
            [self unloadTexturesForFile:texture];
        }
    }
    
    //unload extra textures (stated by removeTextures key... these are not loaded by TextureManager but should be removed)
    textureList = [dict objectForKey:@"removeTextures"];
    textureArray = [NSArray arrayWithArray:[textureList componentsSeparatedByString:@","]];
    for (NSString *texture in textureArray) {
        if (![texture isEqualToString:@"none"]) {
            texture = [texture stringByAppendingString:appendhd];
            [self unloadTexturesForFile:texture];
        }
    }
    
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];    
    
    //unload animations
    NSString *animList = [dict objectForKey:@"animations"];
    NSArray *animArray = [NSArray arrayWithArray:[animList componentsSeparatedByString:@","]];
    for (NSString *anim in animArray) {
        if (![anim isEqualToString:@"none"]) {
            [[AnimationController sharedController] unloadAnimationsForGroup:anim];
        }
    }
    
    //unload sounds
    NSString *soundlist = [dict objectForKey:@"sounds"];
    NSArray *soundArray = [NSArray arrayWithArray:[soundlist componentsSeparatedByString:@","]];
    for (NSString *sound in soundArray) {
        if (![sound isEqualToString:@"none"]) {
            [[SoundEngine shared] unloadSoundForKey:sound];                        
        }
    }
    
}





////////////////////////
//  PRIVATE METHODS
////////////////////////

-(void)loadTexturesForFile:(NSString*)filename
{
    NSString *fullFilename = [NSString stringWithFormat:@"%@.plist",filename];
    CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
    [frameCache addSpriteFramesWithFile:fullFilename];        
}

-(void)unloadTexturesForFile:(NSString*)filename
{
    NSString *plistname = [NSString stringWithFormat:@"%@.plist",filename];
    NSString *texturename = [NSString stringWithFormat:@"%@.png",filename];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:plistname];
    [[CCTextureCache sharedTextureCache] removeTextureForKey:texturename];    
}



@end
