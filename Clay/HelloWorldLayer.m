//
//  HelloWorldLayer.m
//  Clay
//
//  Created by Brian Cable on 8/23/11.
//  Copyright Xecudev, LLC 2011. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

#import "Level.h"
#import "Runner.h"
#import "Camera.h"

// HelloWorldLayer implementation
@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
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
        
        _xp = 0;
        _level = [Level levelWithFilename:@"platformtest.tmx" Background:@"sky.png" Layer:self];
        
        _runner = [Runner runnerWithSprite:[Sprite spriteWithFile:@"player_idle_01.png" toLayer:self] Layer:self];
        [_runner setPositionAtX:20 Y:100];
        
        [[_runner getSprite] setAnimation:[Animation animationFromPlist:@"character_running" forSequence:@"Character_Running_" NumberOfFrames:10 onLayer:self] Delay:0.075f];
        
        [_runner changeToRunnerState:RUNNER_STATE_RUNNING];
        
        [[Camera sharedCamera] moveByX:300 Y:50];
        [[Camera sharedCamera] convertToScreenXY:CGPointMake(420,200)];
        
        
        [self scheduleUpdate];
        self.isTouchEnabled = YES;
	}
	return self;
}

-(void)update:(ccTime)dt
{
    [_runner update:dt];
    CGPoint newRunnerPosition = [_level checkCollisionAtPoint:ccp(_runner.x,_runner.y)];
    [_runner setPositionAtX:_runner.x Y:newRunnerPosition.y - 52];
    [_level update:dt Velocity:_runner.vx];
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
