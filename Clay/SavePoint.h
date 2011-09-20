//
//  SavePoint.h
//  Clay
//
//  Created by Brian Cable on 9/20/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//
//  This class will store several things about the latest checkpoint the player has passed (which might be the beginning
//  of the level). This will then be accessed in order to easily reset the level data to the last safe point for the
//  player, or can be used to save to a storage device when exiting and restored when restarting the program.
//  The following needs to be kept track of: the id of the level, the x and y position of the last checkpoint for the runner to spawn at, 

#import <Foundation/Foundation.h>

@interface SavePoint : NSObject
{
    CGPoint         _position;
    NSString*       _levelName;
    
}



@end
