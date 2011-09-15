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
}

@property(readonly,nonatomic,retain)Level *currentLevel;

+(LevelManager*)shared;
-(void)loadLevelNamed:(NSString*)levelName;

@end
