//
//  EndGameScene.h
//  Clay
//
//  Created by Brian Cable on 10/12/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//
//  Shows up at the end of the game. Not intended to work exactly like this in the final game. This is supposed to go back to the main menu after it is clicked, but currently it is disabled because the code

#import "CCLayer.h"
#import "cocos2d.h"

@class Sprite;
@class ComicLayer;
@class TrackTimer;

typedef enum {
    END_GAME_TRANSITION_IN,
    END_GAME_TRANSITION_IDLE,
    END_GAME_TRANSITION_COMIC_BONUS
}EndGameState;

@interface EndGameScene : CCLayer
{
    
    Sprite *_comic;
    Sprite *_BonusComic;
    CCScene *_scene;
    
    float _alpha;
    bool _initialized;
    bool _shouldExit;
    EndGameState _state;
    
    
    
    NSString *difficulty;
    NSString *mode;
}

+(CCScene *) scene;
-(void)showTimers;
-(void)update:(float)dt;
@end
