//
//  SceneDelegate.m
//  Clay
//

#import "cocos2d.h"

#import "SceneDelegate.h"
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

@implementation SceneDelegate

@synthesize window;
@synthesize viewController;

- (void) removeStartupFlicker
{
	//
	// THIS CODE REMOVES THE STARTUP FLICKER
	//
	// Uncomment the following code if you Application only supports landscape mode
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController

//	CC_ENABLE_DEFAULT_GL_STATES();
//	CCDirector *director = [CCDirector sharedDirector];
//	CGSize size = [director winSize];
//	CCSprite *sprite = [CCSprite spriteWithFile:@"Default.png"];
//	sprite.position = ccp(size.width/2, size.height/2);
//	sprite.rotation = -90;
//	[sprite visit];
//	[[director openGLView] swapBuffers];
//	CC_ENABLE_DEFAULT_GL_STATES();
	
    
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController	
}

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions
{
	UIWindowScene *windowScene = (UIWindowScene *)scene;
	if (![windowScene isKindOfClass:[UIWindowScene class]])
		return;

	// Init the window
	self.window = [[[UIWindow alloc] initWithWindowScene:windowScene] autorelease];

	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeDefault];
	
	
	CCDirector *director = [CCDirector sharedDirector];
	
	// Init the View Controller
	self.viewController = [[[RootViewController alloc] initWithNibName:nil bundle:nil] autorelease];
	
	//
	// Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
	//
	//
	EAGLView *glView = [EAGLView viewWithFrame:[self.window bounds]
								   pixelFormat:kEAGLColorFormatRGB565	// kEAGLColorFormatRGBA8
								   depthFormat:0						// GL_DEPTH_COMPONENT16_OES
						];
	glView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	// attach the openglView to the director
	[director setOpenGLView:glView];
	
	// This project was authored with iPad-specific HD assets and legacy point math.
	// Keeping Retina mode off on iPad preserves the original coordinate system.
    BOOL shouldEnableRetinaDisplay = [GameSettings shouldUseRetinaForDevice];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        shouldEnableRetinaDisplay = NO;
    }
	if( ! [director enableRetinaDisplay:shouldEnableRetinaDisplay] )
		CCLOG(@"Retina Display Not supported");

	
	//
	// VERY IMPORTANT:
	// If the rotation is going to be controlled by a UIViewController
	// then the device orientation should be "Portrait".
	//
	// IMPORTANT:
	// By default, this template only supports Landscape orientations.
	// Edit the RootViewController.m file to edit the supported orientations.
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
#else
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
#endif
	
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
	[director setAnimationInterval:1.0f/60.0f];

    NSString *showFps = [[GameSettings shared] getGlobalForKey:@"showFps"];
    if ([showFps isEqualToString:@"YES"]) {
        [director setDisplayFPS:YES];        
    } else {
        [director setDisplayFPS:NO];
    }
	
	// make the OpenGLView a child of the view controller
	[self.viewController setView:glView];
	
	// Modern iOS expects a root view controller for lifecycle and rotation.
	[self.window setRootViewController:self.viewController];
	
	[self.window makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	// Removes the startup flicker
	[self removeStartupFlicker];

    [[GameSettings shared] setGlobal:@"YES" ForKey:@"titleMusicStarted"];
    [[SoundEngine shared] playMusic:@"title"];
    [[TextureManager shared] loadMemoryForKey:@"launch"];
    
    [[CCDirector sharedDirector] runWithScene:[MainMenuScene scene]]; 
    
    [[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
    
    [[CCDirector sharedDirector] setProjection:CCDirectorProjection2D];
    
    [Appirater appLaunched:YES];

	// Keep AppDelegate.window/.viewController valid for other classes
	// (EndLevelScene, ChooseLevelScreen) that still reach them via
	// [[UIApplication sharedApplication] delegate].
	AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
	appDelegate.window = self.window;
	appDelegate.viewController = self.viewController;
}

- (void)sceneDidBecomeActive:(UIScene *)scene {
	[[CCDirector sharedDirector] resume];
}

- (void)sceneWillResignActive:(UIScene *)scene {
	[[CCDirector sharedDirector] pause];
}

- (void)sceneDidEnterBackground:(UIScene *)scene {
    [[BestTimes shared] saveData];
    [[GameSettings shared] saveToDisk];
	[[CCDirector sharedDirector] stopAnimation];
	_hasEnteredBackground = YES;
}

- (void)sceneWillEnterForeground:(UIScene *)scene {
	// runWithScene: already started the display link when the scene first
	// connected; only resume it here if sceneDidEnterBackground: actually
	// stopped it, otherwise CCDirectorDisplayLink asserts on a double start.
	if (_hasEnteredBackground) {
		[[CCDirector sharedDirector] startAnimation];
	}
    [Appirater appEnteredForeground:YES];
}

- (void)dealloc {
	[window release];
	[viewController release];
	[super dealloc];
}

@end
