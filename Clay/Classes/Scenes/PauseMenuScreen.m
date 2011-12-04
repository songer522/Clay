//
//  PauseMenuScreen.m
//  Clay
//
//  Created by Brian Cable on 9/21/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "PauseMenuScreen.h"
#import "LayerManager.h"
#import "GameController.h"
#import "Sprite.h"

@implementation PauseMenuScreen

@synthesize gameController = _gameController;

+(id)instance
{
    return [[self alloc] init];
}

//- (id)initWithColor:(ccColor4B)color
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        _alpha = 0.0;
        [self scheduleUpdate];
        [[[LayerManager sharedLayers] currentScene] addChild:self];

        _label = [CCLabelTTF labelWithString:@"zzz..." fontName:@"Helvetica-Bold" fontSize:32];
        _label.position = ccp(240, 160);
        [_label setOpacity:0];
        [self addChild:_label];
        
        self.isTouchEnabled = YES;
    }

    return self;
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    for(UITouch *touch in allTouches) {
        [_gameController pauseGame];
        break;
    }
}


-(void)update:(ccTime)dt
{
    
    _alpha += 3.0f * dt;
    if (_alpha > 1.0f) {
        _alpha = 1.0f;
    }
    //[_bkg setAlpha:0.4f * _alpha];
    [_label setOpacity:(int)(255 * _alpha)];
}

-(void)dealloc
{
    [_gameController release];
    [_label release];
    [super dealloc];
}

@end
