//
//  FBPrompt.m
//  Clay
//
//  Created by Yang Song on 12/14/11.
//  Copyright (c) 2011 XecuDev. All rights reserved.
//

#import "FBPrompt.h"

@implementation FBPrompt

@synthesize facebook;

+(id)promptWithAppId:(NSString*)appId andDelegate:(id)delegate
{
    return [[self alloc] initWithAppId:appId andDelegate:delegate];
}

-(id)initWithAppId:(NSString *)appId andDelegate:(id<FBSessionDelegate>)delegate
{
    if((self=[super init])) {
        facebook = [[Facebook alloc] initWithAppId:appId andDelegate:delegate];
        _delegate = delegate;
        _appId = appId;
    }
    return self;
}

-(void)showFacebookDialogWithDescription:(NSString*)description andPicture:(NSString*)picUrl
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
                                   _appId, @"app_id",
                                   @"http://developers.facebook.com/docs/reference/dialogs/", @"link",
                                  picUrl, @"picture",
                                   @"Facebook Dialogs", @"name",
                                   @"Reference Documentation", @"caption",
                                   description, @"description",
                                   @"Facebook Dialogs are so easy!",  @"message",
                                   nil];
    
    [facebook dialog:@"feed" andParams:params andDelegate:_delegate];

}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [facebook handleOpenURL:url]; 
}

-(Facebook*)getFacebookObject
{
    return facebook;
}

-(void)dealloc
{
    [facebook release];
    _delegate = nil;
    [_appId release];
    [super dealloc];
}


@end
