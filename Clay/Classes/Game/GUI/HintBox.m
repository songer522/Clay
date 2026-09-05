//
//  HintBox.m
//  Clay
//
//  Created by Brian Cable on 1/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HintBox.h"
#import "PListLoader.h"
#import "LevelManager.h"
#import "Level.h"
#import "Sprite.h"

#define HINTBOX_SECONDS_BEFORE_NEXT_HINT 6.5f
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define MULTIPLIERX (IS_IPAD ? 2.133 : 1)
#define MULTIPLIERY (IS_IPAD ? 2.4 : 1)
#define HINTBOX_CENTER_X 240.0f
#define HINTBOX_HEADER_X 128.0f
#define HINTBOX_BOX_OFFSET_Y 140.0f
#define HINTBOX_HEADER_OFFSET_Y 166.5f

//Hints were laid out against a 480pt-wide screen with the box pinned at x=240, so on a wide
//phone the whole group stayed at 27% of the width instead of centred. winSize/2 reproduces
//the authored position exactly at 480 and follows the live viewport on modern screens.
//Same idiom as GameObjectWidthScale() in GameObject.m.
#define HINTBOX_HEADER_INSET_X (HINTBOX_CENTER_X - HINTBOX_HEADER_X)

//Interior padding of the blue panel art. The HINT tab sits just above the panel's top edge
//rather than over it, so only a thin inset is needed.
#define HINTBOX_PAD_X 10.0f
#define HINTBOX_PAD_TOP 6.0f
#define HINTBOX_PAD_BOTTOM 6.0f

//The panel art is 288.5x54.5 on a phone, which holds about two lines at the authored 22pt
//while most hints wrap to three or four - that is what used to spill onto the level. Shrink
//the text only as far as HINTBOX_MIN_FONT_SIZE, then grow the panel to cover the rest, so
//the hints stay readable instead of collapsing to fit a fixed box. The iPad panel already
//fits every hint at 22pt, so it keeps its current appearance and is never scaled.
#define HINTBOX_FONT_SIZE 22.0f
#define HINTBOX_MIN_FONT_SIZE 16.0f

static UIFont *HintBoxFont(CGFloat size)
{
    UIFont *font = [UIFont fontWithName:@"Impact" size:size];
    if (font == nil) {
        font = [UIFont fontWithName:@"Impact.ttf" size:size];
    }
    if (font == nil) {
        font = [UIFont systemFontOfSize:size];
    }
    return font;
}

@implementation HintBox

+(id)hintboxOnLayer:(id)layer
{
    return [[self alloc] initOnLayer:layer];
}

-(id)initOnLayer:(id)layer
{
    if ((self=[super init])) {
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        float centerY = winSize.height/2.0f - 35.0f*MULTIPLIERY;

        _hintList = [[NSMutableArray alloc] initWithCapacity:10];
        
        float centerX = winSize.width/2.0f;

        _hintBox = [Sprite spriteCenteredWithFrame:@"UI_HintBox_1.png"];
        CGPoint boxPosition = ccp(centerX, centerY + HINTBOX_BOX_OFFSET_Y * MULTIPLIERY);
        [_hintBox setScreenPosition:boxPosition];
        
        _hintHeader = [Sprite spriteCenteredWithFrame:@"UI_HintBox_2.png"];
        [_hintHeader setScreenPosition:ccp(centerX - HINTBOX_HEADER_INSET_X * MULTIPLIERX, centerY + HINTBOX_HEADER_OFFSET_Y * MULTIPLIERY)];
        
        _textAlpha = 1.0f;
        _currentHintId = -1;
        
        [self loadHints];
        
        NSString *hint = [self getNewHint];
        
        //Size the text block from the panel art rather than a fixed 250x100 box that was
        //taller than the panel interior, which is what let long hints spill onto the level.
        float panelWidth = [_hintBox getWidth];
        float panelHeight = [_hintBox getHeight];
        float textWidth = panelWidth - HINTBOX_PAD_X * 2.0f * MULTIPLIERX;
        float padY = (HINTBOX_PAD_TOP + HINTBOX_PAD_BOTTOM) * MULTIPLIERY;

        float fontSize = [self fittingFontSizeForTextWidth:textWidth
                                            interiorHeight:panelHeight - padY];
        float textHeight = [self heightForTallestHintAtWidth:textWidth fontSize:fontSize];

        //Grow the panel downwards if the tallest hint still needs more room at that size.
        //The top edge stays put so the HINT tab remains attached to it.
        float panelTop = boxPosition.y + panelHeight/2.0f;
        float neededHeight = textHeight + padY;
        if (neededHeight > panelHeight) {
            [[_hintBox getCCSprite] setScaleY:neededHeight / panelHeight];
            panelHeight = neededHeight;
            [_hintBox setScreenPosition:ccp(boxPosition.x, panelTop - panelHeight/2.0f)];
        }

        CGSize textSize = CGSizeMake(textWidth, textHeight);
        _hintText = [CCLabelTTF labelWithString:hint dimensions:textSize alignment:UITextAlignmentLeft fontName:@"Impact.ttf" fontSize:fontSize];
                
        _waitUntilNextHint = HINTBOX_SECONDS_BEFORE_NEXT_HINT + 1.0f;
        
        _phase = HINTBOX_WAITING;
        
        //Top-align the block against the panel interior instead of hanging it off the centre.
        float textCenterY = panelTop - HINTBOX_PAD_TOP * MULTIPLIERY - textHeight/2.0f;
        [_hintText setPosition:ccp(boxPosition.x, textCenterY)];
        [layer addChild:_hintText];

    }
    
    return self;
}

