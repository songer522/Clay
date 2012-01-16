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
    
    float _masterMusicVolume;
    float _masterSfxVolume;
    
    float _volume;
    float _sfxVolume;
    SoundMode _soundMode;
    SoundMode _sfxMode;
    
    AVAudioSession *_session;
    
    bool _enabled;
}
+(SoundEngine*)shared;


-(void)playMusic:(NSString*)music;
-(void)playSound:(NSString*)sound;
-(void)preloadAudio;
-(void)preloadMusicForKey:(NSString*)key;
-(void)loadSoundForKey:(NSString*)key;
-(void)unloadSoundForKey:(NSString*)key;
-(void)toggleMute;
-(void)cueSoundFxFadeIn;
-(void)cueSoundFxFadeOut;
-(void)cueFadeIn;
-(void)cueFadeOut;

-(float)getMastersMusicVolume;
-(float)getMastersSfxVolume;
-(void)setMasterMusicVolume:(float)masterVolume;
-(void)setMasterSfxVolume:(float)masterVolume;
-(void)update:(float)dt;
@end
