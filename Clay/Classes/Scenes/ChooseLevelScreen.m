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
        
        
        _buttons = [[NSMutableArray alloc] initWithCapacity:11];
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

    
    CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
    [frameCache addSpriteFramesWithFile:@"chooseLevel.plist"];
    
    _background = [Sprite spriteFromFrameCacheWithName:@"CL_Background.png"];
    [_background setScreenPosition:ccp(0,0)];
    
    _levelInfoFront = [Sprite spriteFromFrameCacheWithName:@"CL_LevelInfo.png"];
    [_levelInfoFront getCCSprite].anchorPoint = ccp(0.5f,0.5f);
    [_levelInfoFront setScreenPosition:ccp(105.0f,152.0f)];
    
    
    
    
    _levelSelectText = [CCLabelBMFont labelWithString:@"LEVEL SELECT" fntFile:@"GraphicFont.fnt"];
    [_levelSelectText setScale:0.75f];
    _levelSelectText.position = ccp(365.0f,278.0f);
    [[[LayerManager sharedLayers] currentLayer] addChild:_levelSelectText];

    
    //blackBackground = [Sprite spriteWithFile:@"black_background-hd.png"];
    
    //[button setHitbox:CGRectMake(startX - 30.0f, (260.0f - startY), 120.0f, 48.0f)];
    
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
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"chooseLevel.plist"];
    [[CCTextureCache sharedTextureCache] removeTextureForKey:@"chooseLevel.png"];
    [[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];

    
}

-(void)update:(ccTime)dt
{
    [self popAndSwitchToLevel:@"level6"];
}

-(void)unload
{
    //[[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrameByName:@"black_background-hd.png"];
}

@end
