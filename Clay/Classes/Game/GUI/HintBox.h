//
//  HintBox.h
//  Clay
//
//  Created by Brian Cable on 1/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import <Foundation/Foundation.h>

typedef enum {
    HINTBOX_TRANSITION_IN,
    HINTBOX_TRANSITION_OUT,
    HINTBOX_WAITING
}HintboxPhase;

@class Sprite;

@interface HintBox : NSObject
{
    
    NSMutableArray *_hintList;
    
    Sprite *_hintBox;
    Sprite *_hintHeader;
    
    CCLabelTTF *_hintText;
    
    float _textAlpha;
    
    HintboxPhase _phase;
    
    int _currentHintId;
    
    float _waitUntilNextHint;
}

+(id)hintboxOnLayer:(id)layer;
-(id)initOnLayer:(id)layer;

-(void)loadHints;
-(NSString*)getNewHint;
-(void)loadHintsFromDictionary:(NSDictionary*)dict;
-(float)fittingFontSizeForTextWidth:(float)width interiorHeight:(float)interiorHeight;
-(float)heightForTallestHintAtWidth:(float)width fontSize:(float)fontSize;
-(void)setTextAlpha:(float)alpha;
-(void)switchHint;
-(void)update:(float)dt;

@end
