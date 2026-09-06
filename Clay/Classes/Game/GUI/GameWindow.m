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
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        _root.position = ccp(winSize.width / 2.0f - 240 * MULTIPLIERX,
                             winSize.height / 2.0f - 160 * MULTIPLIERY);
        
        [[LayerManager sharedLayers] setWorkingLayer:_root];
        
        _background = [Sprite spriteCenteredWithFrame:backgroundImage Position:ccp(240 *MULTIPLIERX,160 *MULTIPLIERY)];
        
        _header = [GameLabel gameLabelWithText:header Scale:0.65f Position:ccp(240 *MULTIPLIERX,225*MULTIPLIERY)];
        
        // Store descriptions use | as a paragraph separator. Fit the complete message
        // above the choices; the old 25pt fixed box silently clipped phone warnings.
        NSString *displayMessage = [message stringByReplacingOccurrencesOfString:@"|" withString:@"\n"];
        CGFloat textWidth = 250 * MULTIPLIERX;
        CGFloat fontSize = 25;
        CGFloat textHeight = 0;
        do {
            UIFont *font = [UIFont fontWithName:@"Impact" size:fontSize] ?: [UIFont systemFontOfSize:fontSize];
            textHeight = ceilf([displayMessage boundingRectWithSize:CGSizeMake(textWidth, CGFLOAT_MAX)
                options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                attributes:@{NSFontAttributeName:font} context:nil].size.height);
            if (textHeight <= 100 * MULTIPLIERY || fontSize <= 16) break;
            fontSize -= 1;
        } while (YES);
        // Grow downward for longer localized descriptions without reducing legibility.
        CGFloat extraHeight = MAX(0, textHeight - 100 * MULTIPLIERY);
        [_background getCCSprite].scaleY = ([_background getHeight] + extraHeight) / [_background getHeight];
        [_background setScreenPosition:ccp(240 * MULTIPLIERX, 160 * MULTIPLIERY - extraHeight / 2)];
        _message = [CCLabelTTF labelWithString:displayMessage dimensions:CGSizeMake(textWidth, textHeight + 2)
            alignment:UITextAlignmentLeft fontName:@"Impact.ttf" fontSize:fontSize];
        [_message setPosition:ccp(240 * MULTIPLIERX, 205 * MULTIPLIERY - (textHeight + 2) / 2)];
        [_root addChild:_message];

        
        _choiceType = choices;
        _characterLimit = 20;
        
        [self setupChoiceButtons];
        [_choice1 setPosition:ccp([_choice1 getPosition].x, [_choice1 getPosition].y - extraHeight)];
        [_choice2 setPosition:ccp([_choice2 getPosition].x, [_choice2 getPosition].y - extraHeight)];
        _root.position = ccp(_root.position.x, _root.position.y + extraHeight / 2);
        
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
            choice1Pos = ccp(160*MULTIPLIERX,93*MULTIPLIERY);
            choice2Pos = ccp(320*MULTIPLIERX,93*MULTIPLIERY);
            break;
        case WINDOW_CHOICE_YESNO:
            choice1Text = @"YES";
            choice2Text = @"NO";
            choice1Pos = ccp(160*MULTIPLIERX,93*MULTIPLIERY);
            choice2Pos = ccp(320*MULTIPLIERX,93*MULTIPLIERY);
            break;
        case WINDOW_CHOICE_OK:
            choice1Text = @"OK";
            choice1Pos = ccp(240*MULTIPLIERX,93*MULTIPLIERY);
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
    point = [_root convertToNodeSpace:[_root.parent convertToWorldSpace:point]];
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
    [super dealloc];
}


@end
