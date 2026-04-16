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

static BOOL TextureManagerUsesIPadTextureSet(NSString *key)
{
    return [key isEqualToString:@"mainMenu"] ||
        [key isEqualToString:@"chooseLevel"] ||
        [key isEqualToString:@"chooseMode"] ||
        [key isEqualToString:@"optionsScreen"] ||
        [key isEqualToString:@"howtoplayScreen"];
}

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
        
    //NSLog(@"Loading memory for key: %@",key);
    
    //load textures
    NSString *textureList = [dict objectForKey:@"textures"];
    NSArray *textureArray = [NSArray arrayWithArray:[textureList componentsSeparatedByString:@","]];
    for (NSString *texture in textureArray) {
        if (![texture isEqualToString:@"none"]) {
            NSString *resolvedTexture = [self resolvedTextureFilenameForBaseName:texture memoryKey:key];
            if (resolvedTexture != nil) {
                [self loadTexturesForFile:resolvedTexture];
            }
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
    
    NSString *batchObstacles = [dict objectForKey:@"batchObstacles"];
    if(batchObstacles && ![batchObstacles isEqualToString:@"none"]) {
        [self setBatchObstacleFilename:batchObstacles];
    }
    
    [[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
}


-(void)unloadMemoryForKey:(NSString*)key
{
    //NSLog(@"Unloading memory for key: %@",key);

    NSDictionary *dict = [_memoryDictionary objectForKey:key];
    //unload textures
    NSString *textureList = [dict objectForKey:@"textures"];
    NSArray *textureArray = [NSArray arrayWithArray:[textureList componentsSeparatedByString:@","]];
    for (NSString *texture in textureArray) {
        if (![texture isEqualToString:@"none"]) {
            NSString *resolvedTexture = [self resolvedTextureFilenameForBaseName:texture memoryKey:key];
            if (resolvedTexture != nil) {
                [self unloadTexturesForFile:resolvedTexture];
            }
        }
    }
    
    //unload extra textures (stated by removeTextures key... these are not loaded by TextureManager but should be removed)
    textureList = [dict objectForKey:@"removeTextures"];
    textureArray = [NSArray arrayWithArray:[textureList componentsSeparatedByString:@","]];
    for (NSString *texture in textureArray) {
        if (![texture isEqualToString:@"none"]) {
            NSString *resolvedTexture = [self resolvedTextureFilenameForBaseName:texture memoryKey:key];
            if (resolvedTexture != nil) {
                [self unloadTexturesForFile:resolvedTexture];
            }
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


-(NSString*)getBatchObstacleFilename
{
    return _batchObstacleFilename;
}

-(void)setBatchObstacleFilename:(NSString*)batchName
{
    [_batchObstacleFilename release];
    _batchObstacleFilename = [[NSString stringWithFormat:@"%@.png",batchName] retain];
}



////////////////////////
//  PRIVATE METHODS
////////////////////////

-(BOOL)textureAtlasExistsForFilename:(NSString*)filename
{
    NSBundle *bundle = [NSBundle mainBundle];
    return [bundle pathForResource:filename ofType:@"plist"] != nil &&
        [bundle pathForResource:filename ofType:@"png"] != nil;
}

-(NSArray*)candidateTextureFilenamesForBaseName:(NSString*)baseName memoryKey:(NSString*)key
{
    NSMutableArray *candidates = [NSMutableArray arrayWithCapacity:3];
    BOOL usesIPadTextureSet = TextureManagerUsesIPadTextureSet(key);
    BOOL prefersHighResolution = [[GameSettings shared] usingHighResolutionGraphics];
    
    if (usesIPadTextureSet && IS_IPAD) {
        [candidates addObject:[baseName stringByAppendingString:@"-ipad"]];
    } else if (prefersHighResolution) {
        [candidates addObject:[baseName stringByAppendingString:@"-hd"]];
    } else {
        [candidates addObject:baseName];
    }
    
    if (![candidates containsObject:baseName]) {
        [candidates addObject:baseName];
    }
    
    if (prefersHighResolution) {
        NSString *highResolutionName = [baseName stringByAppendingString:@"-hd"];
        if (![candidates containsObject:highResolutionName]) {
            [candidates addObject:highResolutionName];
        }
    }
    
    if (usesIPadTextureSet) {
        NSString *ipadName = [baseName stringByAppendingString:@"-ipad"];
        if (![candidates containsObject:ipadName]) {
            [candidates addObject:ipadName];
        }
    }
    
    return candidates;
}

-(NSString*)resolvedTextureFilenameForBaseName:(NSString*)baseName memoryKey:(NSString*)key
{
    NSArray *candidates = [self candidateTextureFilenamesForBaseName:baseName memoryKey:key];
    for (NSString *candidate in candidates) {
        if ([self textureAtlasExistsForFilename:candidate]) {
            return candidate;
        }
    }
    
    CCLOG(@"TextureManager: could not find atlas for %@ in %@. Tried: %@",
          baseName,
          key,
          [candidates componentsJoinedByString:@", "]);
    return nil;
}

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

-(void)dealloc
{
    [_memoryDictionary release];
    [_batchObstacleFilename release];
    [super dealloc];
}

@end
