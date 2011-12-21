//
//  Window.h
//  Clay
//
//  Created by Brian Cable on 12/21/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class ActionButton;
@class Sprite;
@class GameLabel;

typedef enum {
    WINDOW_CHOICE_YESNO,
    WINDOW_CHOICE_OK
}WindowChoiceType;

typedef enum {
    WIN_SELECT_YES,
    WIN_SELECT_NO,
    WIN_SELECT_OK
}WindowSelectionType;

@protocol GameWindowDelegate <NSObject>

-(void)userMadeGameWindowSelection:(WindowSelectionType)selection;

@end


@interface GameWindow : NSObject
{
    CCNode *_root;
    
    Sprite *_background;
    
    GameLabel *_header;
    
    NSMutableArray *_message;
    
    ActionButton *_choice1;
    ActionButton *_choice2;
    
    float _alpha;
    
    WindowChoiceType _choiceType;
    
}

+(id) gameWindowWithHeader:(NSString*)header Message:(NSString*)message Choices:(WindowChoiceType)choices Layer:(CCLayer*)layer;

-(id) initWithHeader:(NSString*)header Message:(NSString*)message Choices:(WindowChoiceType)choices Layer:(CCLayer*)layer;


#pragma mark - private methods
-(void)setupChoiceButtons; //called by init to setup the "YES/NO" buttons
-(void)setupMessage:(NSString*)message;
-(void)checkCollisionAtPoint:(CGPoint)point;

@end
