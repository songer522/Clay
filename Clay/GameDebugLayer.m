//
//  GameDebugLayer.m
//  Clay
//
//  Created by Brian Cable on 9/19/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "GameDebugLayer.h"
#import "GameLayer.h"
#import "LayerManager.h"
#import "GameObject.h"
#import "Player.h"
#import "Camera.h"

#define DEBUG_DRAW_BOUNDING_BOXES 0

@implementation GameDebugLayer

- (id)initWithScene:(CCScene*)scene GameLayer:(GameLayer*)gameLayer
{
    self = [super init];
    if (self) {
        // Initialization code here.
        [scene addChild:[GameDebugLayer node]];
    }
    
    return self;
}

+(id) debugLayerForScene:(CCScene*)scene GameLayer:(GameLayer*)gameLayer
{
    return [[self alloc] initWithScene:scene GameLayer:gameLayer];
}

-(void)draw
{
    if (DEBUG_DRAW_BOUNDING_BOXES) {
        glColor4ub(255, 0, 255, 255);
        glLineWidth(6.0f);
        GameLayer *gameLayer = [[LayerManager sharedLayers] currentLayer];
        Player *player = gameLayer.player;
        [self drawBoxForGameObject:(GameObject*)player];
        
        //draw for obstacles
        glColor4ub(0, 255, 0, 255);
        
        NSMutableArray *obstacles = [gameLayer getGameObjectsList];
        
        for (GameObject *obstacle in obstacles) {
            if (!obstacle.collided) {
                [self drawBoxForGameObject:obstacle];
            }
        }

        
    }
}

-(void)drawBoxForGameObject:(GameObject*)object
{
    CGPoint point = [object getCCSprite].position;
    float left = point.x + object.boundingBox.origin.x;
    float right = point.x + object.boundingBox.origin.x + object.boundingBox.size.width;
    float top = point.y + object.boundingBox.origin.y;
    float bottom = point.y + object.boundingBox.origin.y + object.boundingBox.size.height;
    
    ccDrawLine(ccp(left, top), ccp(right, top));
    ccDrawLine(ccp(right, top), ccp(right, bottom));
    ccDrawLine(ccp(right, bottom), ccp(left, bottom));
    ccDrawLine(ccp(left, bottom), ccp(left, top));
    
}

@end
