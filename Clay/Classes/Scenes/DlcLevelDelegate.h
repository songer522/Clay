//
//  DlcLevelDelegate.h
//  Clay
//
//  Created by Brian Cable on 1/25/12.
//  Copyright (c) 2012 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kInAppPurchaseTrainingRunProductId @"com.xecudev.Clay.trainingLevelUnlock"
#define kInAppPurchaseDojoRunProductId @"com.xecudev.Clay.dojoLevelUnlock"

@protocol DlcLevelDelegate <NSObject>

-(void)updateDlcLevels;

@end
