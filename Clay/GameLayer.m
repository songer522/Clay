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
        _background = [Background backgroundForLayer:self];
        _player = [Player playerForLayer:self];
        
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"anim_guy.plist"];
        
        CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"anim_guy.png"];
        [self addChild:spriteSheet];
        
        NSMutableArray *walkFrames = [NSMutableArray array];
        for (int i=1; i<=2; i++) {
            [walkFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"player_idle_0%d-hd.png",i]]];
        }
        
        CCAnimation *walkAnim = [CCAnimation animationWithFrames:walkFrames delay:0.1f];
        
        _test = [CCSprite spriteWithSpriteFrameName:@"player_idle_01-hd.png"];
        _test.position = ccp(300,100);
        
        _running = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnim restoreOriginalFrame:NO]];
        [_test runAction:_running];
        
        [spriteSheet addChild:_test];
        
        
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
