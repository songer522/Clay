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
#import "GameLayer.h"
#import "UserData.h"

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
        [[SoundEngine shared] playMusic:_currentLevel.musicName];
        
    }
    
    return self;
}


//TODO: this is an ugly hack since the player references this object and thus first level gets loaded before the player
//object exists. need to fix later
-(void)initAfterPlayerAndHudInit
{
    [_loadedLevel setThirdAction:_thirdAction];
    
}

-(Level*)loadLevelNamed:(NSString*)levelName
{
    NSDictionary *levelSettings = [_levelSettings valueForKey:levelName];
    
    NSString *fileName = [levelSettings valueForKey:@"fileName"];
    NSString *obstacleLayer = [levelSettings valueForKey:@"obstacleLayer"];
    NSString *nextLevelName = [levelSettings valueForKey:@"nextLevelName"];
    NSString *postLevelComicName = [levelSettings valueForKey:@"postLevelComic"];
    NSString *music = [levelSettings valueForKey:@"music"];
    
    _thirdAction = [levelSettings valueForKey:@"thirdAction"];

    NSString *layerList = [levelSettings valueForKey:@"layerList"];

    _playerOffsetY = [[levelSettings valueForKey:@"playerOffsetY"] intValue];
    
    GameLayer *gameLayer = [[LayerManager sharedLayers] currentLayer];
    
    Level *level = [Level levelWithFilename:fileName ObstacleLayer:obstacleLayer LayerList:layerList GameObjectController:_gameObjects Player:gameLayer.player];
    level.nextLevelName = nextLevelName;
    level.postLevelComicName = postLevelComicName;
    level.gameObjects = _gameObjects;
    level.name = levelName;
    level.musicName = music;
    
    _loadedLevel = level;
    
    if (gameLayer.player != nil) {
        [self initAfterPlayerAndHudInit];
    }
    
    if([levelName isEqualToString:@"level4"]) {
        GameLayer *gameLayer = [[LayerManager sharedLayers] currentLayer];
        [gameLayer initializeLaserShow];
    }
    
    return level;
}

-(void)loadNextLevel
{
    //[[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
    _nextLevel = [self loadLevelNamed:_currentLevel.nextLevelName];
    [UserData sharedInstance].currentLevel = [[_currentLevel.name substringFromIndex:5] intValue];
    [[UserData sharedInstance] save];
}

-(void)switchToNextLevel
{
    Level *_levelToUnload = _currentLevel;
    _currentLevel = _nextLevel;
    [_levelToUnload unloadLevel];
    _levelToUnload = nil;
    
    [[SoundEngine shared] playMusic:_currentLevel.musicName];

}

-(void)dealloc
{
    [_levels removeAllObjects];
    [_levels release];
    [_levelSettings release];
    [_currentLevel release];
    [_nextLevel release];
    [_gameObjects release];
    [super dealloc];
}

@end
