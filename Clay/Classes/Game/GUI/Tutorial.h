//
//  Tutorial.h
//  Clay
//
//  Created by Yang Song on 11/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCScrollLayer.h"
#import "ActionButton.h"

typedef enum {
    SCROLLER_FADE_IN,
    SCROLLER_FADE_OUT,
    SCROLLER_IDLE
}ScrollerPhase;

@interface Tutorial : NSObject
{
    CCScrollLayer *scroller;
    
    ScrollerPhase _phase;
    
    NSMutableArray *_pages;
    NSMutableArray *_images;
    
    bool _inTutorial;
    float _alpha;
}

@property(retain,atomic)CCScrollLayer *scroller;
+(id)TutorialWithinLayer:(CCLayer *)layer;
-(id)initWithinLayer:(CCLayer *)layer;
-(void)switchToTutorial;
-(void)setAlpha:(float)alpha;
-(void)update:(float)dt;
-(void)addPage:(NSString*)imageFileName;

-(int)currentPage;
-(int)totalPages;
-(void)switchToPage:(int)page;

@end
