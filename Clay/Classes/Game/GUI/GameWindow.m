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

@implementation GameWindow

@synthesize delegate = _delegate;

+(id) gameWindowWithHeader:(NSString*)header Message:(NSString*)message Choices:(WindowChoiceType)choices Layer:(CCLayer*)layer;
{
    return [[self alloc] initWithHeader:header Message:message Choices:choices Layer:layer];
}

-(id) initWithHeader:(NSString*)header Message:(NSString*)message Choices:(WindowChoiceType)choices  Layer:(CCLayer*)layer
{
    if ((self=[super init])) {
        
        _root = [CCNode node];
        
        [[LayerManager sharedLayers] setWorkingLayer:_root];
        
        _background = [Sprite spriteCenteredWithFrame:@"MessageBox.png" Position:ccp(240,160)];
        
        _header = [GameLabel gameLabelWithText:header Scale:0.65f Position:ccp(240,240)];
        
        _messageSeparation = MESSAGE_SEPARATOR_PIPE; //default
        
        [self setupMessage:message];

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
        case WINDOW_CHOICE_YESNO:
            choice1Text = @"NO";
            choice2Text = @"YES";
            choice1Pos = ccp(160,82);
            choice2Pos = ccp(320,82);
            break;
        case WINDOW_CHOICE_OK:
            choice1Text = @"OK";
            choice1Pos = ccp(240,82);
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

-(void)setupMessage:(NSString*)message
{
    float curYPos = 180.0f;
    _message = [[NSMutableArray alloc] initWithCapacity:10];
    
    NSArray *messageStrings = [self getMessageArrayForString:message];
    for (NSString *lineText in messageStrings) {
        GameLabel *line = [GameLabel gameLabelWithText:lineText Scale:0.5f];
        [line setPosition:ccp(240,curYPos)];
        [_message addObject:line];
        curYPos -= 15.0f;
    }
}

-(NSArray*)getMessageArrayForString:(NSString*)message
{
    NSMutableString *remainingMessage;
    NSArray *messageArray;
    
    if (_messageSeparation == MESSAGE_SEPARATOR_PIPE) {
        messageArray = [message componentsSeparatedByString:message];
    } else {
        //character limit
        NSMutableArray *messages = [[NSMutableArray alloc] initWithCapacity:20];
        
        int currentPos = 0;
        
        while([remainingMessage length] > _characterLimit) {
            NSString *workingString = [remainingMessage substringToIndex:_characterLimit];
            currentPos = [workingString length] - 1;
            while(currentPos >= 0 && [workingString characterAtIndex:currentPos] != ' ') {
                currentPos--;
            }
            
            if (currentPos < 0) {
                [messages addObject:workingString];
                [remainingMessage setString:[remainingMessage substringFromIndex:_characterLimit]];
            } else {
                [messages addObject:[workingString substringToIndex:currentPos]];
                [remainingMessage setString:[remainingMessage substringFromIndex:currentPos]];
            }
        }
        
        messageArray = [NSArray arrayWithArray:messages];      
    }
    
    NSLog(@"Contents of Array: %@",[messageArray description]);
    
    return messageArray;
}

-(WindowSelectionType)checkCollisionAtPoint:(CGPoint)point
{
    WindowSelectionType returnVal = WIN_SELECT_NONE;
    
    if ([_choice1 checkIfSelected:point]) {
        if (_choiceType == WINDOW_CHOICE_YESNO) {
            returnVal = WIN_SELECT_NO;
        } else {
            returnVal = WIN_SELECT_OK;
        }
    } else if([_choice2 checkIfSelected:point]) {
        if (_choiceType == WINDOW_CHOICE_YESNO) {
            returnVal = WIN_SELECT_YES;
        }
    }
    
    return returnVal;
}

-(void)dealloc
{
    [_background release];
    for (GameLabel *line in _message) {
        [line release];
    }
    [_message release];
    [_header release];
    [_choice1 release];
    [_choice2 release];
    _delegate = nil;
}


@end
