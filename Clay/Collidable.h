//
//  Collidable.h
//  Clay
//
//  Created by Brian Cable on 10/26/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Collidable <NSObject>

-(CGRect)getBoundingBox;
-(void)setBoundingBox:(CGRect)boundingBox;
-(CGPoint)getPosition;
-(void)startCollision;

@end
