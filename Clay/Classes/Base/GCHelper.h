//
//  GCHelper.h
//  Clay
//
//  Created by Dustin Werner on 10/17/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//
//  Helper class for using the Game Center. Used to verify that the current device supports game center, that the user has logged in and is authenticated, and to report achievements and leaderboard scores.

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

#define gcAchievementChickensKickedIntoCows @"com.xecudev.tracklapse.kicktenchickens"

@interface GCHelper : NSObject <NSCoding> {
    BOOL gameCenterAvailable;
    BOOL userAuthenticated;
    NSMutableArray *leaderboardToReport;
    NSMutableArray *achievementsToReport;
}
@property (retain) NSMutableArray *leaderboardToReport;
@property (retain) NSMutableArray *achievementsToReport;

+ (GCHelper *) sharedInstance;
- (void)authenticationChanged;
- (void)authenticateLocalUser;

-(void)resendData;
-(void)save;
-(id)initWithLeaderboardToReport:(NSMutableArray *)leaderboardToReport achievementsToReport:(NSMutableArray *)achievementsToReport;
-(void)reportAchievement:(NSString *)identifier percentComplete:(double)percentComplete;
-(void)reportLeaderboard:(NSString *)identifier score:(int)score;

- (void) showGameCenter;

@end
