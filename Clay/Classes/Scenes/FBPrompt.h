//
//  FBPrompt.h
//  Clay
//
//  Created by Yang Song on 12/14/11.
//  Copyright (c) 2011 XecuDev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect.h"

@interface FBPrompt : NSObject<FBSessionDelegate,FBDialogDelegate>
{
    Facebook *facebook;
    id _delegate;
    NSString *_appId;
}
@property (nonatomic, retain) Facebook *facebook;

+(id)promptWithAppId:(NSString*)appId andDelegate:(id<FBSessionDelegate>)delegate;


-(id)initWithAppId:(NSString *)appId andDelegate:(id<FBSessionDelegate>)delegate;

-(void)showFacebookDialogWithDescription:(NSString*)description andPicture:(NSString*)picUrl;

-(Facebook*)getFacebookObject;

@end
