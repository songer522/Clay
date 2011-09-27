//
//  SoundEngine.h
//  Clay
//
//  Created by Brian Cable on 9/23/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SimpleAudioEngine;

typedef enum {
    SOUND_MODE_FADEIN,
    SOUND_MODE_FADEOUT,
    SOUND_MODE_NORMAL
}SoundMode;

@interface SoundEngine : NSObject
{
    SimpleAudioEngine *_audioEngine;
    NSDictionary *_soundMap;
    NSDictionary *_musicMap;
    
    float _volume;
    SoundMode _soundMode;
}
+(SoundEngine*)shared;


-(void)playMusic:(NSString*)music;
-(void)playSound:(NSString*)sound;
-(void)preloadAudio;
-(void)toggleMute;
-(void)cueFadeIn;
-(void)cueFadeOut;
-(void)update:(float)dt;
@end
