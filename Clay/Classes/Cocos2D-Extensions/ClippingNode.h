//
//  ClippingNode.h
//
//  Created by Steffen Itterheim on 01/18/11.
//  Source: http://www.learn-cocos2d.com/2011/01/cocos2d-gem-clippingnode/
//
//  "I needed a way to clip the contents of a node to a specific area of the screen. The goal was to create a scrollable list of items and clipping the items at the top and bottom as they are being scrolled up and down on the screen. The list is of course longer than the screen is high. While you can achieve the same effect by drawing a sprite on top of the scrolling view, I was looking for a cleaner, more flexible and faster solution."


#import <Foundation/Foundation.h>
#import "cocos2d.h"

/** Restricts (clips) drawing of all children to a specific region. */
@interface ClippingNode : CCNode 
{
    CGRect clippingRegionInNodeCoordinates;
    CGRect clippingRegion;
}

@property (nonatomic) CGRect clippingRegion;

@end