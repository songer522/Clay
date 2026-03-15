//
//  RootViewController.m
//  Clay
//
//  Created by Brian Cable on 8/23/11.
//  Copyright Xecudev, LLC 2011. All rights reserved.
//

//
// RootViewController + iAd
// If you want to support iAd, use this class as the controller of your iAd
//

#import "cocos2d.h"

#import "RootViewController.h"
#import "GameConfig.h"

@interface RootViewController()

- (CGRect)currentOpenGLViewFrame;
- (void)resizeOpenGLViewForBounds:(CGRect)bounds;
- (void)resizeOpenGLViewToCurrentLayout;

@end

@implementation RootViewController

@synthesize volumeOverridePlayer;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
	// Custom initialization
	}
	return self;
 }
 */

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
	[super viewDidLoad];
 }
 */


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
	//
	// There are 2 ways to support auto-rotation:
	//  - The OpenGL / cocos2d way
	//     - Faster, but doesn't rotate the UIKit objects
	//  - The ViewController way
	//    - A bit slower, but the UiKit objects are placed in the right place
	//
	
#if GAME_AUTOROTATION==kGameAutorotationNone
	//
	// EAGLView won't be autorotated.
	// Since this method should return YES in at least 1 orientation, 
	// we return YES only in the Portrait orientation
	//
	return ( interfaceOrientation == UIInterfaceOrientationPortrait );
	
#elif GAME_AUTOROTATION==kGameAutorotationCCDirector
	//
	// EAGLView will be rotated by cocos2d
	//
	// Sample: Autorotate only in landscape mode
	//
	if( interfaceOrientation == UIInterfaceOrientationLandscapeLeft ) {
		[[CCDirector sharedDirector] setDeviceOrientation: kCCDeviceOrientationLandscapeRight];
	} else if( interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		[[CCDirector sharedDirector] setDeviceOrientation: kCCDeviceOrientationLandscapeLeft];
	}
	
	// Since this method should return YES in at least 1 orientation, 
	// we return YES only in the Portrait orientation
	return ( interfaceOrientation == UIInterfaceOrientationPortrait );
	
#elif GAME_AUTOROTATION == kGameAutorotationUIViewController
	//
	// EAGLView will be rotated by the UIViewController
	//
	// Sample: Autorotate only in landscpe mode
	//
	// return YES for the supported orientations
	
	return ( UIInterfaceOrientationIsLandscape( interfaceOrientation ) );
	
#else
#error Unknown value in GAME_AUTOROTATION
	
#endif // GAME_AUTOROTATION
	
	
	// Shold not happen
	return NO;
}

//
// This callback only will be called when GAME_AUTOROTATION == kGameAutorotationUIViewController
//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self resizeOpenGLViewToCurrentLayout];
}
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURL *hurtURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"hurt" ofType:@"caf"]];
    volumeOverridePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:hurtURL error:nil];
    [volumeOverridePlayer prepareToPlay];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self resizeOpenGLViewToCurrentLayout];
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    CGRect targetBounds = CGRectMake(0.0f, 0.0f, size.width, size.height);
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self resizeOpenGLViewForBounds:targetBounds];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self resizeOpenGLViewForBounds:targetBounds];
    }];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
#if GAME_AUTOROTATION==kGameAutorotationNone || GAME_AUTOROTATION==kGameAutorotationCCDirector
    return UIInterfaceOrientationMaskPortrait;
#elif GAME_AUTOROTATION == kGameAutorotationUIViewController
    return UIInterfaceOrientationMaskLandscape;
#else
    return UIInterfaceOrientationMaskAll;
#endif
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
    return UIInterfaceOrientationLandscapeRight;
#else
    return UIInterfaceOrientationPortrait;
#endif
}

- (CGRect)currentOpenGLViewFrame
{
    UIView *containerView = self.view.superview;
    if (containerView != nil) {
        return containerView.bounds;
    }
    
    UIWindow *windowRef = self.view.window;
    if (windowRef != nil) {
        return windowRef.bounds;
    }
    
    return [[UIScreen mainScreen] bounds];
}

- (void)resizeOpenGLViewForBounds:(CGRect)bounds
{
    CCDirector *director = [CCDirector sharedDirector];
    EAGLView *glView = [director openGLView];
    if (glView == nil) {
        return;
    }
    
    CGRect frame = CGRectMake(0.0f, 0.0f, bounds.size.width, bounds.size.height);
    if (!CGRectEqualToRect(glView.frame, frame)) {
        glView.frame = frame;
    }
}

- (void)resizeOpenGLViewToCurrentLayout
{
    [self resizeOpenGLViewForBounds:[self currentOpenGLViewFrame]];
}


- (void)dealloc {
    [volumeOverridePlayer release];
    [super dealloc];
}


@end
