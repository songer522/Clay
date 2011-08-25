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
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        background = [Sprite spriteWithFile:@"background.png" toScene:self];
        [background setCentered];
        [background setPositionAtX:screenSize.width/2 Y:screenSize.height/2];
        
        _player = [Player playerForScene:self];
        
        [self scheduleUpdate];
    }
    
    return self;

}
-(void)update:(ccTime)dt
{
    [_player updatePlayer:dt];
}

@end
