//
//  VisibleElement.h
//  Clay
//
//  Created by Brian Cable on 1/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VisibleElement <NSObject>

-(void)setAlpha:(float)alpha;
-(void)setVisible:(bool)isVisible;

@end
