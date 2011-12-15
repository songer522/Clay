//
//  RootViewController.h
//  Clay
//
//  Created by Brian Cable on 8/23/11.
//  Copyright Xecudev, LLC 2011. All rights reserved.
//
//  Should almost never need to touch this class. It's a base class that cocos uses to initialize and handle the player exiting and starting the app. Also has some code to try to override the ringer (see issue #59), but that didn't seem to work, and should be removed after the issue is resolved.

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "FBConnect.h"

@interface RootViewController : UIViewController<FBSessionDelegate> {
    AVAudioPlayer *volumeOverridePlayer; //without this the ringer controls appear instead of normal volume control (issue #59)
}

@property (nonatomic, retain) AVAudioPlayer *volumeOverridePlayer;

@end
