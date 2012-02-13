//
//  Window.m
//  Clay
//
//  Created by Brian Cable on 12/21/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "GameWindow.h"
#import "Sprite.h"
#import "GameLabel.h"
#import "ActionButton.h"
#import "LayerManager.h"
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define MULTIPLIERX (IS_IPAD ? 2.133 : 1)
#define MULTIPLIERY (IS_IPAD ? 2.4 : 1)

@implementation GameWindow

@synthesize delegate = _delegate;

+(id) gameWindowWithHeader:(NSString*)header Message:(NSString*)message Choices:(WindowChoiceType)choices Layer:(CCLayer*)layer withBackground:(NSString *) backgroundImage
{
    return [[self alloc] initWithHeader:header Message:message Choices:choices Layer:layer withBackground:backgroundImage];
}

-(id) initWithHeader:(NSString*)header Message:(NSString*)message Choices:(WindowChoiceType)choices  Layer:(CCLayer*)layer withBackground:(NSString *) backgroundImage
{
    if ((self=[super init])) {
        
        _root = [CCNode node];
        
        [[LayerManager sharedLayers] setWorkingLayer:_root];
        
        _background = [Sprite spriteCenteredWithFrame:backgroundImage Position:ccp(240 *MULTIPLIERX,160 *MULTIPLIERY)];
        
        _header = [GameLabel gameLabelWithText:header Scale:0.65f Position:ccp(240 *MULTIPLIERX,225*MULTIPLIERY)];
        
        _message = [CCLabelTTF labelWithString:message dimensions:CGSizeMake(230*MULTIPLIERX, 110*MULTIPLIERY) alignment:UITextAlignmentLeft fontName:@"Impact.ttf" fontSize:25];
        [_message setPosition:ccp(240.0f*MULTIPLIERX,150.0f*MULTIPLIERY)];
        [_root addChild:_message];

        
        _choiceType = choices;
        _characterLimit = 20;
        
        [self setupChoiceButtons];
        
        [layer addChild:_root];

        [[LayerManager sharedLayers] forgetWorkingLayer];
    }
    return self;
}

-(void)setupChoiceButtons
{
    NSString *choice1Text = nil;
    NSString *choice2Text = nil;
    CGPoint choice1Pos;
    CGPoint choice2Pos;
    switch (_choiceType) {
        case WINDOW_CHOICE_NOYES:
            choice1Text = @"NO";
            choice2Text = @"YES";
            choice1Pos = ccp(160*MULTIPLIERX,90*MULTIPLIERY);
            choice2Pos = ccp(320*MULTIPLIERX,90*MULTIPLIERY);
            break;
        case WINDOW_CHOICE_YESNO:
            choice1Text = @"YES";
            choice2Text = @"NO";
            choice1Pos = ccp(160*MULTIPLIERX,90*MULTIPLIERY);
            choice2Pos = ccp(320*MULTIPLIERX,90*MULTIPLIERY);
            break;
        case WINDOW_CHOICE_OK:
            choice1Text = @"OK";
            choice1Pos = ccp(240*MULTIPLIERX,90*MULTIPLIERY);
        default:
            break;
    }
    
    _choice1 = [ActionButton actionButtonManualSetup];
    [_choice1 setEnabled:true];
    if (choice1Text) {
        [_choice1 setInitialText:choice1Text];
        [_choice1 setPosition:choice1Pos];
    }
    
    _choice2 = [ActionButton actionButtonManualSetup];
    [_choice2 setEnabled:true];
    if (choice2Text) {
        [_choice2 setInitialText:choice2Text];
        [_choice2 setPosition:choice2Pos];
    }
}

-(WindowSelectionType)checkCollisionAtPoint:(CGPoint)point
{
    WindowSelectionType returnVal = WIN_SELECT_NONE;
    
    if ([_choice1 checkIfSelected:point]) {
        if (_choiceType == WINDOW_CHOICE_YESNO) {
            returnVal = WIN_SELECT_YES;
        } else if(_choiceType == WINDOW_CHOICE_NOYES) {
            returnVal = WIN_SELECT_NO;
        } else {
            returnVal = WIN_SELECT_OK;
        }
    } else if([_choice2 checkIfSelected:point]) {
        if (_choiceType == WINDOW_CHOICE_YESNO) {
            returnVal = WIN_SELECT_NO;
        } else if(_choiceType == WINDOW_CHOICE_NOYES) {
            returnVal = WIN_SELECT_YES;
        }
    }
    
    return returnVal;
}

-(void)dealloc
{
    [_background release];
    [_message removeFromParentAndCleanup:YES];
    [_header release];
    [_choice1 release];
    [_choice2 release];
    _delegate = nil;
}


@end
