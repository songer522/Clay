//
//  CreditsScene.h
//  Clay
//
//  Created by Brian Cable on 12/13/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "CCLayer.h"
#import "cocos2d.h"

@interface CreditsScene : CCLayer
{
    float _currentY;
    NSMutableArray *_lines;
    bool _hasSwitched;
}

+(CCScene*)scene;

-(void)loadCredits;

-(void)addGroup:(NSDictionary*)dict;

-(void)addHeader:(NSString*)header;
-(void)addTitle:(NSString*)title;
-(void)addCredit:(NSString*)name;

-(void)switchToOptionsScreen;

@end
