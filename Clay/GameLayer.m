//
//  HelloWorldLayer.m
//  Clay
//
//  Created by Brian Cable on 8/23/11.
//  Copyright Xecudev, LLC 2011. All rights reserved.
//


// Import the interfaces
#import "GameLayer.h"

#import "Level.h"
#import "Runner.h"
#import "Camera.h"
#import "Player.h"
#import "BaseClasses.h"
#import "GameController.h"


// HelloWorldLayer implementation
@implementation GameLayer

@synthesize player = _player;

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
        [_gameController setLayer:self];
        _inputController = [InputController inputController];
        
        [[LayerManager sharedLayers] setCurrentLayer:self];
        
        _xp = 0;
        _level = [Level levelWithFilename:@"clayl2.1.1.tmx"];
        
        _player = [Player playerForLayer:self];
        
        [[AnimationController sharedController] replaceSprite:[_player getSprite] withAnimationNamed:@"runningAnim"];

        CGPoint spawn = [_level getSpawnPoint];
        [_player setPositionAtX:spawn.x Y:spawn.y];
        
        
        [self initCamera];
        
        //[self scheduleUpdate];
        
        [self schedule:@selector(updateLogic:) interval:1.0/60.0f];
        
        self.isTouchEnabled = YES;
	}
	return self;
}

-(Runner*)initRunner:(Runner*)runner atPosition:(CGPoint)position
{
    runner = [Runner runnerWithSprite:[Sprite spriteWithFile:@"player_idle_01.png"] Layer:self];
    [runner setPositionAtX:position.x Y:position.y];
    
    [[AnimationController sharedController] replaceSprite:[runner getSprite] withAnimationNamed:@"runningAnim"];

    [runner changeToRunnerState:RUNNER_STATE_RUNNING];
    
    return runner;
}

-(void)initCamera
{
    [[Camera sharedCamera] setCenter:CGPointMake(90, 100)];        
    [[Camera sharedCamera] setTarget:[_player getSprite]];
    [[Camera sharedCamera] snapToTarget];
}

-(void)update:(ccTime)dt
{
}

-(void)updateLogic:(ccTime)dt
{
    [_player update:dt Level:_level];    

    [_level update:dt Velocity:_player.vx];
    
    
    if([_level testCollisions:_player]) {
        //collision happened, so reduce speed
        [_player startCollision];
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
    
    CGPoint newPosition = [_level checkCollisionForObject:_player AtPoint:[_player getPosition]];
    [runner setPositionAtX:newPosition.x Y:newPosition.y - 22];    
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
