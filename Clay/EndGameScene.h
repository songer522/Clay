//
//  EndGameScene.h
//  Clay
//
//  Created by Brian Cable on 10/12/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "CCLayer.h"
#import "cocos2d.h"

@class Sprite;
@class ComicLayer;

typedef enum {
    END_GAME_TRANSITION_IN,
    END_GAME_TRANSITION_IDLE,
    END_GAME_TRANSITION_OUT
}EndGameState;

@interface EndGameScene : CCLayer
{
    Sprite *_endGame;
    ComicLayer *_comicLayer;
    
    CCScene *_scene;
    
    float _alpha;
    
    EndGameState _state;
}

+(CCScene *) scene;

-(void)update:(float)dt;
@end
