//
//  HelloWorldLayer.m
//  Clay
//
//  Created by Brian Cable on 8/23/11.
//  Copyright Xecudev, LLC 2011. All rights reserved.
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

        CGSize screenSize = [[CCDirector sharedDirector] winSize];

        background = [CCSprite spriteWithFile:@"forest.jpg"];
        background.position = ccp(screenSize.width/2,screenSize.height/2);
        background.scale = 1.0f;
        
        
        speedbar_inner = [CCSprite spriteWithFile:@"speedbar_inner.png"];
        speedbar_inner.position = ccp(screenSize.width / 2 - 63, 100);
        speedbar_inner.anchorPoint = ccp(0,0.5);
        speedbar_inner.scaleX = 0.75f;
        [self addChild:speedbar_inner];
        
        
        speedbar_outer = [CCSprite spriteWithFile:@"speedbar_outer.png"];
        speedbar_outer.position = ccp(screenSize.width / 2, 100);
        [self addChild:speedbar_outer];
        
		// create and initialize a Label
        showDistanceTravelled = [CCLabelTTF labelWithString:@"Distance Travelled: 0.00mi" dimensions:CGSizeMake(300, 50) alignment:UITextAlignmentLeft fontName:@"Arial" fontSize:18];
        
        showVelocity = [CCLabelTTF labelWithString:@"Velocity: 0.0mph" dimensions:CGSizeMake(300, 50) alignment:UITextAlignmentLeft fontName:@"Arial" fontSize:18];
        
        [showDistanceTravelled setColor:ccWHITE];
        [showVelocity setColor:ccWHITE];
        showDistanceTravelled.position = ccp(200,200);
        showVelocity.position = ccp(310,30);
        [self addChild:showDistanceTravelled];
        [self addChild:showVelocity];
        
        
        velocity = 0.0f;
        distanceTravelled = 0.0f;
        stalled = true;
        delayBeforeVisibleFoot = 1.0f;
        acceleration = 0.0f;
        currentFoot = 0;
        
        
        leftFoot = [CCSprite spriteWithFile:@"left_foot.png"];
        leftFoot.position = ccp(45, 50);
        [self addChild:leftFoot];
        leftFoot.opacity = 0.0f;
        
        rightFoot = [CCSprite spriteWithFile:@"right_foot.png"];
        rightFoot.position = ccp(435, 50);
        [self addChild:rightFoot];        
        rightFoot.opacity = 0.0f;
        
        [self addChild:background];
		
        character = [CCSprite spriteWithFile:@"character_Test.png"];
        character.position = ccp(100,0);
        character.scale = 1.0f;
        [self addChild:character];
        
        
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
        [self doRun:touchLocation];
    }
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    for(UITouch *touch in allTouches) {
        CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
        [self doRun:touchLocation];
    }
}

-(void) doRun:(CGPoint)touchLocation
{
    NSLog(@"X:%f Y:%f",touchLocation.x,touchLocation.y);
    if (touchLocation.x <= 240) {
        //check if currently left foot and visible
        if(delayBeforeVisibleFoot <= 0.0f) {
            if (currentFoot == 0) {
                currentFoot = 1;
                delayBeforeVisibleFoot = 0.40f - (acceleration / 5.0f);
                if(delayBeforeVisibleFoot <=0) delayBeforeVisibleFoot = 0;
                leftFoot.opacity = 0;
                stalled = false;
            } else {
                currentFoot = 1;
                [self stallOut];
            }
        } else {
            [self stallOut];
        }
    } else {
        if(delayBeforeVisibleFoot <= 0.0f) {
            if (currentFoot == 1) {
                currentFoot = 0;
                delayBeforeVisibleFoot = 0.40f - (acceleration / 5.0f);
                if(delayBeforeVisibleFoot <=0) delayBeforeVisibleFoot = 0;
                rightFoot.opacity = 0;
                stalled = false;
            } else {
                currentFoot = 0;
                [self stallOut];
            }
        } else {
            [self stallOut];
        }
    }
}

-(void) stallOut
{
    stalled = true;
    velocity = (velocity / 3.0f) * 2.0f;
    acceleration = acceleration / 3.0f;
    delayBeforeVisibleFoot = 0.4f;
    rightFoot.opacity = 0;
    leftFoot.opacity = 0;
    [self updateText];
}

-(void) showFoot
{
    if (currentFoot == 0) {
        leftFoot.opacity = 255;
    } else {
        rightFoot.opacity = 255;
    }
}

-(void) updateText
{
    [showVelocity setString:[NSString stringWithFormat:@"Velocity: %.2fmph",velocity]];
    [showDistanceTravelled setString:[NSString stringWithFormat:@"Distance Travelled: %.3fmi",distanceTravelled]];
}

-(void)update:(ccTime)dt
{
    //NSLog(@"Update: %f",dt);
    
    if (delayBeforeVisibleFoot >= 0.0f) {
        delayBeforeVisibleFoot -= dt;
    }
    
    if (delayBeforeVisibleFoot <=0.0f && leftFoot.opacity == 0 && rightFoot.opacity == 0) {
        [self showFoot];
    }

    
    if (!stalled) {
        if(delayBeforeVisibleFoot >= 0.0f) {
            acceleration += 0.003f * dt;
            if (acceleration > 2.0f) {
                acceleration = 2.0f;
            }
            
            velocity += acceleration;
            if (velocity > 6.0f) {
                velocity = 6.0f;
            }            
        }
        
    } else {
        acceleration -= 0.003f * dt;
        if(acceleration <= 0.0f) {
            acceleration = 0.0f;
        }
        velocity += acceleration;
        if(velocity <=0.0f) {
            velocity = 0.0f;
        }
    }
    
    distanceTravelled += 0.000015f * velocity;
    
    speedbar_inner.scaleX = (21 * velocity)/127;
    
    [self updateText];
    
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
