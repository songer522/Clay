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
    bool _inComic;
    bool _handledPauseEvent; //set when pause happens so that a second call to pause that same frame doesn't invalidate the first click. for example, when the pause icon is touched when paused, pausing would be called first by the pause layer, then again by the gamelayer.
    double time;
    
}

@property(nonatomic,retain) Player *player;
@property(readonly,nonatomic,retain) GameController *gameController;
@property(nonatomic,assign) bool handledPauseEvent;
@property(nonatomic,assign) bool inComic;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

-(void)initializeLaserShow;
-(void)stopLaserShow;

-(void)initializeRainyLevel;
-(void)stopRainyLevel;

-(void)setupHud;
-(HudLayer*)getHud;
-(void)setBoss:(Boss*)boss;
-(Boss*)getBoss;
-(void)pause;
-(void)unpause;

-(void)startLevel:(NSString*)levelName;
-(void)initForLevel; //called by comic manager when switching levels
-(void)restartLevel; //called by pause screen when restarting the level
-(void)endLevel;

-(void)switchToChooseLevel;
-(void)switchToChooseMode;

-(NSMutableArray*)getGameObjectsList;


@end
