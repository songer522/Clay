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
        
        _hintBox = [Sprite spriteCenteredWithFrame:@"UI_HintBox_1.png"];
        [_hintBox setScreenPosition:ccp(240.0f*MULTIPLIERX,centerY + 140.0f*MULTIPLIERY)];
        
        _hintHeader = [Sprite spriteCenteredWithFrame:@"UI_HintBox_2.png"];
        [_hintHeader setScreenPosition:ccp(128.0f*MULTIPLIERX,centerY + 166.5f*MULTIPLIERY)];
        
        _textAlpha = 1.0f;
        _currentHintId = -1;
        
        [self loadHints];
        
        NSString *hint = [self getNewHint];
        
        _hintText = [CCLabelTTF labelWithString:hint dimensions:CGSizeMake(250*MULTIPLIERX, 100*MULTIPLIERY) alignment:UITextAlignmentLeft fontName:@"Impact.ttf" fontSize:22];
                
        _waitUntilNextHint = HINTBOX_SECONDS_BEFORE_NEXT_HINT + 1.0f;
        
        _phase = HINTBOX_WAITING;
        
        [_hintText setPosition:ccp(240.0f*MULTIPLIERX,229.0f*MULTIPLIERY)]; //pause was 211i
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
