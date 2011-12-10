//
//  BossFinalJim.h
//  Clay
//
//  Created by Brian Cable on 10/19/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "Boss.h"


@class Sprite;
@class Level;
@class Player;

@interface BossFinalJim : Boss
{
    Level *_level;
    
    Sprite *_sprite;

    CGPoint _positionOnScreen;

    bool _firstUpdate;
    
    float _xPos;
    float _targetXPos;
    
    float _cameraXPos;
    float _targetCameraXPos;
    
    float _transitionSpeed;
    bool _isTransitioning;
    bool _isMovingCamera;
    
    BossPhase _phase;
    
    float _waitToAttack;
    
    Player *_player; //weak reference
}

-(void)updateTransition:(float)dt;
-(void)shiftCamera:(float)dt;

@end