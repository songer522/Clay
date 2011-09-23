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
#import "GameClasses.h"

#import "GameCenter.h"

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
        [[CCDirector sharedDirector] setProjection:CCDirectorProjection2D];
        
        _gameController = [GameController gameController];
        [_gameController setGameLayer:self];
        _inputController = [InputController inputController];
        
        
        [[LayerManager sharedLayers] setCurrentLayer:self];
        
        _level = [[LevelManager shared] currentLevel];
        
        _player = [Player instance];
        
        _savePoint = [SavePoint instance];
        
        [self initForLevel];
        
        [self scheduleUpdate];
        
        _dustTest = [[ParticleSystem alloc] init];
        
        self.isTouchEnabled = YES;
        
	}
	return self;
}

-(void)initForLevel
{
    _level = [[LevelManager shared] currentLevel];
    
    [_player resetSprite:self];
    
    [_player setOffsetForX:0 Y:[[LevelManager shared] playerOffsetY]];
    
    [_player setPositionAtX:_level.spawnPoint.x Y:_level.spawnPoint.y];
    
    [_savePoint setSavePoint:_level.spawnPoint Level:_level.name];
    
    [self initCamera];
    

}

-(Runner*)initRunner:(Runner*)runner atPosition:(CGPoint)position
{
    runner = [Runner runnerWithSprite:[Sprite spriteWithFile:@"player_idle_01.png"]];
    [runner setPositionAtX:position.x Y:position.y];
    
    [[AnimationController sharedController] replaceSprite:[runner getSprite] withAnimationNamed:@"runningAnim"];

    [runner changeToRunnerState:RUNNER_STATE_RUNNING];
    
    return runner;
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
    [_player update:dt Level:_level];    

    [_level update:dt Velocity:_player.vx];
    
    //check to see if any triggers have been hit
    Trigger *trigger = [_level testTriggers:_player];
    if (trigger) {
        switch (trigger.type) {
            case TRIGGER_NEXTLEVEL:
                [[LevelManager shared] loadNextLevel];
                [[LevelManager shared] switchToNextLevel];
                [self initForLevel];
                break;
            case TRIGGER_CHECKPOINT:
                [_savePoint setSavePoint:trigger.position Level:_level.name];
            default:
                break;
        }
    }
    
    if([_level testCollisions:_player]) {
        //collision happened, so reduce speed
        [_player startCollision];
    }
    
    if(_player.isDead) {
        [_player reset];
        [_savePoint restoreSavePoint:_player];
        _player.isDead = false;
    }
    
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



-(void)updateRunner:(Runner*)runner DT:(float)dt
{
    [runner update:dt];
    
    CGPoint newPosition = [_level checkCollisionForObject:_player];
    [runner setPositionAtX:newPosition.x Y:newPosition.y - 22];    
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


// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
