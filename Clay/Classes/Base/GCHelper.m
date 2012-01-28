//
//  GCHelper.m
//  Clay
//
//  Created by Dustin Werner on 10/17/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GCHelper.h"
#import "Database.h"
#import "cocos2d.h"
#import "Appirater.h"
#import "AppDelegate.h"
#import "GCState.h"

@implementation GCHelper
@synthesize leaderboardToReport;
@synthesize achievementsToReport;
@synthesize achievementDictionary;

#pragma mark Loading/Saving

static GCHelper *sharedHelper = nil;
+ (GCHelper *) sharedInstance {
    @synchronized([GCHelper class])
    {
        if (!sharedHelper) {
            sharedHelper = [loadData(@"GameCenterData") retain];
            if (!sharedHelper){
                [[self alloc] initWithLeaderboardToReport:[NSMutableArray array] achievementsToReport:[NSMutableArray array]];
            }
        }
        //NSLog(@"shared GCHelper");
        return sharedHelper;
    }
    return nil;
}

+ (id)alloc
{
    @synchronized ([GCHelper class])
    {
        NSAssert(sharedHelper == nil, @"Attempted to allocated a second instance of the GCHelper singleton");
        sharedHelper = [super alloc];
        return sharedHelper;
    }
    return nil;
}

-(void)save {
    if(!_enabled) { return; }
    //NSLog(@"gc - save");
    saveData(self, @"GameCenterData");
}

-(BOOL)isGameCenterAvailable {
    if(!_enabled) { return false; }
    
    //NSLog(@"gc - isgamecenteravailable");
    // check for GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    // check if running iOS 4.1 or later
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}

- (id)initWithLeaderboardToReport:(NSMutableArray *)theLeaderboardToReport achievementsToReport:(NSMutableArray *)theAchievementsToReport {
    //NSLog(@"gc - initwithleaderboardtoreport");
    if ((self = [super init])) {
        
        _enabled = true;
        self.leaderboardToReport = theLeaderboardToReport;
        self.achievementsToReport = theAchievementsToReport;
        achievementDictionary=[[NSMutableDictionary alloc] init];
        gameCenterAvailable = [self isGameCenterAvailable];
        if (gameCenterAvailable) {
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc addObserver:self selector:@selector(authenticationChanged) name:GKPlayerAuthenticationDidChangeNotificationName object:nil];
        }
    }
    
    
    
    
    return self;
}

#pragma  mark Internal Functions

- (void)authenticationChanged {
    if(!_enabled) { return; }
    
    //NSLog(@"gc - authenticationchanged");
    dispatch_async(dispatch_get_main_queue(), ^(void)
                   {
                       if ([GKLocalPlayer localPlayer].isAuthenticated && !userAuthenticated) {
                           //NSLog(@"Authentication changed: player authenticated.");
                           userAuthenticated = TRUE;
                           [self resendData];
                       } else if (![GKLocalPlayer localPlayer].isAuthenticated && userAuthenticated) {
                           //NSLog(@"Authentication changed: player not authenticated.");
                           userAuthenticated = FALSE;
                       }
                   });
     
}

-(void)sendAchievement:(GKAchievement *)achievement {
    if(!_enabled) { return; }
    
    //NSLog(@"gc - sendachievement");
   // achievement.percentComplete = 100.0;   //Indicates the achievement is done
    
   
   
    //if(achievement.completed == false){
        
    [achievement reportAchievementWithCompletionHandler:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           if (error == NULL) {
                               //NSLog(@"Successfully sent achievement!");
                               [achievementsToReport removeObject:achievement];
                           } else {
                               //NSLog(@"Achievement failed to send... will try again later. Reason: %@", error.localizedDescription);
                           }
                       });
    }];
    //}
}
-(void)sendScore:(GKScore *)score {
    if(!_enabled) { return; }
    
    //NSLog(@"gc - sendscore");
    [score reportScoreWithCompletionHandler:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           if (error == NULL) {
                               //NSLog(@"Successfully sent score!");
                               [leaderboardToReport removeObject:score];
                           } else {
                               //NSLog(@"Score failed to send... will try again later. Reason: %@", error.localizedDescription);
                           }
                       });
    }];
}

