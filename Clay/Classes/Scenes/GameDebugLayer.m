//
//  GameDebugLayer.m
//  Clay
//
//  Created by Brian Cable on 9/19/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "GameDebugLayer.h"
#import "GameLayer.h"
#import "LevelManager.h"
#import "LayerManager.h"
#import "GameObject.h"
#import "MapObject.h"
#import "Player.h"
#import "Camera.h"
#import "Projectile.h"
#import "PlayerAction.h"
#import "Projectile.h"

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
    glColor4ub(255, 0, 255, 255);
    glLineWidth(6.0f);
    GameLayer *gameLayer = [[LayerManager sharedLayers] currentLayer];
    Player *player = [[LayerManager sharedLayers] getPlayer];
    
    [self drawBoxForCollidable:player];
    
    
    //player action projectiles
    NSMutableArray *projectiles = [[player getThirdAction] getProjectiles];
    if (projectiles!=nil) {
        for (Projectile *projectile in projectiles) {
            if ([projectile getActive]) {
                [self drawBoxForCollidable:projectile];                
            }
        }        
    }
    
    //draw for obstacles
    glColor4ub(0, 255, 0, 255);
    
    NSMutableArray *obstacles = [gameLayer getGameObjectsList];
    
    for (MapObject *mapObject in obstacles) {
        GameObject *obstacle = mapObject.object;
        if (!obstacle.collided) {
            [self drawBoxForCollidable:obstacle];
        }
        
        Projectile *projectile = [obstacle getProjectile];
        if (projectile!=nil && [projectile getActive]) {
            [self drawBoxForCollidable:projectile];
        }
    }
}

-(void)drawBoxForCollidable:(id<Collidable>)object
{
    CGPoint point = [object getCCSprite].position;
    CGRect boundingBox = [object getBoundingBox];
    
    float left = point.x - boundingBox.origin.x;
    float right = point.x - boundingBox.origin.x + boundingBox.size.width;
    float bottom = point.y - boundingBox.origin.y;
    float top = point.y - boundingBox.origin.y + boundingBox.size.height;
    
    ccDrawLine(ccp(left, top), ccp(right, top));
    ccDrawLine(ccp(right, top), ccp(right, bottom));
    ccDrawLine(ccp(right, bottom), ccp(left, bottom));
    ccDrawLine(ccp(left, bottom), ccp(left, top));
    
}

-(void)dealloc
{
    [super dealloc];    
}

@end
