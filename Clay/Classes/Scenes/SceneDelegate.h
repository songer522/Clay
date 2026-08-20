//
//  SceneDelegate.h
//  Clay
//
//  Handles the app's single UIWindowScene. Owns the window and root
//  view controller that AppDelegate used to own directly, before the
//  UIKit scene-based life cycle became mandatory.

#import <UIKit/UIKit.h>

@class RootViewController;

@interface SceneDelegate : UIResponder <UIWindowSceneDelegate> {
	// UIKit calls sceneWillEnterForeground: as part of the initial
	// connect/activate sequence, not just when returning from the
	// background. CCDirector's startAnimation was already started by
	// runWithScene: during willConnectToSession:, so only resume it
	// here if we actually stopped it by entering the background first.
	BOOL _hasEnteredBackground;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) RootViewController *viewController;

@end
