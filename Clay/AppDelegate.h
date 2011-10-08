//
//  AppDelegate.h
//  Clay
//
//  Created by Brian Cable on 8/23/11.
//  Copyright Xecudev, LLC 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@class GameDebugLayer;
@class ComicManager;
@class HudLayer;
@class GameLayer;
@class MainMenuScene;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
    CCScene             *gameScene;
    GameDebugLayer      *_debugLayer;
    HudLayer            *_hudLayer;
    ComicManager        *_comicManager;
    CCScene             *_mainMenuScene;
}

@property (nonatomic, retain) UIWindow *window;

@end
