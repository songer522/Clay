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

-(void)loadTexturesForKey:(NSString*)key;
-(void)unloadTexturesForKey:(NSString*)key;


@end