-(void)resendData {
    if(!_enabled) { return; }
    
    //NSLog(@"gc - resenddata");
    for (GKAchievement *achievement in achievementsToReport) {
        [self sendAchievement:achievement];
    }
    for (GKScore *score in leaderboardToReport) {
        [self sendScore:score];
    }
}


-(void)syncLocalAchievementsData:(GKAchievement *)achievement
{
    if([achievement.identifier isEqualToString:gcAchievementChickensKickedIntoCows]){
        [GCState sharedInstance].chickensKickedIntoCows = (100 * achievement.percentComplete)/100;
    }
    else if([achievement.identifier isEqualToString:gcAchievementTimesDied])
    {
        [GCState sharedInstance].timesDied = (200 * achievement.percentComplete)/100;
    }
    else if([achievement.identifier isEqualToString:gcAchievementShuffled200people])
    {
        [GCState sharedInstance].peopleShuffled = (200 * achievement.percentComplete)/100;
      
    }
    else if([achievement.identifier isEqualToString:gcAchievementBeatStoryEasy])
    {
        [GCState sharedInstance].completeStoryEasy = achievement.completed;
        
    }
    else if([achievement.identifier isEqualToString:gcAchievementBeatStoryNormal])
    {
        [GCState sharedInstance].completeStoryNormal = achievement.completed;
        
    }
    else if([achievement.identifier isEqualToString:gcAchievementBeatStoryHard])
    {
        [GCState sharedInstance].completeStoryHard = achievement.completed;
        
    }
    else if([achievement.identifier isEqualToString:gcAchievementBeatStoryAll])
    {
        [GCState sharedInstance].completeStoryAll = achievement.completed;
        
    }
    else if([achievement.identifier isEqualToString:gcAchievementJumpOver400hurdles])
    {
        [GCState sharedInstance].hurdlesJumpedOver = (400 * achievement.percentComplete)/100;
        
    }
    else if([achievement.identifier isEqualToString:gcAchievementFlawlessRun])
    {
        [GCState sharedInstance].flawlessRun = achievement.completed;
        
    }
    else if([achievement.identifier isEqualToString:gcAchievementJumpOver100dogs])
    {
        [GCState sharedInstance].dogsJumpedOver = (100 * achievement.percentComplete)/100;
        
    }
    else if([achievement.identifier isEqualToString:gcAchievementShoot300zombies])
    {
        [GCState sharedInstance].zombiesShot = (300 * achievement.percentComplete)/100;
        
    }
    else if([achievement.identifier isEqualToString:gcAchievementBlock75attack])
    {
        [GCState sharedInstance].attacksBlocked = (75 * achievement.percentComplete)/100;
        
    }
    else if([achievement.identifier isEqualToString:gcAchievementFreeze200demon])
    {
        [GCState sharedInstance].demonsFreezed = (200 * achievement.percentComplete)/100;
        
    }
    else if([achievement.identifier isEqualToString:gcAchievementJumpOver50frogs])
    {
        [GCState sharedInstance].frogsJumpedOver = (50 * achievement.percentComplete)/100;
        
    }
    else if([achievement.identifier isEqualToString:gcAchievementKnock50Bubbles])
    {
        [GCState sharedInstance].bubblesPoked = (50 * achievement.percentComplete)/100;
        
    }
    
    
    
    else if([achievement.identifier isEqualToString:gcAchievementGetHitby10hurdles])
    {
        [GCState sharedInstance].hurdlesHit = (10 * achievement.percentComplete)/100;
        
    }
    else if([achievement.identifier isEqualToString:gcAchievementGetHitby10cows])
    {
        [GCState sharedInstance].cowsHit = (10 * achievement.percentComplete)/100;
        
    }
    else if([achievement.identifier isEqualToString:gcAchievementGetHitby10birds])
    {
        [GCState sharedInstance].birdsHit = (10 * achievement.percentComplete)/100;
        
    }
    else if([achievement.identifier isEqualToString:gcAchievementGetHitby10dogs])
    {
        [GCState sharedInstance].dogsHit = (10 * achievement.percentComplete)/100;
        
    }
    else if([achievement.identifier isEqualToString:gcAchievementGetHitby10dancers])
    {
        [GCState sharedInstance].dancersHit = (10 * achievement.percentComplete)/100;
        
    }
    else if([achievement.identifier isEqualToString:gcAchievementGetHitby10zombies])
    {
        [GCState sharedInstance].zombiesHit = (10 * achievement.percentComplete)/100;
        
    }
    else if([achievement.identifier isEqualToString:gcAchievementGetHitby10virues])
    {
        [GCState sharedInstance].viruesHit = (10 * achievement.percentComplete)/100;
        
    }
    else if([achievement.identifier isEqualToString:gcAchievementGetHitby10firedemon])
    {
        [GCState sharedInstance].fireDemonHit = (10 * achievement.percentComplete)/100;
        
    }
    else if([achievement.identifier isEqualToString:gcAchievementGetHitby10frogs])
    {
        [GCState sharedInstance].frogsHit = (10 * achievement.percentComplete)/100;
        
    }
    else if([achievement.identifier isEqualToString:gcAchievementGetHitby10fish])
    {
        [GCState sharedInstance].fishHit = (10 * achievement.percentComplete)/100;
        
    }
    else if([achievement.identifier isEqualToString:gcAchievementGetHitby10bats])
    {
        [GCState sharedInstance].batHit = (10 * achievement.percentComplete)/100;
        
    }
    
    
    else if([achievement.identifier isEqualToString:gcAchievementWhoo100times])
    {
        [GCState sharedInstance].timesWhooed = (100 * achievement.percentComplete)/100;
        
    }
    else if([achievement.identifier isEqualToString:gcAchievementFallIntoDeathPit10times])
    {
        [GCState sharedInstance].timesFellIntoDeathPit = (10 * achievement.percentComplete)/100;
        
    }
    else if([achievement.identifier isEqualToString:gcAchievementFalldown50times])
    {
        [GCState sharedInstance].timesFellDown = (50 * achievement.percentComplete)/100;
        
    }
    else if([achievement.identifier isEqualToString:gcAchievementGetHit500times])
    {
        [GCState sharedInstance].gotHit = (500 * achievement.percentComplete)/100;
        
    }
    
    else if([achievement.identifier isEqualToString:gcAchievementFacebookUs])
    {
        [GCState sharedInstance].facebook = achievement.completed;
        
    } else if([achievement.identifier isEqualToString:gcAchievementTwitterUs])
    {
        [GCState sharedInstance].twitter = achievement.completed;
        
    } else if([achievement.identifier isEqualToString:gcAchievementAllGoldInNM])
    {
        [GCState sharedInstance].allGoldInNormal = achievement.completed;
        
    } else if([achievement.identifier isEqualToString:gcAchievementAllGoldInIM])
    {
        [GCState sharedInstance].allGoldInInsane = achievement.completed;
        
    } else if([achievement.identifier isEqualToString:gcAchievementAllStoryAndAllGold])
    {
        [GCState sharedInstance].beatStoryAndAllGold = achievement.completed;
        
    } else if([achievement.identifier isEqualToString:gcAchievementWatchCredits])
    {
        [GCState sharedInstance].watchCredit = achievement.completed;
        
    }
    else if([achievement.identifier isEqualToString:gcAchievementRateTheGame])
    {
        [GCState sharedInstance].rateOurGame = achievement.completed;
        
    }

    
}
-(void)loadAchievements
{
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {
        if(error == nil)
        {dispatch_queue_t downloadQueue = dispatch_queue_create("achievements downloader", NULL);
            dispatch_async(downloadQueue, ^{
                for(GKAchievement *object in achievements)
                {
                    [achievementDictionary setObject:object forKey:object.identifier];
                    [self syncLocalAchievementsData:object];
                     }  
                     
                     });
                     dispatch_release(downloadQueue);
                     
                     
                     }
                     
                     
                     }];
                    
                    
                }


