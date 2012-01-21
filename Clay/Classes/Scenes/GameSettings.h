//
//  GameSettings.h
//  Clay
//
//  Created by Brian Cable on 11/16/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    LOCKTYPE_NOT_ENABLED,
    LOCKTYPE_UNLOCKED,
    LOCKTYPE_UNLOCKED_NEW,
    LOCKTYPE_LOCKED
}LockType;

@interface GameSettings : NSObject
{
    NSMutableDictionary *_settings;
    NSMutableDictionary *_savedSettings;
    bool _usingHighResolutionGraphics;
    bool _isStutterMode;
}

+(GameSettings*)shared;



-(void)setGlobal:(NSString*)setting ForKey:(NSString*)key;
-(void)setSerializedGlobal:(NSString*)setting ForKey:(NSString*)key; //these values get saved in between app sessions
-(NSString*)getGlobalForKey:(NSString*)key;

+(bool)shouldUseRetinaForDevice; //tell whether we want to use low-res for this device
+(NSString*)platform;
-(bool)usingHighResolutionGraphics;  //use throughout code to check high res, includes 'shouldUseRetinaForDevice' method
-(bool)calculateShouldUseHighRes; //ONLY SHOULD BE CALLED BY INIT, TO SAVE PROCESSING TIME

-(void)setStutterMode:(int)shouldStutter;
-(bool)isStutterMode;
-(void)loadFromSettingsPlist;
-(void)saveToDisk;
-(void)setUnlockedForKey:(NSString*)key;
-(LockType)getLockTypeForKey:(NSString*)key;
-(void)setNotNewForKey:(NSString*)key;
-(void)eraseData;

@end
