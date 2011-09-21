//
//  LevelManager.m
//  Clay
//
//  Created by Brian Cable on 9/15/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "LevelManager.h"
#import "PListLoader.h"
#import "GameObjectController.h"
#import "Level.h"
#import "LayerManager.h"
#import "Player.h"

@implementation LevelManager

@synthesize currentLevel = _currentLevel;
@synthesize playerOffsetY = _playerOffsetY;
@synthesize gameObjectFactory = _gameObjects;

static LevelManager *_shared = nil;

+(LevelManager*)shared
{
	if (!_shared) {
        _shared = [[self alloc] init];
	}
	return _shared;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        _gameObjects = [[GameObjectController alloc] init];
        
        _levelSettings = [[NSDictionary alloc] initWithDictionary:[PListLoader loadPlistWithName:@"levels"]];
        
        NSString *startingLevel = [_levelSettings valueForKey:@"startingLevel"];
        
        _currentLevel = [self loadLevelNamed:startingLevel];
        
    }
    
    return self;
}

-(Level*)loadLevelNamed:(NSString*)levelName
{
    NSDictionary *levelSettings = [_levelSettings valueForKey:levelName];
    
    NSString *fileName = [levelSettings valueForKey:@"fileName"];
    NSString *obstacleLayer = [levelSettings valueForKey:@"obstacleLayer"];
    NSString *nextLevelName = [levelSettings valueForKey:@"nextLevelName"];

    NSString *layerList = [levelSettings valueForKey:@"layerList"];

    _playerOffsetY = [[levelSettings valueForKey:@"playerOffsetY"] intValue];
    
    Level *level = [Level levelWithFilename:fileName ObstacleLayer:obstacleLayer LayerList:layerList GameObjectController:_gameObjects];
    level.nextLevelName = nextLevelName;
    level.gameObjects = _gameObjects;
    
    return level;
}

-(void)loadNextLevel
{
    _nextLevel = [self loadLevelNamed:_currentLevel.nextLevelName];
}

-(void)switchToNextLevel
{
    _currentLevel = _nextLevel;
}

@end
