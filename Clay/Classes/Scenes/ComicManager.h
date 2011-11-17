//
//  ComicManager.h
//  Clay
//
//  Created by Brian Cable on 9/26/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//
//  Manages what needs to be done in order for the scene transitions between the end of one level, the displaying of the video (comic), and the transition back to gameplay for the next level.


#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class VideoPlayer;
@class ComicLayer;
@class GameLayer;

typedef enum {
    COMIC_PHASE_BARS_IN,
    COMIC_PHASE_PLAY_VIDEO,
    COMIC_PHASE_LOAD_LEVEL,
    COMIC_PHASE_BARS_OUT,
    COMIC_PHASE_STARTING_VIDEO,
    COMIC_PHASE_PLAY_LEVEL
}ComicPhase;

@interface ComicManager : NSObject
{
    bool _isActive;
    bool _loadNextLevel;
    
    
    GameLayer *_gameLayer;
    VideoPlayer *_videoPlayer;
    NSDictionary *_videoList;
    ComicLayer *_comicLayer;
    
    ComicPhase _phase;
    
    bool _showEndGame;
    bool _introMovie;
    
    NSString *_videoFileName;
}

@property(nonatomic,retain)GameLayer *gameLayer;
@property(nonatomic,assign)bool loadNextLevel;
@property(nonatomic,assign)bool isActive;

+(ComicManager*)shared;

+(id)instance;

-(void)preload;
-(void)update:(ccTime)dt;

-(void)startComic:(NSString*)comic;
-(void)startComic:(NSString*)comic StartPhase:(ComicPhase)phase;
-(void)switchToPhase:(ComicPhase)phase;

-(void)finishedAction;
-(void)resetComicLayer;

-(void)endTheGame;

@end
 