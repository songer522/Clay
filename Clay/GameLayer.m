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
        
        _background = [Background backgroundForLayer:self];
        _player = [Player playerForLayer:self];
        
        _playerAnimation = [Animation animationFromPlist:@"anim_guy" forSequence:@"player_idle_0" withFrameCount:2 onLayer:self];
        [_playerAnimation useAnimationToReplaceSprite:[_player getSprite]];
        
        [self scheduleUpdate];
    }
    
    return self;

}

-(void)update:(ccTime)dt
{
    [_player updatePlayer:dt];
    [_background update:dt];
    
}

@end
