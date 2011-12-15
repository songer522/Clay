//
//  Tutorial.m
//  Clay
//
//  Created by Yang Song on 11/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Tutorial.h"

@implementation Tutorial
@synthesize scroller;

+(id)TutorialWithinLayer:(CCLayer *)layer
{
    return [[self alloc] initWithinLayer:layer];
}


-(id)initWithinLayer:(CCLayer *)layer
{
    if(self =[super init])
              {
    _inTutorial=false;
    CCLayer *pageOne = [[CCLayer alloc] init];
    CCSprite *image1=[CCSprite spriteWithFile:@"image1.png"];
    [image1 setPosition:ccp(240,160)];
    [image1 setScale:1];
    [pageOne addChild:image1];
    
    CCLayer *pageTwo = [[CCLayer alloc] init];
    CCSprite *image2=[CCSprite spriteWithFile:@"image2.png"];
    [image2 setPosition:ccp(240,160)];
    [image2 setScale:1];
    [pageTwo addChild:image2];
    
    CCLayer *pageThree = [[CCLayer alloc] init];
    CCSprite *image3=[CCSprite spriteWithFile:@"image3.png"];
    [image3 setPosition:ccp(240,160)];
    [image3 setScale:1];
    [pageThree addChild:image3];
   button=[ActionButton buttonWithText:@"Done" AtPoint:ccp(320,70) inLayer:pageThree];
   
  
    
    
    scroller = [[CCScrollLayer alloc] initWithLayers:[NSMutableArray arrayWithObjects: pageOne,pageTwo,pageThree,nil] widthOffset: 0];
    
    [layer addChild:scroller];
    [scroller setVisible:NO];
    scroller.showPagesIndicator=NO;
              }
    return self;
}



-(void)switchToTutorial
{
    if(!_inTutorial){
        [scroller setVisible:YES];
        scroller.showPagesIndicator=YES;
        _inTutorial=true;
    }
    else
    {
        [scroller setVisible:NO];
        scroller.showPagesIndicator=NO;
        _inTutorial=false;
    }
}
-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
        
        NSSet *allTouches = [event allTouches];
        
        for(UITouch *touch in allTouches)
        {
            CGPoint position = [self convertTouchToNodeSpace:touch];
            if([button testCollision:position])
            {
                [self switchToTutorial];
            }
        }             
}


@end
