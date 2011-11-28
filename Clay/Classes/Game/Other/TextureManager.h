//
//  TextureManager.h
//  Clay
//
//  Created by Brian Cable on 11/14/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface TextureManager : NSObject
{
    NSDictionary *_memoryDictionary;
}

+(TextureManager*)shared;


#pragma mark - public methods
-(void)loadMemoryForKey:(NSString*)key;
-(void)unloadMemoryForKey:(NSString*)key;


#pragma mark - private methods
-(void)loadTexturesForFile:(NSString*)filename;
-(void)unloadTexturesForFile:(NSString*)filename;


@end
