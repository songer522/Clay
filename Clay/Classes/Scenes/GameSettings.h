//
//  GameSettings.h
//  Clay
//
//  Created by Brian Cable on 11/16/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameSettings : NSObject
{
    NSMutableDictionary *_settings;
}

+(GameSettings*)shared;

-(void)setGlobal:(NSString*)setting ForKey:(NSString*)key;
-(NSString*)getGlobalForKey:(NSString*)key;

@end
