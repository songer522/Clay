//
//  TextureManager.m
//  Clay
//
//  Created by Brian Cable on 11/14/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "TextureManager.h"
#import "PListLoader.h"

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
        _memoryDictionary = [PListLoader loadPlistWithName:@"memory"];
    }
    return self;
}

-(void)loadTexturesForKey:(NSString*)key
{
    NSString *basename = [_memoryDictionary objectForKey:key];
    
    if (![basename isEqualToString:@"none"]) {
        NSString *filename = [NSString stringWithFormat:@"%@.plist",[_memoryDictionary objectForKey:key]];
        
        CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        [frameCache addSpriteFramesWithFile:filename];        
    }
}

-(void)unloadTexturesForKey:(NSString*)key
{
    NSString *basename = [_memoryDictionary objectForKey:key];
    
    if (![basename isEqualToString:@"none"]) {
        NSString *plistname = [NSString stringWithFormat:@"%@.plist",basename];
        NSString *texturename = [NSString stringWithFormat:@"%@.png",basename];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:plistname];
        [[CCTextureCache sharedTextureCache] removeTextureForKey:texturename];    
    }
}

@end
