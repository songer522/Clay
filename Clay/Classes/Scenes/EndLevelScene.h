//
//  EndLevelScene.h
//  Clay
//
//  Created by Song Yang on 1/13/12.
//  Copyright (c) 2012 XecuDev. All rights reserved.
//

#import "CCLayer.h"
#import "cocos2d.h"


@class Sprite;
@class ComicLayer;
@class TrackTimer;
@class ActionButton;

typedef enum {
    END_LEVEL_TRANSITION_IN,
    END_LEVEL_TRANSITION_IDLE,
    END_LEVEL_TRANSITION_OUT
}EndGameStates;

@interface EndLevelScene : CCLayer
{
    Sprite *_endGameComic;
  
    
    CCScene *_scene;
    
    float _alpha;
    bool _initialized;
    
    EndGameStates _state;
    

}

+(CCScene *) scene;

-(void)update:(float)dt;
@end
