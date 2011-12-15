//
//  SoundEngine.m
//  Clay
//
//  Created by Brian Cable on 9/23/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "SoundEngine.h"
#import "SimpleAudioEngine.h"
#import "PListLoader.h"

@implementation SoundEngine

static SoundEngine *_shared = nil;

+(SoundEngine*)shared
{
	if (!_shared) {
        _shared = [[self alloc] init];
	}
	return _shared;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
        _audioEngine = [SimpleAudioEngine sharedEngine];
        _audioEngine.mute = false;
        
        _soundMap = [[NSDictionary alloc] initWithDictionary:[PListLoader loadPlistWithName:@"sounds"]];
        _musicMap = [[NSDictionary alloc] initWithDictionary:[PListLoader loadPlistWithName:@"music"]];
        
        _soundMode = SOUND_MODE_NORMAL;
        _masterMusicVolume = 1.0f;
        _masterSfxVolume = 1.0f;
        
        _session = [AVAudioSession sharedInstance];
    }
    
    return self;
}

-(void)preloadAudio
{
    NSEnumerator *enumerator = [_soundMap keyEnumerator];
    id key;
    while ((key = [enumerator nextObject])) {
        NSString *filename = [_soundMap objectForKey:key];
        [_audioEngine preloadEffect:filename];
    }
    
    
    /*
    enumerator = [_musicMap keyEnumerator];
    
    while ((key = [enumerator nextObject])) {
        NSString *filename = [_musicMap objectForKey:key];
        [_audioEngine preloadBackgroundMusic:filename];
    }*/
}

-(void)preloadMusicForKey:(NSString*)key
{
    NSString *filename = [_musicMap objectForKey:key];
    
    NSAssert(filename!=nil,@"Sound '%@' could not be found. Is it in the sounds.plist?",key);
    
    [_audioEngine preloadBackgroundMusic:filename];
}




-(void)loadSoundForKey:(NSString*)key
{
    NSString *filename = [_soundMap objectForKey:key];
    
    NSAssert(filename!=nil,@"Sound '%@' could not be found. Is it in the sounds.plist?",key);
    
    [_audioEngine preloadEffect:filename];
}

-(void)unloadSoundForKey:(NSString*)key
{
    NSString *filename = [_soundMap objectForKey:key];
    
    NSAssert(filename!=nil,@"Sound '%@' could not be found. Is it in the sounds.plist?",key);
    
    [_audioEngine unloadEffect:filename];
}

-(void) playSound:(NSString*)sound
{
    NSString *filename = [_soundMap objectForKey:sound];
    
    NSAssert(filename!=nil,@"Requested sound '%@' not in dictionary. Double-check sounds.plist",sound);
    
    [[SimpleAudioEngine sharedEngine] playEffect:filename];
}

-(void) playMusic:(NSString*)music
{
    NSString *filename = [_musicMap objectForKey:music];
    
    NSAssert(filename!=nil,@"Requested music '%@' not in dictionary. Double-check music.plist",music);

    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:filename];
}

-(void)toggleMute
{
    if (_audioEngine.mute) {
        _audioEngine.mute = false;
    } else {
        _audioEngine.mute = true;
    }
}

-(void)cueFadeIn
{
    _volume = 0.0f;
    _soundMode = SOUND_MODE_FADEIN;
}

-(void)cueFadeOut
{
    _volume = 1.0f;
    _soundMode = SOUND_MODE_FADEOUT;
}

-(void)setMasterMusicVolume:(float)masterVolume
{
    masterVolume = MIN(masterVolume, 1.0f);
    masterVolume = MAX(masterVolume, 0.0f);
    
    _masterMusicVolume = masterVolume;
    [_audioEngine setBackgroundMusicVolume:masterVolume];        
}

-(void)setMasterSfxVolume:(float)masterVolume
{
    masterVolume = MIN(masterVolume, 1.0f);
    masterVolume = MAX(masterVolume, 0.0f);

    _masterSfxVolume = masterVolume;
    [_audioEngine setEffectsVolume:masterVolume];
}

-(void)update:(float)dt
{
    float rate = 0.5f * dt;
    
    switch (_soundMode) {
        case SOUND_MODE_FADEIN:
            _volume += rate;
            if(_volume >= 1.0f) {
                _volume = 1.0f;
                _soundMode = SOUND_MODE_NORMAL;
            }
            [_audioEngine setBackgroundMusicVolume:_volume * _masterMusicVolume];
            [_audioEngine setEffectsVolume:_volume * _masterSfxVolume];
            break;
        case SOUND_MODE_FADEOUT:
            _volume -= rate;
            if(_volume <= 0.0f) {
                _volume = 0.0f;
                _soundMode = SOUND_MODE_NORMAL;
            }
            [_audioEngine setBackgroundMusicVolume:_volume * _masterMusicVolume];
            [_audioEngine setEffectsVolume:_volume * _masterSfxVolume];
        default:
            break;
    }
}

-(void)dealloc
{
    [_audioEngine release];
    [_soundMap release];
    [_session release];
    [_musicMap release];
    [super dealloc];
}

@end
