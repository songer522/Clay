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

@interface Tutorial : CCLayer<CCScrollLayerDelegate>
{
     CCScrollLayer *scroller;
    bool _inTutorial;
    ActionButton *button;
}

@property(retain,atomic)CCScrollLayer *scroller;
+(id)TutorialWithinLayer:(CCLayer *)layer;
-(id)initWithinLayer:(CCLayer *)layer;
-(void)switchToTutorial;
@end
