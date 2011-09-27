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
        //_audioEngine.mute = true;
        
        _soundMap = [[NSDictionary alloc] initWithDictionary:[PListLoader loadPlistWithName:@"sounds"]];
        _musicMap = [[NSDictionary alloc] initWithDictionary:[PListLoader loadPlistWithName:@"music"]];
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
    
    enumerator = [_musicMap keyEnumerator];
    
    while ((key = [enumerator nextObject])) {
        NSString *filename = [_musicMap objectForKey:key];
        [_audioEngine preloadBackgroundMusic:filename];
    }
}

-(void) playSound:(NSString*)sound
{
    NSString *filename = [_soundMap objectForKey:sound];
    
    NSAssert(filename!=nil,@"Requested sound not in dictionary. Double-check sounds.plist");
    
    [[SimpleAudioEngine sharedEngine] playEffect:filename];
}

-(void) playMusic:(NSString*)music
{
    NSString *filename = [_musicMap objectForKey:music];
    
    NSAssert(filename!=nil,@"Requested music file not in dictionary. Double-check music.plist");
    
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:filename];
}

@end
