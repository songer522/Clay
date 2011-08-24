//
//  HelloWorldLayer.m
//  Clay
//
//  Created by Brian Cable on 8/23/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// HelloWorldLayer implementation
@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		
		// create and initialize a Label
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Hello World" fontName:@"Marker Felt" fontSize:64];
        
        sprite = [CCSprite spriteWithFile:@"red_circle.png"];
        sprite.scale = 0.15f;
        sprite.position = ccp(300,300);
        [self addChild:sprite];
        

		// ask director the the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
	
		// position the label on the center of the screen
		label.position =  ccp( size.width /2 , size.height/2 );
		
		// add the label as a child to this Layer
		[self addChild: label];
        
        self.isTouchEnabled = YES;
        [self scheduleUpdate];
	}
	return self;
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    for(UITouch *touch in allTouches) {
        CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
        [self moveSprite:touchLocation];
        [sprite setOpacity:255];
    }
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    for(UITouch *touch in allTouches) {
        CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
        [self moveSprite:touchLocation];
        [sprite setOpacity:255];
    }
}

-(void) moveSprite:(CGPoint)touchLocation
{
    NSLog(@"X:%f Y:%f",touchLocation.x,touchLocation.y);
    sprite.position = touchLocation;
}

-(void)update:(ccTime)dt
{
    NSLog(@"Update: %f",dt);
    GLubyte opacity = sprite.opacity;
    opacity -= dt*48;
    [sprite setOpacity:opacity];
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
