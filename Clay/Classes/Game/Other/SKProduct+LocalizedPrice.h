//
//  SKProduct+LocalizedPrice.h
//  Clay
//
//  Created by Brian Cable on 1/25/12.
//  Copyright (c) 2012 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface SKProduct (LocalizedPrice)

@property (nonatomic, readonly) NSString *localizedPrice;

@end