-(GKAchievement*)getAchievementByID:(NSString *)identifier
{
    GKAchievement *achievement = [achievementDictionary objectForKey:identifier];
    if (achievement == nil)
    {
        achievement = [[[GKAchievement alloc] initWithIdentifier:identifier] autorelease];
        [achievementDictionary setObject:achievement forKey:achievement.identifier];
    }
    return [[achievement retain] autorelease];
}

#pragma mark User functions

- (void)authenticateLocalUser {
    if(!_enabled) { return; }
    
    //NSLog(@"gc - authenticatelocaluser");
    if (!gameCenterAvailable) return;
    
    //NSLog(@"Authenticating local user...");
    if ([GKLocalPlayer localPlayer].authenticated == NO) {
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError* error)
         {
             [self loadAchievements];
             [[CCDirector sharedDirector] resume];
         }];
    } else {
        //NSLog(@"Already authenticated!");
    }
     
}

- (void)reportLeaderboard:(NSString *)identifier score:(float)rawScore {
    if(!_enabled) { return; }
    
    //NSLog(@"gc - reportleaderboard");
    GKScore *score=[[[GKScore alloc] initWithCategory:identifier] autorelease];
    score.value=rawScore;
    [leaderboardToReport addObject:score];
    [self save];
    if(!gameCenterAvailable || !userAuthenticated) return;
    [self sendScore:score];
}

