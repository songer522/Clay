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

@implementation HintBox

+(id)hintboxOnLayer:(id)layer
{
    return [[self alloc] initOnLayer:layer];
}

-(id)initOnLayer:(id)layer
{
    if ((self=[super init])) {
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        float centerY = winSize.height/2.0f - 35.0f;

        _hintList = [[NSMutableArray alloc] initWithCapacity:10];
        
        _hintBox = [Sprite spriteCenteredWithFrame:@"UI_HintBox_1.png"];
        [_hintBox setScreenPosition:ccp(240.0f,centerY + 140.0f)];
        
        _hintHeader = [Sprite spriteCenteredWithFrame:@"UI_HintBox_2.png"];
        [_hintHeader setScreenPosition:ccp(128.0f,centerY + 166.5f)];
        
        
        [self loadHints];
        
        NSString *hint = [self getNewHint];
        
        _hintText = [CCLabelTTF labelWithString:hint dimensions:CGSizeMake(250, 100) alignment:UITextAlignmentLeft fontName:@"Impact.ttf" fontSize:12];
        
        
        
        [_hintText setPosition:ccp(240.0f,229.0f)]; //pause was 211i
        [layer addChild:_hintText];

    }
    
    return self;
}

-(void)loadHints
{
    NSString *levelName = [[LevelManager shared] currentLevel].name;
    
    NSDictionary *allHints = [PListLoader loadPlistWithName:@"hints"];
    
    NSDictionary *globalHints = [allHints objectForKey:@"global"];
    if (globalHints) {
        [self loadHintsFromDictionary:globalHints];
    }
    
    NSDictionary *levelHints = [allHints objectForKey:levelName];
    if (levelHints) {
        [self loadHintsFromDictionary:levelHints];
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
        int choice = rand()%count;
        return [_hintList objectAtIndex:choice];        
    }
    
    return nil;
}

-(void)setAlpha:(float)alpha
{
    [_hintBox setAlpha:alpha];
    [_hintHeader setAlpha:alpha];
    
    GLubyte opacity = alpha * 255;
    [_hintText setOpacity:opacity];
}

-(void)dealloc
{
    [_hintList removeAllObjects];
    [_hintList release];
    [_hintBox release];
    [_hintHeader release];
    [_hintText removeFromParentAndCleanup:YES];
}

@end
