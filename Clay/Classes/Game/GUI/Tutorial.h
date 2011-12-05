//
//  Tutorial.h
//  Clay
//
//  Created by Yang Song on 11/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCScrollLayer.h"

@interface Tutorial : NSObject
{
     CCScrollLayer *scroller;
    bool _inTutorial;
}

+(id)TutorialWithinLayer:(CCLayer *)layer;
-(id)initWithinLayer:(CCLayer *)layer;
-(void)switchToTutorial;
@end
