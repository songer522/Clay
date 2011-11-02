//
//  AppDelegate.h
//  Clay
//
//  Created by Brian Cable on 8/23/11.
//  Copyright Xecudev, LLC 2011. All rights reserved.
//
//  Main entry point for the app. Where all the layers and scenes are initialized.


#import <UIKit/UIKit.h>

@class RootViewController;

@class GameDebugLayer;
@class ComicManager;
@class HudLayer;
@class GameLayer;
@class MainMenuScene;
@class EndGameScene;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
    CCScene             *gameScene;
    GameDebugLayer      *_debugLayer;
    HudLayer            *_hudLayer;
    ComicManager        *_comicManager;
    CCScene             *_endGameScene;
    CCScene             *_mainMenuScene;
    CCScene             *_chooseLevelScene;
}

@property (nonatomic, retain) UIWindow *window;

@end
