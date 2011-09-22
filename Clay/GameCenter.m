//
//  GameCenter.m
//  Clay
//
//  Created by Brian Cable on 9/22/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "GameCenter.h"

@implementation GameCenter

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+(bool) isGameCenterAvailable
{
    //check to see if the GKLocalPlayer class exists
    bool localPlayerClassAvailable = (NSClassFromString(@"GKLocalPlayer")) != nil;
    
    //device must run 4.1 or later
    NSString *requiredSystemVersion = @"4.1";
    NSString *currentSystemVersion = [[UIDevice currentDevice] systemVersion];
    
    bool osVersionSupported = ([currentSystemVersion compare:requiredSystemVersion options:NSNumericSearch] != NSOrderedAscending);
    
    return (localPlayerClassAvailable && osVersionSupported);
    
}

@end
