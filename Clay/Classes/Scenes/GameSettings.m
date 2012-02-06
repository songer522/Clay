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
#import "Database.h"

#define SETTING_IS_STUTTER_MODE_DEFAULT 0

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
        NSDictionary *gameSettings = loadData(@"savedSettings");
        _savedSettings = [[NSMutableDictionary alloc] initWithDictionary:gameSettings];
        _settings = [[NSMutableDictionary alloc] initWithDictionary:gameSettings];
        [self loadFromSettingsPlist];
        _usingHighResolutionGraphics = [self calculateShouldUseHighRes];
        [self setStutterMode:SETTING_IS_STUTTER_MODE_DEFAULT];
        
    }
    return self;
}

-(void)eraseData
{
    if (_savedSettings!=nil) {
        [_savedSettings removeAllObjects];
        [_savedSettings release];
    }
    
    if (_settings!=nil) {
        [_settings removeAllObjects];
        [_settings release];
    }
    _savedSettings = [[NSMutableDictionary alloc] initWithCapacity:30];
    
    _settings = [[NSMutableDictionary alloc] initWithCapacity:30];
    [self loadFromSettingsPlist];
    
    [self saveToDisk];
}

-(void)setGlobal:(NSString*)setting ForKey:(NSString*)key;
{
    [_settings setValue:[NSString stringWithString:setting] forKey:key];
}

-(NSString*)getGlobalForKey:(NSString*)key
{
    NSString *returnVal = [_settings valueForKey:key];
    
    if (returnVal) {
        return returnVal;        
    }
    
    return @"";
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

-(void)setStutterMode:(int)shouldStutter
{
    [self setGlobal:[NSString stringWithFormat:@"%d",shouldStutter] ForKey:@"isStutterMode"];
    _isStutterMode = shouldStutter;
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
    NSString *showFps = [appSettings objectForKey:@"showFps"];
    NSString *unlockEverything = [appSettings objectForKey:@"unlockEverything"];
    [self setGlobal:versionNumber ForKey:@"versionNumber"];
    [self setGlobal:showFps ForKey:@"showFps"];
    [self setGlobal:unlockEverything ForKey:@"unlockEverything"];
}

-(void)setSerializedGlobal:(NSString*)setting ForKey:(NSString*)key
{
    [_savedSettings setValue:[NSString stringWithString:setting] forKey:key];
    [_settings setValue:[NSString stringWithString:setting] forKey:key];
}

-(void)saveToDisk
{
    saveData(_savedSettings, @"savedSettings");
}

-(void)setUnlockedForKey:(NSString*)key
{
    //check current value, see if needs to be new unlock or not.
    NSString *value = [self getGlobalForKey:key];
    if ([value isEqualToString:@"unlocked"] || [value isEqualToString:@"newUnlocked"]) {
        //do nothing we're already unlocked
    } else {
        [self setSerializedGlobal:@"newUnlocked" ForKey:key];
    }
}

-(void)setNotNewForKey:(NSString*)key
{
    //check current value, and only change if the current value is newly unlocked
    //(this function gets called anytime the proper action occurs, not only when unlocked)
    NSString *value = [self getGlobalForKey:key];
    if ([value isEqualToString:@"newUnlocked"]) {
        [self setSerializedGlobal:@"unlocked" ForKey:key];
    }
}

-(LockType)getLockTypeForKey:(NSString*)key
{
    NSString *value = [self getGlobalForKey:key];
    if ([value isEqualToString:@"unlocked"]) {
        return LOCKTYPE_UNLOCKED;
    } else if([value isEqualToString:@"newUnlocked"]) {
        return LOCKTYPE_UNLOCKED_NEW;
    } else if(![value isEqualToString:@"locked"]) {
        [self setSerializedGlobal:@"locked" ForKey:key];
    }
    
    return LOCKTYPE_LOCKED;
}


-(void)dealloc
{
    [_settings removeAllObjects];
    [_settings release];
}

@end
