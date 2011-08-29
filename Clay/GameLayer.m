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

@synthesize _player;

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
        _inputController = [InputController inputController];
        
        _background = [Background backgroundForLayer:self];
        _player = [Player playerForLayer:self];
        
        _playerAnimation = [Animation animationFromPlist:@"anim_guy" forSequence:@"player_idle_0" NumberOfFrames:2 onLayer:self];
        _playerAnimation.delay = 0.03f;
        [_playerAnimation useAnimationToReplaceSprite:_player.sprite];
        
        Sprite *temp = [Sprite spriteWithFile:@"player_idle_01-hd.png" toLayer:self];
        [temp setPositionAtX:300 Y:100];
        Animation *player2 = [Animation animationFromPlist:@"anim_guy" forSequence:@"player_idle_0" NumberOfFrames:2 onLayer:self];
        [player2 useAnimationToReplaceSprite:temp];
        
        [self scheduleUpdate];
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
