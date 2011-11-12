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
#import "Boss.h"

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
        
        _currentLevel = [self prepareLevelNamed:startingLevel];
        
    }
    
    return self;
}


//TODO: this is an ugly hack since the player references this object and thus first level gets loaded before the player
//object exists. need to fix later
-(void)initAfterPlayerAndHudInit
{
    [_loadedLevel setHudButtonsAndThirdAction:_thirdAction];
    
}

-(Level*)prepareLevelNamed:(NSString*)levelName
{
    
    [[AnimationController sharedController] loadAnimationsForGroup:levelName];
    
    NSDictionary *levelSettings = [_levelSettings valueForKey:levelName];
    
    NSString *fileName = [levelSettings valueForKey:@"fileName"];
    NSString *obstacleLayer = [levelSettings valueForKey:@"obstacleLayer"];
    NSString *nextLevelName = [levelSettings valueForKey:@"nextLevelName"];
    NSString *postLevelComicName = [levelSettings valueForKey:@"postLevelComic"];
    NSString *music = [levelSettings valueForKey:@"music"];
    NSString *preComicName = [levelSettings valueForKey:@"preComic"];
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2){
        // Use HD level for High Res screens
        NSArray *filenameParts = [fileName componentsSeparatedByString:@"."];
        NSMutableString *filenameMuta = [[NSMutableString alloc] initWithString:[filenameParts objectAtIndex:0]];
        [filenameMuta appendString:@"_hd."];
        [filenameMuta appendString:[filenameParts objectAtIndex:1]];
        
        fileName = [NSString stringWithString:filenameMuta];
        
    }
    
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
    level.preComicName = preComicName;
    
    _loadedLevel = level;
    
    if (gameLayer.player != nil) {
        [self initAfterPlayerAndHudInit];
    }
    
    //stop existing laser show, if going, and start new one
    [gameLayer stopLaserShow];
    if([levelName isEqualToString:@"level4"]) {
        [gameLayer initializeLaserShow];
    } else {
    }
    
    return level;
}

-(void)loadLevelNamed:(NSString*) levelName
{
    _nextLevel = [self prepareLevelNamed:levelName];
    [UserData sharedInstance].currentLevel = [[_currentLevel.name substringFromIndex:5] intValue];
    [[UserData sharedInstance] save];
}

-(void)loadNextLevel
{
    [self loadLevelNamed:_currentLevel.nextLevelName];
}

-(void)receiveBoss:(Boss*)boss
{
    GameLayer *gameLayer = [[LayerManager sharedLayers] currentLayer];
    [gameLayer setBoss:boss];
}

-(void)switchToNextLevel
{
    Level *_levelToUnload = _currentLevel;
    _currentLevel = _nextLevel;
    [_levelToUnload unloadLevel];
    _levelToUnload = nil;

    //show 8-bit skin if level 7, otherwise show regular skin
    GameLayer *gameLayer = [[LayerManager sharedLayers] currentLayer];
    int levelNumber = [[_currentLevel.name substringFromIndex:5] intValue];
    if (levelNumber == 7) {
        [gameLayer.player updateSkin:SKINTYPE_8BIT];
    } else {
        [gameLayer.player updateSkin:SKINTYPE_REGULAR];
    }
    
    [[SoundEngine shared] playMusic:_currentLevel.musicName];

}

-(NSMutableArray*)getObstacleArray
{
    return _currentLevel.obstacleSprites;
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
