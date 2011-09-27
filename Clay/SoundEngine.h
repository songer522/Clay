//
//  SoundEngine.h
//  Clay
//
//  Created by Brian Cable on 9/23/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SimpleAudioEngine;

@interface SoundEngine : NSObject
{
    SimpleAudioEngine *_audioEngine;
    NSDictionary *_soundMap;
    NSDictionary *_musicMap;
}
+(SoundEngine*)shared;


-(void)playMusic:(NSString*)music;
-(void)playSound:(NSString*)sound;
-(void)preloadAudio;

@end