-(void)loadHints
{
    NSString *levelName = [[LevelManager shared] currentLevel].name;
    
    NSDictionary *allHints = [PListLoader loadPlistWithName:@"hints"];
    
    NSDictionary *levelHints = [allHints objectForKey:levelName];
    if (levelHints) {
        [self loadHintsFromDictionary:levelHints];
    }
    
    NSDictionary *globalHints = [allHints objectForKey:@"global"];
    if (globalHints) {
        [self loadHintsFromDictionary:globalHints];
    }
}

-(void)loadHintsFromDictionary:(NSDictionary*)dict
{
    NSEnumerator *enumerator = [dict objectEnumerator];
    
    id hint;
    while ((hint = [enumerator nextObject])) {
        if(hint) {
            [_hintList addObject:[NSString stringWithString:hint]];
        }
    }
}

//The tallest wrapped hint in the rotation. Every hint shares one font size and one box
//height so the text does not jump around as the panel cycles through them.
-(float)heightForTallestHintAtWidth:(float)width fontSize:(float)fontSize
{
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:HintBoxFont(fontSize)
                                                           forKey:NSFontAttributeName];
    float tallest = 0.0f;
    for (NSString *hint in _hintList) {
        CGRect bounds = [hint boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:attributes
                                           context:nil];
        if (bounds.size.height > tallest) {
            tallest = bounds.size.height;
        }
    }
    return ceilf(tallest);
}

//Largest size at which every hint fits the panel as drawn, never going below the readable
//floor. Anything the floor still cannot fit is absorbed by growing the panel instead.
-(float)fittingFontSizeForTextWidth:(float)width interiorHeight:(float)interiorHeight
{
    if (width <= 0.0f || interiorHeight <= 0.0f) {
        return HINTBOX_FONT_SIZE;
    }

    for (float fontSize = HINTBOX_FONT_SIZE; fontSize > HINTBOX_MIN_FONT_SIZE; fontSize -= 1.0f) {
        if ([self heightForTallestHintAtWidth:width fontSize:fontSize] <= interiorHeight) {
            return fontSize;
        }
    }

    return HINTBOX_MIN_FONT_SIZE;
}

-(NSString*)getNewHint
{
    int count = [_hintList count];
    if (count > 0) {
        //int choice = rand()%count;
        _currentHintId = (_currentHintId + 1) % count;
        return [_hintList objectAtIndex:_currentHintId];        
    }
    
    return nil;
}

-(void)setTextAlpha:(float)alpha
{
    [_hintBox setAlpha:alpha];
    [_hintHeader setAlpha:alpha];
    
    GLubyte opacity = (alpha * _textAlpha) * 255;
    [_hintText setOpacity:opacity];
}

-(void)update:(float)dt
{
    float rate = 1.5f * dt;
    switch (_phase) {
        case HINTBOX_WAITING:
            _waitUntilNextHint -= dt;
            if (_waitUntilNextHint<=0.0f) {
                _textAlpha = 1.0f;
                _phase = HINTBOX_TRANSITION_OUT;
            }
            break;
        case HINTBOX_TRANSITION_OUT:
            _textAlpha -= rate;
            if (_textAlpha<=0.0f) {
                [self switchHint];
                _textAlpha = 0.0f;
                _phase = HINTBOX_TRANSITION_IN;
            }
            break;
        case HINTBOX_TRANSITION_IN:
            _textAlpha += rate;
            if (_textAlpha >= 1.0f) {
                _textAlpha = 1.0f;
                _waitUntilNextHint = HINTBOX_SECONDS_BEFORE_NEXT_HINT;
                _phase = HINTBOX_WAITING;
            }
            break;
        default:
            //shouldn't get here, but restart the process just in case
            _phase = HINTBOX_WAITING;
            _waitUntilNextHint = HINTBOX_SECONDS_BEFORE_NEXT_HINT;
            break;
    }
    
}

-(void)switchHint
{
    [_hintText setString:[self getNewHint]];
}

-(void)dealloc
{
    [_hintList removeAllObjects];
    [_hintList release];
    [_hintBox release];
    [_hintHeader release];
    [_hintText removeFromParentAndCleanup:YES];
    [super dealloc];
}

@end
