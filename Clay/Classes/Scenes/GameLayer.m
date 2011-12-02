//
//  HelloWorldLayer.m
//  Clay
//
//  Created by Brian Cable on 8/23/11.
//  Copyright Xecudev, LLC 2011. All rights reserved.
//


// Import the interfaces
#import "GameLayer.h"
#import "BaseClasses.h"
#import "GCHelper.h"
#import "ComicManager.h"
#import "HudLayer.h"
#import "Battery.h"
#import "GameController.h"
#import "Player.h"
#import "BossFactory.h"
#import "SavePoint.h"
#import "LaserShow.h"
#import "RainyLevelEffects.h"
#import "TextureManager.h"
#import "GameDebugLayer.h"
#import "GameSettings.h"
#import "Appirater.h"
#import "TrackTimer.h"

#define DEBUG_DRAW_BOUNDING_BOXES 0 

// HelloWorldLayer implementation
@implementation GameLayer

@synthesize player = _player;
@synthesize gameController = _gameController;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    [[LayerManager sharedLayers] setCurrentScene:scene];
	
	// 'layer' is an autorelease object.
	GameLayer *layer = [GameLayer node];
	
    
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        
        [self setVisible:NO];

        [[CCDirector sharedDirector] setProjection:CCDirectorProjection2D];

        [[LayerManager sharedLayers] setCurrentLayer:self];
        
        [[TextureManager shared] loadMemoryForKey:@"gameScene"];
        
        _gameController = [GameController gameController];
        [_gameController setGameLayer:self];
        
        _inputController = [InputController inputController];
        [self addChild:_inputController];       //need to so its scheduled selectors will be trigger
        
        _player = [Player instance];
        
        _savePoint = [SavePoint instance];
        
        [self schedule: @selector(update:)];
        
        _paused = true;
        
        self.isTouchEnabled = YES;
        
        [self updateLogic:0.001f];  //done to correctly position the camera and player before
                                    //the first render cycle
        [self setupLayers];
        
        NSString *startingLevel = [[GameSettings shared] getGlobalForKey:@"startingLevel"];
        
        [self startLevel:startingLevel];
    }
	return self;
}

-(void)setupLayers
{
    // Run the intro Scene    
    [[ComicManager shared] preload];
    
    _hud = [HudLayer instance];
    [self setupHud];
    
#if DEBUG_DRAW_BOUNDING_BOXES
    _debugLayer = [GameDebugLayer debugLayerForScene:[[LayerManager sharedLayers] currentScene] GameLayer:[[LayerManager sharedLayers] currentLayer]];
#endif

}

-(void)startLevel:(NSString*)levelName
{    
    [[LevelManager shared] reset];
   
    [[LevelManager shared] loadLevelNamed:levelName];
    [self initForLevel];
    Level *levelObj = [[LevelManager shared] currentLevel];
    [[ComicManager shared] startComic:levelObj.preComicName StartPhase:COMIC_PHASE_STARTING_VIDEO];
}

-(void)initForLevel
{
    [self setVisible:NO]; //let comic manager make it visible
    
    _level = [[LevelManager shared] currentLevel];
    
    [_player setOffsetForX:0 Y:[[LevelManager shared] playerOffsetY]];
    
    [_player setPositionAtX:_level.spawnPoint.x Y:_level.spawnPoint.y];
    
    [_player reset];
    
    [_savePoint setSavePoint:_level.spawnPoint Level:_level.name];
    
    [self initCamera];
    
    [[LevelManager shared] initAfterPlayerAndHudInit];
    [_hud reset];
    [[ComicManager shared] resetComicLayer];
    
#if DEBUG_DRAW_BOUNDING_BOXES
    [_debugLayer removeFromParentAndCleanup:NO];
    [[[LayerManager sharedLayers] currentScene] addChild:_debugLayer];
#endif
}

-(void)setupHud
{
    _player.battery = [_hud getBattery];
    [_hud getBattery].parent = _player;
    
    //pass on the hud to the gamecontroller
    [_gameController setHud:_hud];
}

-(HudLayer*)getHud
{
    return _hud;
}

-(void)initCamera
{
    [[Camera sharedCamera] setTarget:[_player getSprite]];
    [[Camera sharedCamera] snapToTarget];
}

-(void)update:(ccTime)dt
{
    
    double fixedTimeStep = 1.0f/60.0f;
    float timeToRun = dt + time;
    while(timeToRun >= fixedTimeStep) {
        [self updateLogic:fixedTimeStep];
        timeToRun = timeToRun - fixedTimeStep;
    }
    time = timeToRun;
    
    //[self updateLogic:dt];
}

-(void)unpause
{
    _paused = false;
}

