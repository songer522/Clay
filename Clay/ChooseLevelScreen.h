//
//  ChooseLevelScreen.h
//  Clay
//
//  Created by Brian Cable on 10/24/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class Sprite;

@interface ChooseLevelScreen : CCLayer
{
    Sprite *blackBackground;
    NSMutableArray *_buttons;
    bool _wantToSwitch;
    float _alpha;
    NSString *_levelToSwitchTo;
}

+(CCScene*)scene;
+(id)layerWithScene:(CCScene*)scene;
-(id) initWithScene:(CCScene*)scene;

-(void)load;

-(void)popAndSwitchToLevel:(NSString*)level;


@end
