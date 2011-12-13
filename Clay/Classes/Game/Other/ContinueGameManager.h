//
//  ContinueGameManager.h
//  Clay
//
//  Created by Brian Cable on 12/12/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContinueGameManager : NSObject

+(bool)isAbleToContinueGame;
+(NSString*)getContinueGameDifficulty;
+(NSString*)getContinueGameLevel;

@end
