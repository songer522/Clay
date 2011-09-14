//
//  HelloWorldLayer.h
//  Clay
//
//  Created by Brian Cable on 8/23/11.
//  Copyright Xecudev, LLC 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

@class Level;
@class Runner;
@class Player;
@class InputController;
@class GameController;

// HelloWorldLayer
@interface GameLayer : CCLayer
{
    Level *_level;
    
    Player *_player;
    
    GameController *_gameController;
    
    InputController *_inputController;
    
    Runner *_runner2;
    Runner *_runner3;
    
    float _xp;
    
}

@property(nonatomic,retain) Player *player;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

-(void)initCamera;
-(Runner*)initRunner:(Runner*)runner atPosition:(CGPoint)position;
-(void)updateRunner:(Runner*)runner DT:(float)dt;
@end
