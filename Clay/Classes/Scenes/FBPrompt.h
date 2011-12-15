//
//  FBPrompt.h
//  Clay
//
//  Created by Yang Song on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect.h"

@interface FBPrompt : NSObject<FBSessionDelegate,FBDialogDelegate>
{
    Facebook *facebook;
}
@property (nonatomic, retain) Facebook *facebook;


-(void)initWithAppId:(NSString *)appId andDelegate:(id<FBSessionDelegate>)delegate;
-(void)promptUserWith:(NSString *)appId picture:(NSString *)picURL description:(NSString *)description andDelegate:(id<FBSessionDelegate>)delegate;
@end
