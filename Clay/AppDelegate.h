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

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
    CCScene             *gameScene;
    GameDebugLayer      *_debugLayer;
    ComicManager        *_comicManager;

}

@property (nonatomic, retain) UIWindow *window;

@end
