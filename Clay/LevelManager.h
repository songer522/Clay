//
//  LevelManager.h
//  Clay
//
//  Created by Brian Cable on 9/15/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Level;

@class GameObjectController;

@interface LevelManager : NSObject
{
    NSMutableArray *_levels;

    NSDictionary *_levelSettings;
    
    Level *_currentLevel;
    Level *_nextLevel;
    
    Level *_loadedLevel;
    
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
-(void)switchToNextLevel;

-(void)initAfterPlayerAndHudInit;

-(NSMutableArray*)getObstacleArray;


@end
