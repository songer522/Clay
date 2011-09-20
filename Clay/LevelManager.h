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
    
    GameObjectController *_gameObjects;
    
    int _playerOffsetY;
}

@property(readonly,nonatomic,retain) Level *currentLevel;
@property(readonly,nonatomic,assign) int playerOffsetY;
@property(readonly,nonatomic,retain) GameObjectController *gameObjectFactory;

+(LevelManager*)shared;
-(void)loadLevelNamed:(NSString*)levelName;

@end
