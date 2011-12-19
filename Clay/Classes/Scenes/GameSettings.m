//
//  GameSettings.m
//  Clay
//
//  Created by Brian Cable on 11/16/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "GameSettings.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#import "PListLoader.h"

#define SETTING_IS_STUTTER_MODE_DEFAULT 1

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
        [self loadFromSettingsPlist];
        _usingHighResolutionGraphics = [self calculateShouldUseHighRes];
        [self setGlobal:[NSString stringWithFormat:@"%d",SETTING_IS_STUTTER_MODE_DEFAULT] ForKey:@"isStutterMode"];
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

+ (NSString *) platform{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

-(bool)usingHighResolutionGraphics
{
    return _usingHighResolutionGraphics;
}

-(bool)isStutterMode
{
    return _isStutterMode;
}

-(bool)calculateShouldUseHighRes
{
    //ONLY USE IN INIT: EXPENSIVE CALCULATION THAT SHOULD ONLY BE DONE ONCE, NOT EVERY FRAME. USE 'usingHighResolutionGraphics' INSTEAD.
    return [[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2 && [GameSettings shouldUseRetinaForDevice];
}

+(bool)shouldUseRetinaForDevice
{
    //NOTE: eventually switch ipad 2's back to YES
    NSString *platform = [self platform];
    if ([platform isEqualToString:@"iPhone1,1"]) return NO;     //iphone 1g
    if ([platform isEqualToString:@"iPhone1,2"]) return NO;     //iphone 3g
    if ([platform isEqualToString:@"iPhone2,1"]) return NO;     //iphone 3gs
    if ([platform isEqualToString:@"iPhone3,1"]) return YES;    //iphone 4
    if ([platform isEqualToString:@"iPod1,1"]) return NO;       //ipod touch 1g
    if ([platform isEqualToString:@"iPod2,1"]) return NO;       //ipod touch 2g
    if ([platform isEqualToString:@"iPod3,1"]) return NO;       //ipod touch 3g
    if ([platform isEqualToString:@"iPod4,1"]) return NO;       //ipod touch 4g
    if ([platform isEqualToString:@"iPad1,1"]) return NO;       //ipad
    if ([platform isEqualToString:@"iPad2,1"]) return NO;      //ipad 2 (wifi)
    if ([platform isEqualToString:@"iPad2,2"]) return NO;      //ipad 2 (gsm)
    if ([platform isEqualToString:@"iPad2,3"]) return NO;      //ipad 2 (cdma)
    if ([platform isEqualToString:@"i386"]) return YES;         //simulator, which can always be changed manually
    if ([platform isEqualToString:@"iPod touch"]) return NO;
    return YES; //assume future devices can all handle the retina display
}

-(void)loadFromSettingsPlist
{
    NSDictionary *settings = [PListLoader loadPlistWithName:@"settings"];
    NSDictionary *appSettings = [settings objectForKey:@"app"];
    NSString *versionNumber = [appSettings objectForKey:@"versionNumber"];
    [self setGlobal:versionNumber ForKey:@"versionNumber"];
}

-(void)dealloc
{
    [_settings removeAllObjects];
    [_settings release];
}

@end
