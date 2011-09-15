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

@implementation LevelManager

@synthesize currentLevel = _currentLevel;

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
        
        _levelSettings = [NSDictionary dictionaryWithDictionary:[PListLoader loadPlistWithName:@"levels"]];
        
        NSString *startingLevel = [_levelSettings valueForKey:@"startingLevel"];
        
        [self loadLevelNamed:startingLevel];
        
    }
    
    return self;
}

-(void)loadLevelNamed:(NSString*)levelName
{
    NSDictionary *levelSettings = [_levelSettings valueForKey:levelName];
    
    NSString *fileName = [levelSettings valueForKey:@"fileName"];
    NSString *obstacleLayer = [levelSettings valueForKey:@"obstacleLayer"];
    NSString *nextLevelName = [levelSettings valueForKey:@"nextLevelName"];
    NSString *layerList = [levelSettings valueForKey:@"layerList"];
    
    Level *level = [Level levelWithFilename:fileName ObstacleLayer:obstacleLayer LayerList:layerList];
    level.nextLevelName = nextLevelName;
    level.gameObjects = _gameObjects;
    
    _currentLevel = level;
}

@end
