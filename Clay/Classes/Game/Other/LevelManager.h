//
//  LevelManager.h
//  Clay
//
//  Created by Brian Cable on 9/15/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//
//  Manages the loading and unloading of the current level, switching to the next level, as well as keeping track of the current level and scene, when other classes need to access them.

#import <Foundation/Foundation.h>

@class Level;
@class Boss;

@class GameObjectController;

@interface LevelManager : NSObject
{
    NSMutableArray *_levels;

    NSDictionary *_levelSettings;
    
    Level *_currentLevel;
    
    GameObjectController *_gameObjects;
    NSString *_thirdAction;
    
    int _playerOffsetY;
}

@property(readonly,nonatomic,retain) Level *currentLevel;
@property(readonly,nonatomic,assign) int playerOffsetY;
@property(readonly,nonatomic,retain) GameObjectController *gameObjectFactory;

+(LevelManager*)shared;
-(Level*)prepareLevelNamed:(NSString*)levelName;
-(void)loadLevelNamed:(NSString*) levelName;

-(void)loadNextLevel;

-(void)initAfterPlayerAndHudInit;

-(NSMutableArray*)getObstacleArray;

-(void)dumpMemoryForLevel:(Level*)level;

-(void)receiveBoss:(Boss*)boss;

-(void)reset;

@end
