//
//  EndLevelScene.h
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
    END_LEVEL_TRANSITION_IN,
    END_LEVEL_TRANSITION_IDLE,
    END_LEVEL_TRANSITION_OUT
}EndLevelState;

@interface EndLevelScene : CCLayer
{
    Sprite *_endGame;
    Sprite *_bestTime;
    ComicLayer *_comicLayer;
    
    CCScene *_scene;
    
    float _alpha;
    bool _initialized;
    
    EndLevelState _state;
    
    TrackTimer *_timer;
    TrackTimer *_besttimer;
}

+(CCScene *) scene;

-(void)update:(float)dt;
@end
