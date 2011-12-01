//
//  HelloWorldLayer.h
//  Clay
//
//  Created by Brian Cable on 8/23/11.
//  Copyright Xecudev, LLC 2011. All rights reserved.
//
//  Primary layer for the game. Where most of the real action gets called (player, obstacles, movement, collision, etc)

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
@class LaserShow;
@class GameDebugLayer;
@class Boss;
@class RainyLevelEffects;

// HelloWorldLayer
@interface GameLayer : CCLayer
{
    Level *_level;
    
    Player *_player;
    
    GameController *_gameController;
    
    InputController *_inputController;
    
    SavePoint *_savePoint;
    
    HudLayer *_hud;
    
    GameDebugLayer *_debugLayer;
    
    LaserShow *_laserShow;
    RainyLevelEffects *_rainyLevelEffects;
    
    Boss *_boss;
    
    bool _paused;
    
    double time;
    
}

@property(nonatomic,retain) Player *player;
@property(readonly,nonatomic,retain) GameController *gameController;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
-(void)setupLayers;
-(void)initForLevel;
-(void)initCamera;
-(void)updateLogic:(ccTime)dt;

-(void)initializeLaserShow;
-(void)stopLaserShow;

-(void)initializeRainyLevel;
-(void)stopRainyLevel;

-(void)setupHud;
-(HudLayer*)getHud;
-(void)setBoss:(Boss*)boss;
-(void)unpause;
-(void)updateTriggers:(float)dt;

-(void)updatePlayerDeath:(float)dt;

-(void)startLevel:(NSString*)levelName;
-(void)endLevel;

-(NSMutableArray*)getGameObjectsList;

//the following serve as our pause and unpause functions
//based on code posted at: http://www.cocos2d-iphone.org/forum/topic/1232
-(void)onEnter;
-(void)onExit;

@end
