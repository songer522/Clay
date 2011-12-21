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
#define gcAchievementTimesDied @"com.xecudev.tracklapse.achievement.timesdied"
#define gcLeaderboardNormalTimedLevel1 @"com.xecudev.tracklapse.leaderboard.normaltimed.level1"
#define gcLeaderboardNormalTimedLevel2 @"com.xecudev.tracklapse.leaderboard.normaltimed.level2"
#define gcLeaderboardNormalTimedLevel3 @"com.xecudev.tracklapse.leaderboard.normaltimed.level3"
#define gcLeaderboardNormalTimedLevel4 @"com.xecudev.tracklapse.leaderboard.normaltimed.level4"
#define gcLeaderboardNormalTimedLevel5 @"com.xecudev.tracklapse.leaderboard.normaltimed.level5"
#define gcLeaderboardNormalTimedLevel6 @"com.xecudev.tracklapse.leaderboard.normaltimed.level6"
#define gcLeaderboardNormalTimedLevel7 @"com.xecudev.tracklapse.leaderboard.normaltimed.level7"
#define gcLeaderboardNormalTimedLevel8 @"com.xecudev.tracklapse.leaderboard.normaltimed.level8"
#define gcLeaderboardNormalTimedLevel9 @"com.xecudev.tracklapse.leaderboard.normaltimed.level9"
#define gcLeaderboardNormalTimedLevel10 @"com.xecudev.tracklapse.leaderboard.normaltimed.level10"
#define gcLeaderboardNormalTimedLevel11 @"com.xecudev.tracklapse.leaderboard.normaltimed.level11"
#define gcLeaderboardInsaneTimedLevel1 @"com.xecudev.tracklapse.leaderboard.insanetimed.level1"
#define gcLeaderboardInsaneTimedLevel2 @"com.xecudev.tracklapse.leaderboard.insanetimed.level2"
#define gcLeaderboardInsaneTimedLevel3 @"com.xecudev.tracklapse.leaderboard.insanetimed.level3"
#define gcLeaderboardInsaneTimedLevel4 @"com.xecudev.tracklapse.leaderboard.insanetimed.level4"
#define gcLeaderboardInsaneTimedLevel5 @"com.xecudev.tracklapse.leaderboard.insanetimed.level5"
#define gcLeaderboardInsaneTimedLevel6 @"com.xecudev.tracklapse.leaderboard.insanetimed.level6"
#define gcLeaderboardInsaneTimedLevel7 @"com.xecudev.tracklapse.leaderboard.insanetimed.level7"
#define gcLeaderboardInsaneTimedLevel8 @"com.xecudev.tracklapse.leaderboard.insanetimed.level8"
#define gcLeaderboardInsaneTimedLevel9 @"com.xecudev.tracklapse.leaderboard.insanetimed.level9"
#define gcLeaderboardInsaneTimedLevel10 @"com.xecudev.tracklapse.leaderboard.insanetimed.level10"
#define gcLeaderboardInsaneTimedLevel11 @"com.xecudev.tracklapse.leaderboard.insanetimed.level11"
#define gcLeaderboardStoryEasy @"com.xecudev.tracklapse.leaderboard.story.easy"
#define gcLeaderboardStoryNormal @"com.xecudev.tracklapse.leaderboard.story.normal"
#define gcLeaderboardStoryHard @"com.xecudev.tracklapse.leaderboard.story.hard"


@interface GCHelper : NSObject <NSCoding,GKLeaderboardViewControllerDelegate,GKAchievementViewControllerDelegate> {
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
-(void)reportLeaderboard:(NSString *)identifier score:(float)rawScore;

- (void) showLeaderboards;
- (void) showAchievements;

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController;

@end
