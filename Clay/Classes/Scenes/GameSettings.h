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
    bool _usingHighResolutionGraphics;
}

+(GameSettings*)shared;



-(void)setGlobal:(NSString*)setting ForKey:(NSString*)key;
-(NSString*)getGlobalForKey:(NSString*)key;

+(bool)shouldUseRetinaForDevice; //tell whether we want to use low-res for this device
+(NSString*)platform;
-(bool)usingHighResolutionGraphics;  //use throughout code to check high res, includes 'shouldUseRetinaForDevice' method
-(bool)calculateShouldUseHighRes; //ONLY SHOULD BE CALLED BY INIT, TO SAVE PROCESSING TIME

-(void)loadFromSettingsPlist;

@end
