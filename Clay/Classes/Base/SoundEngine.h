//
//  SoundEngine.h
//  Clay
//
//  Created by Brian Cable on 9/23/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//
//  A simple wrapper for the sound engine to provide added support for muting, fading in and fading out of the sound.

//  TODO: there might be something here that is interfering with the VideoPlayer and causing the ringer volume control bug to happen (see Github issue #59). The video player itself is the other likely culprit.

#import <Foundation/Foundation.h>

@class SimpleAudioEngine;

typedef enum {
    SOUND_MODE_FADEIN,
    SOUND_MODE_FADEOUT,
    SOUND_MODE_NORMAL
}SoundMode;

@class AVAudioSession;

@interface SoundEngine : NSObject
{
    SimpleAudioEngine *_audioEngine;
    NSDictionary *_soundMap;
    NSDictionary *_musicMap;
    
    float _volume;
    SoundMode _soundMode;
    
    AVAudioSession *_session;
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
