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
    _phase = SCROLLER_IDLE;
    
    _pages = [[NSMutableArray alloc] initWithCapacity:3];
    _images = [[NSMutableArray alloc] initWithCapacity:3];
    
    [self addPage:@"HTP_Page_1.png"];
    [self addPage:@"HTP_Page_2.png"];
    [self addPage:@"HTP_Page_3.png"];
    [self addPage:@"HTP_Page_4.png"];

    scroller = [[CCScrollLayer alloc] initWithLayers:_pages widthOffset: 120.0f];
    scroller.minimumTouchLengthToChangePage = 30.0f;
    
   //scroller = [[CCScrollLayer alloc] initWithLayers:[NSMutableArray arrayWithObjects: pageOne,pageTwo,pageThree,nil] widthOffset: 0];
    
    [layer addChild:scroller];
    [scroller setVisible:NO];
    scroller.showPagesIndicator=NO;
              }
    return self;
}

-(void)addPage:(NSString*)imageFileName
{
    CCLayer *page = [[CCLayer alloc] init];
    //CCSprite *image=[CCSprite spriteWithFile:imageFileName];
    CCSprite *image = [CCSprite spriteWithSpriteFrameName:imageFileName];
    [image setPosition:ccp(240,152)];
    [image setScale:1];
    [page addChild:image];
    [_images addObject:image];
    [_pages addObject:page];
}

-(void)setAlpha:(float)alpha
{
    GLubyte opacity = floor(alpha * 255);
    
    for(CCSprite *page in _images) {
        [page setOpacity:opacity];
    }
}


-(void)switchToTutorial
{
    if(!_inTutorial){
       
        [scroller setVisible:YES];
//        scroller.showPagesIndicator=YES;
        scroller.showPagesIndicator=NO;
        [scroller selectPage:0];
        _inTutorial=true;
        _alpha = 0.0f;
        _phase = SCROLLER_FADE_IN;
        [self setAlpha:0.0f];
    }
    else
    {
        scroller.showPagesIndicator=NO;
        _inTutorial=false;
        _phase = SCROLLER_FADE_OUT;
        _alpha = 1.0f;
        [self setAlpha:1.0f];
        
    }
}

-(void)update:(float)dt
{
    float rate = 3.0f * dt;
    switch (_phase) {
        case SCROLLER_FADE_IN:
            _alpha += rate;
             
            if (_alpha >= 1.0f) {
                _alpha = 1.0f;
                _phase = SCROLLER_IDLE;
            }
            [self setAlpha:_alpha];
            break;
        case SCROLLER_FADE_OUT:
            _alpha -= rate;
            if (_alpha <= 0.0f) {
                _alpha = 0.0f;
                [scroller moveToPage:0];
                _phase = SCROLLER_IDLE;
                [scroller setVisible:NO];
            }
            [self setAlpha:_alpha];
        default:
            break;
    }
}

-(void)dealloc
{
    [scroller release];
    [_images removeAllObjects];
    [_images release];
    [_pages removeAllObjects];
    [_pages release];
    
    [super dealloc];
}

@end
