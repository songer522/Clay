//
//  GCHelper.m
//  Clay
//
//  Created by Dustin Werner on 10/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GCHelper.h"
#import "Database.h"
#import "cocos2d.h"
#import "Appirater.h"
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
    saveData(self, @"GameCenterData");
}

-(BOOL)isGameCenterAvailable {
    // check for GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    // check if running iOS 4.1 or later
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}

- (id)initWithLeaderboardToReport:(NSMutableArray *)theLeaderboardToReport achievementsToReport:(NSMutableArray *)theAchievementsToReport {
    if ((self = [super init])) {
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
    dispatch_async(dispatch_get_main_queue(), ^(void)
                   {
                       if ([GKLocalPlayer localPlayer].isAuthenticated && !userAuthenticated) {
                           //NSLog(@"Authentication changed: player authenticated.");
                           userAuthenticated = TRUE;
                           [self resendData];
                       } else if (![GKLocalPlayer localPlayer].isAuthenticated && userAuthenticated) {
                           //NSLog(@"Authentication changed: player not authenticated.");
                       }
                   });
     
}

-(void)sendAchievement:(GKAchievement *)achievement {
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

-(void)resendData {
    for (GKAchievement *achievement in achievementsToReport) {
        [self sendAchievement:achievement];
    }
}

#pragma mark User functions

- (void)authenticateLocalUser {
    if (!gameCenterAvailable) return;
    
    NSLog(@"Authenticating local user...");
    if ([GKLocalPlayer localPlayer].authenticated == NO) {
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError* error)
         {
             [[CCDirector sharedDirector] resume];
         }];
    } else {
        NSLog(@"Already authenticated!");
    }
     
}

- (void)reportLeaderboard:(NSString *)identifier score:(int)score {
    // Used for Leaderboards
}

- (void)reportAchievement:(NSString *)identifier percentComplete:(double)percentComplete {
    GKAchievement* achievement = [[[GKAchievement alloc] initWithIdentifier:identifier] autorelease];
    achievement.percentComplete = percentComplete;
    [achievementsToReport addObject:achievement];
    [self save];
    if (!gameCenterAvailable || !userAuthenticated) {
        return;
    }
    [self sendAchievement:achievement];
}

#pragma mark NSCoding

-(void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:leaderboardToReport forKey:@"LeaderboardToReport"];
    [encoder encodeObject:achievementsToReport forKey:@"AchievementsToReport"];
}

-(id)initWithCoder:(NSCoder *)decoder {
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
