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

@implementation GCHelper
@synthesize leaderboardToReport;
@synthesize achievementsToReport;

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
                          // [self resendData];
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
    
    if([achievement respondsToSelector:@selector(showsCompletionBanner)])
    {achievement.showsCompletionBanner = YES; 
    }   //Indicate that a banner should be shown
   
    if(!achievement.completed){
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
    }
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

#pragma mark User functions

- (void)authenticateLocalUser {
    if(!_enabled) { return; }
    
    //NSLog(@"gc - authenticatelocaluser");
    if (!gameCenterAvailable) return;
    
    //NSLog(@"Authenticating local user...");
    if ([GKLocalPlayer localPlayer].authenticated == NO) {
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError* error)
         {
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
    if(!_enabled) { return; }
    
    //NSLog(@"gc - reportachievement");
    GKAchievement* achievement = [[[GKAchievement alloc] initWithIdentifier:identifier] autorelease];
    achievement.percentComplete = percentComplete;

    [achievementsToReport addObject:achievement];
    [self save];
    if (!gameCenterAvailable || !userAuthenticated) {
        return;
    }
    [self sendAchievement:achievement];
}

- (void) showLeaderboards
{
    //NSLog(@"gc - showleaderboards");
    
    GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init] ;
    
    if (leaderboardController!=NULL) {
        //leaderboardController.category= gcLeaderboardInsaneTimedLevel1;
        leaderboardController.timeScope = GKLeaderboardTimeScopeAllTime;
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
