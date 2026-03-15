//
//  Tutorial.m
//  Clay
//
//  Created by Yang Song on 11/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Tutorial.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define MULTIPLIERX (IS_IPAD ? 2.133 : 1)
#define MULTIPLIERY (IS_IPAD ? 2.4 : 1)

static CGPoint TutorialLegacyPhoneOffset(void)
{
    if (IS_IPAD) {
        return CGPointZero;
    }
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    return ccp(MAX(0.0f, floorf((winSize.width - 480.0f) / 2.0f)), 0.0f);
}

@implementation Tutorial
@synthesize scroller;


+(id)TutorialWithinLayer:(CCLayer *)layer
{
    return [[self alloc] initWithinLayer:layer];
}


-(id)initWithinLayer:(CCLayer *)layer
{
    if((self =[super init])) {
        _inTutorial=false;
        _phase = SCROLLER_IDLE;
        
        _pages = [[NSMutableArray alloc] initWithCapacity:4];
        _images = [[NSMutableArray alloc] initWithCapacity:4];
        
        [self addPage:@"HTP_Page_1.png"];
        [self addPage:@"HTP_Page_2.png"];
        [self addPage:@"HTP_Page_3.png"];
        [self addPage:@"HTP_Page_4.png"];

        int pageOffset = IS_IPAD ? (int)(120.0f * MULTIPLIERX) : 0;
        scroller = [[CCScrollLayer alloc] initWithLayers:_pages widthOffset:pageOffset];
        scroller.minimumTouchLengthToChangePage = 30.0f;
        
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
    CGPoint offset = TutorialLegacyPhoneOffset();
    [image setPosition:ccp(offset.x + (240 * MULTIPLIERX), offset.y + (152 * MULTIPLIERY))];
    [image setScale:1];
    [page addChild:image];
    [_images addObject:image];
    [_pages addObject:page];
    [page release];
}

-(void)setAlpha:(float)alpha
{
    GLubyte opacity = floor(alpha * 255);
    
    for(CCSprite *page in _images) {
        [page setOpacity:opacity];
    }
}

-(void)switchToPage:(int)page
{
    [scroller moveToPage:page];
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

-(int)currentPage
{
    return [scroller currentScreen];
}

-(int)totalPages
{
    return [_pages count];
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
