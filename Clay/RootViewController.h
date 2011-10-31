//
//  RootViewController.h
//  Clay
//
//  Created by Brian Cable on 8/23/11.
//  Copyright Xecudev, LLC 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface RootViewController : UIViewController {
    AVAudioPlayer *volumeOverridePlayer; //without this the ringer controls appear instead of normal volume control (issue #59)
}

@property (nonatomic, retain) AVAudioPlayer *volumeOverridePlayer;

@end
