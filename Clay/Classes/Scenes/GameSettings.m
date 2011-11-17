//
//  GameSettings.m
//  Clay
//
//  Created by Brian Cable on 11/16/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "GameSettings.h"

@implementation GameSettings


static GameSettings *_shared = nil;

+(GameSettings*)shared
{
	if (!_shared) {
        _shared = [[self alloc] init];
	}
	return _shared;
}

-(id)init
{
    if ((self=[super init])) {
        _settings = [[NSMutableDictionary alloc] initWithCapacity:30];
    }
    return self;
}

-(void)setGlobal:(NSString*)setting ForKey:(NSString*)key;
{
    [_settings setValue:[NSString stringWithString:setting] forKey:key];
}

-(NSString*)getGlobalForKey:(NSString*)key
{
    return [_settings valueForKey:key];
}

-(void)dealloc
{
    [_settings removeAllObjects];
    [_settings release];
}

@end
