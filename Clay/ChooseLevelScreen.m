//
//  ChooseLevelScreen.m
//  Clay
//
//  Created by Brian Cable on 10/24/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "ChooseLevelScreen.h"
#import "Sprite.h"
#import "LayerManager.h"
#import "Button.h"

@implementation ChooseLevelScreen


+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	ChooseLevelScreen *layer = [ChooseLevelScreen layerWithScene:scene];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

+(id)layerWithScene:(CCScene*)scene
{
    return [[self alloc] initWithScene:scene];
}

-(id) initWithScene:(CCScene*)scene
{
    if ((self = [super init])) {
        [[LayerManager sharedLayers] setScene:scene ForKey:@"chooseLevel"];
        [self load];
    }
    return self;
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    for(UITouch *touch in allTouches) {
        for (Button *button in _buttons) {
            bool touched = [button testCollision:[self convertTouchToNodeSpace:touch]];
            if(touched) {
                int levelNumber = button.buttonId;
                NSString *levelName = [NSString stringWithFormat:@"level%d",levelNumber];
                NSLog(@"SWITCH TO LEVEL: %@",levelName);
            }
        }
    }
}

-(void)load
{
    [[LayerManager sharedLayers] setWorkingLayer:self];    
    
    blackBackground = [Sprite spriteWithFile:@"black_background-hd.png"];
    
    for (int i=0; i<6; i++) {
        Button *button = [Button buttonWithText:@"test" AtPoint:CGPointMake(100, i * 50.0f)];
        [button setHitbox:CGRectMake(100, i*50.0f, 150.0f, 30.0f)];
        button.buttonId = i;
        [[button getLabel] setColor:ccc3(255, 255, 0)];
        [_buttons addObject:button];
    }
    
    [[LayerManager sharedLayers] forgetWorkingLayer];
    [self scheduleUpdate];
    self.isTouchEnabled = true;    
}


-(void)update:(ccTime)dt
{
    
}

-(void)unload
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrameByName:@"black_background-hd.png"];
}

@end
