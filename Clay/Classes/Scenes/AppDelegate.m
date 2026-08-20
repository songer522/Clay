//
//  AppDelegate.m
//  Clay
//
//  Created by Brian Cable on 8/23/11.
//  Copyright Xecudev, LLC 2011. All rights reserved.
//

#import "cocos2d.h"

#import "AppDelegate.h"
#import "GameConfig.h"
#import "GameLayer.h"
#import "GameDebugLayer.h"
#import "LayerManager.h"
#import "RootViewController.h"
#import "VideoPlayer.h"
#import "CCVideoPlayer.h"
#import "TextureManager.h"
#import "GameSettings.h"
#import "MainMenuScene.h"
#import "Appirater.h"
#import "SoundEngine.h"
#import "BestTimes.h"


@implementation AppDelegate

@synthesize window;
@synthesize viewController;

// Window and view controller setup now happens in SceneDelegate,
// since UIKit requires scene-based life cycle adoption. AppDelegate
// still exposes .window and .viewController, populated by
// SceneDelegate, because other classes (EndLevelScene,
// ChooseLevelScreen) reach them via [[UIApplication sharedApplication] delegate].
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	return YES;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [[BestTimes shared] saveData];
    [[GameSettings shared] saveToDisk];

    //[[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
	[[CCDirector sharedDirector] purgeCachedData];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[[TextureManager shared] unloadMemoryForKey:@"launch"];
    [[GameSettings shared] saveToDisk];
    
    [[BestTimes shared] saveData];
    
    CCDirector *director = [CCDirector sharedDirector];
	
	[[director openGLView] removeFromSuperview];
	
	[director end];	
    
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    // Return YES for supported orientations
    
	
    //return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
          //  interfaceOrientation == UIInterfaceOrientationLandscapeRight );
    
	// eg: Support 4 orientations
	return YES;
}


-(void)simulateIpad1Memory
{
    //basically allocate 256MB of memory so there is less to work with, at least in theory. doesn't seem to be working though.
    int chunkCount = 256;
    int chunkSize = 1L * 1024L * 1024L; //1 megabyte
    
    _wasteMemoryForIpad1 = [[NSMutableArray alloc] initWithCapacity:chunkCount];
    for (int i = 0; i<chunkCount; i++) {
        [_wasteMemoryForIpad1 addObject:[NSValue valueWithPointer:malloc(chunkSize)]];
    }
}

- (void)dealloc {
    [window release];
    [viewController release];
    [gameScene release];
    [_debugLayer release];
    [_hudLayer release];
    [_comicManager release];
    [_endGameScene release];
    [_mainMenuScene release];
    [_chooseLevelScene release];
	[[CCDirector sharedDirector] end];
    
    
    if ([_wasteMemoryForIpad1 count]) {
        for (NSValue* val in _wasteMemoryForIpad1) {
            free([val pointerValue]);
        }
        [_wasteMemoryForIpad1 removeAllObjects];
    }
    [_wasteMemoryForIpad1 release];
    
    
	[super dealloc];
}


@end
