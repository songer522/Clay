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
#import "TextureManager.h"
#import "Boss.h"
#import "GameSettings.h"
#import "Appirater.h"
#import "BestTimes.h"

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
        
        _levelSettings = [[[NSDictionary alloc] initWithDictionary:[PListLoader loadPlistWithName:@"levels"]] retain];
    }
    
    return self;
}


//TODO: this is an ugly hack since the player references this object and thus first level gets loaded before the player
//object exists. need to fix later
-(void)initAfterPlayerAndHudInit
{
    [_currentLevel setHudButtonsAndThirdAction:_thirdAction];
}

-(Level*)prepareLevelNamed:(NSString*)levelName
{
    NSDictionary *levelSettings = [_levelSettings valueForKey:levelName];
    
    NSString *fileName = [levelSettings valueForKey:@"fileName"];
    NSString *obstacleLayer = [levelSettings valueForKey:@"obstacleLayer"];
    
    if ([GameSettings usingHighResolutionGraphics]){
        // Use HD level for High Res screens
        NSArray *filenameParts = [fileName componentsSeparatedByString:@"."];
        NSMutableString *filenameMuta = [[NSMutableString alloc] initWithString:[filenameParts objectAtIndex:0]];
        [filenameMuta appendString:@"_hd."];
        [filenameMuta appendString:[filenameParts objectAtIndex:1]];
        
        fileName = [NSString stringWithString:filenameMuta];
    }
    
    _thirdAction = [NSString stringWithString:[levelSettings valueForKey:@"thirdAction"]];

    NSString *layerList = [NSString stringWithString:[levelSettings valueForKey:@"layerList"]];
    
    _playerOffsetY = [[levelSettings valueForKey:@"playerOffsetY"] intValue];
    
    GameLayer *gameLayer = [[LayerManager sharedLayers] currentLayer];
    
    Level *level = [Level levelWithFilename:fileName ObstacleLayer:obstacleLayer LayerList:layerList GameObjectController:_gameObjects Player:gameLayer.player];
    
    level.nextLevelName = [NSString stringWithString:[levelSettings valueForKey:@"nextLevelName"]];
    level.postLevelComicName = [NSString stringWithString:[levelSettings valueForKey:@"postLevelComic"]];
    level.gameObjects = _gameObjects;
    level.name = [NSString stringWithString:levelName];
    level.musicName = [NSString stringWithString:[levelSettings valueForKey:@"music"]];
    level.preComicName = [NSString stringWithString:[levelSettings valueForKey:@"preComic"]];

    //camera needs to know what the level name is so call after level data is created
    [[Camera sharedCamera] setBoundaries:[level getLevelBoundaries] Level:level];

    return level;
}

-(void)loadLevelNamed:(NSString*) levelName
{
    //this method gets called on the first level loaded, before currentlevel is set
    if(_currentLevel !=nil) {
        [self dumpMemoryForLevel:_currentLevel];        
    }
    
    [[TextureManager shared] loadMemoryForKey:levelName];    
    
    _currentLevel = [self prepareLevelNamed:levelName];

    [UserData sharedInstance].currentLevel = [[_currentLevel.name substringFromIndex:5] intValue];
    [[UserData sharedInstance] save];
    
    GameLayer *gameLayer = [[LayerManager sharedLayers] currentLayer];
    if (gameLayer.player != nil) {
        [self initAfterPlayerAndHudInit];
    }
    
    //stop existing laser show, if going, and start new one
    [gameLayer stopLaserShow];
    if([levelName isEqualToString:@"level4"]) {
        [gameLayer initializeLaserShow];
    } else {
    }
    
    //show 8-bit skin if level 7, otherwise show regular skin
    int levelNumber = [[_currentLevel.name substringFromIndex:5] intValue];
    if (levelNumber == 7) {
        [gameLayer.player updateSkin:SKINTYPE_8BIT];
    } else {
        [gameLayer.player updateSkin:SKINTYPE_REGULAR];
    }
    
    [[SoundEngine shared] playMusic:_currentLevel.musicName];
    
    [[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];

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

-(void)dumpMemoryForLevel:(Level*)level
{
    NSString *levelName = [NSString stringWithString:level.name];

    [level release];
    
    [[TextureManager shared] unloadMemoryForKey:levelName];
}

-(void)recordLevelTime:(float)time
{
    NSString *levelName = [NSString stringWithString:_currentLevel.name];
    NSString *difficulty = [[GameSettings shared] getGlobalForKey:@"gameDifficulty"];
    [[BestTimes shared] reportTime:time forLevel:levelName forDifficulty:difficulty];
}

-(NSMutableArray*)getObstacleArray
{
    return _currentLevel.obstacleSprites;
}

-(void)reset
{
    _currentLevel = nil;
    
    //did this because some string values are not sticking around after going restarting the game a few times
    if (_levelSettings!=nil) {
        //[_levelSettings release]; can't do because something is deallocating it
        _levelSettings = [[NSDictionary alloc] initWithDictionary:[PListLoader loadPlistWithName:@"levels"]];        
    }
}

-(void)dealloc
{
    [_levels removeAllObjects];
    [_levels release];
    [_levelSettings release];
    [_currentLevel release];
    [_gameObjects release];
    [super dealloc];
}

@end
