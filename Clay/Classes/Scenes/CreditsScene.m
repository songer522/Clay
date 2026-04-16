//
//  CreditsScene.m
//  Clay
//
//  Created by Brian Cable on 12/13/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "CreditsScene.h"
#import "GameLabel.h"
#import "LayerManager.h"
#import "PListLoader.h"
#import "OptionsScene.h"
#import "EndLevelScene.h"
#import "SoundEngine.h"
#import "GameSettings.h"
#import "GCState.h"
#import "GCHelper.h"
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define MULTIPLIERX (IS_IPAD ? 2.133 : 1)
#define MULTIPLIERY (IS_IPAD ? 2.4 : 1)

static CGFloat CreditsCenterX(void)
{
    if (IS_IPAD) {
        return 240.0f * MULTIPLIERX;
    }

    CGSize winSize = [[CCDirector sharedDirector] winSize];
    return floorf(winSize.width * 0.5f);
}

static CGFloat CreditsInitialY(void)
{
    if (IS_IPAD) {
        return -50.0f;
    }

    CGSize winSize = [[CCDirector sharedDirector] winSize];
    return -MAX(24.0f, floorf(winSize.height * 0.06f));
}

static CGFloat CreditsInterGroupSpacing(void)
{
    if (IS_IPAD) {
        return 90.0f * MULTIPLIERY;
    }

    return 54.0f;
}

static CGFloat CreditsExitPadding(void)
{
    if (IS_IPAD) {
        return 320.0f;
    }

    CGSize winSize = [[CCDirector sharedDirector] winSize];
    return MAX(56.0f, floorf(winSize.height * 0.18f));
}

@implementation CreditsScene

+(CCScene*)scene
{
    CCScene *scene = [CCScene node];
    CreditsScene *layer = [CreditsScene node];
    [scene addChild:layer];
    return scene;
}

-(id)init
{
    if((self=[super init])) {
        
        
        _lines = [[NSMutableArray alloc] initWithCapacity:10];
        _currentY = CreditsInitialY();
        _hasSwitched = false;
        
        
        [[LayerManager sharedLayers] setWorkingLayer:self];

        
        [self loadCredits];
        
        [[LayerManager sharedLayers] forgetWorkingLayer];
        
        [self scheduleUpdate];
        self.isTouchEnabled = YES;
        
        [[GameSettings shared] setGlobal:@"NO" ForKey:@"titleMusicStarted"];
        
        NSString *creditsMusicStarted = [[GameSettings shared] getGlobalForKey:@"creditsMusicStarted"];
        if(![creditsMusicStarted isEqualToString:@"YES"]) {
            [[SoundEngine shared] playMusic:@"credits"];
            [[SoundEngine shared] cueFadeIn];
        }
    }
    
    return self;
}

-(void)addGroup:(NSDictionary*)dict
{
    NSString *headerName = [dict objectForKey:@"name"];
    int count = [[dict objectForKey:@"count"] intValue];
    
    [self addHeader:headerName];
    
    for (int i=1; i<=count; i++) {
        NSString *credit = [dict objectForKey:[NSString stringWithFormat:@"%d",i]];
        NSArray *creditLine = [credit componentsSeparatedByString:@":"];

        
        NSString *title = [creditLine objectAtIndex:0];
        [self addTitle:title];
        
        
        NSArray *names = [[creditLine objectAtIndex:1] componentsSeparatedByString:@","];

        for (NSString *name in names) {
            [self addCredit:name];
        }
        
        _currentY -= 20;
    }
}

-(void)addHeader:(NSString*)header
{
    GameLabel *label = [GameLabel gameLabelWithText:[header uppercaseString] Scale:1.25f Position:ccp(CreditsCenterX(),_currentY * MULTIPLIERY)];
    [_lines addObject:label];
    _currentY -= 60;
}

-(void)addCredit:(NSString*)name
{
    GameLabel *creditLabel = [GameLabel gameLabelWithText:[name uppercaseString] Scale:0.9f Position:ccp(CreditsCenterX(),_currentY * MULTIPLIERY)];
    [_lines addObject:creditLabel];
    _currentY -= 23;    
}

-(void)addTitle:(NSString*)title;
{
    GameLabel *titleLabel = [GameLabel gameLabelWithText:[title uppercaseString] Scale:0.5f Position:ccp(CreditsCenterX(),_currentY * MULTIPLIERY)];
    [_lines addObject:titleLabel];
    _currentY -= 20;
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    
    for(UITouch *touch in allTouches)
    {
        [self switchToOptionsScreen];
        break;        
    }
}


-(void)loadCredits
{
    NSDictionary *credits = [PListLoader loadPlistWithName:@"credits"];

    NSDictionary *group1 = [credits objectForKey:@"group1"];
    [self addGroup:group1];
    _currentY -= CreditsInterGroupSpacing();
    
    NSDictionary *group2 = [credits objectForKey:@"group2"];
    [self addGroup:group2];
}

-(void)switchToOptionsScreen
{
    [[GameSettings shared] setGlobal:@"NO" ForKey:@"creditsMusicStarted"];
    
    NSString *switchTo= [[GameSettings shared] getGlobalForKey:@"switchToCreditsFrom"];
    if([switchTo isEqualToString:@"endGame"])
    {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[EndLevelScene scene]]];
    }
    else if ([switchTo isEqualToString:@"options"])
    {
        [[SoundEngine shared] cueFastFadeOut];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[OptionsScene scene]]];
    }
}

-(void)update:(ccTime)dt
{
    [[SoundEngine shared] update:dt];
    
    float rate = 32.0f * dt;
    self.position = ccp(self.position.x, self.position.y + rate);
    if (!_hasSwitched && self.position.y > (-_currentY) + CreditsExitPadding()) {
        _hasSwitched = true;

        if(![GCState sharedInstance].watchCredit)
        {
            
            [GCState sharedInstance].watchCredit =true;
            [[GCHelper sharedInstance] reportAchievement:gcAchievementWatchCredits percentComplete:100.0];
        }

        [self switchToOptionsScreen];
    }
}

-(void)onExit
{
    [self unscheduleUpdate];
    self.isTouchEnabled = false;
}

-(void)dealloc
{
    for (GameLabel *line in _lines) {
        [line release];
        line = nil;
    }
    [_lines release];
    [super dealloc];
}

@end