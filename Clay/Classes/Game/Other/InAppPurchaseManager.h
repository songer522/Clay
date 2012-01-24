//
//  InAppPurchaseManager.h
//  Clay
//
//  Created by Brian Cable on 1/24/12.
//  Copyright (c) 2012 Xecudev, LLC. All rights reserved.
//
//  Based on code from: http://troybrant.net/blog/2010/01/in-app-purchases-a-full-walkthrough/

#import <StoreKit/StoreKit.h>

#define kInAppPurchaseManagerProductsFetchedNotification @"kInAppPurchaseManagerProductsFetchedNotification"

@interface InAppPurchaseManager : NSObject <SKProductsRequestDelegate>
{
    SKProductsRequest *_productsRequest;
    
    SKProduct *_trainingLevelProduct;
    SKProduct *_dojoLevelProduct;
}

@end