- (void)reportAchievement:(NSString *)identifier percentComplete:(double)percentComplete {
    if(!_enabled ) { return; }
    
    //NSLog(@"gc - reportachievement");

    GKAchievement* achievement = [self getAchievementByID:identifier];
    if(achievement !=nil && achievement.percentComplete < percentComplete)
    {
        if(!achievement.isCompleted)
        {
            if([achievement respondsToSelector:@selector(showsCompletionBanner)])
            {
                achievement.showsCompletionBanner = YES; 
            }   //Indicate that a banner should be shown
            achievement.percentComplete = percentComplete;
            [achievementsToReport addObject:achievement];
            if (!gameCenterAvailable || !userAuthenticated) {
                return;
            }
            [self sendAchievement:achievement];

        }
    }
    /*
    achievement.percentComplete = percentComplete;
   
    
   [achievementsToReport addObject:achievement];
    [self save];
    if (!gameCenterAvailable || !userAuthenticated) {
        return;
    }
    [self sendAchievement:achievement];
     */
}

- (void) showLeaderboards
{
    //NSLog(@"gc - showleaderboards");
    
    GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init] ;
    
    if (leaderboardController!=NULL) {
        
        leaderboardController.timeScope = GKLeaderboardTimeScopeToday;
        //leaderboardController.view.
        leaderboardController.leaderboardDelegate = self;
        AppDelegate *delegate = [UIApplication sharedApplication].delegate;
        [delegate.viewController presentModalViewController:leaderboardController animated:YES];
    }
    
}

- (void) showAchievements
{
    GKAchievementViewController *achievementController = [[[GKAchievementViewController alloc] init] autorelease];
    
    if (achievementController!=NULL) {
        achievementController.achievementDelegate = self;
        AppDelegate *delegate = [UIApplication sharedApplication].delegate;
        [delegate.viewController presentModalViewController:achievementController animated:YES];
    }
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate.viewController dismissModalViewControllerAnimated:YES];
}


-(void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate.viewController dismissModalViewControllerAnimated:YES];
}


#pragma mark NSCoding

-(void)encodeWithCoder:(NSCoder *)encoder {
    //NSLog(@"gc - encodewithcoder");
    [encoder encodeObject:leaderboardToReport forKey:@"LeaderboardToReport"];
    [encoder encodeObject:achievementsToReport forKey:@"AchievementsToReport"];
}

-(id)initWithCoder:(NSCoder *)decoder {
    //NSLog(@"gc - initwithcoder");
    NSMutableArray * theLeaderboardToReport = [decoder decodeObjectForKey:@"LeaderboardToReport"];
    NSMutableArray * theAchievementsToReport = [decoder decodeObjectForKey:@"AchievementsToReport"];
    return [self initWithLeaderboardToReport:theLeaderboardToReport achievementsToReport:theAchievementsToReport];
}

-(void)dealloc
{
    [leaderboardToReport removeAllObjects];
    [leaderboardToReport release];
    [achievementsToReport removeAllObjects];
    [achievementsToReport release];
    [super dealloc];
}

@end
