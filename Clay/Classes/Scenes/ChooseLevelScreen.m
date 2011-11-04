//
//  ChooseLevelScreen.m
//  Clay
//
//  Created by Brian Cable on 10/24/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "ChooseLevelScreen.h"
#import "Sprite.h"
#import "LevelManager.h"
#import "LayerManager.h"
#import "Button.h"
#import "ComicManager.h"

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
        _buttons = [[NSMutableArray alloc] initWithCapacity:4];
        _alpha = 1.0f;
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
                int levelNumber = button.buttonId + 1;
                _levelToSwitchTo = [[NSString alloc] initWithFormat:@"level%d",levelNumber];
                _wantToSwitch = true;
                NSLog(@"SWITCH TO LEVEL %d",levelNumber);
            }
        }
    }
}

-(void)load
{
    [[LayerManager sharedLayers] setWorkingLayer:self];    
    
    blackBackground = [Sprite spriteWithFile:@"black_background-hd.png"];
    
    for (int i=0; i<7; i++) {
        float startX = (i<6)? 100.0f : 300.0f;
        float startY = (i % 6) * 48.0f;
        Button *button = [Button buttonWithText:[NSString stringWithFormat:@"Level %d",(i+1)] AtPoint:CGPointMake(startX, 280.0f - startY)];
        [button setHitbox:CGRectMake(startX - 30.0f, (260.0f - startY), 120.0f, 48.0f)];
        button.buttonId = i;
        [[button getLabel] setColor:ccc3(255, 255, 0)];
        [_buttons addObject:button];
    }
    
    [[LayerManager sharedLayers] forgetWorkingLayer];
    [self scheduleUpdate];
    self.isTouchEnabled = true;    
}


-(void)popAndSwitchToLevel:(NSString*)level
{
    [self unscheduleUpdate];
    [self setVisible:NO];
    for (Button *button in _buttons) {
        [[button getLabel] setVisible:NO];
    }
    [[LevelManager shared] loadLevelNamed:level];
    [[LevelManager shared] switchToNextLevel];
    [[ComicManager shared] startComic:@"intro" StartPhase:COMIC_PHASE_PLAY_VIDEO];    
    [[LayerManager sharedLayers] popAndPushSceneNamed:@"game"];
    
    [[CCTextureCache sharedTextureCache] removeAllTextures];
    [[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
}

-(void)update:(ccTime)dt
{
    if (_wantToSwitch) {
        _alpha -= 5.0f * dt;
        if (_alpha<=0.0f) {
            [self popAndSwitchToLevel:_levelToSwitchTo];
        }
        
        for (Button *button in _buttons) {
            [[button getLabel] setOpacity:(int)(_alpha*255.0f)];
        }
    }
    
}

-(void)unload
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrameByName:@"black_background-hd.png"];
}

@end