-(void)updateLogic:(ccTime)dt
{    
#if CC_ENABLE_PROFILERS
    CCProfilingTimer *timer = [CCProfiler timerWithName:@"pfull" andInstance:self];
    CCProfilingBeginTimingBlock(timer);
#endif  

    [[ComicManager shared] update:dt];
    [[SoundEngine shared] update:dt];

    if (!_paused) {
        
        [_level update:dt Velocity:_player.vx];
        
        [_player update:dt Level:_level];
        
        [self updateTriggers:dt];
        
        [_level testCollisions:_player];
        
        [self updatePlayerDeath:dt];
        
        [_hud update:dt];
        
        if (_laserShow!=nil) {
            [_laserShow update:dt];
        } else if(_rainyLevelEffects !=nil) {
            [_rainyLevelEffects update:dt];
        }
        
    }
    
    
#if CC_ENABLE_PROFILERS
    CCProfilingEndTimingBlock(timer);
#endif

}

-(void)updatePlayerDeath:(float)dt
{
    if (![[ComicManager shared] isActive]) {
        if(_player.isDead) {
            [_player reset];
            
            if(_boss){
                [_boss reset];
            }
            
            [_savePoint restoreSavePoint:_player];
            _player.isDead = false;
            [_player rechargeBattery];
            
            [_level resetObstacles];
            [_level resetTriggers];
        }        
    }
}

-(void)updateTriggers:(float)dt
{
    //check to see if any triggers have been hit
    Trigger *trigger = [_level testTriggers:_player];
    if (trigger) {
        switch (trigger.type) {
            case TRIGGER_NEXTLEVEL:
                [self endLevel];
                break;
            case TRIGGER_CHECKPOINT:
                [_savePoint setSavePoint:trigger.position Level:_level.name];
                [_level disablePassedTrigger];
                [[SoundEngine shared] playSound:@"checkpoint"];
                [_player rechargeBattery];
                [_player resetSprint];
                break;
            case TRIGGER_BOSS_SHOOT:
                [_boss triggerAttack];
                trigger.triggered=true;
                break;
            case TRIGGER_WIND_SHORT:
                break;
            case TRIGGER_WIND_MEDIUM:
                break;
            case TRIGGER_WIND_LONG:
                break;
            default:
                break;
        }
    }
}
                     
-(void)endLevel
{
    float finalLevelTime = [[_hud getTrackTimer] getLevelTime];
    [[LevelManager shared] recordLevelTime:finalLevelTime];

    [[ComicManager shared] startComic:_level.postLevelComicName];
    [ComicManager shared].loadNextLevel = true;
}

-(void)setBoss:(Boss*)boss
{
    
   

    _boss = boss;
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    for(UITouch *touch in allTouches) {
        InputEvent *event = [InputEvent inputEventWithType:INPUT_EVENT_TYPE_TOUCHES_BEGAN];
        [event setReceiver:_gameController];
        [event setTouchLocation:[self convertTouchToNodeSpace:touch]];
        [_inputController interpretAndReactToInputEvent:event];
    }
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    for(UITouch *touch in allTouches) {
        InputEvent *event = [InputEvent inputEventWithType:INPUT_EVENT_TYPE_TOUCHES_ENDED];
        [event setReceiver:_gameController];
        [event setTouchLocation:[self convertTouchToNodeSpace:touch]];
        [_inputController interpretAndReactToInputEvent:event];
    }
    
}


-(NSMutableArray*)getGameObjectsList
{
    return _level.obstacleSprites;    
}


-(void)onExit
{
    if (!_gameController.isHandlingPause) {
        [self unscheduleUpdate];
        self.isTouchEnabled = false;
    } else {
        [super onExit];
    }
}

-(void)onEnter
{
    //if (!_gameController.isHandlingPause) {
        [super onEnter];
    //}
}

-(void)initializeLaserShow
{
    _laserShow = [LaserShow instance];
}
-(void)stopLaserShow
{
    if (_laserShow!=nil) {
        [_laserShow release];
        _laserShow = nil;
    }
}

-(void)initializeRainyLevel
{
    _rainyLevelEffects = [RainyLevelEffects instance];
}

-(void)stopRainyLevel
{
    if (_rainyLevelEffects!=nil) {
        [_rainyLevelEffects release];
        _rainyLevelEffects = nil;
    }
}


- (void) dealloc
{
    //can't put these in onexit like the others for some reason
    [_level release];
    [_player release];
    [_gameController release];
    [_inputController release];
    [_savePoint release];
    [_hud release];
    
    [[TextureManager shared] unloadMemoryForKey:@"gameScene"];
    
	[super dealloc];
}

@end
