//
//  GameLayer.m
//  Clay
//
//  Created by Brian Cable on 8/25/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "cocos2d.h"
#import "GameLayer.h"
#import "GameClasses.h"

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


- (id)init
{
    if( (self=[super init])) {
        [[CCDirector sharedDirector] setProjection:CCDirectorProjection2D];
        
        _gameController = [GameController gameController];
        [_gameController setLayer:self];
        _inputController = [InputController inputController];
        
        _background = [Background backgroundForLayer:self];
        _player = [Player playerForLayer:self];
        
        _playerAnimation = [Animation animationFromPlist:@"character_running" forSequence:@"Character_Running_" NumberOfFrames:10 onLayer:self];
        _playerAnimation.delay = 0.075f;
        [_playerAnimation useAnimationToReplaceSprite:_player.sprite];
                
        [self scheduleUpdate];
        self.isTouchEnabled = YES;
    }
    
    return self;

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


-(void)update:(ccTime)dt
{
    [_player update:dt];
    [_background update:dt];
    
}

-(void) dealloc
{
    [_player release];
    [_background release];
    [_playerAnimation release];
    [super dealloc];
}

@end
