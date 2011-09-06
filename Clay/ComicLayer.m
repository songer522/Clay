//
//  ComicScene.m
//  Clay
//
//  Created by Brian Cable on 9/2/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "ComicLayer.h"

@implementation ComicLayer

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameLayer *layer = [GameLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}





@end
