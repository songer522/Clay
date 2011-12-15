//
//  FBPrompt.m
//  Clay
//
//  Created by Yang Song on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FBPrompt.h"

@implementation FBPrompt

@synthesize facebook;

-(void)initWithAppId:(NSString *)appId andDelegate:(id<FBSessionDelegate>)delegate
{
    facebook = [[Facebook alloc] initWithAppId:appId andDelegate:delegate];
}

-(void)promptUserWith:(NSString *)appId picture:(NSString *)picURL description:(NSString *)description andDelegate:(id<FBDialogDelegate>)delegate
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"])
    {
        facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    /*
     if (![facebook isSessionValid]) 
     {
     [facebook authorize:nil];
     }
     */
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   appId, @"app_id",
                                   @"http://developers.facebook.com/docs/reference/dialogs/", @"link",
                                  picURL, @"picture",
                                   @"Facebook Dialogs", @"name",
                                   @"Reference Documentation", @"caption",
                                   description, @"description",
                                   @"Facebook Dialogs are so easy!",  @"message",
                                   nil];
    
    [facebook dialog:@"feed" andParams:params andDelegate:delegate];

}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [facebook handleOpenURL:url]; 
}



@end
