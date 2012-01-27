//
//  EndLevelScene.h
//  Clay
//
//  Created by Brian Cable on 10/12/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//
//  Shows up at the end of the game. Not intended to work exactly like this in the final game. This is supposed to go back to the main menu after it is clicked, but currently it is disabled because the code

#import "CCLayer.h"
#import "cocos2d.h"
#import <Twitter/Twitter.h>
#import "FBConnect.h"
#import <Accounts/Accounts.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class Sprite;
@class ComicLayer;
@class TrackTimer;
@class ActionButton;
@class FBPrompt;

typedef enum {
    END_LEVEL_TRANSITION_IN,
    END_LEVEL_TRANSITION_IDLE,
    END_LEVEL_TRANSITION_OUT
}EndLevelState;

@interface EndLevelScene : CCLayer <FBDialogDelegate,FBSessionDelegate>
{
    Sprite *_endGame;
    Sprite *_bestTime;
    ComicLayer *_comicLayer;
    Sprite *_facebookIcon;
    Sprite *_twitterIcon;
    
    CCScene *_scene;
    
    float _alpha;
    bool _initialized;
    bool _openFacebook;
    bool _openTwitter;
    
    TWTweetComposeViewController *_tweetViewController;
    FBPrompt *_fbprompt;

    
    EndLevelState _state;
    
    TrackTimer *_timer;
    TrackTimer *_besttimer;
    
    ActionButton *_facebookButton;
    ActionButton *_twitterButton;
    
    NSString *_difficulty;
    NSString *time;
    
    NSString *_description;
    
}

+(CCScene *) scene;

-(void)update:(float)dt;
@end
