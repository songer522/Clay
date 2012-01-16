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
#define gcAchievementBeatStoryEasy @"com.xecudev.tracklapse.achievement.story.beateasy"
#define gcAchievementBeatStoryNormal @"com.xecudev.tracklapse.achievement.story.beatnormal"
#define gcAchievementBeatStoryHard @"com.xecudev.tracklapse.achievement.story.beathard"
#define gcAchievementBeatStoryAll @"com.xecudev.tracklapse.achievement.story.beatall"
#define gcAchievementJumpOver400hurdles @"com.xecudev.tracklapse.achievement.jumpover400hurdles"
#define gcAchievementFlawlessRun @"com.xecudev.tracklapse.achievement.flawlessrun"
#define gcAchievementShuffled200people @"com.xecudev.tracklapse.achievement.shuffledoverpeople"
#define gcAchievementJumpOver100dogs   @"com.xecudev.tracklapse.achievement.jumpoverdogs"
#define gcAchievementShoot300zombies @"com.xecudev.tracklapse.achievement.shotzombies"
#define gcAchievementBlock75attack   @"com.xecudev.tracklapse.achievement.blockattacks"
#define gcAchievementFreeze200demon @"com.xecudev.tracklapse.achievement.freezedemons"
#define gcAchievementJumpOver50frogs @"com.xecudev.tracklapse.achievement.jumpoverfrogs"
#define gcAchievementGetHitby10hurdles  @"com.xecudev.tracklapse.achievement.gethitbyhurdles"
#define gcAchievementGetHitby10cows  @"com.xecudev.tracklapse.achievement.gethitbycows"
#define gcAchievementGetHitby10birds  @"com.xecudev.tracklapse.achievement.gethitbybirds"
#define gcAchievementGetHitby10dogs  @"com.xecudev.tracklapse.achievement.gethitbydogs"
#define gcAchievementGetHitby10dancers  @"com.xecudev.tracklapse.achievement.gethitbydancers"
#define gcAchievementGetHitby10zombies  @"com.xecudev.tracklapse.achievement.gethitbyzombies"
#define gcAchievementGetHitby10virues  @"com.xecudev.tracklapse.achievement.gethitbyvirues"
#define gcAchievementGetHitby10firedemon  @"com.xecudev.tracklapse.achievement.gethitbyfiredemon"
#define gcAchievementGetHitby10frogs  @"com.xecudev.tracklapse.achievement.gethitbyfrogs"
#define gcAchievementGetHitby10fish  @"com.xecudev.tracklapse.achievement.gethitbyfish"
#define gcAchievementGetHitby10bats  @"com.xecudev.tracklapse.achievement.gethitbybats"
#define gcAchievementGetHit500times  @"com.xecudev.tracklapse.achievement.timesgothit"

#define gcAchievementClear500enimies @"com.xecudev.tracklapse.achievement.clear500enimies"
#define gcAchievementClear1000enimies @"com.xecudev.tracklapse.achievement.clear1000enimies"
#define gcAchievementClear2500enimies @"com.xecudev.tracklapse.achievement.clear2500enimies"

#define gcAchievementBeatEachLevel10times  @"com.xecudev.tracklapse.achievement.beateachlevel10times"
#define gcAchievementWhoo100times  @"com.xecudev.tracklapse.achievement.timeswhooed"
#define gcAchievementFallIntoDeathPit10times @"com.xecudev.tracklapse.achievement.timesfellintodeathpit"
#define gcAchievementFalldown50times @"com.xecudev.tracklapse.achievement.timesfelldown"

#define gcAchievementFacebookUs      @"com.xecudev.tracklapse.achievement.facebook"
#define gcAchievementTwitterUs       @"com.xecudev.tracklapse.achievement.twitter"
#define gcAchievementAllGoldInNM     @"com.xecudev.tracklapse.achievement.normaltimedallgold"
#define gcAchievementAllGoldInIM     @"com.xecudev.tracklapse.achievement.insantimedallgold"
#define gcAchievementAllStoryAndAllGold @"com.xecudev.tracklapse.achievement.allstoryandallgold"
#define gcAchievementWatchCredits    @"com.xecudev.tracklapse.achievement.watchcredits"
#define gcAchievementRateTheGame     @"com.xecudev.tracklapse.achievement.ratethegame"


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
    bool _enabled;
    NSMutableDictionary *achievementDictionary;
}
@property (retain) NSMutableArray *leaderboardToReport;
@property (retain) NSMutableArray *achievementsToReport;
@property (nonatomic, retain) NSMutableDictionary *achievementDictionary;

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

-(GKAchievement*)getAchievementByID:(NSString *)identifier;
- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController;

@end
