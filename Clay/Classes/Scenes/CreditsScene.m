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
        _currentY = -50;
        
        [[LayerManager sharedLayers] setWorkingLayer:self];

        [self loadCredits];
        
        [[LayerManager sharedLayers] forgetWorkingLayer];
        
        [self scheduleUpdate];
        self.isTouchEnabled = YES;
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
    GameLabel *label = [GameLabel gameLabelWithText:[header uppercaseString] Scale:1.25f Position:ccp(240,_currentY)];
    [_lines addObject:label];
    _currentY -= 60;
}

-(void)addCredit:(NSString*)name
{
    GameLabel *creditLabel = [GameLabel gameLabelWithText:[name uppercaseString] Scale:0.9f Position:ccp(240,_currentY)];
    [_lines addObject:creditLabel];
    _currentY -= 23;    
}

-(void)addTitle:(NSString*)title;
{
    GameLabel *titleLabel = [GameLabel gameLabelWithText:[title uppercaseString] Scale:0.5f Position:ccp(240,_currentY)];
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
    NSEnumerator *enumerator = [credits objectEnumerator];

    id group;
    while ((group = [enumerator nextObject])) {
        [self addGroup:(NSDictionary*)group];
        _currentY -= 25.0f;
    }
}

-(void)switchToOptionsScreen
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[OptionsScene scene]]];
}

-(void)update:(ccTime)dt
{
    float rate = 32.0f * dt;
    self.position = ccp(self.position.x, self.position.y + rate);
}

-(void)onExit
{
    [self unscheduleUpdate];
    self.isTouchEnabled = false;
}

-(void)dealloc
{
    [_lines removeAllObjects];
    [super dealloc];
}

@end