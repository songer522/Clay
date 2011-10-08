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
@class SavePoint;
@class InputController;
@class GameController;
@class SoundEngine;
@class ParticleSystem;
@class ComicLayer;
@class Sprite;
@class HudLayer;

// HelloWorldLayer
@interface GameLayer : CCLayer
{
    Level *_level;
    
    Player *_player;
    
    GameController *_gameController;
    
    InputController *_inputController;
    
    SavePoint *_savePoint;
    
    ParticleSystem *_dustTest;
    
    HudLayer *_hud;
    
}

@property(nonatomic,retain) Player *player;
@property(readonly,nonatomic,retain) GameController *gameController;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
-(void)initForLevel;
-(void)initCamera;
-(void)updateLogic:(ccTime)dt;

-(void)setupHud:(HudLayer*)hud;
-(HudLayer*)getHud;


-(NSMutableArray*)getGameObjectsList;

//the following serve as our pause and unpause functions
//based on code posted at: http://www.cocos2d-iphone.org/forum/topic/1232
-(void)onEnter;
-(void)onExit;

@end
