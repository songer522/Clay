//
//  LayerManager.h
//  Clay
//
//  Created by Brian Cable on 9/8/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LayerManager : NSObject
{
    id _currentLayer;
    
}
+(LayerManager*)sharedLayers;
-(void)setCurrentLayer:(id)layer;
-(id)currentLayer;

@end
