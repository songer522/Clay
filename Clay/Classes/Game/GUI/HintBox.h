//
//  HintBox.h
//  Clay
//
//  Created by Brian Cable on 1/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import <Foundation/Foundation.h>

@class Sprite;

@interface HintBox : NSObject
{
    
    NSMutableArray *_hintList;
    
    Sprite *_hintBox;
    Sprite *_hintHeader;
    
    CCLabelTTF *_hintText;
}

+(id)hintboxOnLayer:(id)layer;
-(id)initOnLayer:(id)layer;

-(void)loadHints;
-(NSString*)getNewHint;
-(void)loadHintsFromDictionary:(NSDictionary*)dict;
-(void)setAlpha:(float)alpha;

@end
