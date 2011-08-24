//
//  HelloWorldLayer.h
//  Clay
//
//  Created by Brian Cable on 8/23/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer
{
    CCSprite *sprite;
    
    CCSprite *background;
    CCSprite *leftFoot;
    CCSprite *rightFoot;
    
    CCLabelTTF *showDistanceTravelled;
    CCLabelTTF *showVelocity;
    
    
    float delayBeforeVisibleFoot;
    float distanceTravelled;
    float velocity;
    float acceleration;
    bool stalled;
    int currentFoot;
    
    
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

-(void) doRun:(CGPoint)touchLocation;
-(void) showFoot;
-(void) updateText;
-(void) stallOut;

@end
