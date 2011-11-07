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

// HelloWorldLayer implementation
@implementation GameLayer

@synthesize player = _player;
@synthesize gameController = _gameController;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
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
        
        [[SoundEngine shared] preloadAudio];
        
        _gameController = [GameController gameController];
        [_gameController setGameLayer:self];
        
        _inputController = [InputController inputController];
        [self addChild:_inputController];       //need to so its scheduled selectors will be trigger
        
        [[LayerManager sharedLayers] setCurrentLayer:self];
        
        _player = [Player instance];
        
        _level = [[LevelManager shared] currentLevel];
        
        _savePoint = [SavePoint instance];
        
        
        [self scheduleUpdate];
        
        [self initForLevel];
        

        self.isTouchEnabled = YES;
        
        [self updateLogic:0.001f];  //done to correctly position the camera and player before
                                    //the first render cycle
        

        
        //[self schedule:@selector(updateLogic:) interval:(1.0f/30.0f)];
        [[CCTextureCache sharedTextureCache] removeAllTextures];
        [[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
        

	}
	return self;
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
    
    [_hud reset];
}

-(void)setupHud:(HudLayer*)hud
{
    _hud = hud;
    
    _player.battery = [_hud getBattery];
    [_hud getBattery].parent = _player;
    
    //pass on the hud to the gamecontroller
    [_gameController setHud:hud];
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
    [self updateLogic:dt];
}

-(void)updateLogic:(ccTime)dt
{
    [[ComicManager shared] update:dt];
    [[SoundEngine shared] update:dt];
    
    [_player update:dt Level:_level];
    
    [_level update:dt Velocity:_player.vx];
    
    //check to see if any triggers have been hit
    Trigger *trigger = [_level testTriggers:_player];
    if (trigger) {
        switch (trigger.type) {
            case TRIGGER_NEXTLEVEL:
                [[ComicManager shared] startComic:_level.postLevelComicName];
                [ComicManager shared].loadNextLevel = true;
                break;
            case TRIGGER_CHECKPOINT:
                [_savePoint setSavePoint:trigger.position Level:_level.name];
                [[SoundEngine shared] playSound:@"checkpoint"];
                [_player rechargeBattery];
                break;
            default:
                break;
        }
    }
    
    [_level testCollisions:_player];
    
    if (![[ComicManager shared] isActive]) {
        if(_player.isDead) {
            [_player reset];
            [_savePoint restoreSavePoint:_player];
            _player.isDead = false;
            [_player rechargeBattery];
            
            [_level resetObstacles];
        }        
    }
    
    [_hud update:dt];
    
    if (_laserShow!=nil) {
        [_laserShow update:dt];
    }
    
    [_boss update:dt];
    
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
    [[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
    
}


-(NSMutableArray*)getGameObjectsList
{
    return _level.obstacleSprites;    
}


-(void)onExit
{
    if (!_gameController.isPaused) {
        [super onExit];
    }
}

-(void)onEnter
{
    if (!_gameController.isPaused) {
        [super onEnter];
    }
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


// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
    [_level release];
    [_player release];
    [_gameController release];
    [_inputController release];
    [_savePoint release];
    [_hud release];
	[super dealloc];
}

@end
